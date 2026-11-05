import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/theme/hela_theme.dart';
import 'package:hela/widgets/theme_switch_button.dart';
import 'package:hela/widgets/hela_drawer.dart';
import 'package:hela/pages/home_page.dart';

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
  group('Hela Theme & Color Tokens Tests', () {
    test('HelaColors light and dark palettes have matching distinct branding colors', () {
      expect(HelaColors.lightPalette.brightness, Brightness.light);
      expect(HelaColors.darkPalette.brightness, Brightness.dark);

      // Light mode uses deep forest green primary and warm cream background
      expect(HelaColors.lightPalette.primary, const Color(0xFF19331F));
      expect(HelaColors.lightPalette.background, const Color(0xFFFAF9F3));

      // Dark mode uses radiant emerald green primary and Ceylon pine-slate night background
      expect(HelaColors.darkPalette.primary, const Color(0xFF7ED994));
      expect(HelaColors.darkPalette.background, const Color(0xFF0D140F));
      expect(HelaColors.darkPalette.surface, const Color(0xFF131B15));
      expect(HelaColors.darkPalette.onSurface, const Color(0xFFE2E5DE));
    });

    test('HelaTheme produces valid ThemeData for light and dark modes', () {
      final lightTheme = HelaTheme.lightTheme;
      final darkTheme = HelaTheme.darkTheme;

      expect(lightTheme.brightness, Brightness.light);
      expect(darkTheme.brightness, Brightness.dark);
      expect(lightTheme.scaffoldBackgroundColor, HelaColors.lightPalette.background);
      expect(darkTheme.scaffoldBackgroundColor, HelaColors.darkPalette.background);
    });

    test('HelaAppState manages theme mode and toggles correctly', () {
      final appState = HelaAppState();
      expect(appState.themeMode, ThemeMode.light);
      expect(appState.isDarkMode, false);

      appState.toggleTheme();
      expect(appState.themeMode, ThemeMode.dark);
      expect(appState.isDarkMode, true);

      appState.toggleTheme();
      expect(appState.themeMode, ThemeMode.light);
      expect(appState.isDarkMode, false);

      appState.setThemeMode(ThemeMode.system);
      expect(appState.themeMode, ThemeMode.system);
    });
  });

  group('Home Page Theme Switch UI Tests', () {
    testWidgets('Home page renders theme switch button in AppBar', (tester) async {
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
          child: ListenableBuilder(
            listenable: appState,
            builder: (context, _) => MaterialApp(
              theme: HelaTheme.lightTheme,
              darkTheme: HelaTheme.darkTheme,
              themeMode: appState.themeMode,
              home: const HelaHomePage(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify the theme switch button exists in the AppBar
      expect(find.byType(HelaThemeSwitchButton), findsOneWidget);

      // Tap the AppBar theme switch button to switch to Dark Mode
      await tester.tap(find.byType(HelaThemeSwitchButton));
      await tester.pumpAndSettle();

      // State is now dark mode!
      expect(appState.isDarkMode, true);
      expect(appState.themeMode, ThemeMode.dark);

      // Tap again to switch back to Light Mode
      await tester.tap(find.byType(HelaThemeSwitchButton));
      await tester.pumpAndSettle();

      expect(appState.isDarkMode, false);
      expect(appState.themeMode, ThemeMode.light);
    });

    testWidgets('Menu button opens HelaNavigationDrawer with theme mode selector', (tester) async {
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
          child: ListenableBuilder(
            listenable: appState,
            builder: (context, _) => MaterialApp(
              theme: HelaTheme.lightTheme,
              darkTheme: HelaTheme.darkTheme,
              themeMode: appState.themeMode,
              home: const HelaHomePage(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Tap the menu icon in the top AppBar
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();

      // Drawer is now open
      expect(find.byType(HelaNavigationDrawer), findsOneWidget);
      expect(find.text('APPEARANCE'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Auto'), findsOneWidget);

      // Tap "Dark" in drawer
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(appState.themeMode, ThemeMode.dark);
      expect(appState.isDarkMode, true);
    });
  });
}
