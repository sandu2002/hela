import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hela/data/sri_lanka_images.dart';
import 'package:hela/models/destination.dart';
import 'package:hela/models/tour_preferences.dart';
import 'package:hela/pages/trip_planner/itinerary_planning_loading_page.dart';
import 'package:hela/services/place_service.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/theme/hela_colors.dart';
import 'package:hela/widgets/navigation/hela_bottom_nav_bar.dart';
import 'package:hela/widgets/common/hela_network_image.dart';

/// Trip Planner Page - 100% matched to Google Stitch Design
/// (Screen 1b1afbb5b8884b4e8ceaf12ac9c68d70: Plan Your Sri Lankan Adventure
///  & Screen d48a0b4b55994a0d876eccbe5db39ab5: Your Sri Lankan Adventure)
class TripPlannerPage extends StatefulWidget {
  final String? initialExtraNote;

  const TripPlannerPage({super.key, this.initialExtraNote});

  @override
  State<TripPlannerPage> createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends State<TripPlannerPage> {
  static const String _fontFamily = 'Plus Jakarta Sans';

  // Form State
  String? _activeQuickPresetId;
  final TextEditingController _startLocationController = TextEditingController(
    text: 'Bandaranaike Intl Airport (CMB)',
  );
  final TextEditingController _endLocationController = TextEditingController(
    text: 'Bandaranaike Intl Airport (CMB)',
  );
  final TextEditingController _customStopController = TextEditingController();
  final TextEditingController _extraNotesController = TextEditingController();
  bool _returnToStart = true;

  void _applyQuickPreset({
    required String id,
    required int days,
    required Set<String> interests,
    required String pace,
    required String budgetTier,
  }) {
    final start = _startDate.isBefore(_today)
        ? _today.add(const Duration(days: 7))
        : _startDate;
    setState(() {
      _activeQuickPresetId = id;
      _startDate = start;
      _endDate = start.add(Duration(days: days));
      _selectedInterests
        ..clear()
        ..addAll(interests);
      _selectedPace = pace;
      _selectedBudgetTier = budgetTier;
      _returnToStart = true;
    });
  }

  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _startDate = today.add(const Duration(days: 7));
    _endDate = _startDate.add(const Duration(days: 10));
    if (widget.initialExtraNote != null &&
        widget.initialExtraNote!.trim().isNotEmpty) {
      _extraNotesController.text = widget.initialExtraNote!.trim();
    }
  }

  int _adults = 2;
  int _children = 0;

  // Budget Tier: 'value', 'comfort', 'luxury', 'custom'
  String _selectedBudgetTier = 'comfort';
  int _customDailyBudget = 120;
  final TextEditingController _customBudgetController = TextEditingController(
    text: '120',
  );

  String get _effectiveBudgetTier => _selectedBudgetTier == 'custom'
      ? 'custom:$_customDailyBudget'
      : _selectedBudgetTier;

  String get _customBudgetStyleHint {
    if (_customDailyBudget <= 75) return 'Guesthouses & scenic trains';
    if (_customDailyBudget <= 180) return 'Boutique villas & private AC car';
    if (_customDailyBudget <= 320) return 'Upscale resorts & chauffeur-guide';
    return '5-star luxury & bespoke transfers';
  }

  // Multi-select Travel Interests
  final Set<String> _selectedInterests = {
    'Beaches',
    'Nature',
    'Culture',
    'Hikes & Adventure',
    'Authentic Food',
  };

  // Travel Pace: 'relaxed', 'balanced', 'active'
  String _selectedPace = 'balanced';

  // Preferred Transport Mode
  String _selectedTransportMode = 'Private AC Car + Chauffeur';

  // Accommodation Style
  AccommodationType _selectedAccommodationType = AccommodationType.noPreference;

  // Must-Visit Destination IDs (from curated list) & Custom Stops
  final Set<String> _selectedDestinationIds = {};
  final List<String> _customMustVisitStops = [];

  // Hard Constraints for AI Routing
  final Set<String> _selectedDietary = {};
  final Set<String> _selectedAccessibility = {};

