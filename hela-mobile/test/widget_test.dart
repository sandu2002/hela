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
import 'package:hela/pages/saved_page.dart';
import 'package:hela/pages/profile_page.dart';
import 'package:hela/pages/profile/edit_profile_page.dart';
import 'package:hela/pages/cultural_guide/cultural_guide_page.dart';
import 'package:hela/pages/cultural_guide/article_detail_page.dart';
import 'package:hela/onbording/onboarding_page.dart';
import 'package:hela/pages/auth/signup_page.dart';
import 'package:hela/pages/explore_page.dart';
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

    expect(find.text('Discover Sri Lanka, Your Way'), findsOneWidget);
    expect(find.text('Featured Destinations'), findsOneWidget);
  });

  testWidgets('HelaHomePage category filter updates tour cards when tapped', (WidgetTester tester) async {
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
        child: const MaterialApp(
          home: HelaHomePage(),
        ),
      ),
    );
    await tester.pump();

    // Initially "Featured Destinations" and Sigiriya are visible
    expect(find.text('Featured Destinations'), findsOneWidget);
    expect(find.text('Sigiriya'), findsOneWidget);

    // Tap "Beaches" filter chip
    await tester.tap(find.text('Beaches'));
    await tester.pumpAndSettle();

    // Experience card now shows Beaches experience
    expect(find.text('Weligama Surfing & Tangalle Bays'), findsOneWidget);

    // Tap "Nature & Wildlife" filter chip
    await tester.tap(find.text('Nature & Wildlife'));
    await tester.pumpAndSettle();

    expect(find.text('Minneriya Elephant Gathering & Yala Safaris'), findsOneWidget);
  });

  testWidgets('TripPlannerPage smoke test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(
      _wrapWithState(const TripPlannerPage()),
    );
    await tester.pump();

    expect(find.text('Plan Your Sri Lankan Adventure'), findsOneWidget);
    expect(find.text('Where does your journey begin?'), findsOneWidget);
    expect(find.text('Travel Dates'), findsOneWidget);
    expect(find.text('Travel Budget'), findsOneWidget);
    expect(find.text('Travel Interests'), findsOneWidget);
    expect(find.text('Pace & Travel Style'), findsOneWidget);
    expect(find.text('Generate My Itinerary ✨'), findsOneWidget);
    expect(find.text('Get Directions'), findsOneWidget);
    expect(find.text('Add to My Trip'), findsOneWidget);
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
      _wrapWithState(
        const OnboardingPage(),
      ),
    );

    expect(find.text('HELA'), findsWidgets);
    expect(find.text('Sri Lanka Travel Companion'), findsOneWidget);
    expect(find.text('Discover Sri Lanka,\nYour Way'), findsOneWidget);
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

    expect(find.text('HELA • CEYLON'), findsOneWidget);
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
    await tester.pumpWidget(
      _wrapWithState(const EditProfilePage()),
    );

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Explorer Identity'), findsOneWidget);
    expect(find.text('Contact & Location'), findsOneWidget);
    expect(find.text('Bio & Travel Notes'), findsOneWidget);
    expect(find.text('Wanderlust Interests'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(find.text('Change Portrait'), findsOneWidget);
  });

  testWidgets('ProfilePage tap Edit Profile navigates to EditProfilePage', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(
      _wrapWithState(const ProfilePage()),
    );

    expect(find.text('Edit Profile'), findsOneWidget);
    await tester.tap(find.text('Edit Profile'));
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

    expect(appState.isHavenSaved('Nine Arch Bridge & Demodara Tea Valley'), isFalse);
    expect(appState.savedHavens.length, 0);

    // Save haven
    appState.toggleSaveHaven(testHaven);
    expect(appState.isHavenSaved('Nine Arch Bridge & Demodara Tea Valley'), isTrue);
    expect(appState.savedHavens.length, 1);
    expect(appState.savedHavens.first.title, 'Nine Arch Bridge & Demodara Tea Valley');

    // Remove haven
    appState.toggleSaveHaven(testHaven);
    expect(appState.isHavenSaved('Nine Arch Bridge & Demodara Tea Valley'), isFalse);
    expect(appState.savedHavens.length, 0);
  });

  testWidgets('SavedPage empty state test', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(
      _wrapWithState(const SavedPage()),
    );

    expect(find.text('Saved Page'), findsOneWidget);
    expect(find.text('Your Saved Sanctuary is Empty'), findsOneWidget);
    expect(find.text('Explore Havens & Tours'), findsOneWidget);
  });

  testWidgets('SavedPage with saved HavenCard renders card with details', (WidgetTester tester) async {
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

    expect(find.text('Saved Page'), findsOneWidget);
    expect(find.text('Nine Arch Bridge & Demodara Tea Valley'), findsOneWidget);
    expect(find.text('Ella, Highlands'), findsOneWidget);
    expect(find.text('4.90'), findsOneWidget);
    expect(find.text('240+ Verified Explorers'), findsOneWidget);
    expect(find.text('Explore'), findsAtLeastNWidgets(1));
  });

  testWidgets('ExplorePage smoke test and view toggle', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(
      _wrapWithState(const ExplorePage()),
    );
    await tester.pump();

    expect(find.text('Explore Sri Lanka'), findsOneWidget);
    expect(find.text('Find places worth discovering.'), findsOneWidget);
    expect(find.text('Popular Destinations'), findsOneWidget);
    expect(find.text('Hidden Gems'), findsOneWidget);
    expect(find.text('Cultural Experiences'), findsOneWidget);

    // Toggle Map view
    final mapToggleFinder = find.byKey(const ValueKey('explore_map_toggle'));
    expect(mapToggleFinder, findsOneWidget);
    await tester.tap(mapToggleFinder);
    await tester.pump(const Duration(milliseconds: 100));

    // Map view is displayed
    expect(find.byType(RealTimeGoogleMap), findsOneWidget);

    // Toggle back to List view
    final listToggleFinder = find.byKey(const ValueKey('explore_list_toggle'));
    expect(listToggleFinder, findsOneWidget);
    await tester.tap(listToggleFinder);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Popular Destinations'), findsOneWidget);
  });
}

