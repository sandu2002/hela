import 'package:flutter/material.dart';
import 'package:hela/data/sri_lanka_images.dart';
import 'package:hela/pages/itinerary_planning_loading_page.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/theme/hela_colors.dart';
import 'package:hela/widgets/hela_bottom_nav_bar.dart';
import 'package:hela/widgets/hela_network_image.dart';

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
  // Form State
  final TextEditingController _startLocationController =
      TextEditingController(text: 'Bandaranaike Intl Airport (CMB)');
  final TextEditingController _extraNotesController = TextEditingController();

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

  // Budget Tier: 'value', 'comfort', 'luxury'
  String _selectedBudgetTier = 'comfort';

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
    _extraNotesController.dispose();
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
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const List<String> _fullMonths = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  String _formatShortDate(DateTime date) =>
      '${_shortMonths[date.month - 1]} ${date.day}, ${date.year}';

  String _weekdayName(DateTime date) => _weekdays[date.weekday - 1];

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
          backgroundColor: isDark ? colors.surfaceContainer : colors.cardBackground,
        ),
      ),
      child: child!,
    );
  }

  Future<void> _pickDateRange() async {
    final firstDate = _today;
    final lastDate = firstDate.add(const Duration(days: 730));
    final initialStart =
        _startDate.isBefore(firstDate) ? firstDate : _startDate;
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
    final initialDate =
        _startDate.isBefore(firstDate) ? firstDate : _startDate;

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

  void _triggerGenerate() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ItineraryPlanningLoadingPage(
          startLocation: _startLocationController.text,
          startDate: _startDate,
          endDate: _endDate,
          adults: _adults,
          children: _children,
          budgetTier: _selectedBudgetTier,
          interests: _selectedInterests,
          pace: _selectedPace,
          extraNotes: _extraNotesController.text,
          tripDays: _tripDays,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
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
            colors: [
              Color(0xFF004D40),
              Color(0xFF00251A),
            ],
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
      backgroundColor: colors.surface.withValues(alpha: isDark ? 0.96 : 0.94),
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 68,
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surfaceContainer,
                      border: Border.all(
                        color: colors.architecturalBorder.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: colors.onSurface,
                      size: 22,
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
          fontSize: 34,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
          fontFamily: 'Inter',
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gemini AI Planner • Ready to craft your journey'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surfaceContainer,
                border: Border.all(
                  color: colors.architecturalBorder.withValues(alpha: 0.6),
                ),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: colors.primary,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);
    final isDark = colors.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildTopAppBar(colors, isDark),
      body: SafeArea(
        top: false,
        bottom: false,
        child: _buildPlannerFormView(colors),
      ),
      bottomNavigationBar: const HelaBottomNavBar(currentIndex: 2),
    );
  }

  // ==========================================
  // PREFERENCES FORM VIEW
  // ==========================================
  Widget _buildPlannerFormView(HelaColorPalette colors) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Center(
        heightFactor: 1.0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Visual Showcase Banner (Single large image matching Home Screen Hero UI)
              _buildHeroShowcaseBanner(colors),
              const SizedBox(height: 24),

              // 1. Where does your journey begin?
              _buildSectionStartingLocation(colors),
              const SizedBox(height: 20),

              // 2. Travel Dates
              _buildSectionTravelDates(colors),
              const SizedBox(height: 20),

              // 3. Travel Party
              _buildSectionTravelParty(colors),
              const SizedBox(height: 20),

              // 4. Travel Budget
              _buildSectionTravelBudget(colors),
              const SizedBox(height: 20),

              // 5. Travel Interests
              _buildSectionTravelInterests(colors),
              const SizedBox(height: 20),

              // 6. Pace & Travel Style
              _buildSectionPaceAndStyle(colors),
              const SizedBox(height: 20),

              // 7. AI Engine Preview Card (Island Route Optimizer ACTIVE)
              _buildRouteOptimizerCard(colors),
              const SizedBox(height: 22),

              // 9. Generate CTA Button
              _buildGenerateButton(colors),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroShowcaseBanner(HelaColorPalette colors) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildNetworkImage(SriLankaImages.sigiriya),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    colors.primary.withValues(alpha: 0.95),
                    colors.primary.withValues(alpha: 0.45),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Floating Badges at Top of Banner
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 12, color: Color(0xFF6EE7B7)),
                        SizedBox(width: 5),
                        Text(
                          'Gemini AI Curated',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_rounded, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Sigiriya Fortress',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Integrated Title, Subtitle and Badges at Bottom of Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    HelaAppStateProvider.of(context).tr('plan_your_adventure'),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: -0.3,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          offset: Offset(0, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    HelaAppStateProvider.of(context).tr('planner_subtitle'),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w500,
                      shadows: const [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.primaryFixed,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt_rounded, size: 15, color: colors.primary),
                            const SizedBox(width: 5),
                            Text(
                              'Instant AI Routes',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.tune_rounded, size: 15, color: Color(0xFF00382E)),
                            SizedBox(width: 5),
                            Text(
                              '100% Tailored',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF00382E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Starting Location
  Widget _buildSectionStartingLocation(HelaColorPalette colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      HelaAppStateProvider.of(context).tr('starting_location'),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  const Text(
                    ' *',
                    style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Required',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: colors.secondary),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Input Box
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.architecturalBorder.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.location_on_rounded, size: 20, color: colors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    inputDecorationTheme: const InputDecorationTheme(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      filled: false,
                      fillColor: Colors.transparent,
                    ),
                  ),
                  child: TextField(
                    controller: _startLocationController,
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: colors.onSurface),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      filled: false,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.my_location_rounded, size: 19, color: colors.secondary),
                onPressed: () {
                  setState(() => _startLocationController.text = 'Bandaranaike Intl Airport (CMB)');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Set to current location: Bandaranaike Airport (CMB)')),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Quick Suggestion Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildLocationQuickPill('CMB Airport', Icons.flight_land_rounded, 'Bandaranaike Airport (CMB)', colors),
              const SizedBox(width: 6),
              _buildLocationQuickPill('Colombo Fort', Icons.train_rounded, 'Colombo Fort Railway Station', colors),
              const SizedBox(width: 6),
              _buildLocationQuickPill('Kandy', Icons.temple_buddhist_rounded, 'Kandy City Center', colors),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationQuickPill(String label, IconData icon, String targetValue, HelaColorPalette colors) {
    return InkWell(
      onTap: () {
        setState(() => _startLocationController.text = targetValue);
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12.5, color: colors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Travel Dates
  Widget _buildSectionTravelDates(HelaColorPalette colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  HelaAppStateProvider.of(context).tr('travel_dates'),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.onSurface),
                ),
                const Text(' *', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
              ],
            ),
            InkWell(
              onTap: _pickDateRange,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timelapse_rounded, size: 12, color: colors.onSecondaryContainer),
                    const SizedBox(width: 4),
                    Text(
                      '$_tripDays Days Island Loop',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.edit_calendar_rounded, size: 11, color: colors.onSecondaryContainer),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Two Date Cards
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _pickArrivalDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.architecturalBorder),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 13, color: colors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'ARRIVAL',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurfaceVariant,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.edit_rounded, size: 12, color: colors.onSurfaceVariant),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatShortDate(_startDate),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: colors.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_weekdayName(_startDate)} • Morning',
                        style: TextStyle(fontSize: 11, color: colors.secondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: _pickDepartureDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.architecturalBorder),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.event_available_rounded, size: 13, color: colors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'DEPARTURE',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurfaceVariant,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.edit_rounded, size: 12, color: colors.onSurfaceVariant),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatShortDate(_endDate),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: colors.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_weekdayName(_endDate)} • Evening',
                        style: TextStyle(fontSize: 11, color: colors.secondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.sunny, size: 13, color: colors.goldenAmber),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _seasonalTip(_startDate.month),
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 3. Travel Party
  Widget _buildSectionTravelParty(HelaColorPalette colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              HelaAppStateProvider.of(context).tr('travel_party'),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.onSurface),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${_adults + _children} Travellers • $_partyDescription',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.architecturalBorder),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              // Adults
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Adults', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: colors.onSurface)),
                      Text('Age 12 and above', style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                    ],
                  ),
                  Row(
                    children: [
                      _buildStepperBtn(
                        icon: Icons.remove_rounded,
                        onTap: () {
                          if (_adults > 1) setState(() => _adults--);
                        },
                        colors: colors,
                        isPrimary: false,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          '$_adults',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: colors.onSurface),
                        ),
                      ),
                      _buildStepperBtn(
                        icon: Icons.add_rounded,
                        onTap: () => setState(() => _adults++),
                        colors: colors,
                        isPrimary: true,
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: colors.architecturalBorder, height: 1),
              ),
              // Children
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Children', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: colors.onSurface)),
                      Text('Age 0 to 11 years', style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                    ],
                  ),
                  Row(
                    children: [
                      _buildStepperBtn(
                        icon: Icons.remove_rounded,
                        onTap: () {
                          if (_children > 0) setState(() => _children--);
                        },
                        colors: colors,
                        isPrimary: false,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          '$_children',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: colors.onSurface),
                        ),
                      ),
                      _buildStepperBtn(
                        icon: Icons.add_rounded,
                        onTap: () => setState(() => _children++),
                        colors: colors,
                        isPrimary: true,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
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
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isPrimary ? colors.primary : colors.surfaceContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isPrimary ? Colors.white : colors.primary,
        ),
      ),
    );
  }

  // 4. Travel Budget
  Widget _buildSectionTravelBudget(HelaColorPalette colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              HelaAppStateProvider.of(context).tr('travel_budget'),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.onSurface),
            ),
            const Text(' *', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
          ],
        ),
        Text('Choose your lodging & transit tier', style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
        const SizedBox(height: 8),

        // Tier 1: Value Explorer
        _buildBudgetCard(
          id: 'value',
          title: 'Value Explorer',
          priceRange: r'~$40 - $70 / day',
          description: 'Guesthouses, scenic 2nd/3rd class train rides, and vibrant local rice & curry spots.',
          icon: Icons.backpack_rounded,
          colors: colors,
        ),
        const SizedBox(height: 8),

        // Tier 2: Comfort & Boutique (Most Popular)
        _buildBudgetCard(
          id: 'comfort',
          title: 'Comfort & Boutique',
          priceRange: r'~$100 - $180 / day',
          description: 'Boutique heritage villas, private AC car/tuk-tuk connections, and curated guided tours.',
          icon: Icons.hotel_rounded,
          isPopular: true,
          colors: colors,
        ),
        const SizedBox(height: 8),

        // Tier 3: Luxury Ceylon
        _buildBudgetCard(
          id: 'luxury',
          title: 'Luxury Ceylon',
          priceRange: r'~$250+ / day',
          description: '5-star colonial tea bungalows, dedicated chauffeur-guide, chartered seaplane hops.',
          icon: Icons.villa_rounded,
          colors: colors,
        ),
      ],
    );
  }

  Widget _buildBudgetCard({
    required String id,
    required String title,
    required String priceRange,
    required String description,
    required IconData icon,
    bool isPopular = false,
    required HelaColorPalette colors,
  }) {
    final isSelected = _selectedBudgetTier == id;

    return InkWell(
      onTap: () => setState(() => _selectedBudgetTier = id),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? colors.primary : colors.architecturalBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? colors.primary.withValues(alpha: 0.22) : Colors.black.withValues(alpha: 0.03),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              if (isPopular)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.tertiaryFixed,
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star_rounded, size: 12, color: colors.onTertiaryFixed),
                        const SizedBox(width: 3),
                        Text(
                          'Most Popular',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: colors.onTertiaryFixed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isSelected ? colors.primaryContainer : colors.surfaceContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: isSelected ? Colors.white : colors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : colors.onSurface,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: isPopular ? 80 : 0),
                                child: Text(
                                  priceRange,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? colors.goldenAmber : colors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? Colors.white.withValues(alpha: 0.9) : colors.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.white : colors.surfaceContainer,
                      ),
                      child: isSelected
                          ? Icon(Icons.check_rounded, size: 14, color: colors.primary)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 5. Travel Interests
  Widget _buildSectionTravelInterests(HelaColorPalette colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      HelaAppStateProvider.of(context).tr('travel_interests'),
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.onSurface),
                    ),
                    const Text(' *', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                  ],
                ),
                Text('Tap to pick your island passions', style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colors.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${_selectedInterests.length} Selected',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : colors.cardBackground,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected ? colors.primary : colors.architecturalBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? colors.primary.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : colors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isSelected ? Icons.check_rounded : Icons.add_rounded,
                      size: 14,
                      color: isSelected ? Colors.white : colors.outlineVariant,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 6. Pace & Travel Style
  Widget _buildSectionPaceAndStyle(HelaColorPalette colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          HelaAppStateProvider.of(context).tr('pace_travel_style'),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.onSurface),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _buildPaceOption(
                id: 'relaxed',
                label: 'Relaxed',
                sublabel: '2-3 nights per town',
                icon: Icons.self_improvement_rounded,
                colors: colors,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPaceOption(
                id: 'balanced',
                label: 'Balanced',
                sublabel: 'Ideal mix of sights & rest',
                icon: Icons.tune_rounded,
                colors: colors,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPaceOption(
                id: 'active',
                label: 'Active',
                sublabel: 'Sunrise hikes & surf',
                icon: Icons.directions_run_rounded,
                colors: colors,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaceOption({
    required String id,
    required String label,
    required String sublabel,
    required IconData icon,
    required HelaColorPalette colors,
  }) {
    final isSelected = _selectedPace == id;

    return InkWell(
      onTap: () => setState(() => _selectedPace = id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.primary : colors.architecturalBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? colors.primary.withValues(alpha: 0.22) : Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? colors.secondaryContainer : colors.secondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : colors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(
                fontSize: 9.5,
                color: isSelected ? colors.secondaryContainer : colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 7. Island Route Optimizer Card
  Widget _buildRouteOptimizerCard(HelaColorPalette colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surfaceContainerHigh,
            colors.secondaryContainer.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.architecturalBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.hub_rounded, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      HelaAppStateProvider.of(context).tr('island_route_optimizer'),
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: colors.tertiaryFixed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: colors.onTertiaryFixed,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'HELA calculates monsoon weather divides, mountain road transit hours, and UNESCO site crowd forecasts across all 9 provinces in seconds.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colors.onSurface,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 9. Generate Button
  Widget _buildGenerateButton(HelaColorPalette colors) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _triggerGenerate,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: colors.primary.withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome_rounded, size: 19, color: colors.goldenAmber),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    HelaAppStateProvider.of(context).tr('generate_my_itinerary'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user_rounded, size: 13, color: colors.secondary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                HelaAppStateProvider.of(context).tr('free_instant_generation'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
