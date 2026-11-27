import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hela/models/destination.dart';
import 'package:hela/models/tour_plan.dart';
import 'package:hela/models/tour_preferences.dart';
import 'package:hela/pages/trip_planner/itinerary_details_page.dart';
import 'package:hela/services/ai_service.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/theme/hela_colors.dart';
import 'package:hela/widgets/common/hela_logo.dart';

/// Full-screen animated AI Itinerary Planning Loading Experience.
///
/// Faithfully reproduces the Lankan Tropical Modernism Stitch design:
/// - "• HELA AI • BESPOKE TOUR PLANNER" header with brand leaf emblem
/// - Scenic island landscape illustration with COAST, Sigiriya rock, HIGHLANDS
/// - Animated dashed trajectory arc with a traveling flight beacon
/// - "Creating Your Journey..." headline with bespoke curation subtitle
/// - Cycling real-time AI synthesis steps ("SELECTING SUNLIT COASTAL VILLAS...")
/// - Animated 3-dot pulse & smooth progress bar
/// - Transitions seamlessly to [ItineraryDetailsPage] upon AI completion
class ItineraryPlanningLoadingPage extends StatefulWidget {
  final String startLocation;
  final String endLocation;
  final DateTime startDate;
  final DateTime endDate;
  final int adults;
  final int children;
  final String budgetTier;
  final Set<String> interests;
  final String pace;
  final AccommodationType accommodationType;
  final String transportMode;
  final List<Destination> selectedDestinations;
  final Set<String> dietaryPreferences;
  final Set<String> accessibilityNeeds;
  final String extraNotes;
  final int tripDays;

  const ItineraryPlanningLoadingPage({
    super.key,
    required this.startLocation,
    this.endLocation = '',
    required this.startDate,
    required this.endDate,
    this.adults = 2,
    this.children = 0,
    this.budgetTier = 'comfort',
    this.interests = const {
      'Beaches',
      'Nature',
      'Culture',
      'Hikes & Adventure',
      'Authentic Food',
    },
    this.pace = 'balanced',
    this.accommodationType = AccommodationType.noPreference,
    this.transportMode = 'Private AC Car + Chauffeur',
    this.selectedDestinations = const [],
    this.dietaryPreferences = const {},
    this.accessibilityNeeds = const {},
    this.extraNotes = '',
    required this.tripDays,
  });

  @override
  State<ItineraryPlanningLoadingPage> createState() =>
      _ItineraryPlanningLoadingPageState();
}

