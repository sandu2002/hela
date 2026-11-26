import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hela/models/destination.dart';
import 'package:hela/models/tour_plan.dart';
import 'package:hela/models/tour_preferences.dart';
import 'package:hela/pages/trip_planner/itinerary_details_page.dart';
import 'package:hela/pages/trip_planner/trip_planner_page.dart';
import 'package:hela/services/ai_service.dart';
import 'package:hela/state/app_state.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AIService Gemini tour plan parsing', () {
    test('parses fenced Gemini JSON itinerary into TourPlan', () {
      const rawGeminiResponse = '''
```json
{
  "id": "tour_12345",
  "title": "Tea Mist & Southern Waves",
  "summary": "A 2-day bespoke Gemini itinerary from Kandy to Galle.",
  "matchReason": "Tailored to your love of Ceylon tea trails and coastal forts.",
  "durationDays": 2,
  "estimatedTotalCostUsd": 220.0,
  "budgetBreakdown": "Boutique stays, scenic train, and local meals.",
  "travelTips": ["Book 2nd class observation seats early"],
  "warnings": ["Carry a light rain jacket for Ella afternoons"],
  "days": [
    {
      "dayNumber": 1,
      "title": "Kandy → Ella Tea Express",
      "summary": "Scenic highland rail journey through emerald tea estates",
      "estimatedDayCostUsd": 110.0,
      "overnightStay": "Ella",
      "activities": [
        {
          "title": "Peradeniya Royal Botanical Walk",
          "description": "Morning stroll among giant bamboo and orchid houses.",
          "startTime": "08:00 AM",
          "estimatedDuration": "2 hours",
          "category": "Nature",
          "estimatedCostUsd": 12.0,
          "tips": ["Arrive early before tour buses"]
        },
        {
          "title": "Nine Arch Bridge Sunset",
          "description": "Watch the blue train cross Demodara stone viaduct.",
          "startTime": "04:30 PM",
          "estimatedDuration": "1.5 hours",
          "category": "Scenic",
          "estimatedCostUsd": 0.0,
          "travelTimeFromPrevious": "3 hours",
          "travelMethod": "Scenic Highland Train",
          "tips": ["Walk down from Gotuwala trail for best angle"]
        }
      ]
    },
    {
      "dayNumber": 2,
      "title": "Ella → Galle Dutch Fort",
      "summary": "Descend to the southern coast heritage ramparts",
      "estimatedDayCostUsd": 110.0,
      "overnightStay": "Galle Fort",
      "activities": [
        {
          "title": "Galle Lighthouse Golden Hour",
          "description": "Sunset walk along the 17th-century Dutch ramparts.",
          "startTime": "05:00 PM",
          "estimatedDuration": "2 hours",
          "category": "Culture",
          "estimatedCostUsd": 0.0,
          "travelTimeFromPrevious": "3.5 hours",
          "travelMethod": "Private AC Car",
          "tips": ["Try fresh passionfruit sorbet on Pedlar Street"]
        }
      ]
    }
  ]
}
```
''';

      final plan = AIService.parseTourPlanJson(rawGeminiResponse);
      expect(plan.title, 'Tea Mist & Southern Waves');
      expect(plan.durationDays, 2);
      expect(plan.days.length, 2);
      expect(plan.days[0].title, 'Kandy → Ella Tea Express');
      expect(plan.days[0].activities.length, 2);
      expect(plan.days[0].activities[1].travelMethod, 'Scenic Highland Train');
      expect(plan.days[1].overnightStay, 'Galle Fort');
      expect(plan.travelTips.first, 'Book 2nd class observation seats early');
    });
  });

  group('ItineraryDetailsPage Gemini TourPlan rendering', () {
    testWidgets('renders AI days and switches stops when selecting Day 2', (tester) async {
      final aiPlan = TourPlan(
        id: 'tour_widget_1',
        title: 'Gemini Highland & Coast',
        summary: 'Custom 2-day route crafted by Gemini AI.',
        matchReason: 'Matches your beaches and tea trail interests.',
        durationDays: 2,
        estimatedTotalCostUsd: 260,
        travelTips: const ['Keep small LKR notes for tuk-tuks'],
        warnings: const ['Expect afternoon mist in Nuwara Eliya'],
        dataSources: const ['Google Gemini AI (gemini-3.6-flash)'],
        days: const [
          ItineraryDay(
            dayNumber: 1,
            title: 'Colombo → Kandy',
            summary: 'Sacred temple and royal gardens',
            estimatedDayCostUsd: 120,
            overnightStay: 'Kandy',
            activities: [
              ItineraryActivity(
                title: 'Temple of the Sacred Tooth Relic',
                description: 'Evening pooja ceremony at Sri Dalada Maligawa.',
                startTime: '05:30 PM',
                estimatedDuration: '2 hours',
                category: 'Culture',
                estimatedCostUsd: 10,
                tips: ['Cover shoulders and knees'],
              ),
            ],
          ),
          ItineraryDay(
            dayNumber: 2,
            title: 'Kandy → Mirissa Beach',
            summary: 'Southern coast sunset relaxation',
            estimatedDayCostUsd: 140,
            overnightStay: 'Mirissa',
            activities: [
              ItineraryActivity(
                title: 'Coconut Tree Hill Sunset',
                description: 'Iconic palm cliff overlooking the Indian Ocean.',
                startTime: '05:15 PM',
                estimatedDuration: '1.5 hours',
                category: 'Beaches',
                estimatedCostUsd: 0,
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        HelaAppStateProvider(
          state: HelaAppState(),
          child: MaterialApp(
            home: ItineraryDetailsPage(
              startLocation: 'Colombo Fort',
              startDate: DateTime(2026, 12, 1),
              endDate: DateTime(2026, 12, 3),
              aiTourPlan: aiPlan,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('GEMINI AI PLAN'), findsOneWidget);
      expect(find.text('Gemini Highland & Coast'), findsOneWidget);
      expect(find.text('Temple of the Sacred Tooth Relic'), findsWidgets);
      expect(find.text('Keep small LKR notes for tuk-tuks'), findsOneWidget);

      // Tap Day 2 pill and verify Day 2 AI activity renders
      await tester.tap(find.text('Day 2'));
      await tester.pumpAndSettle();

      expect(find.text('Coconut Tree Hill Sunset'), findsWidgets);
      expect(find.text('Mirissa'), findsWidgets);
    });

    test('AIService.buildChatHistoryFromMessages restores user & model turns', () {
      const messages = [
        ChatMessage(
          id: 'u1',
          content: '[Day 1] Add a seafood lunch stop',
          isUser: true,
          timestamp: '10:00 AM',
        ),
        ChatMessage(
          id: 'a1',
          content: 'Applied v2: Added Negombo Lagoon seafood lunch on Day 1.',
          isUser: false,
          timestamp: '10:01 AM',
        ),
      ];

      final history = AIService.buildChatHistoryFromMessages(messages);
      expect(history.length, 2);
      expect(history[0].isUser, isTrue);
      expect(history[0].text, '[Day 1] Add a seafood lunch stop');
      expect(history[1].isUser, isFalse);
      expect(
        history[1].text,
        'Applied v2: Added Negombo Lagoon seafood lunch on Day 1.',
      );
    });

    testWidgets('restores persisted customization chat memory in Ask HELA Adjust sheet', (tester) async {
      SharedPreferences.setMockInitialValues({
        'hela_itinerary_chat_tour_mem_1': jsonEncode([
          {
            'id': 'u1',
            'content': 'Make Day 1 more relaxed',
            'isUser': true,
            'timestamp': '9:30 AM',
          },
          {
            'id': 'a1',
            'content': 'Removed afternoon hike and added lakeside tea.',
            'isUser': false,
            'timestamp': '9:31 AM',
          },
        ]),
      });

      const aiPlan = TourPlan(
        id: 'tour_mem_1',
        title: 'Kandy Cultural Escape',
        summary: 'Relaxed cultural itinerary.',
        durationDays: 1,
        days: [
          ItineraryDay(
            dayNumber: 1,
            title: 'Kandy Heritage',
            overnightStay: 'Kandy',
            activities: [
              ItineraryActivity(
                title: 'Kandy Lake Stroll',
                startTime: '04:00 PM',
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        HelaAppStateProvider(
          state: HelaAppState(),
          child: MaterialApp(
            home: ItineraryDetailsPage(
              startLocation: 'Kandy',
              startDate: DateTime(2026, 12, 1),
              endDate: DateTime(2026, 12, 2),
              aiTourPlan: aiPlan,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final adjustBtn = find.text('Ask HELA to Adjust Day 1 (1)');
      await tester.ensureVisible(adjustBtn);
      await tester.tap(adjustBtn);
      await tester.pumpAndSettle();

      expect(find.text('Ask HELA • Adjust Day 1'), findsOneWidget);
      expect(find.text('Memory active • 2 messages saved'), findsOneWidget);
      final aiReply = find.text('Removed afternoon hike and added lakeside tea.');
      await tester.ensureVisible(aiReply);
      expect(find.text('Make Day 1 more relaxed'), findsWidgets);
      expect(aiReply, findsOneWidget);
    });
  });

  group('TripPlannerPage structured AI inputs & prompt payload', () {
    test('AIService.generateTourPlan embeds all user planning inputs in prompt', () async {
      String capturedPrompt = '';
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        capturedPrompt = body['prompt']?.toString() ?? '';
        return http.Response(
          jsonEncode({
            'model': 'gemini-test',
            'text': jsonEncode({
              'id': 'tour_ai_inputs',
              'title': 'South Coast Express',
              'summary': 'Colombo to Galle rail & villa route.',
              'durationDays': 3,
              'days': [
                {
                  'dayNumber': 1,
                  'title': 'Colombo to Kandy',
                  'summary': 'Scenic start',
                  'estimatedDayCostUsd': 100.0,
                  'overnightStay': 'Kandy',
                  'activities': [
                    {
                      'title': 'Temple Visit',
                      'description': 'Morning visit',
                      'startTime': '09:00 AM',
                      'estimatedDuration': '2h',
                      'category': 'Culture',
                      'estimatedCostUsd': 10.0,
                    },
                  ],
                },
              ],
            }),
          }),
          200,
        );
      });

      final service = AIService(
        client: mockClient,
        backendUrl: 'https://example.test/api/tour/generate',
      );
      final plan = await service.generateTourPlan(
        preferences: const TourPreferences(
          duration: TravelDuration.threeDays,
          startingLocationName: 'Colombo Fort',
          endLocationName: 'Galle Dutch Fort',
          interests: {TravelInterest.beaches, TravelInterest.culture},
          budgetLevel: BudgetLevel.medium,
          pace: TravelPace.relaxed,
          accommodationType: AccommodationType.villa,
          transportMode: 'Scenic Train + Tuk-Tuk Mix',
          dietaryPreferences: {'Halal', 'Vegetarian'},
          accessibilityNeeds: {'Minimal Stairs / Step-Free'},
          numberOfTravelers: 2,
          additionalNotes: 'Sunset photography priority',
        ),
        selectedDestinations: const [
          Destination(
            sourceId: 'd_ella',
            name: 'Ella & Nine Arch Bridge',
            latitude: 6.8728,
            longitude: 81.0464,
            region: 'Uva Province',
          ),
        ],
      );

      expect(plan.title, 'South Coast Express');
      expect(capturedPrompt, contains('Ending / Drop-off Location: Galle Dutch Fort'));
      expect(capturedPrompt, contains('Preferred Transport Mode: Scenic Train + Tuk-Tuk Mix'));
      expect(capturedPrompt, contains('Accommodation Style: Villa'));
      expect(capturedPrompt, contains('Dietary Requirements: Halal, Vegetarian'));
      expect(capturedPrompt, contains('Mobility & Comfort Constraints: Minimal Stairs / Step-Free'));
      expect(capturedPrompt, contains('Ella & Nine Arch Bridge'));
      expect(capturedPrompt, contains('Sunset photography priority'));
    });

    testWidgets('TripPlannerPage exposes interactive AI planning controls', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        HelaAppStateProvider(
          state: HelaAppState(),
          child: const MaterialApp(
            home: TripPlannerPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Trip Ending / Drop-off'), findsOneWidget);
      expect(find.text('Preferred Transport Mode'), findsOneWidget);
      expect(find.text('Accommodation Style'), findsOneWidget);
      expect(find.text('Must-Visit Places (Optional)'), findsOneWidget);
      expect(find.text('Dietary, Accessibility & AI Notes'), findsOneWidget);

      // Select transport mode & accommodation style
      final trainOption = find.text('Train + Tuk-Tuk');
      await tester.ensureVisible(trainOption);
      await tester.tap(trainOption);
      await tester.pump();

      final villaChip = find.text('Villa');
      await tester.ensureVisible(villaChip);
      await tester.tap(villaChip);
      await tester.pump();

      // Add a custom must-visit stop
      final customStopField = find.widgetWithText(
        TextField,
        'Add custom stop (e.g. Jaffna, Arugam Bay)',
      );
      await tester.ensureVisible(customStopField);
      await tester.enterText(customStopField, 'Jaffna');
      final addBtn = find.text('Add');
      await tester.ensureVisible(addBtn);
      await tester.tap(addBtn);
      await tester.pump();
      expect(find.text('Jaffna'), findsOneWidget);
      expect(find.text('1 Pinned'), findsOneWidget);

      // Tap dietary chip & quick AI note prompt
      final halalChip = find.text('Halal');
      await tester.ensureVisible(halalChip);
      await tester.tap(halalChip);
      await tester.pump();

      final quickPrompt = find.text('+ Golden hour photography');
      await tester.ensureVisible(quickPrompt);
      await tester.tap(quickPrompt);
      await tester.pump();
      expect(find.text('✓ Golden hour photography'), findsOneWidget);
    });
  });
}
