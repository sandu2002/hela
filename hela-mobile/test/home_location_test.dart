import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hela/pages/home_page.dart';
import 'package:hela/services/live_weather_service.dart';
import 'package:hela/state/app_state.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('HelaHomePage updates header location pill from phone GPS', (tester) async {
    final mockClient = MockClient((request) async {
      if (request.url.toString().contains('nominatim.openstreetmap.org/reverse')) {
        return http.Response(
          jsonEncode({
            'address': {'city': 'Kandy', 'country': 'Sri Lanka'},
          }),
          200,
        );
      }
      return http.Response('Not Found', 404);
    });

    final fakePosition = Position(
      longitude: 80.6337,
      latitude: 7.2906,
      timestamp: DateTime(2026, 11, 25),
      accuracy: 10,
      altitude: 0,
      altitudeAccuracy: 1,
      heading: 0,
      headingAccuracy: 1,
      speed: 0,
      speedAccuracy: 1,
    );

    final locationService = LiveWeatherService(
      client: mockClient,
      positionProvider: () async => fakePosition,
    );

    final appState = HelaAppState();

    await tester.pumpWidget(
      HelaAppStateProvider(
        state: appState,
        child: MaterialApp(
          home: HelaHomePage(weatherService: locationService),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kandy'), findsWidgets);
    expect(appState.detectedCurrentCity, 'Kandy');

    // Open location picker sheet and verify GPS option + manual override
    await tester.tap(find.text('Kandy').first);
    await tester.pumpAndSettle();

    expect(find.text('Use My Current GPS Location'), findsOneWidget);

    await tester.tap(find.text('Galle').last);
    await tester.pumpAndSettle();

    expect(appState.detectedCurrentCity, 'Galle');
    expect(find.text('Galle'), findsWidgets);
  });
}
