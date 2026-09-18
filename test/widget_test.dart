// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hela/state/app_state.dart';
import 'package:hela/pages/home_page.dart';
import 'package:hela/pages/trip_planner_page.dart';
import 'package:hela/pages/fair_ride_page.dart';
import 'package:hela/pages/stays_page.dart';
import 'package:hela/pages/profile_page.dart';
import 'package:hela/pages/cultural_guide_page.dart';
import 'package:hela/pages/article_detail_page.dart';
import 'package:hela/onbording/onboarding_page.dart';
import 'package:hela/pages/signup_page.dart';
import 'package:hela/widgets/haven_card.dart';
import 'package:hela/widgets/stay_card.dart';
import 'package:hela/widgets/itinerary_card.dart';
import 'package:hela/widgets/real_time_calendar.dart';
import 'package:hela/widgets/real_time_map.dart';

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
    await tester.pumpWidget(
      const MaterialApp(
        home: HelaHomePage(),
      ),
    );

    expect(find.text('Discover Sri Lanka'), findsOneWidget);
    expect(find.text('Hill Country'), findsOneWidget);
  });

  testWidgets('TripPlannerPage smoke test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(
      const MaterialApp(
        home: TripPlannerPage(),
      ),
    );

    expect(find.text('AI PLANNER'), findsOneWidget);
    expect(find.text('Where do you feel like wandering?'), findsOneWidget);
    expect(find.text('AI-Suggested Itineraries'), findsOneWidget);
  });

  testWidgets('FairRidePage smoke test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(
      const MaterialApp(
        home: FairRidePage(),
      ),
    );

    expect(find.text('Fair Ride Ceylon'), findsOneWidget);
    expect(find.text('Select Ceylon Vehicle'), findsOneWidget);
    expect(find.text('Tuk-Tuk'), findsOneWidget);
  });

  testWidgets('StaysPage smoke test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(
      const MaterialApp(
        home: StaysPage(),
      ),
    );

    expect(find.text('Sanctuaries & Stays'), findsOneWidget);
    expect(find.text('28 Eco-Havens'), findsOneWidget);
    expect(find.text('98 Acres Luxury Tea Pavilion'), findsOneWidget);
  });

  testWidgets('ProfilePage smoke test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfilePage(),
      ),
    );

    expect(find.text('Kavinda Wickramasinghe'), findsOneWidget);
    expect(find.text('Verified Resident Explorer'), findsOneWidget);
    expect(find.text('Ceylon Eco-Pledge'), findsOneWidget);
    expect(find.text('Saved Itineraries'), findsOneWidget);
  });

  testWidgets('CulturalGuidePage smoke test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(
      _wrapWithState(const CulturalGuidePage()),
    );

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
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingPage(),
      ),
    );

    expect(find.text('HELA'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('BESPOKE ITINERARIES'), findsOneWidget);
    expect(find.text('Plan Effortlessly'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
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
            subtitle: 'UNESCO rock fortresses, cave monasteries and spice trails',
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
    expect(find.text('Sunset climb up Lion Rock to ancient sky palace ruins'), findsOneWidget);
    expect(find.textContaining(r'$295', findRichText: true), findsOneWidget);
    expect(find.text('View Route'), findsOneWidget);
  });

  testWidgets('RealTimeCalendarCard component test', (WidgetTester tester) async {
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
    await tester.pumpWidget(
      _wrapWithState(const SignUpPage()),
    );

    expect(find.text('HELA'), findsOneWidget);
    expect(find.text('Begin Your Journey'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Create HELA Account'), findsOneWidget);
  });

  testWidgets('SignUpPage signIn mode test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(
      _wrapWithState(const SignUpPage(initialMode: AuthMode.signIn)),
    );

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });
}

