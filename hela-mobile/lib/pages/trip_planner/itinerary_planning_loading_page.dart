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
/// Modern Lankan Tropical UI featuring:
/// - Minimal header with HELA branding pill and optional cancel control
/// - Elevated misty Ceylon landscape card (COAST -> Sigiriya -> HIGHLANDS)
/// - Trip brief summary chips echoing the user's selected days, budget & pace
/// - Structured AI Progress Card with percentage, progress bar & 3-stage pipeline
/// - Rotating Sri Lanka insider tip pill while DeepSeek AI builds the itinerary
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

  // Gentle ambient mist drift animation
  late final AnimationController _mistController;

  // Progress bar animation (0.0 to 1.0)
  late final AnimationController _progressController;

  // 3-dots bounce animation
  late final AnimationController _dotsController;

  // Status steps & tips ticker
  int _currentStepIndex = 0;
  int _currentTipIndex = 0;
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

  static const List<String> _insiderTips = [
    'Arrive at Sigiriya before 7:30 AM for golden light and quiet trails.',
    'The Kandy-to-Ella scenic train runs brightest on left-side seats.',
    'Sri Lanka has two monsoon seasons — sunny beaches are always nearby.',
    'Tap any stop in your itinerary later to adjust pace or save favorites.',
  ];

  TourPlan? _generatedPlan;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _beaconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _mistController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat(reverse: true);

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _progressController =
        AnimationController(vsync: this, duration: const Duration(seconds: 16))
          ..animateTo(
            0.92,
            duration: const Duration(seconds: 16),
            curve: Curves.easeOutCubic,
          );

    // Calmly rotate status steps & insider tips every 2.2s
    _stepTimer = Timer.periodic(const Duration(milliseconds: 2200), (_) {
      if (!_isDisposed && mounted) {
        setState(() {
          _currentStepIndex = (_currentStepIndex + 1) % _planningSteps.length;
          if (_currentStepIndex.isEven) {
            _currentTipIndex = (_currentTipIndex + 1) % _insiderTips.length;
          }
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

    // Smoothly complete the visual progress bar right before transitioning
    await _progressController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );

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
    _mistController.dispose();
    _progressController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  static const String _fontFamily = 'Plus Jakarta Sans';

  String _compactPlaceName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'Colombo';
    final codeMatch = RegExp(r'\(([A-Z]{3})\)').firstMatch(trimmed);
    if (codeMatch != null) return codeMatch.group(1)!;
    final firstPart = trimmed.split(',').first.trim();
    if (firstPart.length <= 16) return firstPart;
    return '${firstPart.substring(0, 14)}…';
  }

  String _formatBudgetLabel(String tier) {
    final lower = tier.toLowerCase();
    if (lower.startsWith('custom:')) {
      final amount = int.tryParse(lower.split(':').last);
      if (amount != null && amount > 0) return '\$$amount/day';
    }
    switch (lower) {
      case 'value':
        return 'Value';
      case 'luxury':
        return 'Luxury';
      case 'comfort':
      default:
        return 'Comfort';
    }
  }

  String _formatPaceLabel(String pace) {
    switch (pace.toLowerCase()) {
      case 'relaxed':
        return 'Relaxed';
      case 'active':
        return 'Active';
      case 'balanced':
      default:
        return 'Balanced';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);
    final isDark = colors.isDark;

    return Scaffold(
      backgroundColor: isDark ? colors.background : const Color(0xFFF1F9F7),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [
                    Color(0xFF0A1715),
                    Color(0xFF0F211E),
                    Color(0xFF132A25),
                  ]
                : const [
                    Color(0xFFF3FAF8),
                    Color(0xFFE7F5F2),
                    Color(0xFFDDF0EC),
                  ],
          ),
        ),
        child: SafeArea(
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontFamily: _fontFamily),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        child: Column(
                          children: [
                            // 1. Minimal Header with Branding & Close Safety
                            _buildTopBranding(colors),

                            const SizedBox(height: 18),

                            // 2. Elevated Scenic Ceylon Journey Card
                            _buildIslandLandscapeCard(colors),

                            const SizedBox(height: 22),

                            // 3. Headline & Bespoke Curation Subtitle
                            Text(
                              'Creating Your Journey...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: isDark
                                    ? colors.onSurface
                                    : const Color(0xFF093630),
                                fontFamily: _fontFamily,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Curating hidden tea trails, coastal tides\n& bespoke stops',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? colors.onSurfaceVariant
                                    : const Color(0xFF3E6862),
                                fontFamily: _fontFamily,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // 4. Compact Trip Brief Chips
                            _buildTripSummaryChips(colors),

                            const SizedBox(height: 18),

                            // 5. Elevated Live AI Progress & Pipeline Card
                            _buildPlanningProgressCard(colors),

                            const Spacer(),

                            const SizedBox(height: 16),

                            // 6. Calm Insider Travel Tip Banner
                            _buildTravelInsightBanner(colors),

                            const SizedBox(height: 6),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 1. TOP BRANDING & CANCEL SAFETY
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTopBranding(HelaColorPalette colors) {
    final isDark = colors.isDark;
    final accentColor = isDark ? colors.primary : const Color(0xFF0B5D56);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const SizedBox(width: 32),
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colors.surfaceContainer.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isDark
                          ? colors.outlineVariant.withValues(alpha: 0.5)
                          : const Color(0xFFC8E4DD),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'HELA AI • BESPOKE TOUR PLANNER',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.05,
                            color: isDark
                                ? colors.onSurface
                                : const Color(0xFF134E48),
                            fontFamily: _fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 32,
              height: 32,
              child: Material(
                color: isDark
                    ? colors.surfaceContainer.withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.8),
                shape: CircleBorder(
                  side: BorderSide(
                    color: isDark
                        ? colors.outlineVariant.withValues(alpha: 0.5)
                        : const Color(0xFFC8E4DD),
                  ),
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.maybePop(context),
                  child: Tooltip(
                    message: 'Cancel planning',
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: isDark
                          ? colors.onSurfaceVariant
                          : const Color(0xFF28554F),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HelaLogo(size: 24),
            const SizedBox(width: 8),
            Text(
              'HELA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 3.8,
                color: accentColor,
                fontFamily: _fontFamily,
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
    final isDark = colors.isDark;

    return Container(
      width: double.infinity,
      height: 222,
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark
              ? colors.outlineVariant.withValues(alpha: 0.45)
              : const Color(0xFFBFE2DA),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF0A4D46)).withValues(
              alpha: isDark ? 0.35 : 0.08,
            ),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Dawn / Twilight Sky Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const [
                          Color(0xFF0F2622),
                          Color(0xFF15342E),
                          Color(0xFF102A25),
                        ]
                      : const [
                          Color(0xFFECFAF6),
                          Color(0xFFD5EDE8),
                          Color(0xFFC1E2DC),
                        ],
                ),
              ),
            ),

            // Animated Layered Ceylon Landscape (Mist drift + Sigiriya + Ocean shimmer)
            AnimatedBuilder(
              animation: _mistController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _IslandLandscapePainter(
                    isDark: isDark,
                    mistShift: _mistController.value,
                  ),
                );
              },
            ),

            // Animated Route Trajectory Arc
            AnimatedBuilder(
              animation: _flightController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _FlightTrajectoryPainter(
                    progress: _flightController.value,
                    isDark: isDark,
                  ),
                );
              },
            ),

            // Subtle Route Duration Tag (Top-left inside canvas)
            Positioned(
              left: 16,
              top: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0xFF0B1C19) : Colors.white)
                      .withValues(alpha: 0.84),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: (isDark ? colors.outlineVariant : Colors.white)
                        .withValues(alpha: 0.7),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 12,
                      color: isDark ? colors.primary : const Color(0xFF0B5D56),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${widget.tripDays}-Day Island Route',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? colors.onSurface
                            : const Color(0xFF0F433D),
                        fontFamily: _fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Location Marker 1: COAST (Left)
            Positioned(
              left: 24,
              bottom: 34,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDark ? colors.primary : const Color(0xFF0B5D56),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.9),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF0B5D56,
                          ).withValues(alpha: 0.28),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Transform.rotate(
                      angle: -0.4,
                      child: Icon(
                        Icons.navigation_rounded,
                        size: 12,
                        color: isDark ? colors.onPrimary : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  _buildMapLocationPill(label: 'COAST', colors: colors),
                ],
              ),
            ),

            // Location Marker 2: HIGHLANDS (Right)
            Positioned(
              right: 24,
              top: 36,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _beaconController,
                    builder: (context, _) {
                      final scale = 1.0 + (_beaconController.value * 0.28);
                      return SizedBox(
                        width: 30,
                        height: 30,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(
                                    0xFFF59E0B,
                                  ).withValues(alpha: 0.26),
                                ),
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
                              width: 5.5,
                              height: 5.5,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  _buildMapLocationPill(label: 'HIGHLANDS', colors: colors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapLocationPill({
    required String label,
    required HelaColorPalette colors,
  }) {
    final isDark = colors.isDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF0A1A17) : Colors.white).withValues(
          alpha: 0.9,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? colors.outlineVariant.withValues(alpha: 0.5)
              : const Color(0xFFD5EBE5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.9,
          color: isDark ? colors.onSurface : const Color(0xFF0F433D),
          fontFamily: _fontFamily,
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 4. COMPACT TRIP SUMMARY CHIPS
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTripSummaryChips(HelaColorPalette colors) {
    final startLabel = _compactPlaceName(widget.startLocation);
    final endLabel = widget.endLocation.trim().isNotEmpty
        ? _compactPlaceName(widget.endLocation)
        : '';
    final routeText = (endLabel.isNotEmpty && endLabel != startLabel)
        ? '$startLabel → $endLabel'
        : startLabel;
    final guests = widget.adults + widget.children;
    final guestText =
        '${widget.tripDays}D · $guests Guest${guests == 1 ? '' : 's'}';
    final styleText =
        '${_formatBudgetLabel(widget.budgetTier)} · ${_formatPaceLabel(widget.pace)}';

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildBriefChip(
          icon: Icons.place_outlined,
          label: routeText,
          colors: colors,
        ),
        _buildBriefChip(
          icon: Icons.schedule_rounded,
          label: guestText,
          colors: colors,
        ),
        _buildBriefChip(
          icon: Icons.tune_rounded,
          label: styleText,
          colors: colors,
        ),
      ],
    );
  }

  Widget _buildBriefChip({
    required IconData icon,
    required String label,
    required HelaColorPalette colors,
  }) {
    final isDark = colors.isDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? colors.surfaceContainer.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? colors.outlineVariant.withValues(alpha: 0.5)
              : const Color(0xFFCDE5DF),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isDark ? colors.primary : const Color(0xFF0B5D56),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isDark ? colors.onSurface : const Color(0xFF17453F),
                fontFamily: _fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5. LIVE AI PROGRESS & 3-STAGE PIPELINE CARD
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildPlanningProgressCard(HelaColorPalette colors) {
    final isDark = colors.isDark;
    final primaryAccent = isDark ? colors.primary : const Color(0xFF0B5D56);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: isDark ? colors.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? colors.outlineVariant.withValues(alpha: 0.55)
              : const Color(0xFFD2E9E3),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF0A4D46)).withValues(
              alpha: isDark ? 0.28 : 0.06,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, _) {
          final rawProgress = _progressController.value.clamp(0.06, 1.0);
          final percent = (rawProgress * 100).round();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Ticker Header + Percentage Pill
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildStatusTicker(colors)),
                        const SizedBox(width: 4),
                        _buildPulsingDots(colors),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? colors.primary.withValues(alpha: 0.16)
                          : const Color(0xFFE7F6F2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$percent%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: primaryAccent,
                        fontFamily: _fontFamily,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Smooth Progress Track
              Container(
                width: double.infinity,
                height: 6,
                decoration: BoxDecoration(
                  color: isDark
                      ? colors.surfaceContainerHighest
                      : const Color(0xFFE1F1ED),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: rawProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF4AB9AA), colors.primary]
                              : const [Color(0xFF00443E), Color(0xFF148375)],
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),
              Divider(
                height: 1,
                color: isDark
                    ? colors.outlineVariant.withValues(alpha: 0.4)
                    : const Color(0xFFE8F3F0),
              ),
              const SizedBox(height: 12),

              // 3-Stage Pipeline Checklist
              _buildMilestoneRow(
                label: 'Analyzing weather, tides & optimal route',
                isDone: rawProgress >= 0.35,
                isActive: rawProgress < 0.35,
                colors: colors,
              ),
              const SizedBox(height: 9),
              _buildMilestoneRow(
                label: 'Selecting stays, dining & hidden gems',
                isDone: rawProgress >= 0.68,
                isActive: rawProgress >= 0.35 && rawProgress < 0.68,
                colors: colors,
              ),
              const SizedBox(height: 9),
              _buildMilestoneRow(
                label: 'Balancing daily pace, timing & insider tips',
                isDone: rawProgress >= 0.99,
                isActive: rawProgress >= 0.68 && rawProgress < 0.99,
                colors: colors,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMilestoneRow({
    required String label,
    required bool isDone,
    required bool isActive,
    required HelaColorPalette colors,
  }) {
    final isDark = colors.isDark;
    final activeColor = isDark ? colors.primary : const Color(0xFF0B5D56);

    return Row(
      children: [
        if (isDone)
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: activeColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 12,
              color: isDark ? colors.onPrimary : Colors.white,
            ),
          )
        else if (isActive)
          Container(
            width: 18,
            height: 18,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(activeColor),
            ),
          )
        else
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? colors.outline.withValues(alpha: 0.5)
                    : const Color(0xFFB7D4CD),
                width: 1.5,
              ),
            ),
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive || isDone
                  ? FontWeight.w600
                  : FontWeight.w500,
              color: isDone || isActive
                  ? (isDark ? colors.onSurface : const Color(0xFF103E38))
                  : (isDark
                        ? colors.onSurfaceVariant.withValues(alpha: 0.7)
                        : const Color(0xFF6B8E88)),
              fontFamily: _fontFamily,
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // DYNAMIC STATUS TICKER & PULSING 3-DOTS
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildStatusTicker(HelaColorPalette colors) {
    final isDark = colors.isDark;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.centerLeft,
          children: [...previousChildren, ?currentChild],
        );
      },
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.25),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        _planningSteps[_currentStepIndex],
        key: ValueKey<int>(_currentStepIndex),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.9,
          color: isDark ? colors.primary : const Color(0xFF134E48),
          fontFamily: _fontFamily,
        ),
      ),
    );
  }

  Widget _buildPulsingDots(HelaColorPalette colors) {
    final dotColor = colors.isDark ? colors.primary : const Color(0xFF0B5D56);
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, _) {
        final val = _dotsController.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final offset = index * 0.28;
            final progress = (val - offset) % 1.0;
            final opacity =
                0.3 + (math.sin(progress * math.pi) * 0.7).clamp(0.0, 0.7);
            final scale =
                0.8 + (math.sin(progress * math.pi) * 0.35).clamp(0.0, 0.35);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 4.5,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: dotColor.withValues(alpha: opacity),
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
  // 6. INSIDER TIP BANNER
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTravelInsightBanner(HelaColorPalette colors) {
    final isDark = colors.isDark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isDark
            ? colors.surfaceContainerLow.withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? colors.outlineVariant.withValues(alpha: 0.4)
              : const Color(0xFFCDE5DF),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: 15,
              color: isDark ? colors.goldenAmber : const Color(0xFFB45309),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _insiderTips[_currentTipIndex],
                key: ValueKey<int>(_currentTipIndex),
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? colors.onSurfaceVariant
                      : const Color(0xFF2D5953),
                  fontFamily: _fontFamily,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER: Atmospheric Ceylon Landscape with Sigiriya, Mist & Palms
// ────────────────────────────────────────────────────────────────────────────
class _IslandLandscapePainter extends CustomPainter {
  final bool isDark;
  final double mistShift;

  _IslandLandscapePainter({required this.isDark, required this.mistShift});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Warm Dawn Sun Glow behind the Highlands
    final sunCenter = Offset(size.width * 0.82, size.height * 0.24);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.26 : 0.34),
          const Color(0xFFF59E0B).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: 74));
    canvas.drawCircle(sunCenter, 74, glowPaint);

    // 2. Soft Far Mountain Range
    final farMountainPaint = Paint()
      ..color = (isDark ? const Color(0xFF1F453E) : const Color(0xFFA7D3CB))
          .withValues(alpha: isDark ? 0.65 : 0.52)
      ..style = PaintingStyle.fill;

    final farPath = Path()
      ..moveTo(0, size.height * 0.66)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.48,
        size.width * 0.48,
        size.height * 0.60,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.45,
        size.width,
        size.height * 0.58,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(farPath, farMountainPaint);

    // 3. Stepped Sigiriya Lion Rock Silhouette with subtle sun highlight
    final rockWidth = size.width * 0.34;
    final rockLeft = (size.width - rockWidth) / 2;
    final rockBase = size.height * 0.67;
    final rockTop = size.height * 0.38;

    final rockPath = Path()
      ..moveTo(rockLeft - 14, rockBase)
      ..lineTo(rockLeft + 4, rockBase - (rockBase - rockTop) * 0.42)
      ..lineTo(rockLeft + 10, rockBase - (rockBase - rockTop) * 0.46)
      ..quadraticBezierTo(
        rockLeft + 14,
        rockTop + 10,
        rockLeft + 22,
        rockTop + 2,
      )
      ..lineTo(rockLeft + rockWidth * 0.55, rockTop)
      ..lineTo(rockLeft + rockWidth - 20, rockTop + 3)
      ..quadraticBezierTo(
        rockLeft + rockWidth - 10,
        rockTop + 14,
        rockLeft + rockWidth - 4,
        rockBase - (rockBase - rockTop) * 0.36,
      )
      ..lineTo(rockLeft + rockWidth + 14, rockBase)
      ..close();

    final rockPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF2E635A), Color(0xFF1A3D37)]
                : const [Color(0xFF7BB0A8), Color(0xFF5C918A)],
          ).createShader(
            Rect.fromLTWH(rockLeft, rockTop, rockWidth, rockBase - rockTop),
          );
    canvas.drawPath(rockPath, rockPaint);

    // Sunlit right cliff facet on Sigiriya
    final highlightPath = Path()
      ..moveTo(rockLeft + rockWidth * 0.56, rockTop)
      ..lineTo(rockLeft + rockWidth - 20, rockTop + 3)
      ..quadraticBezierTo(
        rockLeft + rockWidth - 10,
        rockTop + 14,
        rockLeft + rockWidth - 4,
        rockBase - (rockBase - rockTop) * 0.36,
      )
      ..lineTo(rockLeft + rockWidth + 14, rockBase)
      ..lineTo(rockLeft + rockWidth * 0.56, rockBase)
      ..close();
    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = (isDark ? const Color(0xFF8ED3CA) : Colors.white).withValues(
          alpha: isDark ? 0.08 : 0.16,
        ),
    );

    // 4. Gently Drifting Mist Ribbon across Sigiriya Foothills
    final driftOffset = (mistShift - 0.5) * 18;
    final mistPaint = Paint()
      ..color = (isDark ? const Color(0xFF8ED3CA) : Colors.white).withValues(
        alpha: isDark ? 0.09 : 0.38,
      )
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.18 + driftOffset,
          size.height * 0.57,
          size.width * 0.58,
          10,
        ),
        const Radius.circular(999),
      ),
      mistPaint,
    );

    // 5. Lush Midground Hills
    final hillPaint1 = Paint()
      ..color = (isDark ? const Color(0xFF1C473F) : const Color(0xFF85BCB4))
          .withValues(alpha: isDark ? 0.8 : 0.58)
      ..style = PaintingStyle.fill;

    final hillPath1 = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.32,
        size.height * 0.59,
        size.width * 0.62,
        size.height * 0.69,
      )
      ..quadraticBezierTo(
        size.width * 0.84,
        size.height * 0.75,
        size.width,
        size.height * 0.65,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hillPath1, hillPaint1);

    // 6. Foreground Coastal Cove & Turquoise Shoreline
    final hillPaint2 = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xFF1A4E46), Color(0xFF10342F)]
                : const [Color(0xFF6BA69E), Color(0xFF4F8E86)],
          ).createShader(
            Rect.fromLTWH(
              0,
              size.height * 0.74,
              size.width,
              size.height * 0.26,
            ),
          );

    final hillPath2 = Path()
      ..moveTo(0, size.height * 0.80)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.72,
        size.width * 0.55,
        size.height * 0.79,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.85,
        size.width,
        size.height * 0.77,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hillPath2, hillPaint2);

    // Gentle shoreline shimmer ripples near Coast
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.14 : 0.32)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.90),
      Offset(size.width * 0.28, size.height * 0.90),
      wavePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.56, size.height * 0.92),
      Offset(size.width * 0.76, size.height * 0.92),
      wavePaint,
    );

    // 7. Tropical Palm Silhouettes
    _drawPalmTree(canvas, Offset(size.width * 0.14, size.height * 0.76), 27);
    _drawPalmTree(canvas, Offset(size.width * 0.21, size.height * 0.79), 20);
    _drawPalmTree(canvas, Offset(size.width * 0.84, size.height * 0.74), 24);
  }

  void _drawPalmTree(Canvas canvas, Offset base, double height) {
    final palmColor =
        (isDark ? const Color(0xFF7ABEB4) : const Color(0xFF356A63)).withValues(
          alpha: isDark ? 0.45 : 0.58,
        );
    final trunkPaint = Paint()
      ..color = palmColor
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final leafPaint = Paint()
      ..color = palmColor
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final trunkPath = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
        base.dx - 3,
        base.dy - (height * 0.6),
        base.dx + 2,
        base.dy - height,
      );
    canvas.drawPath(trunkPath, trunkPaint);

    final top = Offset(base.dx + 2, base.dy - height);
    for (int i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + (i - 2.5) * 0.48;
      final leafLen = height * 0.4;
      final leafEnd = Offset(
        top.dx + math.cos(angle) * leafLen,
        top.dy + math.sin(angle) * leafLen + 2.5,
      );
      final frond = Path()
        ..moveTo(top.dx, top.dy)
        ..quadraticBezierTo(
          top.dx + (leafEnd.dx - top.dx) * 0.5,
          top.dy - 3.5,
          leafEnd.dx,
          leafEnd.dy,
        );
      canvas.drawPath(frond, leafPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _IslandLandscapePainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.mistShift != mistShift;
  }
}

