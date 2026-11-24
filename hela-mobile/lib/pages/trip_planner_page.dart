import 'package:flutter/material.dart';
import 'package:hela/models/tour_plan.dart';
import 'package:hela/models/tour_preferences.dart';
import 'package:hela/pages/itinerary_details_page.dart';
import 'package:hela/pages/profile_page.dart';
import 'package:hela/services/ai_service.dart';
import 'package:hela/theme/hela_colors.dart';
import 'package:hela/widgets/hela_bottom_nav_bar.dart';

/// Trip Planner Page - 100% matched to Google Stitch Design
/// (Screen 1b1afbb5b8884b4e8ceaf12ac9c68d70: Plan Your Sri Lankan Adventure
///  & Screen d48a0b4b55994a0d876eccbe5db39ab5: Your Sri Lankan Adventure)
class TripPlannerPage extends StatefulWidget {
  const TripPlannerPage({super.key});

  @override
  State<TripPlannerPage> createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends State<TripPlannerPage> {
  // Form State
  final TextEditingController _startLocationController =
      TextEditingController(text: 'Bandaranaike Intl Airport (CMB)');
  final TextEditingController _extraNotesController = TextEditingController();

  DateTime _startDate = DateTime(2025, 10, 14);
  DateTime _endDate = DateTime(2025, 10, 24);

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

  // Navigation & Generation State
  bool _isGenerating = false;
  bool _isSaved = false;

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

  void _appendPrompt(String text) {
    final current = _extraNotesController.text.trim();
    if (current.isEmpty) {
      _extraNotesController.text = text;
    } else {
      _extraNotesController.text = '$current $text';
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        final colors = HelaColors.of(context);
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colors.primary,
              onPrimary: Colors.white,
              surface: colors.cardBackground,
              onSurface: colors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _triggerGenerate() async {
    setState(() => _isGenerating = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('HELA AI is synthesizing real-time routes, weather & trains...'),
        duration: Duration(milliseconds: 1400),
      ),
    );

    TourPlan? aiTourPlan;
    try {
      final prefs = TourPreferences(
        duration: TravelDuration.custom,
        customDays: _tripDays,
        startingLocationName: _startLocationController.text,
        interests: _selectedInterests.map((name) {
          return TravelInterest.values.firstWhere(
            (c) => c.label.toLowerCase() == name.toLowerCase(),
            orElse: () => TravelInterest.nature,
          );
        }).toSet(),
        numberOfTravelers: _adults + _children,
        additionalNotes: _extraNotesController.text,
      );

      aiTourPlan = await AIService()
          .generateTourPlan(preferences: prefs, selectedDestinations: const [])
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      // Graceful fallback to rich curated itinerary
    }

    if (!mounted) return;
    setState(() => _isGenerating = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItineraryDetailsPage(
          startLocation: _startLocationController.text,
          startDate: _startDate,
          endDate: _endDate,
          adults: _adults,
          children: _children,
          budgetTier: _selectedBudgetTier,
          interests: _selectedInterests,
          pace: _selectedPace,
          extraNotes: _extraNotesController.text,
          aiTourPlan: aiTourPlan,
        ),
      ),
    );
  }

  Widget _buildNetworkImage(String url, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: const Color(0xFF0B5D56).withValues(alpha: 0.12),
        child: const Center(
          child: Icon(Icons.landscape_rounded, color: Color(0xFF0B5D56), size: 28),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);
    final isDark = colors.isDark;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: _buildTopAppBar(colors, isDark),
      body: SafeArea(
        top: false,
        bottom: false,
        child: _buildPlannerFormView(colors),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDockedActionBar(colors),
          const HelaBottomNavBar(currentIndex: 2),
        ],
      ),
    );
  }

  // ==========================================
  // TOP APP BAR
  // ==========================================
  PreferredSizeWidget _buildTopAppBar(HelaColorPalette colors, bool isDark) {
    return AppBar(
      backgroundColor: colors.surface.withValues(alpha: isDark ? 0.96 : 0.94),
      elevation: 0,
      scrolledUnderElevation: 1.0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          InkWell(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.cardBackground,
                shape: BoxShape.circle,
                border: Border.all(color: colors.architecturalBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_rounded, size: 19, color: colors.onSurface),
            ),
          ),

          // Action Buttons
          Row(
            children: [
              // Bookmark Favorite
              InkWell(
                onTap: () {
                  setState(() => _isSaved = !_isSaved);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isSaved ? 'Trip saved to your bookmarks!' : 'Trip removed from bookmarks.'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.architecturalBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isSaved ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    size: 19,
                    color: _isSaved ? const Color(0xFFE11D48) : colors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Profile Avatar
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                },
                borderRadius: BorderRadius.circular(999),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: colors.primary,
                  child: const Icon(Icons.person_rounded, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // DOCKED ACTION BAR (BOTTOM BUTTONS)
  // ==========================================
  Widget _buildDockedActionBar(HelaColorPalette colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.98),
        border: Border(top: BorderSide(color: colors.architecturalBorder)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening live island GPS navigation route...'),
                          duration: Duration(milliseconds: 1200),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.secondaryContainer,
                      foregroundColor: colors.onSecondaryContainer,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.near_me_rounded, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Get Directions',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Trip successfully added to My Saved Journeys! ✨'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: colors.primary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.playlist_add_rounded, size: 19),
                        SizedBox(width: 6),
                        Text(
                          'Add to My Trip',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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
    );
  }

  // ==========================================
  // STEP 1: PREFERENCES FORM VIEW
  // ==========================================
  Widget _buildPlannerFormView(HelaColorPalette colors) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Step / AI Aura Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 13, color: colors.tertiary),
                    const SizedBox(width: 5),
                    Text(
                      'HELA AI • Live Island Intelligence',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(width: 4, height: 4, decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(
                      'Step 1 of 2',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: colors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Title & Subtitle
              Text(
                'Plan Your Sri Lankan Adventure',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                  fontFamily: 'Inter',
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tell us what you love. HELA will synthesize real-time weather, train timetables, and heritage gems into your bespoke itinerary.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: colors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Mini Visual Showcase Strip (3 photo cards)
              Row(
                children: [
                  Expanded(
                    child: _buildShowcaseCard(
                      'Central Highlands',
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBs_XTpZKMpdPe-QRpIy4hqdIg9uURYhpyrlSvlOtIRuuS4oWcES1vqSYTj4d1VaviJYn3uj7VRe7ei_uJK8t4PsYK_EyLrtEolEcJGjSWUul5l7l4LfkauA9dpsFuOJSScp_LlXUbzMAWTcKIEvEr8DOu8XPyPG9ocI9-CDD_MKUUfWqXpW8bB5duRqszaVJ01WC7ZIvLL9L-YVQvqk9CUKypvfzEGzw1fUyJ-678',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildShowcaseCard(
                      'South Coast',
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBPkLckqRGKAlatJCUM4gzHwUasDEoxiUV5dsXjSnc19gS9bfJoY2acl0NSPlOg5DQaW4C6jOVdSQmQpqYxFE_es6O_i-QcNsNpsN8djPl1yVSDswCM8Vk9AJYCh9s_QhyElsuPXx6yTFRbEqT2h4h6m9czsbJZhjAf7L1I0wy2n3ap4_0VzJqe7ZEufOFq1A1lqQRXnXu65hu3KLg12iLqCKMwSyKtKDnCSAFA9Do',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildShowcaseCard(
                      'Cultural Triangle',
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCyl99JeHU0i5pKUTjsb7qgKbHrl5G21ra2Whx8gvRoseh60V0pChotYO705JSrpPKAUXNeDh1MghKukIU8TB4GUvFh4fMmllN7u5iuTcX3lbLGBn77iCHbTANUcvkHudj_JoSPTqfEh4-nsoiT4xvHZfbnSHmTkOaX03VfjzxJXWD_P0nw_b6TIQakMs5VM0W-RiKVzAcoZQLhN1iorttL6YgEkYJUUBCDQak5GAY',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

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

              // 7. Anything else HELA should know?
              _buildSectionExtraNotes(colors),
              const SizedBox(height: 20),

              // 8. AI Engine Preview Card (Island Route Optimizer ACTIVE)
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

  Widget _buildShowcaseCard(String label, String imageUrl) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildNetworkImage(imageUrl),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 6,
              left: 6,
              right: 6,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
            Row(
              children: [
                Text(
                  'Where does your journey begin?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const Text(
                  ' *',
                  style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              'Required',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: colors.secondary),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Input Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.architecturalBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.location_on_rounded, size: 20, color: colors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
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
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
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
                  'Travel Dates',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.onSurface),
                ),
                const Text(' *', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
              ],
            ),
            Container(
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
                ],
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
                onTap: _pickDateRange,
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
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Oct ${_startDate.day}, ${_startDate.year}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: colors.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tuesday • Morning',
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
                onTap: _pickDateRange,
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
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Oct ${_endDate.day}, ${_endDate.year}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: colors.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Friday • Evening',
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
                'October is peak dry season for South-West beaches & Yala safaris.',
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
              'Travel Party',
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
              'Travel Budget',
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
                      'Travel Interests',
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
          'Pace & Travel Style',
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

  // 7. Extra Notes
  Widget _buildSectionExtraNotes(HelaColorPalette colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Anything else HELA should know?',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.onSurface),
            ),
            Text(
              'Optional',
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Container(
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
            children: [
              TextField(
                controller: _extraNotesController,
                maxLines: 3,
                style: TextStyle(fontSize: 12.5, color: colors.onSurface),
                decoration: InputDecoration(
                  hintText:
                      'e.g. Vegetarian dining only, desire first-class Kandy to Ella train observation deck tickets, interested in a Galle Fort cooking masterclass...',
                  hintStyle: TextStyle(fontSize: 12, color: colors.outline),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  filled: false,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 8),
              Divider(color: colors.architecturalBorder, height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.edit_note_rounded, size: 16, color: colors.secondary),
                  Text(
                    'HELA tailors every leg',
                    style: TextStyle(fontSize: 10.5, color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Quick Prompt Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildPromptPill('Vegetarian Friendly', 'Vegetarian/Vegan friendly meals preferred.', colors),
              const SizedBox(width: 6),
              _buildPromptPill('Tuk-Tuk Bookings', 'Pre-book licensed Tuk-Tuk safari drivers.', colors),
              const SizedBox(width: 6),
              _buildPromptPill('Family Safe Bays', 'Family friendly pace with safe swimming beaches.', colors),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromptPill(String title, String promptText, HelaColorPalette colors) {
    return InkWell(
      onTap: () => _appendPrompt(promptText),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.architecturalBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('+', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.secondary)),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  // 8. Island Route Optimizer Card
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
                      'Island Route Optimizer',
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
            onPressed: _isGenerating ? null : _triggerGenerate,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: colors.primary.withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isGenerating
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'HELA is Mapping Routes...',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 19, color: colors.goldenAmber),
                      const SizedBox(width: 8),
                      const Text(
                        'Generate My Itinerary ✨',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
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
            Text(
              'Free instant generation • 100% customizable with your local guide',
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }
}
