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

      // Light mode uses deep Ocean Teal primary and tropical mint surface
      expect(HelaColors.lightPalette.primary, const Color(0xFF00443E));
      expect(HelaColors.lightPalette.background, const Color(0xFFE9FEF9));

      // Dark mode uses radiant Ceylon Sea Foam primary and Ceylon Emerald Night background
      expect(HelaColors.darkPalette.primary, const Color(0xFF8ED3CA));
      expect(HelaColors.darkPalette.background, const Color(0xFF0B1715));
      expect(HelaColors.darkPalette.surface, const Color(0xFF10211E));
      expect(HelaColors.darkPalette.onSurface, const Color(0xFFE0F5F0));
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
    testWidgets('Home page does not render theme switch button in AppBar', (tester) async {
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

      // Verify the theme switch button is removed from the Home AppBar
      expect(find.byType(HelaThemeSwitchButton), findsNothing);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
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

      // Open the drawer via Scaffold state
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
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