class _ItineraryPlanningLoadingPageState
    extends State<ItineraryPlanningLoadingPage>
    with TickerProviderStateMixin {
  // Flight arc animation (dot moving from Coast to Highlands)
  late final AnimationController _flightController;

  // Beacon pulse animation (Highlands sun)
  late final AnimationController _beaconController;

  // Progress bar animation (0.0 to 1.0)
  late final AnimationController _progressController;

  // 3-dots bounce animation
  late final AnimationController _dotsController;

  // Status steps ticker
  int _currentStepIndex = 0;
  Timer? _stepTimer;
  Timer? _delayTimer;

  static const List<String> _planningSteps = [
    'CONNECTING TO DEEPSEEK AI PLANNER...',
    'ANALYZING MONSOON WEATHER & OCEAN TIDES...',
    'CURATING SCENIC ROUTES & HIDDEN GEMS...',
    'MATCHING STAYS TO YOUR BUDGET & PACE...',
    'OPTIMIZING TRANSIT TIMES & INSIDER TIPS...',
    'FINALIZING YOUR BESPOKE SRI LANKA EXPEDITION...',
  ];

  TourPlan? _generatedPlan;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _beaconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..forward();

    // Rotate status steps every 800ms
    _stepTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (!_isDisposed && mounted) {
        setState(() {
          _currentStepIndex = (_currentStepIndex + 1) % _planningSteps.length;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        _startGenerationPipeline();
      }
    });
  }

  BudgetLevel _mapBudgetTier(String tier) {
    final lower = tier.toLowerCase();
    if (lower.startsWith('custom:')) {
      final amount = int.tryParse(lower.split(':').last) ?? 120;
      if (amount <= 75) return BudgetLevel.low;
      if (amount >= 220) return BudgetLevel.high;
      return BudgetLevel.medium;
    }
    switch (lower) {
      case 'value':
        return BudgetLevel.low;
      case 'luxury':
        return BudgetLevel.high;
      case 'comfort':
      default:
        return BudgetLevel.medium;
    }
  }

  TravelPace _mapTravelPace(String pace) {
    switch (pace.toLowerCase()) {
      case 'relaxed':
        return TravelPace.relaxed;
      case 'active':
        return TravelPace.active;
      case 'balanced':
      default:
        return TravelPace.moderate;
    }
  }

  Set<TravelInterest> _mapInterests(Set<String> rawInterests) {
    final mapped = <TravelInterest>{};
    for (final raw in rawInterests) {
      final lower = raw.toLowerCase();
      if (lower.contains('beach')) {
        mapped.add(TravelInterest.beaches);
      } else if (lower.contains('wildlife') || lower.contains('safari')) {
        mapped.add(TravelInterest.wildlife);
      } else if (lower.contains('culture') ||
          lower.contains('heritage') ||
          lower.contains('ruin')) {
        mapped.add(TravelInterest.culture);
      } else if (lower.contains('hike') || lower.contains('adventure')) {
        mapped.add(TravelInterest.hiking);
        mapped.add(TravelInterest.adventure);
      } else if (lower.contains('food')) {
        mapped.add(TravelInterest.food);
      } else if (lower.contains('photo')) {
        mapped.add(TravelInterest.photography);
      } else if (lower.contains('ayurveda') || lower.contains('wellness')) {
        mapped.add(TravelInterest.relaxation);
      } else if (lower.contains('tea') || lower.contains('nature')) {
        mapped.add(TravelInterest.nature);
      }
    }
    return mapped.isNotEmpty
        ? mapped
        : {TravelInterest.nature, TravelInterest.culture};
  }

  void _startGenerationPipeline() async {
    final startTime = DateTime.now();
    final preferredLang = HelaAppStateProvider.of(context).selectedLanguage;

    TourPlan? aiTourPlan;
    try {
      final notesBuffer = <String>[];
      if (widget.budgetTier.toLowerCase().startsWith('custom:')) {
        final amount = int.tryParse(widget.budgetTier.split(':').last);
        if (amount != null && amount > 0) {
          notesBuffer.add('Target custom daily budget: \$$amount USD per day');
        }
      }
      if (widget.interests.isNotEmpty) {
        notesBuffer.add(
          'Preferred experiences: ${widget.interests.join(", ")}',
        );
      }
      if (widget.extraNotes.trim().isNotEmpty) {
        notesBuffer.add(widget.extraNotes.trim());
      }

      final prefs = TourPreferences(
        duration: TravelDuration.custom,
        customDays: widget.tripDays,
        startingLocationName: widget.startLocation,
        endLocationName: widget.endLocation,
        interests: _mapInterests(widget.interests),
        budgetLevel: _mapBudgetTier(widget.budgetTier),
        pace: _mapTravelPace(widget.pace),
        accommodationType: widget.accommodationType,
        transportMode: widget.transportMode,
        dietaryPreferences: widget.dietaryPreferences,
        accessibilityNeeds: widget.accessibilityNeeds,
        numberOfTravelers: widget.adults + widget.children,
        additionalNotes: notesBuffer.join(' | '),
      );

      aiTourPlan = await AIService()
          .generateTourPlan(
            preferences: prefs,
            selectedDestinations: widget.selectedDestinations,
            startDate: widget.startDate,
            endDate: widget.endDate,
            adults: widget.adults,
            children: widget.children,
            preferredLanguage: preferredLang,
          )
          .timeout(const Duration(seconds: 95));
    } catch (e) {
      debugPrint('[TripPlannerLoading] AI generation error: $e');
    }

    _generatedPlan = aiTourPlan;

    // Guarantee minimum animation display duration (3.2s) so user sees the delightful graphics
    final elapsed = DateTime.now().difference(startTime);
    const minDuration = Duration(milliseconds: 3200);
    if (elapsed < minDuration && !_isDisposed) {
      final completer = Completer<void>();
      _delayTimer = Timer(minDuration - elapsed, () {
        if (!completer.isCompleted) completer.complete();
      });
      await completer.future;
    }

    if (!mounted || _isDisposed) return;

    // Transition smoothly to Itinerary Details Page
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ItineraryDetailsPage(
              startLocation: widget.startLocation,
              startDate: widget.startDate,
              endDate: widget.endDate,
              adults: widget.adults,
              children: widget.children,
              budgetTier: widget.budgetTier,
              interests: widget.interests,
              pace: widget.pace,
              extraNotes: widget.extraNotes,
              aiTourPlan: _generatedPlan,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stepTimer?.cancel();
    _delayTimer?.cancel();
    _flightController.dispose();
    _beaconController.dispose();
    _progressController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF5F3), Color(0xFFDEF0EC), Color(0xFFD6EAE5)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // 1. Top Header Tracking & Branding
                _buildTopBranding(colors),

                const Spacer(flex: 1),

                // 2. Island Landscape Illustration Card with Animated Arc
                _buildIslandLandscapeCard(colors),

                const SizedBox(height: 28),

                // 3. Main Headline & Subtitle
                Text(
                  'Creating Your Journey...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: const Color(0xFF0C3833),
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Curating hidden tea trails, coastal tides\n& bespoke stops',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF3B635E),
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),

                const Spacer(flex: 2),

                // 4. Dynamic Status Ticker
                _buildStatusTicker(),

                const SizedBox(height: 12),

                // 5. Pulsing 3-Dots
                _buildPulsingDots(),

                const SizedBox(height: 16),

                // 6. Subtle Progress Bar
                _buildProgressBar(),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 1. TOP BRANDING
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTopBranding(HelaColorPalette colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF0B5D56),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'HELA AI • BESPOKE TOUR PLANNER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8,
                color: const Color(0xFF134E48),
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Brand Logo
            const HelaLogo(size: 26),
            const SizedBox(width: 8),
            Text(
              'HELA',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 4.0,
                color: const Color(0xFF0B5D56),
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 2. ISLAND LANDSCAPE ILLUSTRATION CARD
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildIslandLandscapeCard(HelaColorPalette colors) {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        color: const Color(0xFFC7E5DF).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFB0DBD3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B5D56).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Sky Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE2F3F0),
                    Color(0xFFCDE8E2),
                    Color(0xFFBBDDD6),
                  ],
                ),
              ),
            ),

            // Landscape Custom Painter (Hills, Sigiriya Silhouette, Palm trees)
            CustomPaint(painter: _IslandLandscapePainter()),

            // Animated Route Trajectory Arc
            AnimatedBuilder(
              animation: _flightController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _FlightTrajectoryPainter(
                    progress: _flightController.value,
                  ),
                );
              },
            ),

            // Location Marker 1: COAST (Left)
            Positioned(
              left: 28,
              bottom: 48,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Green pointer arrow
                  Transform.rotate(
                    angle: -0.4,
                    child: const Icon(
                      Icons.navigation_rounded,
                      size: 18,
                      color: Color(0xFF0B5D56),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Text(
                      'COAST',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Color(0xFF0F433D),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Location Marker 2: HIGHLANDS (Right)
            Positioned(
              right: 28,
              top: 52,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pulsing Golden Sun Beacon
                  AnimatedBuilder(
                    animation: _beaconController,
                    builder: (context, _) {
                      final scale = 1.0 + (_beaconController.value * 0.28);
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 24 * scale,
                            height: 24 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(
                                0xFFF59E0B,
                              ).withValues(alpha: 0.22),
                            ),
                          ),
                          Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD97706),
                            ),
                          ),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Text(
                      'HIGHLANDS',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Color(0xFF0F433D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 4. DYNAMIC STATUS TICKER
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildStatusTicker() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        _planningSteps[_currentStepIndex],
        key: ValueKey<int>(_currentStepIndex),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.3,
          color: Color(0xFF134E48),
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5. PULSING 3-DOTS
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildPulsingDots() {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, _) {
        final val = _dotsController.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final offset = index * 0.28;
            final progress = (val - offset) % 1.0;
            final opacity =
                0.3 + (math.sin(progress * math.pi) * 0.7).clamp(0.0, 0.7);
            final scale =
                0.8 + (math.sin(progress * math.pi) * 0.4).clamp(0.0, 0.4);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B5D56).withValues(alpha: opacity),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 6. SUBTLE PROGRESS BAR
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, _) {
        return Container(
          width: 140,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFFB5DAD3).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: _progressController.value.clamp(0.05, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0B5D56),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER: Island Landscape with Sigiriya & Layered Terrain
// ────────────────────────────────────────────────────────────────────────────
class _IslandLandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Central Sigiriya Lion Rock Silhouette (Subtle majestic plateau in mist)
    final rockPaint = Paint()
      ..color = const Color(0xFF6B9F98).withValues(alpha: 0.38)
      ..style = PaintingStyle.fill;

    final rockPath = Path();
    final rockWidth = size.width * 0.36;
    final rockLeft = (size.width - rockWidth) / 2;
    final rockBase = size.height * 0.62;
    final rockTop = size.height * 0.42;

    rockPath.moveTo(rockLeft - 8, rockBase);
    // Left cliff slope
    rockPath.quadraticBezierTo(
      rockLeft + 8,
      rockTop + 14,
      rockLeft + 18,
      rockTop,
    );
    // Plateau top
    rockPath.quadraticBezierTo(
      size.width * 0.5,
      rockTop - 2,
      rockLeft + rockWidth - 18,
      rockTop,
    );
    // Right cliff slope
    rockPath.quadraticBezierTo(
      rockLeft + rockWidth - 8,
      rockTop + 14,
      rockLeft + rockWidth + 8,
      rockBase,
    );
    rockPath.close();
    canvas.drawPath(rockPath, rockPaint);

    // 2. Distant Hill Ridge Layer
    final hillPaint1 = Paint()
      ..color = const Color(0xFF8FBDB6).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final hillPath1 = Path();
    hillPath1.moveTo(0, size.height * 0.72);
    hillPath1.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.58,
      size.width * 0.6,
      size.height * 0.68,
    );
    hillPath1.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.76,
      size.width,
      size.height * 0.64,
    );
    hillPath1.lineTo(size.width, size.height);
    hillPath1.lineTo(0, size.height);
    hillPath1.close();
    canvas.drawPath(hillPath1, hillPaint1);

    // 3. Foreground Coastal & Valley Layer
    final hillPaint2 = Paint()
      ..color = const Color(0xFF7AAFA7).withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    final hillPath2 = Path();
    hillPath2.moveTo(0, size.height * 0.82);
    hillPath2.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.74,
      size.width * 0.5,
      size.height * 0.80,
    );
    hillPath2.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.86,
      size.width,
      size.height * 0.78,
    );
    hillPath2.lineTo(size.width, size.height);
    hillPath2.lineTo(0, size.height);
    hillPath2.close();
    canvas.drawPath(hillPath2, hillPaint2);

    // 4. Stylized Palm Tree Silhouette (Left side near Coast)
    _drawPalmTree(canvas, Offset(size.width * 0.16, size.height * 0.74), 26);
    _drawPalmTree(canvas, Offset(size.width * 0.22, size.height * 0.77), 20);

    // 5. Stylized Highland Palm Tree (Right side near Highlands)
    _drawPalmTree(canvas, Offset(size.width * 0.82, size.height * 0.72), 24);
  }

  void _drawPalmTree(Canvas canvas, Offset base, double height) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF4C7E77).withValues(alpha: 0.45)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final leafPaint = Paint()
      ..color = const Color(0xFF4C7E77).withValues(alpha: 0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Curved trunk
    final trunkPath = Path();
    trunkPath.moveTo(base.dx, base.dy);
    trunkPath.quadraticBezierTo(
      base.dx - 3,
      base.dy - (height * 0.6),
      base.dx + 2,
      base.dy - height,
    );
    canvas.drawPath(trunkPath, trunkPaint);

    // Palm fronds (5 fronds radiating)
    final top = Offset(base.dx + 2, base.dy - height);
    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (i - 2) * 0.55;
      final leafLen = height * 0.38;
      final leafEnd = Offset(
        top.dx + math.cos(angle) * leafLen,
        top.dy + math.sin(angle) * leafLen + 2,
      );
      final frond = Path()
        ..moveTo(top.dx, top.dy)
        ..quadraticBezierTo(
          top.dx + (leafEnd.dx - top.dx) * 0.5,
          top.dy - 3,
          leafEnd.dx,
          leafEnd.dy,
        );
      canvas.drawPath(frond, leafPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER: Animated Dashed Flight / Journey Path Arc
// ────────────────────────────────────────────────────────────────────────────
class _FlightTrajectoryPainter extends CustomPainter {
  final double progress;

  _FlightTrajectoryPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final p0 = Offset(size.width * 0.17, size.height * 0.72); // Coast
    final p2 = Offset(size.width * 0.82, size.height * 0.28); // Highlands
    final p1 = Offset(
      size.width * 0.45,
      size.height * 0.05,
    ); // High apex above rock

    // Construct Quadratic Bézier Arc
    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..quadraticBezierTo(p1.dx, p1.dy, p2.dx, p2.dy);

    // Paint Dashed Arc Line
    final dashPaint = Paint()
      ..color = const Color(0xFF0B5D56).withValues(alpha: 0.65)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    _drawDashedPath(canvas, path, dashPaint, dashLength: 6.0, dashGap: 4.5);

    // Calculate Point along the Bézier curve for the traveling beacon
    final t = progress;
    final bx =
        (1 - t) * (1 - t) * p0.dx + 2 * (1 - t) * t * p1.dx + t * t * p2.dx;
    final by =
        (1 - t) * (1 - t) * p0.dy + 2 * (1 - t) * t * p1.dy + t * t * p2.dy;
    final beaconPoint = Offset(bx, by);

    // Draw Traveling Glowing Beacon
    final glowPaint = Paint()
      ..color = const Color(0xFF0B5D56).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(beaconPoint, 8, glowPaint);

    final dotPaint = Paint()
      ..color = const Color(0xFF074540)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(beaconPoint, 3.5, dotPaint);

    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(beaconPoint, 1.5, innerPaint);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLength,
    required double dashGap,
  }) {
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = math.min(dashLength, metric.length - distance);
        final extractPath = metric.extractPath(distance, distance + len);
        canvas.drawPath(extractPath, paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FlightTrajectoryPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