// ────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER: Animated Dashed Flight / Journey Path Arc
// ────────────────────────────────────────────────────────────────────────────
class _FlightTrajectoryPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _FlightTrajectoryPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final p0 = Offset(size.width * 0.14, size.height * 0.72);
    final p2 = Offset(size.width * 0.84, size.height * 0.24);
    final p1 = Offset(size.width * 0.46, size.height * 0.04);

    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..quadraticBezierTo(p1.dx, p1.dy, p2.dx, p2.dy);

    final lineColor = isDark
        ? const Color(0xFF8ED3CA)
        : const Color(0xFF0B5D56);

    final dashPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.58)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    _drawDashedPath(canvas, path, dashPaint, dashLength: 6.5, dashGap: 4.5);

    final t = progress;
    final bx =
        (1 - t) * (1 - t) * p0.dx + 2 * (1 - t) * t * p1.dx + t * t * p2.dx;
    final by =
        (1 - t) * (1 - t) * p0.dy + 2 * (1 - t) * t * p1.dy + t * t * p2.dy;
    final beaconPoint = Offset(bx, by);

    canvas.drawCircle(
      beaconPoint,
      10,
      Paint()..color = lineColor.withValues(alpha: 0.22),
    );
    canvas.drawCircle(beaconPoint, 4.5, Paint()..color = lineColor);
    canvas.drawCircle(beaconPoint, 1.8, Paint()..color = Colors.white);
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
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
