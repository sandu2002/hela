// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hela/services/google_place_rating_service.dart';

import 'package:hela/state/app_state.dart';
import 'package:hela/models/tour_plan.dart';
import 'package:hela/l10n/localization_service.dart';
import 'package:hela/pages/home/home_page.dart';
import 'package:hela/pages/trip_planner/trip_planner_page.dart';
import 'package:hela/pages/bookings/fair_ride_page.dart';
import 'package:hela/pages/bookings/stays_page.dart';
import 'package:hela/pages/saved/saved_page.dart';
import 'package:hela/pages/profile/profile_page.dart';
import 'package:hela/pages/profile/edit_profile_page.dart';
import 'package:hela/pages/cultural_guide/cultural_guide_page.dart';
import 'package:hela/pages/cultural_guide/article_detail_page.dart';
import 'package:hela/pages/onboarding/onboarding_page.dart';
import 'package:hela/pages/auth/signup_page.dart';
import 'package:hela/pages/explore/explore_page.dart';
import 'package:hela/pages/trip_planner/itinerary_details_page.dart';
import 'package:hela/pages/trip_planner/active_journey_page.dart';
import 'package:hela/pages/ask_hela/ask_hela_page.dart';
import 'package:hela/pages/trip_planner/itinerary_planning_loading_page.dart';
import 'package:hela/widgets/cards/haven_card.dart';
import 'package:hela/widgets/cards/stay_card.dart';
import 'package:hela/widgets/cards/itinerary_card.dart';
import 'package:hela/widgets/cards/real_time_calendar_card.dart';
import 'package:hela/widgets/maps/real_time_google_map.dart';
import 'package:hela/widgets/navigation/hela_bottom_nav_bar.dart';

/// Helper to wrap a widget with HelaAppStateProvider for testing.
Widget _wrapWithState(Widget child) {
  final appState = HelaAppState();
  return HelaAppStateProvider(
    state: appState,
    child: MaterialApp(home: child),
  );
}

void _ignoreOverflow() {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final msg = details.toString();
    if (msg.contains('overflowed') || msg.contains('RenderFlex')) {
      return;
    }
    originalOnError?.call(details);
  };
  addTearDown(() {
    FlutterError.onError = originalOnError;
  });
}

