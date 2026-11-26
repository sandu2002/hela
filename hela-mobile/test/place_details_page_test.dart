import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hela/data/place_details_catalog.dart';
import 'package:hela/pages/home_page.dart';
import 'package:hela/pages/place_details_page.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/widgets/featured_destination_card.dart';

Widget _wrap(Widget child, {HelaAppState? state}) {
  return HelaAppStateProvider(
    state: state ?? HelaAppState(),
    child: MaterialApp(home: child),
  );
}

void main() {
  group('FeaturedDestinationCard & PlaceDetailsPage', () {
    testWidgets('FeaturedDestinationCard supports const construction',
        (tester) async {
      const card = FeaturedDestinationCard(
        item: FeaturedDestinationItem(
          title: 'Sigiriya',
          subtitle: 'Ancient Lion Rock fortress',
          rating: '5.0',
          badge: 'UNESCO',
          footerTag: 'Cultural Wonder',
          imageUrl: 'https://example.com/sigiriya.jpg',
        ),
      );

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: card)));
      expect(find.text('Sigiriya'), findsOneWidget);
      expect(find.text('UNESCO'), findsOneWidget);
      expect(find.text('Cultural Wonder'), findsOneWidget);
    });

    testWidgets(
        'tapping bottom experience card on HelaHomePage opens PlaceDetailsPage',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final appState = HelaAppState();
      await tester.pumpWidget(_wrap(const HelaHomePage(), state: appState));
      await tester.pump();

      final expFinder = find.text('Minneriya Elephant Gathering & Yala Safaris');
      await tester.ensureVisible(expFinder);
      await tester.tap(expFinder);
      await tester.pumpAndSettle();

      expect(find.byType(PlaceDetailsPage), findsOneWidget);
      expect(find.text('Minneriya & Yala Safaris'), findsOneWidget);
      expect(find.text('Location & Geography'), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.text('Get Directions'), findsNothing);
      final addTripFinder = find.text('Add to My Trip');
      await tester.ensureVisible(addTripFinder);
      expect(addTripFinder, findsOneWidget);
    });

    testWidgets(
        'tapping FeaturedDestinationCard opens Sigiriya details with interactive tabs & save',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final appState = HelaAppState();
      await tester.pumpWidget(_wrap(const HelaHomePage(), state: appState));
      await tester.pump();

      await tester.tap(find.text('Sigiriya').first);
      await tester.pumpAndSettle();

      expect(find.byType(PlaceDetailsPage), findsOneWidget);
      expect(find.text('සීගිරිය'), findsOneWidget);
      expect(find.text('Tourist Essentials'), findsOneWidget);
      expect(find.text('Opening Hours'), findsOneWidget);
      expect(find.text('Entry & Ticket Fee'), findsOneWidget);
      expect(find.text('Dress Code & Rules'), findsOneWidget);
      expect(find.text('The Water & Boulder Gardens'), findsOneWidget);

      // Switch to History tab
      final historyTab = find.text('History');
      await tester.ensureVisible(historyTab);
      await tester.tap(historyTab);
      await tester.pumpAndSettle();
      expect(find.text('King Kashyapa\'s Sky Palace'), findsOneWidget);

      // Switch to Visit Tips tab
      final tipsTab = find.text('Visit Tips');
      await tester.ensureVisible(tipsTab);
      await tester.tap(tipsTab);
      await tester.pumpAndSettle();
      expect(find.text('Best Climbing Window'), findsOneWidget);

      // Toggle Favorite heart and verify HelaAppState updates
      expect(appState.isHavenSaved('Sigiriya'), isFalse);
      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pumpAndSettle();
      expect(appState.isHavenSaved('Sigiriya'), isTrue);
    });

    testWidgets('Nearby Discoveries card navigates to nearby place details',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _wrap(const PlaceDetailsPage(place: PlaceDetailCatalog.sigiriya)),
      );
      await tester.pumpAndSettle();

      final nearbyFinder = find.text('Pidurangala Rock');
      await tester.ensureVisible(nearbyFinder);
      await tester.tap(nearbyFinder);
      await tester.pumpAndSettle();

      expect(find.text('පිදුරංගල'), findsOneWidget);
      expect(find.text('Lion Rock Horizon Summit'), findsOneWidget);
    });
  });
}