  static const List<Map<String, dynamic>> _transportOptions = [
    {
      'id': 'Private AC Car + Chauffeur',
      'title': 'Private AC Car',
      'subtitle': 'Chauffeur-guide · Flexible stops',
      'icon': Icons.directions_car_rounded,
    },
    {
      'id': 'Scenic Train + Tuk-Tuk Mix',
      'title': 'Train + Tuk-Tuk',
      'subtitle': 'Kandy–Ella scenic rail & hops',
      'icon': Icons.train_rounded,
    },
    {
      'id': 'Self-Drive Tuk-Tuk / Scooter',
      'title': 'Self-Drive Tuk-Tuk',
      'subtitle': 'Independent island adventure',
      'icon': Icons.electric_rickshaw_rounded,
    },
    {
      'id': 'Public Bus & Express Train',
      'title': 'Bus & Rail',
      'subtitle': 'Budget local public transit',
      'icon': Icons.directions_bus_rounded,
    },
    {
      'id': 'Luxury Van / Seaplane Mix',
      'title': 'Luxury Van / Air',
      'subtitle': 'VIP group or domestic flights',
      'icon': Icons.flight_rounded,
    },
  ];

  static const List<String> _dietaryOptions = [
    'Vegetarian',
    'Vegan',
    'Halal',
    'Gluten-Free',
    'Seafood Allergy',
    'Kid-Friendly Food',
  ];

  static const List<String> _accessibilityOptions = [
    'Minimal Stairs / Step-Free',
    'Senior-Friendly Pace',
    'Stroller / Toddler Friendly',
    'Avoid Long Drives (>3h)',
  ];

  static const List<String> _quickPromptChips = [
    'Honeymoon romantic spots',
    'Golden hour photography',
    'Avoid early 5 AM starts',
    'Good Wi-Fi for remote work',
  ];

  // Available Interests Data
  final List<Map<String, String>> _allInterests = const [
    {'label': 'Beaches', 'emoji': '🏖️'},
    {'label': 'Nature', 'emoji': '🌿'},
    {'label': 'Wildlife Safaris', 'emoji': '🐘'},
    {'label': 'Culture', 'emoji': '🏛️'},
    {'label': 'Heritage Ruins', 'emoji': '📜'},
    {'label': 'Hikes & Adventure', 'emoji': '🧗'},
    {'label': 'Authentic Food', 'emoji': '🍛'},
    {'label': 'Photography', 'emoji': '📸'},
    {'label': 'Ayurveda & Wellness', 'emoji': '🧘'},
    {'label': 'Ceylon Tea Trails', 'emoji': '☕'},
  ];

  @override
  void dispose() {
    _startLocationController.dispose();
    _endLocationController.dispose();
    _customStopController.dispose();
    _extraNotesController.dispose();
    _customBudgetController.dispose();
    super.dispose();
  }

  int get _tripDays {
    final diff = _endDate.difference(_startDate).inDays;
    return diff > 0 ? diff : 1;
  }

  String get _partyDescription {
    final total = _adults + _children;
    if (total == 1) return 'Solo Explorer';
    if (total == 2 && _children == 0) return 'Couple / Duo';
    if (total > 2 && _children > 0) return 'Family Party';
    return 'Group Journey';
  }

  static const List<String> _shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _fullMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  String _formatShortDate(DateTime date) =>
      '${_shortMonths[date.month - 1]} ${date.day}, ${date.year}';

  String _seasonalTip(int month) {
    final monthName = _fullMonths[month - 1];
    if (month == 12 || month <= 4) {
      return '$monthName is peak dry season for South-West beaches, Hill Country & Yala safaris.';
    } else if (month >= 5 && month <= 9) {
      return '$monthName is ideal for sunny East Coast beaches, Trincomalee & Arugam Bay.';
    } else {
      return '$monthName brings lush green tea hills & great wildlife sightings across reserves.';
    }
  }