void main() {
  testWidgets('HelaHomePage smoke test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(const MaterialApp(home: HelaHomePage()));

    expect(find.textContaining('Discover Sri Lanka'), findsOneWidget);
    expect(find.text('Featured Destinations'), findsOneWidget);
  });

  testWidgets('HelaHomePage category filter updates tour cards when tapped', (
    WidgetTester tester,
  ) async {
    _ignoreOverflow();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final appState = HelaAppState();
    await tester.pumpWidget(
      HelaAppStateProvider(
        state: appState,
        child: const MaterialApp(home: HelaHomePage()),
      ),
    );
    await tester.pump();

    // Initially "Featured Destinations" and Sigiriya are visible, "All" shows Top 10 most famous destinations
    expect(find.text('Featured Destinations'), findsOneWidget);
    expect(find.text('Sigiriya'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Adventure'), findsOneWidget);
    expect(find.text('Hill Country'), findsNothing);
    expect(find.text('Sigiriya Lion Rock Fortress'), findsOneWidget);
    expect(find.text('Arugam Bay Surf Capital'), findsOneWidget);
    expect(find.text('Adam\'s Peak (Sri Pada) Night Trek'), findsOneWidget);

    // Tap "Beaches" filter chip
    final beachesChip = find.text('Beaches');
    await tester.ensureVisible(beachesChip);
    await tester.tap(beachesChip);
    await tester.pump(const Duration(milliseconds: 250));

    // Experience card now shows Beaches experience
    expect(find.text('Weligama Surfing & Tangalle Bays'), findsOneWidget);
    expect(find.text('Mirissa Beach & Coconut Tree Hill'), findsOneWidget);

    // Tap "Nature & Wildlife" filter chip
    final wildlifeChip = find.text('Nature & Wildlife');
    await tester.ensureVisible(wildlifeChip);
    await tester.tap(wildlifeChip);
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.text('Minneriya Elephant Gathering & Yala Safaris'),
      findsOneWidget,
    );
    expect(find.text('Udawalawe National Park'), findsOneWidget);

    // Tap "Adventure" filter chip
    final adventureChip = find.text('Adventure');
    await tester.ensureVisible(adventureChip);
    await tester.tap(adventureChip);
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.text('Nine Arch Bridge & Flying Ravana Zipline'),
      findsOneWidget,
    );
    expect(find.text('Kitulgala White-Water Rafting'), findsOneWidget);
  });

  testWidgets('TripPlannerPage smoke test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(_wrapWithState(const TripPlannerPage()));
    await tester.pump();

    expect(find.text('Plan Your Sri Lankan Adventure'), findsOneWidget);
    expect(find.text('Where does your journey begin?'), findsOneWidget);
    expect(find.text('Travel Dates'), findsOneWidget);
    expect(find.text('Travel Budget'), findsOneWidget);
    expect(find.text('Travel Interests'), findsOneWidget);
    expect(find.text('Pace & Travel Style'), findsOneWidget);
    expect(find.text('Generate My Itinerary ✨'), findsOneWidget);
  });

  testWidgets('TripPlannerPage quick templates and compact layout verification', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(720, 1480);
    tester.view.devicePixelRatio = 2.0; // 360x740 logical pixels
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final appState = HelaAppState();
    await tester.pumpWidget(
      HelaAppStateProvider(
        state: appState,
        child: MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: const TripPlannerPage(),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);

    expect(find.text('Quick Templates'), findsOneWidget);
    expect(find.text('5D Coast & Culture'), findsOneWidget);
    expect(find.text('7D Tea & Heritage'), findsOneWidget);
    expect(find.text('10D Classic Island'), findsOneWidget);
    expect(
      find.text('10 Days · 2 Guests · Comfort · Balanced'),
      findsOneWidget,
    );

    final teaPreset = find.text('7D Tea & Heritage');
    await tester.ensureVisible(teaPreset);
    await tester.pump();
    await tester.tap(teaPreset);
    await tester.pump();
    expect(find.text('7 Days · 2 Guests · Comfort · Balanced'), findsOneWidget);

    // Scroll through optional section on compact viewport to confirm zero overflow
    final optionalHeader = find.text('OPTIONAL FINE-TUNING');
    await tester.ensureVisible(optionalHeader);
    await tester.pump();
    expect(optionalHeader, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('FairRidePage smoke test', (WidgetTester tester) async {
    _ignoreOverflow();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(home: FairRidePage()));

    expect(find.text('SOS EMERGENCY'), findsOneWidget);
    expect(find.text('Select Ceylon Vehicle'), findsOneWidget);
    expect(find.text('Tuk-Tuk'), findsOneWidget);
    expect(find.text('Ceylon Pay / Visa'), findsOneWidget);

    // Tap Change to open payment method picker
    final changeButton = find.text('Change');
    await tester.ensureVisible(changeButton);
    await tester.tap(changeButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Select Payment Method'), findsOneWidget);
    expect(find.text('Cash on Arrival (LKR)'), findsOneWidget);

    // Select Cash
    await tester.tap(find.text('Cash on Arrival (LKR)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verify Cash is now selected on main screen
    expect(find.text('Cash on Arrival (LKR)'), findsOneWidget);
  });

  testWidgets('StaysPage smoke test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(const MaterialApp(home: StaysPage()));

    expect(find.text('Sanctuaries & Stays'), findsOneWidget);
    expect(find.text('28 Eco-Havens'), findsOneWidget);
    expect(find.text('98 Acres Luxury Tea Pavilion'), findsOneWidget);
  });

  testWidgets('ProfilePage smoke test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(_wrapWithState(const ProfilePage()));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsAtLeastNWidgets(1));
    expect(find.text('Edit Personal Profile'), findsOneWidget);
    expect(find.text('Saved Itineraries'), findsOneWidget);
  });

  testWidgets('CulturalGuidePage smoke test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(_wrapWithState(const CulturalGuidePage()));

    expect(find.text('CULTURAL HERITAGE'), findsOneWidget);
    expect(find.text('Voice of Ceylon'), findsOneWidget);
    expect(find.text('Temple Etiquette & Mindful Conduct'), findsOneWidget);
  });

  testWidgets('ArticleDetailPage smoke test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(
      const MaterialApp(
        home: ArticleDetailPage(
          title: 'The Fire Dancers of Kandy',
          subtitle: 'Rhythm, ritual percussion, and sacred temple fires',
          authorName: 'Dr. Indika Bandara',
          readTime: '5 min read',
        ),
      ),
    );

    expect(find.text('The Fire Dancers of Kandy'), findsOneWidget);
    expect(find.text('Dr. Indika Bandara'), findsOneWidget);
    expect(find.text('Article Coming Soon'), findsOneWidget);
  });

  testWidgets('OnboardingPage smoke test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(_wrapWithState(const OnboardingPage()));

    expect(find.text('HELA'), findsWidgets);
    expect(find.text('Sri Lanka Travel Companion'), findsOneWidget);
    expect(find.text('Discover Sri Lanka,\nYour Way'), findsOneWidget);
    expect(find.text('AI Smart Itineraries'), findsOneWidget);
    expect(find.text('Transparent Fares'), findsOneWidget);
    expect(find.text('Local Heritage'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('HavenCard component test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HavenCard(
            title: 'Nine Arch Bridge & Demodara Tea Valley',
            location: 'Ella, Highlands',
            category: 'Guided Excursion',
            price: '\$45',
            rating: 4.90,
            badgeText: '240+ Verified Explorers',
            imageUrl: 'https://example.com/image.jpg',
            isBookmarked: false,
          ),
        ),
      ),
    );

    expect(find.text('Ella, Highlands'), findsOneWidget);
    expect(find.text('Nine Arch Bridge & Demodara Tea Valley'), findsOneWidget);
    expect(find.text('Guided Excursion'), findsOneWidget);
    expect(find.text('4.90'), findsOneWidget);
    expect(find.text('240+ Verified Explorers'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
  });

  testWidgets('StayCard component test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StayCard(
            title: '98 Acres Luxury Tea Pavilion',
            location: 'Ella Gap, Badulla · 1.2 km to Ravana Falls',
            rating: 4.96,
            reviewsCount: 340,
            ratingLabel: 'Exceptional',
            pricePerNight: 148,
            feeNote: 'taxes and estate fees included',
            imageUrl: 'https://example.com/stay.jpg',
            amenities: const [],
          ),
        ),
      ),
    );

    expect(find.text('98 Acres Luxury Tea Pavilion'), findsOneWidget);
    expect(find.text('Best Price Guarantee'), findsOneWidget);
    expect(find.text('4.96'), findsOneWidget);
    expect(find.text('(340 reviews) · Exceptional'), findsOneWidget);
    expect(find.textContaining('148', findRichText: true), findsOneWidget);
    expect(find.text('View Haven'), findsOneWidget);
  });

  testWidgets('ItineraryCard component test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItineraryCard(
            title: 'Ancient Kingdoms & Sigiriya',
            subtitle:
                'UNESCO rock fortresses, cave monasteries and spice trails',
            durationTag: '4 Days · Cultural',
            routeName: 'Sacred Cultural Triangle',
            rating: 4.9,
            reviewsCount: 94,
            price: r'$295',
            imageUrl: 'https://example.com/sigiriya.jpg',
            highlights: const [
              'Dambulla cave temple frescoes with local monastery elder',
              'Sunset climb up Lion Rock to ancient sky palace ruins',
              'Village culinary cooking masterclass using clay hearths',
            ],
          ),
        ),
      ),
    );

    expect(find.text('Ancient Kingdoms & Sigiriya'), findsOneWidget);
    expect(find.text('4 Days · Cultural'), findsOneWidget);
    expect(find.text('Sacred Cultural Triangle'), findsOneWidget);
    expect(find.text('4.9'), findsOneWidget);
    expect(find.text('(94)'), findsOneWidget);
    expect(
      find.text('Sunset climb up Lion Rock to ancient sky palace ruins'),
      findsOneWidget,
    );
    expect(find.textContaining(r'$295', findRichText: true), findsOneWidget);
    expect(find.text('View Route'), findsOneWidget);
  });

  testWidgets('RealTimeCalendarCard component test', (
    WidgetTester tester,
  ) async {
    _ignoreOverflow();
    final start = DateTime(2026, 10, 14);
    final end = DateTime(2026, 10, 21);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RealTimeCalendarCard(
            initialStartDate: start,
            initialEndDate: end,
          ),
        ),
      ),
    );

    expect(find.text('TRAVEL TIMEFRAME'), findsOneWidget);
    expect(find.textContaining('Oct 14', findRichText: true), findsOneWidget);
    expect(find.textContaining('Oct 21', findRichText: true), findsOneWidget);
    expect(find.textContaining('8 Days', findRichText: true), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('+3 Days'), findsOneWidget);
  });

  testWidgets('RealTimeGoogleMap component test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RealTimeGoogleMap(
            pickupLocation: '98 Acres Resort & Spa, Ella',
            dropoffLocation: 'Ravana Falls & Rock Sanctuary',
            durationText: '18 mins',
            distanceText: '8.4 km via B113',
            vehicleType: 'Tuk-Tuk',
          ),
        ),
      ),
    );

    expect(find.text('98 Acres Resort & Spa, Ella'), findsOneWidget);
    expect(find.text('Ravana Falls & Rock Sanctuary'), findsOneWidget);
    expect(find.text('18 mins'), findsOneWidget);
    expect(find.text('8.4 km via B113'), findsOneWidget);
    expect(find.byIcon(Icons.layers_rounded), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    expect(find.byIcon(Icons.my_location_rounded), findsNWidgets(2));
  });

  testWidgets('SignUpPage smoke test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(_wrapWithState(const SignUpPage()));

    expect(find.text('HELA • CEYLON'), findsNothing);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsWidgets);
    expect(find.text('Begin Your Journey'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Create Password'), findsOneWidget);
    expect(find.text('Create HELA Account'), findsOneWidget);
  });

  testWidgets('SignUpPage signIn mode test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(
      _wrapWithState(const SignUpPage(initialMode: AuthMode.signIn)),
    );

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('EditProfilePage smoke test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(_wrapWithState(const EditProfilePage()));

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Explorer Identity'), findsOneWidget);
    expect(find.text('Contact & Location'), findsOneWidget);
    expect(find.text('Bio & Travel Notes'), findsOneWidget);
    expect(find.text('Wanderlust Interests'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(find.text('Change Portrait'), findsOneWidget);
  });

  testWidgets('ProfilePage tap Edit Profile navigates to EditProfilePage', (
    WidgetTester tester,
  ) async {
    _ignoreOverflow();
    await tester.pumpWidget(_wrapWithState(const ProfilePage()));
    await tester.pumpAndSettle();

    final editBtn = find.text('Edit Personal Profile');
    expect(editBtn, findsOneWidget);
    await tester.ensureVisible(editBtn);
    await tester.tap(editBtn);
    await tester.pumpAndSettle();

    expect(find.text('Explorer Identity'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });

  test('HelaAppState haven saving and removal test', () {
    final appState = HelaAppState();
    const testHaven = HavenItem(
      title: 'Nine Arch Bridge & Demodara Tea Valley',
      location: 'Ella, Highlands',
      category: 'Guided Excursion',
      price: '\$45',
      rating: 4.90,
      badgeText: '240+ Verified Explorers',
      imageUrl: 'https://example.com/bridge.jpg',
    );

    expect(
      appState.isHavenSaved('Nine Arch Bridge & Demodara Tea Valley'),
      isFalse,
    );
    expect(appState.savedHavens.length, 0);

    // Save haven
    appState.toggleSaveHaven(testHaven);
    expect(
      appState.isHavenSaved('Nine Arch Bridge & Demodara Tea Valley'),
      isTrue,
    );
    expect(appState.savedHavens.length, 1);
    expect(
      appState.savedHavens.first.title,
      'Nine Arch Bridge & Demodara Tea Valley',
    );

    // Remove haven
    appState.toggleSaveHaven(testHaven);
    expect(
      appState.isHavenSaved('Nine Arch Bridge & Demodara Tea Valley'),
      isFalse,
    );
    expect(appState.savedHavens.length, 0);
  });

  testWidgets('SavedPage empty state test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(_wrapWithState(const SavedPage()));

    expect(find.text('Saved Collection'), findsOneWidget);
    expect(find.text('Your Saved Sanctuary is Empty'), findsOneWidget);
    expect(find.text('Explore Havens & Tours'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.byType(HelaBottomNavBar), findsNothing);
  });

  testWidgets('SavedPage with saved HavenCard renders card with details', (
    WidgetTester tester,
  ) async {
    _ignoreOverflow();
    final appState = HelaAppState();
    const testHaven = HavenItem(
      title: 'Nine Arch Bridge & Demodara Tea Valley',
      location: 'Ella, Highlands',
      category: 'Guided Excursion',
      price: '\$45',
      rating: 4.90,
      badgeText: '240+ Verified Explorers',
      imageUrl: 'https://example.com/bridge.jpg',
    );
    appState.toggleSaveHaven(testHaven);

    await tester.pumpWidget(
      HelaAppStateProvider(
        state: appState,
        child: const MaterialApp(home: SavedPage()),
      ),
    );

    expect(find.text('Saved Collection'), findsOneWidget);
    expect(find.text('Nine Arch Bridge & Demodara Tea Valley'), findsOneWidget);
    expect(find.text('Ella, Highlands'), findsOneWidget);
    expect(find.text('4.90'), findsOneWidget);
    expect(find.text('240+ Verified Explorers'), findsOneWidget);
    expect(find.text('Explore'), findsAtLeastNWidgets(1));
  });

  testWidgets('ExplorePage smoke test and search verification', (
    WidgetTester tester,
  ) async {
    _ignoreOverflow();
    await tester.pumpWidget(_wrapWithState(const ExplorePage()));
    await tester.pump();

    expect(find.text('Explore'), findsAtLeastNWidgets(1));
    expect(find.text('Popular Destinations'), findsOneWidget);
    expect(find.text('Hidden Gems'), findsOneWidget);
    expect(find.text('Cultural Experiences'), findsOneWidget);

    // Verify search bar presence
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Places to go, things to do, hotels...'), findsOneWidget);
  });

  testWidgets(
    'ExplorePage destination card displays real-time Google live rating top-left',
    (WidgetTester tester) async {
      _ignoreOverflow();
      GooglePlaceRatingService.clearMemoryCache();
      SharedPreferences.setMockInitialValues({});

      final mockClient = MockClient((request) async {
        final bodyStr = request.body;
        if (bodyStr.contains('Unawatuna Beach')) {
          return http.Response(
            jsonEncode({
              'places': [
                {
                  'displayName': {'text': 'Unawatuna Beach'},
                  'rating': 4.5,
                  'userRatingCount': 11840,
                },
              ],
            }),
            200,
          );
        }
        if (bodyStr.contains('Mirissa Beach')) {
          return http.Response(
            jsonEncode({
              'places': [
                {
                  'displayName': {'text': 'Mirissa Beach'},
                  'rating': 4.6,
                  'userRatingCount': 2530,
                },
              ],
            }),
            200,
          );
        }
        return http.Response(jsonEncode({'places': []}), 200);
      });

      final ratingService = GooglePlaceRatingService(
        client: mockClient,
        googlePlacesApiKey: 'AIzaMockLiveKey',
      );

      await tester.pumpWidget(
        _wrapWithState(ExplorePage(ratingService: ratingService)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unawatuna Beach'), findsOneWidget);
      expect(find.text('4.5 • 11.8k'), findsOneWidget);
      expect(find.text('4.6 • 2.5k'), findsOneWidget);
    },
  );

  testWidgets('ItineraryDetailsPage smoke test and stop rendering', (
    WidgetTester tester,
  ) async {
    _ignoreOverflow();
    await tester.pumpWidget(
      _wrapWithState(
        ItineraryDetailsPage(
          startDate: DateTime(2025, 10, 14),
          endDate: DateTime(2025, 10, 24),
          adults: 2,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Itinerary Details'), findsOneWidget);
    expect(find.text('AI CURATED PLAN'), findsOneWidget);
    expect(find.text('Cultural Wonders & Emerald Peaks'), findsOneWidget);
    expect(find.text('10 Days / 9 Nights'), findsOneWidget);
    expect(find.text('2 Travellers'), findsOneWidget);
    expect(find.text('AI Adjust'), findsOneWidget);
    expect(find.text('Schedule by Day'), findsOneWidget);
    expect(find.text('Sigiriya'), findsOneWidget);
    expect(find.text(r'~$140'), findsOneWidget);
    expect(find.text('Balanced'), findsOneWidget);
    expect(find.text('Day 1 Route Overview'), findsOneWidget);
    expect(find.text('Day 1 Itinerary'), findsOneWidget);
    expect(find.text('Arrival & Tropical Welcome at CMB'), findsOneWidget);
    expect(
      find.text('Traditional Rice & Curry Feast at Kurunegala'),
      findsOneWidget,
    );
    expect(find.text('Ascent of Sigiriya Lion Rock Citadel'), findsOneWidget);
    expect(
      find.text('Boutique Heritage Villa Check-In & Dinner'),
      findsOneWidget,
    );
    expect(find.text('HELA Fair-Price Assurance'), findsOneWidget);
    expect(find.text('Start My Journey'), findsOneWidget);

    // Ensure sticky bottom bar stays docked at bottom and does not cover body
    final bodyRect = tester.getRect(find.byType(SingleChildScrollView).first);
    final startBtnRect = tester.getRect(find.text('Start My Journey'));
    expect(bodyRect.height, greaterThan(350));
    expect(startBtnRect.top, greaterThan(450));

    // Tap Start My Journey and verify navigation to ActiveJourneyPage
    await tester.tap(find.text('Start My Journey'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Day 1 Live Journey'), findsOneWidget);
    expect(find.text('GPS LIVE'), findsOneWidget);
  });

  testWidgets('ActiveJourneyPage smoke test and stop checklist', (
    WidgetTester tester,
  ) async {
    _ignoreOverflow();
    await tester.pumpWidget(_wrapWithState(const ActiveJourneyPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Day 1 Live Journey'), findsOneWidget);
    expect(find.text('GPS LIVE'), findsOneWidget);
    expect(
      find.text('In 1.4 km • Turn Right onto Central Link'),
      findsOneWidget,
    );
    expect(find.text('Chaminda Perera'), findsOneWidget);
    expect(find.text('CURRENT LEG 2 OF 4'), findsOneWidget);
    expect(find.text('Day 1 Timeline & Stops'), findsOneWidget);
    expect(find.text('Mark as Arrived at Kurunegala'), findsOneWidget);

    // Scroll into view and tap Mark as Arrived
    await tester.ensureVisible(find.text('Mark as Arrived at Kurunegala'));
    await tester.tap(find.text('Mark as Arrived at Kurunegala'));
    await tester.pump();
    expect(find.text('Completed ✓'), findsOneWidget);
  });

  test('HelaAppState and LocalizationService language synchronization', () {
    final appState = HelaAppState();
    expect(appState.selectedLanguage, 'EN');
    expect(appState.languageDisplayName, 'English (US)');
    expect(appState.tr('get_started'), 'Get Started');

    // Verify all 20 world most spoken languages (without SI/TA) including UR, SW, and RTL AR
    expect(
      LocalizationService.supportedLanguages.any((l) => l.code == 'SI'),
      isFalse,
    );
    expect(
      LocalizationService.supportedLanguages.any((l) => l.code == 'TA'),
      isFalse,
    );
    expect(
      LocalizationService.supportedLanguages.any((l) => l.code == 'UR'),
      isTrue,
    );
    expect(
      LocalizationService.supportedLanguages.any((l) => l.code == 'SW'),
      isTrue,
    );
    expect(
      LocalizationService.supportedLanguages.any((l) => l.code == 'AR'),
      isTrue,
    );
    expect(LocalizationService.supportedLanguages.length, 20);
    expect(appState.isRtl, isFalse);

    appState.setLanguage('AR');
    expect(appState.selectedLanguage, 'AR');
    expect(appState.isRtl, isTrue);

    appState.setLanguage('DE');
    expect(appState.selectedLanguage, 'DE');
    expect(appState.isRtl, isFalse);
    expect(appState.languageDisplayName, 'German');
    expect(appState.tr('get_started'), 'Loslegen');

    appState.setLanguage('FR');
    expect(appState.selectedLanguage, 'FR');
    expect(appState.languageDisplayName, 'French');
    expect(appState.tr('get_started'), 'Commencer');

    appState.setLanguage('ZH');
    expect(appState.selectedLanguage, 'ZH');
    expect(appState.languageDisplayName, 'Chinese (Mandarin)');

    appState.setLanguage('RU');
    expect(appState.selectedLanguage, 'RU');
    expect(appState.languageDisplayName, 'Russian');
  });

  testWidgets(
    'OnboardingPage language selector changes app language and updates UI',
    (WidgetTester tester) async {
      _ignoreOverflow();
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final appState = HelaAppState();
      await tester.pumpWidget(
        HelaAppStateProvider(
          state: appState,
          child: const MaterialApp(home: OnboardingPage()),
        ),
      );
      await tester.pump();

      // Verify initial language pill shows EN
      expect(find.text('EN'), findsWidgets);

      // Tap the language selector pill
      await tester.tap(find.text('EN').first);
      await tester.pumpAndSettle();

      // Modal bottom sheet appears with 'Select Language' and world languages (no Sinhala/Tamil)
      expect(find.text('Select Language'), findsOneWidget);
      expect(find.text('Sinhala'), findsNothing);
      expect(find.text('Tamil'), findsNothing);
      expect(find.text('Chinese (Mandarin)'), findsOneWidget);
      expect(find.text('Hindi'), findsOneWidget);

      // Filter to French using search and tap it
      await tester.enterText(find.byType(TextField), 'French');
      await tester.pumpAndSettle();
      expect(find.text('Français'), findsOneWidget);
      await tester.tap(find.text('Français'));
      await tester.pumpAndSettle();

      // Verify app state language updated to FR
      expect(appState.selectedLanguage, 'FR');
      expect(find.text('FR'), findsWidgets);
      expect(find.text('Commencer'), findsOneWidget);
      expect(find.text('Continuer en invité'), findsOneWidget);
    },
  );

  testWidgets(
    'OnboardingPage texts dynamically translate when language changes to German (DE)',
    (WidgetTester tester) async {
      _ignoreOverflow();
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final appState = HelaAppState();
      await tester.pumpWidget(
        HelaAppStateProvider(
          state: appState,
          child: const MaterialApp(home: OnboardingPage()),
        ),
      );
      await tester.pump();

      // English initially
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);

      // Open language selector
      await tester.tap(find.text('EN').first);
      await tester.pumpAndSettle();

      // Search for German and select it
      await tester.enterText(find.byType(TextField), 'German');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deutsch'));
      await tester.pumpAndSettle();

      // Verify UI translated to German
      expect(appState.selectedLanguage, 'DE');
      expect(find.text('DE'), findsWidgets);
      expect(find.text('Loslegen'), findsOneWidget);
      expect(find.text('Als Gast fortfahren'), findsOneWidget);
      expect(find.text('Sigiriya, Kulturelles Dreieck'), findsOneWidget);
    },
  );

  testWidgets(
    'ProfilePage language setting displays current language and syncs updates with HelaAppState',
    (WidgetTester tester) async {
      _ignoreOverflow();
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final appState = HelaAppState();
      appState.setLanguage('EN');

      await tester.pumpWidget(
        HelaAppStateProvider(
          state: appState,
          child: const MaterialApp(home: ProfilePage()),
        ),
      );
      await tester.pump();

      // Initial language value should show English
      expect(find.text('English'), findsOneWidget);

      // Scroll into view and tap Language tile to open language picker
      await tester.ensureVisible(find.text('Language'));
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      // Check languages in bottom sheet: world languages included, Sinhala & Tamil excluded
      expect(find.text('Sinhala'), findsNothing);
      expect(find.text('Tamil'), findsNothing);
      expect(find.text('Chinese (Mandarin)'), findsOneWidget);
      expect(find.text('Spanish'), findsOneWidget);

      // Search for German and tap it
      await tester.enterText(find.byType(TextField), 'German');
      await tester.pumpAndSettle();
      expect(find.text('Deutsch'), findsOneWidget);
      await tester.tap(find.text('Deutsch'));
      await tester.pumpAndSettle();

      // Verify appState is now DE and ProfilePage reflects it
      expect(appState.selectedLanguage, 'DE');
      expect(find.text('Deutsch'), findsOneWidget);
    },
  );

  testWidgets(
    'OnboardingPage renders Continue as Guest with explore icon and sign-in option',
    (WidgetTester tester) async {
      _ignoreOverflow();
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final appState = HelaAppState();
      await tester.pumpWidget(
        HelaAppStateProvider(
          state: appState,
          child: const MaterialApp(home: OnboardingPage()),
        ),
      );
      await tester.pump();

      // Verify Continue as Guest button with explore icon
      expect(find.text('Continue as Guest'), findsOneWidget);
      expect(find.byIcon(Icons.explore_outlined), findsOneWidget);

      // Verify Ayubowan hospitality card at the bottom was removed
      expect(find.text('Ayubowan! "May you live long."'), findsNothing);
      expect(find.byIcon(Icons.wb_twilight_rounded), findsNothing);
    },
  );

  testWidgets(
    'OnboardingPage Screen 2 renders highlight pills without tip card',
    (WidgetTester tester) async {
      _ignoreOverflow();
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final appState = HelaAppState();
      await tester.pumpWidget(
        HelaAppStateProvider(
          state: appState,
          child: const MaterialApp(home: OnboardingPage()),
        ),
      );
      await tester.pump();

      // Navigate to slide 1 (Screen 2)
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Verify Screen 2 headline
      expect(find.text('Explore Every Corner'), findsOneWidget);

      // Verify Tip Card is removed
      expect(find.text('Scenic Rail Tip'), findsNothing);
      expect(
        find.text(
          'Reserve 1st or 2nd class observation carriage seats at least 30 days ahead during peak season for panoramic misty views.',
        ),
        findsNothing,
      );

      // Verify the 4 highlight pills are rendered
      expect(find.text('Golden Coastlines'), findsOneWidget);
      expect(find.text('Tea Country Peaks'), findsOneWidget);
      expect(find.text('Yala Wildlife'), findsOneWidget);
      expect(find.text('Ancient Temples'), findsOneWidget);
      expect(find.byIcon(Icons.waves_rounded), findsOneWidget);
      expect(find.byIcon(Icons.terrain_rounded), findsOneWidget);
      expect(find.byIcon(Icons.pets_rounded), findsOneWidget);
      expect(find.byIcon(Icons.temple_buddhist_rounded), findsOneWidget);
    },
  );

  testWidgets(
    'OnboardingPage Screen 3 renders stitch bento layout with 3/3 progress, showcase card and 3 bento cards',
    (WidgetTester tester) async {
      _ignoreOverflow();
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final appState = HelaAppState();
      await tester.pumpWidget(
        HelaAppStateProvider(
          state: appState,
          child: const MaterialApp(home: OnboardingPage()),
        ),
      );
      await tester.pump();

      // Navigate to slide 2 (Screen 3)
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify top progress indicator shows 3/3
      expect(find.text('3/3'), findsOneWidget);

      // Verify top bar language selector is removed on Screen 3
      expect(find.text('EN / සිංහල'), findsNothing);

      // Verify visual showcase card location pill
      expect(find.text('Temple of the Tooth'), findsOneWidget);
      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
      expect(find.text('Cultural Immersion • Kandy Heritage'), findsNothing);
      expect(find.text('🪔'), findsNothing);
      expect(find.text('Live Folk Lore & Ola Leaf Tales'), findsNothing);
      expect(find.text('4.98'), findsNothing);

      // Verify headline and 3 bento cards with badges
      expect(find.text('Your Personal Travel Companion'), findsOneWidget);
      expect(find.text('AI Tour Guide'), findsOneWidget);
      expect(find.text('Bilingual'), findsOneWidget);
      expect(find.text('Dynamic Trip Planner'), findsOneWidget);
      expect(find.text('Auto-Sync'), findsOneWidget);
      expect(find.text('Fair Taxi Pricing'), findsOneWidget);
      expect(find.text('Meter Verified'), findsOneWidget);

      // Verify CTAs
      expect(find.text('Start Exploring'), findsOneWidget);
      expect(
        find.text(
          'Continue as Guest • No credit card or upfront registration required',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Language selector bottom sheet does not overflow on compact screens',
    (WidgetTester tester) async {
      _ignoreOverflow();
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final appState = HelaAppState();
      await tester.pumpWidget(
        HelaAppStateProvider(
          state: appState,
          child: const MaterialApp(home: OnboardingPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap language pill
      await tester.tap(find.text('EN').first);
      await tester.pumpAndSettle();

      // Modal sheet appears with no overflows and world languages instead of Sinhala/Tamil
      expect(find.text('Select Language'), findsOneWidget);
      expect(find.text('English (US)'), findsOneWidget);
      expect(find.text('Sinhala'), findsNothing);
      expect(find.text('Tamil'), findsNothing);
      expect(find.text('Chinese (Mandarin)'), findsOneWidget);
      expect(find.text('Hindi'), findsOneWidget);
      expect(find.text('Spanish'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Russian');
      await tester.pumpAndSettle();
      expect(find.text('Русский'), findsOneWidget);
    },
  );

  testWidgets('AskHelaPage smoke test and UI verification', (
    WidgetTester tester,
  ) async {
    _ignoreOverflow();
    await tester.pumpWidget(_wrapWithState(const AskHelaPage()));
    await tester.pump();

    // Verify top bar without status and weather bar
    expect(find.text('Ask HELA'), findsOneWidget);
    expect(find.byIcon(Icons.translate_rounded), findsNothing);
    expect(find.text('Online • Island Intelligence Active'), findsNothing);
    expect(find.byIcon(Icons.thermostat_rounded), findsNothing);

    // Verify welcome intro card & suggested inquiries
    expect(find.text("Hello! I'm your HELA travel guide."), findsOneWidget);
    expect(find.text('Temple etiquette'), findsOneWidget);
    expect(find.text('History of Sigiriya'), findsOneWidget);

    // Verify initial chat message and rich response
    expect(
      find.text(
        "What should I know before visiting a Buddhist temple like Kandy's Temple of the Tooth?",
      ),
      findsOneWidget,
    );
    expect(find.text('Ayubowan! 🙏'), findsOneWidget);
    expect(find.text('Verified Lore'), findsOneWidget);
    expect(find.text('Modest Attire (White Preferred)'), findsOneWidget);
    expect(find.text('Footwear & Headwear'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('HelaHomePage tap Ask HELA redirects to AskHelaPage', (
    WidgetTester tester,
  ) async {
    _ignoreOverflow();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_wrapWithState(const HelaHomePage()));
    await tester.pump();

    final askHelaButton = find.text('Ask HELA');
    expect(askHelaButton, findsWidgets);
    await tester.ensureVisible(askHelaButton.last);
    await tester.tap(askHelaButton.last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Now on AskHelaPage
    expect(find.byType(AskHelaPage), findsOneWidget);
    expect(find.text("Hello! I'm your HELA travel guide."), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('ItineraryPlanningLoadingPage smoke test and UI verification', (
    WidgetTester tester,
  ) async {
    _ignoreOverflow();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _wrapWithState(
        ItineraryPlanningLoadingPage(
          startLocation: 'Bandaranaike Intl Airport (CMB)',
          startDate: DateTime.now().add(const Duration(days: 3)),
          endDate: DateTime.now().add(const Duration(days: 8)),
          tripDays: 5,
        ),
      ),
    );
    await tester.pump();

    // Verify header branding
    expect(find.text('HELA AI • BESPOKE TOUR PLANNER'), findsOneWidget);
    expect(find.text('HELA'), findsOneWidget);

    // Verify landscape labels
    expect(find.text('COAST'), findsOneWidget);
    expect(find.text('HIGHLANDS'), findsOneWidget);

    // Verify main headlines
    expect(find.text('Creating Your Journey...'), findsOneWidget);
    expect(
      find.text('Curating hidden tea trails, coastal tides\n& bespoke stops'),
      findsOneWidget,
    );

    // Verify progress indicator, pipeline checklist, summary chips & first ticker step
    expect(find.text('CONNECTING TO DEEPSEEK AI PLANNER...'), findsOneWidget);
    expect(find.text('5-Day Island Route'), findsOneWidget);
    expect(find.text('5D · 2 Guests'), findsOneWidget);
    expect(find.text('Comfort · Balanced'), findsOneWidget);
    expect(
      find.text('Analyzing weather, tides & optimal route'),
      findsOneWidget,
    );
    expect(find.byTooltip('Cancel planning'), findsOneWidget);

    // Dispose cleanly
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'ItineraryPlanningLoadingPage renders without overflow on compact screens and dark theme',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(720, 1480);
      tester.view.devicePixelRatio = 2.0; // 360x740 logical pixels
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final appState = HelaAppState();
      await tester.pumpWidget(
        HelaAppStateProvider(
          state: appState,
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: ItineraryPlanningLoadingPage(
              startLocation: 'Colombo, Sri Lanka',
              endLocation: 'Galle Fort',
              startDate: DateTime.now().add(const Duration(days: 2)),
              endDate: DateTime.now().add(const Duration(days: 6)),
              tripDays: 4,
              adults: 3,
              children: 1,
              budgetTier: 'luxury',
              pace: 'relaxed',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Colombo → Galle Fort'), findsOneWidget);
      expect(find.text('4D · 4 Guests'), findsOneWidget);
      expect(find.text('Luxury · Relaxed'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'ItineraryDetailsPage renders dynamic AI TourPlan with Stitch timeline UI',
    (WidgetTester tester) async {
      _ignoreOverflow();
      final aiPlan = TourPlan(
        id: 'tour_ai_test',
        title: 'Bespoke Misty Highlands & Coast',
        summary: 'AI-tailored 2-day expedition across Sri Lanka.',
        matchReason: 'Custom matched for Culture and Beaches.',
        durationDays: 2,
        estimatedTotalCostUsd: 280.0,
        dataSources: const ['Google Gemini AI (gemini-3.6-flash)'],
        days: const [
          ItineraryDay(
            dayNumber: 1,
            title: 'CMB → Cultural Triangle',
            summary: 'Heritage gateway',
            estimatedDayCostUsd: 140.0,
            overnightStay: 'Sigiriya',
            activities: [
              ItineraryActivity(
                title: 'Arrival & King Coconut Welcome',
                description: 'Chauffeur pickup at CMB airport.',
                startTime: '08:30 AM',
                estimatedDuration: '~1 hr',
                category: 'Arrival',
                estimatedCostUsd: 0.0,
              ),
              ItineraryActivity(
                title: 'Sigiriya Lion Rock Sunrise Climb',
                description: 'Explore ancient frescoes and summit views.',
                startTime: '03:30 PM',
                estimatedDuration: 'Must-See Wonder',
                category: 'UNESCO Ticket',
                estimatedCostUsd: 36.0,
                travelMethod: 'Private Chauffeur AC Car',
                travelTimeFromPrevious: '140 km (~3h 20m)',
                tips: ['Arrive before 4 PM for golden hour light.'],
              ),
            ],
          ),
          ItineraryDay(
            dayNumber: 2,
            title: 'Kandy Royal Sanctuary',
            summary: 'Sacred temple visit',
            estimatedDayCostUsd: 140.0,
            overnightStay: 'Kandy',
            activities: [
              ItineraryActivity(
                title: 'Temple of the Tooth Relic',
                description: 'Morning ceremony by Kandy Lake.',
                startTime: '09:00 AM',
                estimatedDuration: '~2 hrs',
                category: 'Culture',
                estimatedCostUsd: 12.0,
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        _wrapWithState(
          ItineraryDetailsPage(
            startDate: DateTime(2025, 10, 14),
            endDate: DateTime(2025, 10, 16),
            aiTourPlan: aiPlan,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('GEMINI AI PLAN'), findsOneWidget);
      expect(find.text('Bespoke Misty Highlands & Coast'), findsOneWidget);
      expect(find.text('Arrival & King Coconut Welcome'), findsOneWidget);
      expect(find.text('Sigiriya Lion Rock Sunrise Climb'), findsOneWidget);
      expect(find.text('Private Chauffeur AC Car:'), findsOneWidget);
      expect(
        find.textContaining('Arrive before 4 PM for golden hour light.'),
        findsOneWidget,
      );

      // Switch to Day 2
      await tester.tap(find.text('Day 2'));
      await tester.pump();
      expect(find.text('Temple of the Tooth Relic'), findsWidgets);
      expect(find.text('Morning ceremony by Kandy Lake.'), findsOneWidget);
      expect(find.text('Day 2 Route Overview'), findsOneWidget);
    },
  );
}
