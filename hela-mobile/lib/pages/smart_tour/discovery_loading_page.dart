import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hela/theme/hela_colors.dart';
import 'package:hela/models/tour_preferences.dart';
import 'package:hela/state/tour_planner_state.dart';
import 'package:hela/services/tour_api_service.dart';
import 'package:hela/pages/smart_tour/destination_recommendations_page.dart';

/// Screen displayed while AI discovers destinations matching the user's travel preferences.
class DiscoveryLoadingPage extends StatefulWidget {
  final TourPreferences preferences;

  const DiscoveryLoadingPage({
    super.key,
    required this.preferences,
  });

  @override
  State<DiscoveryLoadingPage> createState() => _DiscoveryLoadingPageState();
}

class _DiscoveryLoadingPageState extends State<DiscoveryLoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _stepTimer;
  int _currentStep = 0;

  final List<String> _loadingSteps = [
    'Connecting to HELA Intelligence Engine...',
    'Scanning OpenStreetMap Sri Lanka tourism data...',
    'Analyzing your travel interests with Gemini AI...',
    'Ranking optimal destinations & travel routes...',
    'Synthesizing your personalized recommendations...',
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Progress through steps smoothly
    _stepTimer = Timer.periodic(const Duration(milliseconds: 1600), (timer) {
      if (mounted && _currentStep < _loadingSteps.length - 1) {
        setState(() => _currentStep++);
      }
    });

    _startDiscovery();
  }

  Future<void> _startDiscovery() async {
    try {
      final destinations =
          await TourApiService().discoverDestinations(widget.preferences);

      if (!mounted) return;

      final state = TourPlannerStateProvider.of(context);
      state.setDiscoveredDestinations(destinations);

      // Transition smoothly to recommendations page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DestinationRecommendationsPage(
            preferences: widget.preferences,
            destinations: destinations,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Discovery notice: $e'),
          backgroundColor: HelaColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final interestNames =
        widget.preferences.interests.map((i) => i.label).take(3).join(', ');

    return Scaffold(
      backgroundColor: HelaColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Animated Pulsing AI Orb
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        HelaColors.tertiaryFixed,
                        HelaColors.primaryContainer,
                        HelaColors.primary,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: HelaColors.tertiaryFixed.withValues(alpha: 0.4),
                        blurRadius: 36,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Title
              const Text(
                'Discovering Sri Lanka',
                style: TextStyle(
                  color: HelaColors.primary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 10),

              // Subtitle
              Text(
                'Crafting experiences for $interestNames and more...',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: HelaColors.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 36),

              // Animated step indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: HelaColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: HelaColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(HelaColors.primary),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _loadingSteps[_currentStep],
                          key: ValueKey<int>(_currentStep),
                          style: const TextStyle(
                            color: HelaColors.onSurface,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Progress bar
              LinearProgressIndicator(
                value: (_currentStep + 1) / _loadingSteps.length,
                backgroundColor: HelaColors.surfaceContainerHigh,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(HelaColors.primary),
                borderRadius: BorderRadius.circular(8),
                minHeight: 6,
              ),

              const Spacer(flex: 3),

              // Source Attribution pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: HelaColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded, size: 12, color: HelaColors.outline),
                    SizedBox(width: 6),
                    Text(
                      'Powered by Google Gemini AI & OpenStreetMap',
                      style: TextStyle(
                        color: HelaColors.outline,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
