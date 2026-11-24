import 'package:flutter/material.dart';
import 'package:hela/models/tour_plan.dart';
import 'package:hela/pages/active_journey_page.dart';
import 'package:hela/pages/fair_ride_page.dart';
import 'package:hela/pages/profile_page.dart';
import 'package:hela/theme/hela_colors.dart';
import 'package:hela/widgets/hela_bottom_nav_bar.dart';

/// Itinerary Details Page - 100% matched to Google Stitch Design
/// (Screen d48a0b4b55994a0d876eccbe5db39ab5: HELA - Your Sri Lankan Adventure)
class ItineraryDetailsPage extends StatefulWidget {
  final String startLocation;
  final DateTime startDate;
  final DateTime endDate;
  final int adults;
  final int children;
  final String budgetTier;
  final Set<String> interests;
  final String pace;
  final String extraNotes;
  final TourPlan? aiTourPlan;

  const ItineraryDetailsPage({
    super.key,
    this.startLocation = 'Bandaranaike Intl Airport (CMB)',
    required this.startDate,
    required this.endDate,
    this.adults = 2,
    this.children = 0,
    this.budgetTier = 'comfort',
    this.interests = const {'Beaches', 'Nature', 'Culture', 'Hikes & Adventure', 'Authentic Food'},
    this.pace = 'balanced',
    this.extraNotes = '',
    this.aiTourPlan,
  });

  @override
  State<ItineraryDetailsPage> createState() => _ItineraryDetailsPageState();
}

class _ItineraryDetailsPageState extends State<ItineraryDetailsPage> {
  int _selectedDayIndex = 0;
  bool _isSaved = false;

  int get _tripDays {
    final diff = widget.endDate.difference(widget.startDate).inDays;
    return diff > 0 ? diff : 5;
  }

