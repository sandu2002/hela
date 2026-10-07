import 'package:flutter/material.dart';
import 'package:hela/onbording/onboarding_page.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/state/tour_planner_state.dart';
import 'package:hela/theme/hela_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final HelaAppState _appState = HelaAppState();
  final TourPlannerState _tourPlannerState = TourPlannerState();

  @override
  void dispose() {
    _appState.dispose();
    _tourPlannerState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HelaAppStateProvider(
      state: _appState,
      child: TourPlannerStateProvider(
        state: _tourPlannerState,
        child: ListenableBuilder(
          listenable: _appState,
          builder: (context, _) {
            return MaterialApp(
              title: 'HELA — Discover Sri Lanka',
              debugShowCheckedModeBanner: false,
              theme: HelaTheme.lightTheme,
              darkTheme: HelaTheme.darkTheme,
              themeMode: _appState.themeMode,
              home: const OnboardingPage(),
            );
          },
        ),
      ),
    );
  }
}
