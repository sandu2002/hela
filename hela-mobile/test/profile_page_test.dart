import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hela/pages/profile_page.dart';
import 'package:hela/state/app_state.dart';

void main() {
  Widget wrapProfile(HelaAppState appState) {
    return HelaAppStateProvider(
      state: appState,
      child: const MaterialApp(
        home: ProfilePage(),
      ),
    );
  }

  group('ProfilePage UI & interactions', () {
    testWidgets('renders hero card, travel hub, preferences, legal & logout', (tester) async {
      final appState = HelaAppState()
        ..signIn(
          name: 'Elena Rostova',
          email: 'elena.travels@worldmail.com',
        )
        ..updateProfile(phone: '+44 7911 123456');

      await tester.pumpWidget(wrapProfile(appState));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsAtLeastNWidgets(1));
      expect(find.text('Elena Rostova'), findsOneWidget);
      expect(find.text('elena.travels@worldmail.com'), findsOneWidget);
      expect(find.text('+44 7911 123456'), findsOneWidget);
      expect(find.text('GB'), findsOneWidget);
      expect(find.text('SLTDA Tourist ID #8492'), findsOneWidget);
      expect(find.text('Edit Personal Profile'), findsOneWidget);
      expect(find.text('MY TRAVEL HUB'), findsOneWidget);
      expect(find.text('Saved Destinations'), findsOneWidget);
      expect(find.text('Saved Itineraries'), findsOneWidget);
      expect(find.text('My Active Bookings'), findsOneWidget);
      expect(find.text('Island Travel History'), findsOneWidget);
      expect(find.text('PREFERENCES'), findsOneWidget);
      expect(find.text('ASSISTANCE & LEGAL'), findsOneWidget);
      expect(find.text('Log Out of HELA Account'), findsOneWidget);
      expect(find.text('HELA Sri Lanka v2.4.1'), findsOneWidget);
    });

    testWidgets('toggles currency display and smart travel alerts', (tester) async {
      final appState = HelaAppState();
      await tester.pumpWidget(wrapProfile(appState));
      await tester.pumpAndSettle();

      expect(appState.preferredCurrency, 'USD (\$)');

      final lkrFinder = find.text('LKR (Rs)');
      await tester.ensureVisible(lkrFinder);
      await tester.tap(lkrFinder);
      await tester.pumpAndSettle();
      expect(appState.preferredCurrency, 'LKR (Rs)');

      expect(appState.smartTravelAlerts, isTrue);
      final switchFinder = find.byType(Switch);
      await tester.ensureVisible(switchFinder);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(appState.smartTravelAlerts, isFalse);
    });

    testWidgets('opens SOS emergency sheet and logout confirmation dialog', (tester) async {
      final appState = HelaAppState();
      await tester.pumpWidget(wrapProfile(appState));
      await tester.pumpAndSettle();

      // Open SOS bottom sheet
      await tester.tap(find.text('SOS').first);
      await tester.pumpAndSettle();
      expect(find.text('Tourist Emergency SOS'), findsOneWidget);
      expect(find.text('Sri Lanka Tourist Police'), findsOneWidget);
      expect(find.text('Suwa Seriya National Ambulance'), findsOneWidget);

      // Dismiss SOS sheet
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Scroll to Log Out button and tap it
      final logoutFinder = find.text('Log Out of HELA Account');
      await tester.ensureVisible(logoutFinder);
      await tester.tap(logoutFinder);
      await tester.pumpAndSettle();
      expect(find.text('Log Out of HELA Account?'), findsOneWidget);
    });
  });
}
