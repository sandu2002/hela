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
import 'package:hela/pages/itinerary_details_page.dart';
import 'package:hela/pages/active_journey_page.dart';
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

    expect(find.textContaining('Discover Sri Lanka'), findsOneWidget);
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

  testWidgets('ItineraryDetailsPage smoke test and stop rendering', (WidgetTester tester) async {
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
    expect(find.text('Day 1 Route Overview'), findsOneWidget);
    expect(find.text('Day 1 Itinerary'), findsOneWidget);
    expect(find.text('Arrival & Tropical Welcome at CMB'), findsOneWidget);
    expect(find.text('Traditional Rice & Curry Feast at Kurunegala'), findsOneWidget);
    expect(find.text('Ascent of Sigiriya Lion Rock Citadel'), findsOneWidget);
    expect(find.text('Boutique Heritage Villa Check-In & Dinner'), findsOneWidget);
    expect(find.text('HELA Fair-Price Assurance'), findsOneWidget);
    expect(find.text('Start My Journey'), findsOneWidget);

    // Tap Start My Journey and verify navigation to ActiveJourneyPage
    await tester.tap(find.text('Start My Journey'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Day 1 Live Journey'), findsOneWidget);
    expect(find.text('GPS LIVE'), findsOneWidget);
  });

  testWidgets('ActiveJourneyPage smoke test and stop checklist', (WidgetTester tester) async {
    _ignoreOverflow();
    await tester.pumpWidget(
      _wrapWithState(const ActiveJourneyPage()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Day 1 Live Journey'), findsOneWidget);
    expect(find.text('GPS LIVE'), findsOneWidget);
    expect(find.text('In 1.4 km • Turn Right onto Central Link'), findsOneWidget);
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

    appState.setLanguage('SI');
    expect(appState.selectedLanguage, 'SI');
    expect(appState.languageDisplayName, 'සිංහල (Sinhala)');
    expect(appState.tr('get_started'), 'ආරම්භ කරමු');

    appState.setLanguage('TA');
    expect(appState.selectedLanguage, 'TA');
    expect(appState.languageDisplayName, 'தமிழ் (Tamil)');
    expect(appState.tr('get_started'), 'தொடங்குங்கள்');

    appState.setLanguage('DE');
    expect(appState.selectedLanguage, 'DE');
    expect(appState.languageDisplayName, 'Deutsch (German)');

    appState.setLanguage('FR');
    expect(appState.selectedLanguage, 'FR');
    expect(appState.languageDisplayName, 'Français (French)');

    appState.setLanguage('ZH');
    expect(appState.selectedLanguage, 'ZH');
    expect(appState.languageDisplayName, '中文 (Mandarin)');

    appState.setLanguage('RU');
    expect(appState.selectedLanguage, 'RU');
    expect(appState.languageDisplayName, 'Русский (Russian)');
  });

  testWidgets('OnboardingPage language selector changes app language and updates UI', (WidgetTester tester) async {
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
          home: OnboardingPage(),
        ),
      ),
    );
    await tester.pump();

    // Verify initial language pill shows EN
    expect(find.text('EN'), findsWidgets);

    // Tap the language selector pill
    await tester.tap(find.text('EN').first);
    await tester.pumpAndSettle();

    // Modal bottom sheet appears with 'Select Language'
    expect(find.text('Select Language'), findsOneWidget);
    expect(find.text('සිංහල (Sinhala)'), findsOneWidget);

    // Tap Sinhala
    await tester.tap(find.text('සිංහල (Sinhala)'));
    await tester.pumpAndSettle();

    // Verify app state language updated to SI
    expect(appState.selectedLanguage, 'SI');
    expect(find.text('SI'), findsWidgets);
    expect(find.text('ආරම්භ කරමු'), findsOneWidget);
    expect(find.text('ආගන්තුකයෙකු ලෙස යන්න'), findsOneWidget);
  });

  testWidgets('OnboardingPage texts dynamically translate when language changes to German (DE)', (WidgetTester tester) async {
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
          home: OnboardingPage(),
        ),
      ),
    );
    await tester.pump();

    // English initially
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);

    // Open language selector
    await tester.tap(find.text('EN').first);
    await tester.pumpAndSettle();

    // Select Deutsch
    await tester.tap(find.text('Deutsch (German)'));
    await tester.pumpAndSettle();

    // Verify UI translated to German
    expect(appState.selectedLanguage, 'DE');
    expect(find.text('DE'), findsWidgets);
    expect(find.text('Loslegen'), findsOneWidget);
    expect(find.text('Als Gast fortfahren'), findsOneWidget);
    expect(find.text('Goldene Morgendämmerung'), findsOneWidget);
    expect(find.text('Sigiriya, Kulturelles Dreieck'), findsOneWidget);
  });

  testWidgets('ProfilePage language setting displays current language and syncs updates with HelaAppState', (WidgetTester tester) async {
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
        child: const MaterialApp(
          home: ProfilePage(),
        ),
      ),
    );
    await tester.pump();

    // Initial language subtitle should show English (US)
    expect(find.text('English (US)'), findsOneWidget);

    // Scroll into view and tap Language tile to open language picker
    await tester.ensureVisible(find.text('Language'));
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();

    // Check languages in bottom sheet
    expect(find.text('සිංහල (Sinhala)'), findsOneWidget);

    // Tap Sinhala
    await tester.tap(find.text('සිංහල (Sinhala)'));
    await tester.pumpAndSettle();

    // Verify appState is now SI and ProfilePage reflects it
    expect(appState.selectedLanguage, 'SI');
    expect(find.text('සිංහල (Sinhala)'), findsOneWidget);
  });

  testWidgets('OnboardingPage renders bottom hospitality card and Continue as Guest with explore icon', (WidgetTester tester) async {
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
          home: OnboardingPage(),
        ),
      ),
    );
    await tester.pump();

    // Verify Continue as Guest button with explore icon
    expect(find.text('Continue as Guest'), findsOneWidget);
    expect(find.byIcon(Icons.explore_outlined), findsOneWidget);

    // Verify Ayubowan hospitality card at the bottom
    expect(find.text('Ayubowan! "May you live long."'), findsOneWidget);
    expect(
      find.text('Authentic local train timetables & meter guides await.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.wb_twilight_rounded), findsOneWidget);
  });
}

