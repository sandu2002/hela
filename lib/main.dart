import 'package:flutter/material.dart';
import 'package:hela/onbording/onboarding_page.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/state/tour_planner_state.dart';
import 'package:hela/pages/home_page.dart';

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
        child: MaterialApp(
          title: 'HELA — Discover Sri Lanka',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Plus Jakarta Sans',
            scaffoldBackgroundColor: HelaColors.background,
            colorScheme: ColorScheme.fromSeed(
              seedColor: HelaColors.primary,
              primary: HelaColors.primary,
              secondary: HelaColors.secondary,
              surface: HelaColors.surface,
            ),
          ),
          home: const OnboardingPage(),
        ),
      ),
    );
  }
}
