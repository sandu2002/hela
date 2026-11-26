import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hela/models/tour_plan.dart';
import 'package:hela/pages/trip_planner/itinerary_details_page.dart';
import 'package:hela/services/route_map_service.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/widgets/maps/live_route_overview_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('RouteMapService', () {
    test('resolves known Sri Lankan landmarks and airports accurately', () {
      final cmb = RouteMapService.resolveKnownCoordinates(
        'Bandaranaike Intl Airport (CMB)',
      );
      expect(cmb, isNotNull);
      expect(cmb!.latitude, closeTo(7.1808, 0.01));

      final tooth = RouteMapService.resolveKnownCoordinates(
        'Evening pooja at Temple of the Sacred Tooth Relic',
      );
      expect(tooth, isNotNull);
      expect(tooth!.latitude, closeTo(7.2936, 0.01));

      final nineArch = RouteMapService.resolveKnownCoordinates(
        'Nine Arch Bridge Sunrise',
      );
      expect(nineArch, isNotNull);
      expect(nineArch!.longitude, closeTo(81.0608, 0.01));
    });

    test('builds ordered route stops from ItineraryDay activities', () {
      const day = ItineraryDay(
        dayNumber: 1,
        title: 'Kandy → Ella',
        overnightStay: 'Ella',
        activities: [
          ItineraryActivity(
            title: 'Peradeniya Royal Botanical Walk',
            startTime: '08:30 AM',
            category: 'Nature',
          ),
          ItineraryActivity(
            title: 'Nine Arch Bridge Sunset',
            startTime: '04:30 PM',
            category: 'Scenic',
          ),
        ],
      );

      final stops = RouteMapService.buildDayRouteStops(
        originLabel: 'Kandy',
        destinationLabel: 'Ella',
        day: day,
      );

      expect(stops.length, greaterThanOrEqualTo(3));
      expect(stops.first.isOrigin, isTrue);
      expect(stops.first.title, 'Kandy');
      expect(stops[1].badgeText, '1');
      expect(stops[1].title, 'Peradeniya Royal Botanical Walk');
      expect(stops[2].badgeText, '2');
      expect(stops[2].title, 'Nine Arch Bridge Sunset');
    });
  });

  group('LiveRouteOverviewMap widget', () {
    testWidgets('renders FlutterMap with live GPS status and updates on stream',
        (tester) async {
      final controller = StreamController<LatLng>.broadcast();
      addTearDown(controller.close);

      final stops = RouteMapService.buildDayRouteStops(
        originLabel: 'Bandaranaike Intl Airport (CMB)',
        destinationLabel: 'Sigiriya',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveRouteOverviewMap(
              dayNumber: 1,
              routeSummary: 'CMB → Kurunegala → Sigiriya',
              stops: stops,
              stopsCount: 4,
              initialUserLocation: const LatLng(7.1950, 79.8950),
              locationStreamOverride: controller.stream,
              enableDeviceLocation: false,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.textContaining('Live GPS'), findsOneWidget);
      expect(find.text('4 stops'), findsOneWidget);

      // Emit a new live location closer to Kurunegala
      controller.add(const LatLng(7.4800, 80.3500));
      await tester.pump();

      expect(find.textContaining('Live GPS'), findsOneWidget);
    });

    testWidgets('ItineraryDetailsPage displays LiveRouteOverviewMap and opens Expand page',
        (tester) async {
      await tester.pumpWidget(
        HelaAppStateProvider(
          state: HelaAppState(),
          child: MaterialApp(
            home: ItineraryDetailsPage(
              startDate: DateTime(2026, 10, 14),
              endDate: DateTime(2026, 10, 18),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Day 1 Route Overview'), findsOneWidget);
      expect(find.byType(LiveRouteOverviewMap), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);

      // Scroll Expand into view (above sticky bottom bar) and tap it
      await tester.ensureVisible(find.text('Expand'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Expand'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(LiveRouteMapPage), findsOneWidget);
      expect(find.text('Day 1 Live Route Map'), findsOneWidget);
    });
  });
}
