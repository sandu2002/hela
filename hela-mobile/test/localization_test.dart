import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hela/pages/profile_page.dart';
import 'package:hela/services/localization_service.dart';
import 'package:hela/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalizationService 20-language coverage', () {
    test('exposes 20 major world and local languages', () {
      const expectedCodes = [
        'EN',
        'SI',
        'TA',
        'ZH',
        'ES',
        'HI',
        'AR',
        'PT',
        'BN',
        'RU',
        'JA',
        'DE',
        'FR',
        'KO',
        'IT',
        'TR',
        'ID',
        'NL',
        'TH',
        'VI',
      ];
      final codes =
          LocalizationService.supportedLanguages.map((l) => l.code).toList();
      expect(codes, expectedCodes);
      expect(codes.length, 20);
    });

    test('translates core keys across every supported language', () {
      const requiredKeys = [
        'home',
        'explore',
        'trip_planner',
        'bookings',
        'profile',
        'language',
        'select_language',
        'search_language',
        'my_profile',
        'explore_sri_lanka',
        'plan_your_adventure',
        'my_bookings',
        'select_current_location',
        'saved_collection',
        'edit_profile',
        'itinerary_details',
      ];

      for (final lang in LocalizationService.supportedLanguages) {
        for (final key in requiredKeys) {
          final value = LocalizationService.tr(key, lang.code);
          expect(
            value.trim().isNotEmpty,
            isTrue,
            reason: 'Missing non-empty value for $key in ${lang.code}',
          );
          expect(
            value,
            isNot(equals(key)),
            reason: 'Untranslated raw key $key in ${lang.code}',
          );
        }
      }

      expect(LocalizationService.tr('my_profile', 'SI'), 'මගේ පැතිකඩ');
      expect(LocalizationService.tr('my_profile', 'TA'), 'என் சுயவிவரம்');
      expect(LocalizationService.tr('my_profile', 'DE'), 'Mein Profil');
      expect(LocalizationService.tr('my_profile', 'ES'), 'Mi Perfil');
      expect(LocalizationService.tr('my_profile', 'AR'), 'ملفي الشخصي');
      expect(LocalizationService.tr('my_profile', 'JA'), 'マイプロフィール');
      expect(LocalizationService.tr('my_profile', 'HI'), 'मेरी प्रोफ़ाइल');
    });
  });

  group('HelaAppState language persistence & RTL', () {
    test('persists selected language and restores it on startup', () async {
      final initial = HelaAppState();
      expect(initial.selectedLanguage, 'EN');
      expect(initial.isRtl, isFalse);

      initial.setLanguage('AR');
      expect(initial.selectedLanguage, 'AR');
      expect(initial.isRtl, isTrue);

      // Wait briefly for async SharedPreferences write
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final restored = HelaAppState();
      await restored.restoreLanguage();
      expect(restored.selectedLanguage, 'AR');
      expect(restored.isRtl, isTrue);

      restored.setLanguage('SI');
      expect(restored.isRtl, isFalse);
    });
  });

  group('Dynamic UI switching via ProfilePage language picker', () {
    testWidgets('switching language updates ProfilePage and bottom nav live',
        (tester) async {
      final appState = HelaAppState();
      await tester.pumpWidget(
        HelaAppStateProvider(
          state: appState,
          child: ListenableBuilder(
            listenable: appState,
            builder: (context, _) {
              return MaterialApp(
                builder: (context, child) => Directionality(
                  textDirection:
                      appState.isRtl ? TextDirection.rtl : TextDirection.ltr,
                  child: child ?? const SizedBox.shrink(),
                ),
                home: const ProfilePage(),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsAtLeastNWidgets(1));
      expect(find.text('Explore'), findsOneWidget);

      // Scroll to Language setting row and open the language picker sheet
      final languageFinder = find.text('Language');
      await tester.ensureVisible(languageFinder);
      await tester.tap(languageFinder);
      await tester.pumpAndSettle();

      expect(find.text('Select Language'), findsOneWidget);

      // Filter by search input for German and select it
      await tester.enterText(find.byType(TextField), 'German');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Deutsch'));
      await tester.pumpAndSettle();

      expect(appState.selectedLanguage, 'DE');
      expect(find.text('Profil'), findsAtLeastNWidgets(1));
      expect(find.text('EINSTELLUNGEN'), findsOneWidget);
      expect(find.text('Entdecken'), findsOneWidget);
      expect(find.text('Gespeichert'), findsOneWidget);

      // Switch to Arabic and verify RTL directionality updates
      final spracheFinder = find.text('Sprache');
      await tester.ensureVisible(spracheFinder);
      await tester.tap(spracheFinder);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Arabic');
      await tester.pumpAndSettle();
      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();

      expect(appState.selectedLanguage, 'AR');
      expect(appState.isRtl, isTrue);
      expect(find.text('الملف الشخصي'), findsAtLeastNWidgets(1));
    });
  });
}