  String get _budgetPriceBadge {
    switch (widget.budgetTier.toLowerCase()) {
      case 'value':
        return r'Value (~$55/day)';
      case 'luxury':
        return r'Luxury (~$260/day)';
      case 'comfort':
      default:
        return r'Boutique (~$140/day)';
    }
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
      appBar: _buildAppBar(colors, isDark),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Trip Header Summary Card
                  _buildSummaryHeaderCard(colors),
                  const SizedBox(height: 12),

                  // 2. Quick Action Toolbar
                  _buildQuickActionToolbar(colors),
                  const SizedBox(height: 16),

                  // 3. Interactive Day Selector (Horizontal Scroll)
                  _buildDaySelector(colors),
                  const SizedBox(height: 16),

                  // 4. Day 1 Route Map Overview Card
                  _buildRouteMapOverviewCard(colors),
                  const SizedBox(height: 20),

                  // 5. Vertical Timeline Section
                  _buildTimelineSection(colors),
                  const SizedBox(height: 20),

                  // 6. AI Travel Assistant Dynamic Callout
                  _buildAiAssistantCallout(colors),
                  const SizedBox(height: 16),

                  // 7. HELA Fair-Price Assurance Card
                  _buildFairPriceAssuranceCard(colors),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildStickyBottomBar(colors),
    );
  }

  // ==========================================
  // TOP APP BAR
  // ==========================================
  PreferredSizeWidget _buildAppBar(HelaColorPalette colors, bool isDark) {
    return AppBar(
      backgroundColor: colors.surface.withValues(alpha: isDark ? 0.96 : 0.94),
      elevation: 0,
      scrolledUnderElevation: 1.0,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Center(
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.cardBackground,
                shape: BoxShape.circle,
                border: Border.all(color: colors.architecturalBorder),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Icon(Icons.arrow_back_rounded, size: 20, color: colors.onSurface),
            ),
          ),
        ),
      ),
      title: Text(
        'Itinerary Details',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: colors.onSurface,
          fontFamily: 'Inter',
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.share_rounded, size: 20, color: colors.onSurfaceVariant),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Itinerary link copied to clipboard!')),
            );
          },
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, size: 20, color: colors.onSurfaceVariant),
          onSelected: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Option selected: $value')),
            );
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'pdf', child: Text('Export Itinerary as PDF')),
            const PopupMenuItem(value: 'offline', child: Text('Download for Offline Use')),
            const PopupMenuItem(value: 'guide', child: Text('Connect with Local Chauffeur')),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
            borderRadius: BorderRadius.circular(999),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: colors.primary,
              child: const Icon(Icons.person_rounded, size: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 1. TRIP HEADER SUMMARY CARD
  // ==========================================
  Widget _buildSummaryHeaderCard(HelaColorPalette colors) {
    final title = widget.aiTourPlan?.title.isNotEmpty == true
        ? widget.aiTourPlan!.title
        : 'Cultural Wonders & Emerald Peaks';
    final summary = widget.aiTourPlan?.summary.isNotEmpty == true
        ? widget.aiTourPlan!.summary
        : 'Sri Lanka Grand Highlights Expedition';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.architecturalBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top AI Badge & Edit Preferences Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 12.5, color: colors.primary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'AI CURATED PLAN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: colors.primary,
                            letterSpacing: 0.4,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Edit Preferences',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(Icons.edit_rounded, size: 14, color: colors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Main Title
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
              fontFamily: 'Inter',
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            summary,
            style: TextStyle(fontSize: 12.5, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),

          // Sub-badges row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildBadgePill(Icons.calendar_month_rounded, '$_tripDays Days / ${_tripDays - 1} Nights', colors),
              _buildBadgePill(Icons.group_rounded, '${widget.adults + widget.children} Travellers', colors),
              _buildBadgePill(Icons.hotel_rounded, _budgetPriceBadge, colors),
            ],
          ),
          const SizedBox(height: 10),

          // Friendly Note
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_rounded, size: 16, color: colors.goldenAmber),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Sample AI Itinerary • Fully customizable on-the-go with certified local guides and chauffeur-drivers.',
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgePill(IconData icon, String label, HelaColorPalette colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.onSurface),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. QUICK ACTION TOOLBAR (Save, Share, Ask HELA, Book Taxi)
  // ==========================================
  Widget _buildQuickActionToolbar(HelaColorPalette colors) {
    return Row(
      children: [
        _buildActionToolItem(
          icon: _isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
          label: 'Save',
          iconColor: _isSaved ? const Color(0xFFE11D48) : colors.primary,
          colors: colors,
          onTap: () {
            setState(() => _isSaved = !_isSaved);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isSaved ? 'Itinerary bookmarked to your Saved Trips! ✨' : 'Itinerary removed from Saved Trips.'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        _buildActionToolItem(
          icon: Icons.share_rounded,
          label: 'Share',
          iconColor: colors.primary,
          colors: colors,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Itinerary share link copied to clipboard!')),
            );
          },
        ),
        const SizedBox(width: 8),
        _buildActionToolItem(
          icon: Icons.auto_fix_high_rounded,
          label: 'Ask HELA',
          iconColor: colors.goldenAmber,
          colors: colors,
          onTap: () {
            HelaBottomNavBar.openAskHelaSheet(context);
          },
        ),
        const SizedBox(width: 8),
        _buildActionToolItem(
          icon: Icons.local_taxi_rounded,
          label: 'Book Taxi',
          iconColor: colors.primary,
          colors: colors,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FairRidePage()));
          },
        ),
      ],
    );
  }

  Widget _buildActionToolItem({
    required IconData icon,
    required String label,
    required Color iconColor,
    required HelaColorPalette colors,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.architecturalBorder),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1)),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 3. INTERACTIVE DAY SELECTOR (Horizontal Scroll)
  // ==========================================
  Widget _buildDaySelector(HelaColorPalette colors) {
    final days = const [
      {'day': 'Day 1', 'date': 'Oct 14', 'route': 'Colombo → Sigiriya'},
      {'day': 'Day 2', 'date': 'Oct 15', 'route': 'Cultural Triangle'},
      {'day': 'Day 3', 'date': 'Oct 16', 'route': 'Kandy Tea Hills'},
      {'day': 'Day 4', 'date': 'Oct 17', 'route': 'Ella Misty Rails'},
      {'day': 'Day 5', 'date': 'Oct 18', 'route': 'Galle Fort Coast'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(days.length, (idx) {
          final isSelected = _selectedDayIndex == idx;
          final d = days[idx];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedDayIndex = idx),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : colors.cardBackground,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected ? colors.primary : colors.architecturalBorder,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      d['day']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : colors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      d['date']!,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? colors.secondaryContainer : colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      d['route']!,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isSelected ? Colors.white.withValues(alpha: 0.9) : colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ==========================================
  // 4. DAY ROUTE OVERVIEW CARD
  // ==========================================
  Widget _buildRouteMapOverviewCard(HelaColorPalette colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.architecturalBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.alt_route_rounded, size: 19, color: colors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Day ${_selectedDayIndex + 1} Route Overview',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ActiveJourneyPage(
                        dayNumber: _selectedDayIndex + 1,
                        dateText: 'Oct ${_selectedDayIndex + 14}, 2025',
                        origin: widget.startLocation,
                        destination: 'Sigiriya Lion Rock Citadel',
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Expand',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.primary),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.open_in_full_rounded, size: 13, color: colors.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Map snapshot with gradient overlay
          Container(
            height: 125,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildNetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDsPhxvlkvEc_GnJikri37Bd4TMnnwB8f-PwV_qOm05koJCQcNcQ5R2clelwJjk56-f8XmEZcBQX-q7q3ZJFTRV2UVqWWf3UMVCowXYnEjfH8hwvCWnKNs-6w_CmyLX2piFnVvT6MkuoovLf3qgeFe5K8gStCbi1a-k3nFhviaJ65kxRBhYDeM8_DKMOx5QiIK-Vq6sMnM6H-OcVv3H1Yr1z_Mi9cNZtl8UAP2We4U',
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [colors.primary.withValues(alpha: 0.88), Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.near_me_rounded, size: 15, color: Colors.white),
                            SizedBox(width: 5),
                            Text(
                              'CMB Airport → Kurunegala → Sigiriya',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            '148 km',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Route Specs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRouteSpec('Distance', '148 km', colors),
                _buildRouteSpec('Drive Time', '3h 45m', colors),
                _buildRouteSpec('Main Highway', 'A1 / Kurunegala', colors),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSpec(String label, String value, HelaColorPalette colors) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colors.onSurface),
        ),
      ],
    );
  }

  // ==========================================
  // 5. TIMELINE SECTION (4 CURATED STOPS)
  // ==========================================
  Widget _buildTimelineSection(HelaColorPalette colors) {
    final stops = const [
      _TimelineStopData(
        number: '1',
        time: '08:30 AM',
        duration: '~1 hr',
        title: 'Arrival & Tropical Welcome at CMB',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAb04tp-4RaKYvUAcYtIB-a9elZBDCBxTlB5125n2MjJffHypFjheVbvoXIQPbF8lGBxolYcZWPL0ffjchaSQqf36xw-Hvm-qlacpbOk3Kk7qSe8Q4ovfHokxX3jMsMO2pyLZAYNb-3iJoskufaRDmrNVHZ3apbe37F8LdIm-HdZHOdBSIkTzboPSn0qEsdpA3AcXZgc0ta5BZIlh5LabtiU7Qv1e2gLOTYu-RQULY',
        description:
            'Private AC car pickup, high-speed Dialog SIM setup, fresh Thambili (king coconut) welcome drink, and departure towards the lush Central Province.',
        costLabel: 'Estimated Cost',
        costValue: 'Included in Boutique Package',
        nextTransit: 'Private Chauffeur AC Car: 140 km (~3h 20m via Ambepussa)',
      ),
      _TimelineStopData(
        number: '2',
        time: '12:30 PM',
        duration: '~1.5 hr',
        title: 'Traditional Rice & Curry Feast at Kurunegala',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuD6DYHx6xsupMcKrY4sKJBzofWULV5Fj-8VBBaqO1bEvlTIs9ulLuCa1hS7ifHgepQWIhBGi-QGRlcJyEIKnVLSsPjGfVVAq6svVqmOt4YwfWCZyUEAAk7g5UhxRL49makxjxI0yJ_i2YM06yAnkUlDSjsv6xcw_oSpwJpQDMLmjvzwgFtiPUiEnGefuRt9NeJYrvxGf21uo6xIJLRchyyjttw7V2odGtqChW_rdDY',
        description:
            'Clay-pot village feast with fragrant coconut sambol, creamy dhal curry, polos (jackfruit curry), and fresh lake fish in an open-air garden pavilion.',
        costLabel: 'Meal Estimate',
        costValue: r'Approx. $8 - $12 / person',
        nextTransit: 'Country Road Drive: 38 km (~45m scenic country passage)',
      ),
      _TimelineStopData(
        number: '3',
        time: '03:30 PM',
        duration: 'Must-See Wonder',
        title: 'Ascent of Sigiriya Lion Rock Citadel',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBPSIyMAiIWjbG-KXdm_VKdFoEa1JeRVUdo_vCKB2gTIgKHDz93WL5qjrTMWiKAMQTUL2QHWVlQiNUvyujN1kGUs9ZLGHyjWLafI2yNud5V2ph9BMhUCaqamFU4OO3PKhmdHOR7Os9JOGC1KFQEu1BXUaukDfPHYn8bnrH0HdogAUKlKVXACQQJ8jay3TFAzev5GHFfwJ4mX65cwgMXbAzWchQP3L-K-yVkGYQ2jk4',
        description:
            'Golden-hour climb of King Kashyapa\'s UNESCO 5th-century palace fortress. Explore landscaped water gardens, the ancient Mirror Wall poetry, and sweeping 360° summit views.',
        costLabel: 'UNESCO Official Ticket',
        costValue: r'~$36 / adult (Official Rate)',
        insiderTip:
            'Insider Tip: Ascending after 3:30 PM avoids harsh tropical midday heat and catches golden photography light on the west-facing lion paw terrace.',
        nextTransit: 'Scenic Tuk-Tuk Hop: 4 km (~10m jungle border lane)',
      ),
      _TimelineStopData(
        number: '4',
        time: '07:30 PM',
        duration: 'Evening Rest',
        title: 'Boutique Heritage Villa Check-In & Dinner',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAvPPgRKvbaydemzVuQRIlh0aNN2hOFEOzyq4udjTk35033ZwhSPKjh_9rIr40KdL9j-ZfmsJHWVS2yxKzdjli0L0WDaqk2DotLgoDl3cyn0ReIS5iVPfWx7OufEvQp069nTLlZzBDJ52lpUnQttduCB4QVNh5M_cPdelYdkahyk9ffxvFnKRNGuIVKhEnN8SOuD_G9PTG-iDPDbV8QpGHer574Voe1p2otnRziyig',
        description:
            'Unwind at an eco-resort overlooking the jungle canopy with warm herbal ayurvedic tea, followed by candlelit dinner under tranquil island night skies.',
        costLabel: 'Accommodation',
        costValue: r'Eco Heritage Stay (~$130/night)',
        nextTransit: null,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day ${_selectedDayIndex + 1} Itinerary',
                  style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: colors.onSurface),
                ),
                Text(
                  'Arrival to the Ancient Citadel • 4 Curated Stops',
                  style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: colors.surfaceContainer, borderRadius: BorderRadius.circular(999)),
              child: Text(
                'Oct ${_selectedDayIndex + 14}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Vertical Nodes
        ...stops.map((stop) {
          final isHighlight = stop.number == '3';
          final hasTip = stop.insiderTip != null;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline bullet node & vertical track
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isHighlight ? colors.tertiary : colors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          stop.number,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    if (stop.nextTransit != null)
                      Container(
                        width: 2,
                        height: 250,
                        color: colors.surfaceContainerHighest,
                      ),
                  ],
                ),
                const SizedBox(width: 10),

                // Stop Card
                Expanded(
                  child: Column(
                    children: [
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 14,
                                      color: isHighlight ? colors.tertiary : colors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      stop.time,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: isHighlight ? colors.tertiary : colors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isHighlight ? colors.tertiaryFixed : colors.surfaceContainer,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    stop.duration,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: isHighlight ? colors.onTertiaryFixed : colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              stop.title,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.onSurface),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                height: 115,
                                width: double.infinity,
                                child: _buildNetworkImage(stop.imageUrl),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              stop.description,
                              style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant, height: 1.35),
                            ),

                            // Local Insider Tip if available
                            if (hasTip) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.tips_and_updates_rounded, size: 15, color: colors.primary),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        stop.insiderTip!,
                                        style: TextStyle(fontSize: 10.5, color: colors.onSurface, height: 1.3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      stop.costLabel,
                                      style: TextStyle(fontSize: 10.5, color: colors.onSurfaceVariant),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    stop.costValue,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isHighlight ? colors.tertiary : colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Next Transit Banner
                      if (stop.nextTransit != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isHighlight ? Icons.electric_rickshaw_rounded : Icons.directions_car_rounded,
                                size: 14,
                                color: isHighlight ? colors.tertiary : colors.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  stop.nextTransit!,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colors.onSurface),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // 6. AI TRAVEL ASSISTANT DYNAMIC CALLOUT
  // ==========================================
  Widget _buildAiAssistantCallout(HelaColorPalette colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: colors.primary.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.smart_toy_rounded, size: 20, color: colors.onSecondaryContainer),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need custom changes to Day ${_selectedDayIndex + 1}?',
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  'Swap stops, adjust timings for jet lag, or book a sunrise hot air balloon over Sigiriya with verified local rates.',
                  style: TextStyle(fontSize: 11, color: colors.onPrimaryContainer, height: 1.3),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => HelaBottomNavBar.openAskHelaSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 14, color: colors.primary),
                        const SizedBox(width: 5),
                        Text(
                          'Ask HELA to Adjust Day ${_selectedDayIndex + 1}',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 7. HELA FAIR-PRICE ASSURANCE CARD
  // ==========================================
  Widget _buildFairPriceAssuranceCard(HelaColorPalette colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.architecturalBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_rounded, size: 18, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                'HELA Fair-Price Assurance',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: colors.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'All transfers in this itinerary utilize government-vetted tourist chauffeurs and official meter pricing. No hidden fuel surcharges or surprise tourist markups.',
            style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant, height: 1.35),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Icon(Icons.shield_rounded, size: 16, color: colors.primary),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'SLTDA Tourist Board Registered',
                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: colors.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Icon(Icons.cancel_rounded, size: 16, color: colors.primary),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Free cancellation up to 24h',
                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: colors.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FIXED BOTTOM STICKY BOOKING BAR
  // ==========================================
  Widget _buildStickyBottomBar(HelaColorPalette colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.98),
        border: Border(top: BorderSide(color: colors.architecturalBorder)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ActiveJourneyPage(
                            dayNumber: _selectedDayIndex + 1,
                            dateText: 'Oct ${_selectedDayIndex + 14}, 2025',
                            origin: widget.startLocation,
                            destination: 'Sigiriya Lion Rock Citadel',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Start My Journey', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 19),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download_for_offline_rounded, size: 13, color: colors.primary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Turn-by-turn live navigation & offline mode included',
                        style: TextStyle(fontSize: 10.5, color: colors.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimelineStopData {
  final String number;
  final String time;
  final String duration;
  final String title;
  final String imageUrl;
  final String description;
  final String costLabel;
  final String costValue;
  final String? insiderTip;
  final String? nextTransit;

  const _TimelineStopData({
    required this.number,
    required this.time,
    required this.duration,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.costLabel,
    required this.costValue,
    this.insiderTip,
    this.nextTransit,
  });
}