  Widget _buildDatePickerTheme(BuildContext context, Widget? child) {
    final colors = HelaColors.of(context);
    final isDark = colors.brightness == Brightness.dark;
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme(
          brightness: colors.brightness,
          primary: colors.primary,
          onPrimary: colors.onPrimary,
          secondary: colors.secondary,
          onSecondary: colors.onSecondary,
          error: colors.error,
          onError: colors.onError,
          surface: colors.cardBackground,
          onSurface: colors.onSurface,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: isDark
              ? colors.surfaceContainer
              : colors.cardBackground,
        ),
      ),
      child: child!,
    );
  }

  Future<void> _pickDateRange() async {
    final firstDate = _today;
    final lastDate = firstDate.add(const Duration(days: 730));
    final initialStart = _startDate.isBefore(firstDate)
        ? firstDate
        : _startDate;
    final rawEnd = _endDate.isAfter(initialStart)
        ? _endDate
        : initialStart.add(const Duration(days: 1));
    final initialEnd = rawEnd.isAfter(lastDate) ? lastDate : rawEnd;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
      helpText: 'SELECT TRAVEL DATES',
      builder: _buildDatePickerTheme,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end.isAfter(picked.start)
            ? picked.end
            : picked.start.add(const Duration(days: 1));
      });
    }
  }

  Future<void> _pickArrivalDate() async {
    final firstDate = _today;
    final lastDate = firstDate.add(const Duration(days: 730));
    final initialDate = _startDate.isBefore(firstDate) ? firstDate : _startDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(lastDate) ? lastDate : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'SELECT ARRIVAL DATE',
      builder: _buildDatePickerTheme,
    );

    if (picked != null) {
      setState(() {
        final currentDuration = _tripDays;
        _startDate = picked;
        if (!_endDate.isAfter(_startDate)) {
          _endDate = _startDate.add(Duration(days: currentDuration));
        }
      });
    }
  }

  Future<void> _pickDepartureDate() async {
    final firstDate = _startDate.add(const Duration(days: 1));
    final lastDate = _today.add(const Duration(days: 731));
    final initialDate = _endDate.isBefore(firstDate) ? firstDate : _endDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(lastDate) ? lastDate : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'SELECT DEPARTURE DATE',
      builder: _buildDatePickerTheme,
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  List<Destination> _buildSelectedDestinations() {
    final curated = PlaceService.curatedSriLankaPlaces
        .where((d) => _selectedDestinationIds.contains(d.sourceId))
        .toList();
    final custom = _customMustVisitStops.map((name) {
      return Destination(
        sourceId:
            'custom_${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}',
        name: name,
        description: 'Traveler requested must-visit stop in Sri Lanka',
        latitude: 7.8731,
        longitude: 80.7718,
        region: 'Sri Lanka',
        categories: const ['Custom Stop'],
      );
    });
    return [...curated, ...custom];
  }

  String get _effectiveEndLocation {
    final start = _startLocationController.text.trim();
    if (_returnToStart) return start;
    final end = _endLocationController.text.trim();
    return end.isNotEmpty ? end : start;
  }

  void _addCustomMustVisitStop() {
    final raw = _customStopController.text.trim();
    if (raw.isEmpty) return;
    final exists = _customMustVisitStops.any(
      (s) => s.toLowerCase() == raw.toLowerCase(),
    );
    setState(() {
      if (!exists) _customMustVisitStops.add(raw);
      _customStopController.clear();
    });
  }

  void _triggerGenerate() {
    final start = _startLocationController.text.trim();
    if (start.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a starting location for your AI route.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ItineraryPlanningLoadingPage(
              startLocation: start,
              endLocation: _effectiveEndLocation,
              startDate: _startDate,
              endDate: _endDate,
              adults: _adults,
              children: _children,
              budgetTier: _effectiveBudgetTier,
              interests: _selectedInterests,
              pace: _selectedPace,
              accommodationType: _selectedAccommodationType,
              transportMode: _selectedTransportMode,
              selectedDestinations: _buildSelectedDestinations(),
              dietaryPreferences: _selectedDietary,
              accessibilityNeeds: _selectedAccessibility,
              extraNotes: _extraNotesController.text,
              tripDays: _tripDays,
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
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  Widget _buildNetworkImage(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return HelaNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF004D40), Color(0xFF00251A)],
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.landscape_rounded,
            color: Color(0xFF6EE7B7),
            size: 32,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopAppBar(HelaColorPalette colors, bool isDark) {
    final canPop = Navigator.canPop(context);
    return AppBar(
      backgroundColor: isDark ? colors.background : const Color(0xFFF3FAF7),
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 58,
      titleSpacing: canPop ? 0 : 16,
      automaticallyImplyLeading: false,
      leading: canPop
          ? Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Center(
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.cardBackground,
                      border: Border.all(
                        color: colors.architecturalBorder.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: colors.onSurface,
                      size: 19,
                    ),
                  ),
                ),
              ),
            )
          : null,
      title: Text(
        HelaAppStateProvider.of(context).tr('trip_planner'),
        style: TextStyle(
          color: colors.onSurface,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.7,
          fontFamily: _fontFamily,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);
    final isDark = colors.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? colors.background : const Color(0xFFF3FAF7),
      appBar: _buildTopAppBar(colors, isDark),
      body: SafeArea(
        top: false,
        bottom: false,
        child: DefaultTextStyle.merge(
          style: const TextStyle(fontFamily: _fontFamily),
          child: Column(
            children: [
              Expanded(child: _buildPlannerFormView(colors)),
              _buildStickyGenerateBar(colors),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const HelaBottomNavBar(currentIndex: 2),
    );
  }

  // ==========================================
  // CLEAN MINIMAL PLANNER FORM VIEW
  // ==========================================
  Widget _buildPlannerFormView(HelaColorPalette colors) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 22),
      child: Center(
        heightFactor: 1.0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compact Clean Hero Banner
              _buildHeroShowcaseBanner(colors),
              const SizedBox(height: 12),

              // One-Tap Quick Tour Presets (Simple 1-click planning)
              _buildQuickTripPresets(colors),
              const SizedBox(height: 16),

              // Card 1: Where & When (Origin, Drop-off & Travel Dates)
              _buildRouteAndDatesCard(colors),
              const SizedBox(height: 14),

              // Card 2: Travelers & Budget (Compact Stepper + 4-Segment Budget Bar)
              _buildPartyAndBudgetCard(colors),
              const SizedBox(height: 14),

              // Card 3: Pace & Travel Interests
              _buildPaceAndInterestsCard(colors),
              const SizedBox(height: 18),

              // Calm Eyebrow Label for Optional Details
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'OPTIONAL FINE-TUNING',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                    color: colors.onSurfaceVariant,
                    fontFamily: _fontFamily,
                  ),
                ),
              ),

              // Card 4: Clean Grouped Optional Details
              _buildOptionalCustomizationCard(colors),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _minimalCardDecoration(HelaColorPalette colors) {
    final isDark = colors.brightness == Brightness.dark;
    return BoxDecoration(
      color: colors.cardBackground,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark
            ? colors.outlineVariant.withValues(alpha: 0.5)
            : const Color(0xFFD7EBE5),
      ),
      boxShadow: [
        BoxShadow(
          color: (isDark ? Colors.black : const Color(0xFF0A4D46)).withValues(
            alpha: isDark ? 0.22 : 0.04,
          ),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildHeroShowcaseBanner(HelaColorPalette colors) {
    return Container(
      height: 144,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildNetworkImage(SriLankaImages.sigiriya),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.55, 1.0],
                  colors: [
                    const Color(0xFF003B34).withValues(alpha: 0.92),
                    const Color(0xFF003B34).withValues(alpha: 0.52),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    HelaAppStateProvider.of(context).tr('plan_your_adventure'),
                    style: const TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.18,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    HelaAppStateProvider.of(context).tr('planner_subtitle'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                      fontFamily: _fontFamily,
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

  Widget _buildQuickTripPresets(HelaColorPalette colors) {
    final presets = [
      (
        id: 'south_5d',
        emoji: '🏖️',
        title: '5D Coast & Culture',
        days: 5,
        interests: {'Beaches', 'Culture', 'Authentic Food'},
        pace: 'relaxed',
        budget: 'comfort',
      ),
      (
        id: 'tea_7d',
        emoji: '⛰️',
        title: '7D Tea & Heritage',
        days: 7,
        interests: {
          'Nature',
          'Culture',
          'Ceylon Tea Trails',
          'Hikes & Adventure',
        },
        pace: 'balanced',
        budget: 'comfort',
      ),
      (
        id: 'grand_10d',
        emoji: '🏝️',
        title: '10D Classic Island',
        days: 10,
        interests: {
          'Beaches',
          'Nature',
          'Wildlife Safaris',
          'Culture',
          'Authentic Food',
        },
        pace: 'balanced',
        budget: 'comfort',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Templates',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: colors.onSurfaceVariant,
            fontFamily: _fontFamily,
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: presets.map((p) {
              final isSelected = _activeQuickPresetId == p.id;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => _applyQuickPreset(
                    id: p.id,
                    days: p.days,
                    interests: p.interests,
                    pace: p.pace,
                    budgetTier: p.budget,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.primary
                          : colors.cardBackground,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isSelected
                            ? colors.primary
                            : colors.architecturalBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(p.emoji, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        Text(
                          p.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? colors.onPrimary
                                : colors.onSurface,
                            fontFamily: _fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // CARD 1: ROUTE & DATES (UNIFIED CLEAN CARD)
  // ==========================================
  Widget _buildRouteAndDatesCard(HelaColorPalette colors) {
    final isDark = colors.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _minimalCardDecoration(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Starting Location Header
          Text(
            HelaAppStateProvider.of(context).tr('starting_location'),
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
              fontFamily: _fontFamily,
            ),
          ),
          const SizedBox(height: 8),

          // Minimal Input Surface
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? colors.surfaceContainerLow
                  : const Color(0xFFF3FAF7),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: isDark
                    ? colors.outlineVariant.withValues(alpha: 0.4)
                    : const Color(0xFFD5EBE4),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.place_rounded, size: 18, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: const InputDecorationTheme(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                      ),
                    ),
                    child: TextField(
                      controller: _startLocationController,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () {
                    setState(
                      () => _startLocationController.text =
                          'Bandaranaike Intl Airport (CMB)',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Set to current location: Bandaranaike Airport (CMB)',
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.my_location_rounded,
                      size: 18,
                      color: colors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Clean Location Quick Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildLocationQuickPill(
                  'CMB Airport',
                  Icons.flight_land_rounded,
                  'Bandaranaike Airport (CMB)',
                  colors,
                ),
                const SizedBox(width: 6),
                _buildLocationQuickPill(
                  'Colombo Fort',
                  Icons.train_rounded,
                  'Colombo Fort Railway Station',
                  colors,
                ),
                const SizedBox(width: 6),
                _buildLocationQuickPill(
                  'Kandy',
                  Icons.temple_buddhist_rounded,
                  'Kandy City Center',
                  colors,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Compact Trip Ending / Drop-off Row
          Row(
            children: [
              Icon(
                Icons.flag_outlined,
                size: 15,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Trip Ending / Drop-off',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              InkWell(
                onTap: () => setState(() => _returnToStart = !_returnToStart),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _returnToStart
                        ? colors.primary.withValues(alpha: isDark ? 0.2 : 0.1)
                        : colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _returnToStart ? 'Round-Trip Loop' : 'Custom End',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!_returnToStart) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _endLocationController,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Galle Fort, Trincomalee, CMB Airport',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                filled: true,
                fillColor: isDark
                    ? colors.surfaceContainerLow
                    : const Color(0xFFF3FAF7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: colors.architecturalBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: colors.architecturalBorder),
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: colors.architecturalBorder.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 14),

          // Travel Dates Row
          Row(
            children: [
              Expanded(
                child: Text(
                  HelaAppStateProvider.of(context).tr('travel_dates'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _pickDateRange,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(
                      alpha: isDark ? 0.18 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_tripDays Days',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.edit_calendar_rounded,
                        size: 12,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Minimal Unified 2-Column Date Picker Tray
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? colors.surfaceContainerLow
                  : const Color(0xFFF3FAF7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? colors.outlineVariant.withValues(alpha: 0.4)
                    : const Color(0xFFD5EBE4),
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickArrivalDate,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ARRIVAL',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _formatShortDate(_startDate),
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  VerticalDivider(
                    width: 18,
                    thickness: 1,
                    color: colors.architecturalBorder.withValues(alpha: 0.65),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: _pickDepartureDate,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DEPARTURE',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _formatShortDate(_endDate),
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.wb_sunny_outlined,
                size: 13,
                color: colors.goldenAmber,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  _seasonalTip(_startDate.month),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationQuickPill(
    String label,
    IconData icon,
    String targetValue,
    HelaColorPalette colors, {
    TextEditingController? targetController,
  }) {
    final ctrl = targetController ?? _startLocationController;
    final isDark = colors.brightness == Brightness.dark;
    return InkWell(
      onTap: () => setState(() => ctrl.text = targetValue),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDark
              ? colors.surfaceContainerHighest
              : const Color(0xFFE7F5F0),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: colors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // CARD 2: PARTY & BUDGET (COMPACT SEGMENTED)
  // ==========================================
  Widget _buildPartyAndBudgetCard(HelaColorPalette colors) {
    final isDark = colors.brightness == Brightness.dark;
    final budgetTiers = [
      (id: 'value', label: 'Value', price: r'~$55/d'),
      (id: 'comfort', label: 'Comfort', price: r'~$140/d'),
      (id: 'luxury', label: 'Luxury', price: r'~$260/d'),
      (id: 'custom', label: 'Custom', price: '\$$_customDailyBudget/d'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _minimalCardDecoration(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Travel Party Row
          Row(
            children: [
              Expanded(
                child: Text(
                  HelaAppStateProvider.of(context).tr('travel_party'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(
                      alpha: isDark ? 0.18 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_adults + _children} • $_partyDescription',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Minimal Compact Steppers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? colors.surfaceContainerLow
                  : const Color(0xFFF3FAF7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildCompactCounter(
                    label: 'Adults',
                    value: _adults,
                    onDec: () {
                      if (_adults > 1) setState(() => _adults--);
                    },
                    onInc: () => setState(() => _adults++),
                    colors: colors,
                  ),
                ),
                Container(
                  width: 1,
                  height: 26,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: colors.architecturalBorder.withValues(alpha: 0.65),
                ),
                Expanded(
                  child: _buildCompactCounter(
                    label: 'Children',
                    value: _children,
                    onDec: () {
                      if (_children > 0) setState(() => _children--);
                    },
                    onInc: () => setState(() => _children++),
                    colors: colors,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: colors.architecturalBorder.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 14),

          // Travel Budget Header
          Text(
            HelaAppStateProvider.of(context).tr('travel_budget'),
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 10),

          // Clean 4-Segment Budget Bar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? colors.surfaceContainerLow
                  : const Color(0xFFF1F8F5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? colors.outlineVariant.withValues(alpha: 0.35)
                    : const Color(0xFFDCEEE8),
              ),
            ),
            child: Row(
              children: budgetTiers.map((tier) {
                final selected = _selectedBudgetTier == tier.id;
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedBudgetTier = tier.id),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? colors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tier.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? colors.onPrimary
                                  : colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            tier.price,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? colors.onPrimary.withValues(alpha: 0.85)
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          if (_selectedBudgetTier == 'custom')
            _buildCustomBudgetControls(colors),
        ],
      ),
    );
  }

  Widget _buildCompactCounter({
    required String label,
    required int value,
    required VoidCallback onDec,
    required VoidCallback onInc,
    required HelaColorPalette colors,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStepperBtn(
              icon: Icons.remove_rounded,
              onTap: onDec,
              colors: colors,
              isPrimary: false,
            ),
            SizedBox(
              width: 22,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
            ),
            _buildStepperBtn(
              icon: Icons.add_rounded,
              onTap: onInc,
              colors: colors,
              isPrimary: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepperBtn({
    required IconData icon,
    required VoidCallback onTap,
    required HelaColorPalette colors,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isPrimary ? colors.primary : colors.cardBackground,
          shape: BoxShape.circle,
          border: isPrimary
              ? null
              : Border.all(color: colors.architecturalBorder),
        ),
        child: Icon(
          icon,
          size: 14,
          color: isPrimary ? colors.onPrimary : colors.primary,
        ),
      ),
    );
  }

  // ==========================================
  // CARD 3: PACE & TRAVEL INTERESTS
  // ==========================================
  Widget _buildPaceAndInterestsCard(HelaColorPalette colors) {
    final isDark = colors.brightness == Brightness.dark;
    final paces = [
      (id: 'relaxed', label: 'Relaxed', icon: Icons.spa_outlined),
      (id: 'balanced', label: 'Balanced', icon: Icons.tune_rounded),
      (id: 'active', label: 'Active', icon: Icons.directions_run_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _minimalCardDecoration(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            HelaAppStateProvider.of(context).tr('pace_travel_style'),
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 10),

          // Slim 3-Segment Pace Pill Strip
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? colors.surfaceContainerLow
                  : const Color(0xFFF1F8F5),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: paces.map((p) {
                final isSelected = _selectedPace == p.id;
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedPace = p.id),
                    borderRadius: BorderRadius.circular(9),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            p.icon,
                            size: 14,
                            color: isSelected
                                ? colors.onPrimary
                                : colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              p.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? colors.onPrimary
                                    : colors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: colors.architecturalBorder.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Text(
                  HelaAppStateProvider.of(context).tr('travel_interests'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_selectedInterests.length} Selected',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: _allInterests.map((interest) {
              final label = interest['label']!;
              final emoji = interest['emoji']!;
              final isSelected = _selectedInterests.contains(label);

              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedInterests.remove(label);
                    } else {
                      _selectedInterests.add(label);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(999),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6.5,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary
                        : (isDark
                              ? colors.surfaceContainerLow
                              : const Color(0xFFF5FAF8)),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSelected
                          ? colors.primary
                          : colors.architecturalBorder.withValues(alpha: 0.75),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 12.5)),
                      const SizedBox(width: 5),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? colors.onPrimary
                              : colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CARD 4: OPTIONAL FINE-TUNING (CLEAN GROUPED)
  // ==========================================
  Widget _buildOptionalCustomizationCard(HelaColorPalette colors) {
    final isDark = colors.brightness == Brightness.dark;
    final totalPinned =
        _selectedDestinationIds.length + _customMustVisitStops.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _minimalCardDecoration(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transport Mode
          Text(
            'Preferred Transport Mode',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: _transportOptions.map((option) {
              final id = option['id'] as String;
              final title = option['title'] as String;
              final icon = option['icon'] as IconData;
              final isSelected = _selectedTransportMode == id;

              return _buildSelectableChip(
                label: title,
                selected: isSelected,
                colors: colors,
                icon: icon,
                onTap: () => setState(() => _selectedTransportMode = id),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: colors.architecturalBorder.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 14),

          // Accommodation Style
          Text(
            'Accommodation Style',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: AccommodationType.values.map((type) {
              return _buildSelectableChip(
                label: type.label,
                selected: _selectedAccommodationType == type,
                colors: colors,
                onTap: () => setState(() => _selectedAccommodationType = type),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: colors.architecturalBorder.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 14),

          // Must-Visit Places
          Row(
            children: [
              Expanded(
                child: Text(
                  'Must-Visit Places (Optional)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                totalPinned == 0 ? 'AI Chooses' : '$totalPinned Pinned',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              ...PlaceService.curatedSriLankaPlaces.take(6).map((place) {
                final isSelected = _selectedDestinationIds.contains(
                  place.sourceId,
                );
                return _buildSelectableChip(
                  label: place.name,
                  selected: isSelected,
                  colors: colors,
                  icon: Icons.place_outlined,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedDestinationIds.remove(place.sourceId);
                      } else {
                        _selectedDestinationIds.add(place.sourceId);
                      }
                    });
                  },
                );
              }),
              ..._customMustVisitStops.map((stop) {
                return InputChip(
                  label: Text(
                    stop,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: colors.onPrimary,
                    ),
                  ),
                  selected: true,
                  selectedColor: colors.primary,
                  deleteIconColor: colors.onPrimary,
                  onDeleted: () {
                    setState(() => _customMustVisitStops.remove(stop));
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customStopController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addCustomMustVisitStop(),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add custom stop (e.g. Jaffna, Arugam Bay)',
                    hintStyle: TextStyle(
                      fontSize: 11.5,
                      color: colors.onSurfaceVariant,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? colors.surfaceContainerLow
                        : const Color(0xFFF3FAF7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: BorderSide(color: colors.architecturalBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: BorderSide(color: colors.architecturalBorder),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 38,
                child: FilledButton.tonalIcon(
                  onPressed: _addCustomMustVisitStop,
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary.withValues(
                      alpha: isDark ? 0.2 : 0.12,
                    ),
                    foregroundColor: colors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: colors.architecturalBorder.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 14),

          // Dietary, Accessibility & Notes
          Text(
            'Dietary, Accessibility & AI Notes',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              ..._dietaryOptions.map((item) {
                final selected = _selectedDietary.contains(item);
                return _buildSelectableChip(
                  label: item,
                  selected: selected,
                  colors: colors,
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedDietary.remove(item);
                      } else {
                        _selectedDietary.add(item);
                      }
                    });
                  },
                );
              }),
              ..._accessibilityOptions.map((item) {
                final selected = _selectedAccessibility.contains(item);
                return _buildSelectableChip(
                  label: item,
                  selected: selected,
                  colors: colors,
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedAccessibility.remove(item);
                      } else {
                        _selectedAccessibility.add(item);
                      }
                    });
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _extraNotesController,
            maxLines: 2,
            onChanged: (_) => setState(() {}),
            style: TextStyle(fontSize: 12.5, color: colors.onSurface),
            decoration: InputDecoration(
              hintText: 'Optional notes (anniversary, avoid early starts...)',
              hintStyle: TextStyle(
                fontSize: 11.5,
                color: colors.onSurfaceVariant,
              ),
              filled: true,
              fillColor: isDark
                  ? colors.surfaceContainerLow
                  : const Color(0xFFF3FAF7),
              contentPadding: const EdgeInsets.all(11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: colors.architecturalBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: colors.architecturalBorder),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _quickPromptChips.map((chip) {
              final alreadyAdded = _extraNotesController.text.contains(chip);
              return ActionChip(
                label: Text(
                  alreadyAdded ? '✓ $chip' : '+ $chip',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: alreadyAdded
                        ? colors.primary
                        : colors.onSurfaceVariant,
                  ),
                ),
                backgroundColor: alreadyAdded
                    ? colors.primary.withValues(alpha: isDark ? 0.18 : 0.1)
                    : (isDark
                          ? colors.surfaceContainerLow
                          : const Color(0xFFF5FAF8)),
                side: BorderSide(color: colors.architecturalBorder),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  setState(() {
                    if (alreadyAdded) return;
                    final trimmed = _extraNotesController.text.trim();
                    _extraNotesController.text = trimmed.isEmpty
                        ? chip
                        : '$trimmed, $chip';
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBudgetControls(HelaColorPalette colors) {
    final isDark = colors.brightness == Brightness.dark;
    final sliderValue = _customDailyBudget.clamp(30, 500).toDouble();
    final estimatedTotal = _customDailyBudget * _tripDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 108,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? colors.surfaceContainerLow
                    : const Color(0xFFF3FAF7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    r'$',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _customBudgetController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null && parsed > 0) {
                          setState(() => _customDailyBudget = parsed);
                        }
                      },
                    ),
                  ),
                  Text(
                    '/d',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Est. ~\$$estimatedTotal ($_tripDays days) · $_customBudgetStyleHint',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: colors.primary,
            inactiveTrackColor: colors.primary.withValues(alpha: 0.16),
            thumbColor: colors.primary,
            trackHeight: 3.5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: sliderValue,
            min: 30,
            max: 500,
            divisions: 47,
            onChanged: (value) {
              final rounded = value.round();
              setState(() {
                _customDailyBudget = rounded;
                _customBudgetController.text = '$rounded';
                _customBudgetController.selection = TextSelection.collapsed(
                  offset: _customBudgetController.text.length,
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectableChip({
    required String label,
    required bool selected,
    required HelaColorPalette colors,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    final isDark = colors.brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary
              : (isDark ? colors.surfaceContainerLow : const Color(0xFFF5FAF8)),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? colors.primary
                : colors.architecturalBorder.withValues(alpha: 0.75),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: selected ? colors.onPrimary : colors.primary,
              ),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? colors.onPrimary : colors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // DOCKED MINIMAL GENERATE BAR (ALWAYS READY)
  // ==========================================
  Widget _buildStickyGenerateBar(HelaColorPalette colors) {
    final isDark = colors.brightness == Brightness.dark;
    final budgetTag = _selectedBudgetTier == 'custom'
        ? '\$$_customDailyBudget/day'
        : (_selectedBudgetTier[0].toUpperCase() +
              _selectedBudgetTier.substring(1));

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        border: Border(
          top: BorderSide(
            color: isDark
                ? colors.outlineVariant.withValues(alpha: 0.45)
                : const Color(0xFFDCEEE8),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Center(
        heightFactor: 1.0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 12,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      '$_tripDays Days · ${_adults + _children} Guests · $budgetTag · ${_selectedPace[0].toUpperCase()}${_selectedPace.substring(1)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _triggerGenerate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 18,
                        color: isDark ? colors.onPrimary : colors.goldenAmber,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          HelaAppStateProvider.of(
                            context,
                          ).tr('generate_my_itinerary'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            fontFamily: _fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
