import 'package:flutter/material.dart';
import 'package:hela/models/tour_plan.dart';
import 'package:hela/pages/cultural_guide/cultural_guide_page.dart';
import 'package:hela/pages/home_page.dart';
import 'package:hela/pages/profile_page.dart';
import 'package:hela/pages/smart_tour/smart_tour_home_page.dart';
import 'package:hela/pages/smart_tour/tour_plan_details_page.dart';
import 'package:hela/pages/stays_page.dart';
import 'package:hela/pages/travel_preferences_page.dart';
import 'package:hela/pages/trip_planner_page.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/widgets/haven_card.dart';
import 'package:hela/widgets/stay_card.dart';

/// Dedicated Saved / Wishlist Page for the HELA app.
///
/// Displays all saved Haven cards, Eco-Stays, and Experiences.
class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  int _selectedFilterIndex = 0; // 0: All, 1: Smart Tours, 2: Havens & Excursions, 3: Eco-Stays, 4: Experiences
  final int _selectedNavIndex = 1; // "Saved" is tab index 1

  final List<String> _filters = const [
    'All',
    'Smart Tours',
    'Havens & Excursions',
    'Eco-Stays',
    'Experiences',
  ];

  @override
  Widget build(BuildContext context) {
    final appState = HelaAppStateProvider.of(context);
    final savedTours = appState.savedTours;
    final savedHavens = appState.savedHavens;
    final savedStays = appState.savedStays;
    final savedExperiences = appState.savedExperiences;

    final totalCount = savedTours.length + savedHavens.length + savedStays.length + savedExperiences.length;

    return Scaffold(
      backgroundColor: HelaColors.background,
      appBar: _buildAppBar(totalCount, appState),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    _buildHeaderBanner(totalCount),
                    const SizedBox(height: 16),
                    _buildFilterChips(savedTours.length, savedHavens.length, savedStays.length, savedExperiences.length),
                    const SizedBox(height: 20),
                    _buildContent(appState),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar(int totalCount, HelaAppState appState) {
    return AppBar(
      backgroundColor: HelaColors.surface.withValues(alpha: 0.94),
      elevation: 0,
      scrolledUnderElevation: 1.5,
      shadowColor: Colors.black12,
      toolbarHeight: 64,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: HelaColors.tertiaryFixed.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bookmark_rounded,
              color: HelaColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Saved Page',
                style: TextStyle(
                  color: HelaColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.4,
                ),
              ),
              Text(
                'Your Ceylon Wishlist & Bookmarks',
                style: TextStyle(
                  color: HelaColors.onSurfaceVariant,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (totalCount > 0)
          TextButton.icon(
            onPressed: () => _confirmClearAll(context, appState),
            icon: const Icon(Icons.delete_outline_rounded, size: 16, color: HelaColors.secondary),
            label: const Text(
              'Clear All',
              style: TextStyle(
                color: HelaColors.secondary,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeaderBanner(int totalCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HelaColors.primaryContainer,
            HelaColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: HelaColors.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: HelaColors.tertiaryFixed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$totalCount ${totalCount == 1 ? 'ITEM' : 'ITEMS'} SAVED',
                        style: const TextStyle(
                          color: HelaColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Curated Sri Lankan Sanctuaries',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  totalCount > 0
                      ? 'Ready to turn these dreams into an unforgettable journey.'
                      : 'Save cards while exploring to plan your custom adventure.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                color: HelaColors.tertiaryFixed,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(int toursCount, int havensCount, int staysCount, int expCount) {
    final counts = [
      toursCount + havensCount + staysCount + expCount,
      toursCount,
      havensCount,
      staysCount,
      expCount,
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          final count = counts[index];

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() {
                _selectedFilterIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? HelaColors.primaryContainer : HelaColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? HelaColors.primaryContainer
                      : HelaColors.outlineVariant.withValues(alpha: 0.6),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: HelaColors.primaryContainer.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _filters[index],
                    style: TextStyle(
                      color: isSelected ? HelaColors.onPrimary : HelaColors.onSurfaceVariant,
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? HelaColors.tertiaryFixed
                            : HelaColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color: isSelected ? HelaColors.primary : HelaColors.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(HelaAppState appState) {
    final showTours = _selectedFilterIndex == 0 || _selectedFilterIndex == 1;
    final showHavens = _selectedFilterIndex == 0 || _selectedFilterIndex == 2;
    final showStays = _selectedFilterIndex == 0 || _selectedFilterIndex == 3;
    final showExp = _selectedFilterIndex == 0 || _selectedFilterIndex == 4;

    final visibleTours = showTours ? appState.savedTours : <TourPlan>[];
    final visibleHavens = showHavens ? appState.savedHavens : <HavenItem>[];
    final visibleStays = showStays ? appState.savedStays : <StayHaven>[];
    final visibleExp = showExp ? appState.savedExperiences : <ExperienceItem>[];

    final totalVisible = visibleTours.length + visibleHavens.length + visibleStays.length + visibleExp.length;

    if (totalVisible == 0) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Saved Smart Tours ─────────────────────────────────────
        if (visibleTours.isNotEmpty) ...[
          if (_selectedFilterIndex == 0)
            _buildSectionHeader('Smart Tours & Itineraries', visibleTours.length),
          ...visibleTours.map((tour) => _buildSavedTourCardItem(tour, appState)),
        ],

        // ── Saved Havens & Excursions ─────────────────────────────
        if (visibleHavens.isNotEmpty) ...[
          if (_selectedFilterIndex == 0 && visibleTours.isNotEmpty)
            const SizedBox(height: 12),
          if (_selectedFilterIndex == 0)
            _buildSectionHeader('Havens & Excursions', visibleHavens.length),
          ...visibleHavens.map((haven) => _buildHavenCardItem(haven, appState)),
        ],

        // ── Saved Eco-Stays ──────────────────────────────────────
        if (visibleStays.isNotEmpty) ...[
          if (_selectedFilterIndex == 0) ...[
            const SizedBox(height: 12),
            _buildSectionHeader('Eco-Stays & Lodges', visibleStays.length),
          ],
          ...visibleStays.map((stay) => _buildStayCardItem(stay, appState)),
        ],

        // ── Saved Experiences ────────────────────────────────────
        if (visibleExp.isNotEmpty) ...[
          if (_selectedFilterIndex == 0) ...[
            const SizedBox(height: 12),
            _buildSectionHeader('Trending Experiences', visibleExp.length),
          ],
          ...visibleExp.map((exp) => _buildExperienceCardItem(exp, appState)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: HelaColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: HelaColors.tertiaryFixed.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: HelaColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedTourCardItem(TourPlan tour, HelaAppState appState) {
    final totalActivities = tour.days.fold(0, (sum, d) => sum + d.activities.length);
    final costPerPerson = tour.estimatedTotalCostUsd?.toInt() ?? 225;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF19331F), Color(0xFF274B2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TourPlanDetailsPage(plan: tour),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag Row: Duration Badge + Price + Bookmark Unsave Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: HelaColors.tertiaryFixed,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome_rounded, size: 14, color: HelaColors.onTertiaryFixed),
                          const SizedBox(width: 5),
                          Text(
                            '${tour.durationDays} Days Itinerary',
                            style: const TextStyle(
                              color: HelaColors.onTertiaryFixed,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '~\$$costPerPerson / person',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            appState.removeSavedTour(tour.id);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Removed "${tour.title}" from Saved'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  textColor: HelaColors.tertiaryFixed,
                                  onPressed: () => appState.saveTour(tour),
                                ),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.bookmark_rounded,
                              color: HelaColors.tertiaryFixed,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Tour Title
                Text(
                  tour.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),

                // Summary
                Text(
                  tour.summary.isNotEmpty
                      ? tour.summary
                      : 'A handcrafted ${tour.durationDays}-day journey across Sri Lanka.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 13,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Days & Activities Bar + Action Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 14, color: HelaColors.tertiaryFixed),
                      const SizedBox(width: 6),
                      Text(
                        '${tour.days.length} Days',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      if (totalActivities > 0) ...[
                        const Text(' · ', style: TextStyle(color: Colors.white54)),
                        const Icon(Icons.explore_rounded, size: 14, color: HelaColors.tertiaryFixed),
                        const SizedBox(width: 6),
                        Text(
                          '$totalActivities Activities',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                      const Spacer(),
                      const Text(
                        'View Tour',
                        style: TextStyle(
                          color: HelaColors.tertiaryFixed,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: HelaColors.tertiaryFixed),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHavenCardItem(HavenItem haven, HelaAppState appState) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: HavenCard.fromHavenItem(
        haven,
        width: double.infinity,
        height: 380,
        isBookmarked: true,
        onBookmarkTap: () {
          _removeHavenWithUndo(context, haven, appState);
        },
        onExploreTap: () {
          if (haven.title.toLowerCase().contains('citadel') || haven.title.toLowerCase().contains('sigiriya')) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CulturalGuidePage()),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SmartTourHomePage()),
            );
          }
        },
      ),
    );
  }

  Widget _buildStayCardItem(StayHaven stay, HelaAppState appState) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: StayCard.fromStayHaven(
        stay,
        isBookmarked: true,
        onBookmarkTap: () {
          appState.toggleSaveStay(stay);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Removed "${stay.title}" from Saved'),
              action: SnackBarAction(
                label: 'Undo',
                textColor: HelaColors.tertiaryFixed,
                onPressed: () => appState.toggleSaveStay(stay),
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        },
        onViewTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const StaysPage()),
          );
        },
      ),
    );
  }

  Widget _buildExperienceCardItem(ExperienceItem exp, HelaAppState appState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: HelaColors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      exp.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: HelaColors.surfaceContainerHigh,
                        child: const Icon(Icons.landscape_rounded, color: HelaColors.primary),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bookmark button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Material(
                      color: HelaColors.primaryContainer.withValues(alpha: 0.9),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          appState.toggleSaveExperience(exp);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Removed "${exp.title}" from Saved'),
                              action: SnackBarAction(
                                label: 'Undo',
                                textColor: HelaColors.tertiaryFixed,
                                onPressed: () => appState.toggleSaveExperience(exp),
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(7.0),
                          child: Icon(
                            Icons.bookmark_rounded,
                            size: 18,
                            color: HelaColors.tertiaryFixed,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Category badge
                  Positioned(
                    bottom: 10,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: HelaColors.tertiaryFixed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(exp.categoryIcon, size: 12, color: HelaColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            exp.category,
                            style: const TextStyle(
                              color: HelaColors.primary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exp.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: HelaColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 13, color: HelaColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              exp.duration,
                              style: const TextStyle(
                                fontSize: 12,
                                color: HelaColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD4A017)),
                            const SizedBox(width: 2),
                            Text(
                              exp.rating.toString(),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${exp.price}/p',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: HelaColors.primary,
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: HelaColors.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: HelaColors.tertiaryFixed.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.bookmark_outline_rounded,
                size: 42,
                color: HelaColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Your Saved Sanctuary is Empty',
            style: TextStyle(
              color: HelaColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Discover Ceylon’s iconic bridges, tea estates, ancient citadels, and wildlife safaris. Tap the bookmark icon on any card to save it here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: HelaColors.onSurfaceVariant,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HelaHomePage()),
              );
            },
            icon: const Icon(Icons.explore_rounded, size: 18),
            label: const Text(
              'Explore Havens & Tours',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: HelaColors.primary,
              foregroundColor: HelaColors.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removeHavenWithUndo(BuildContext context, HavenItem haven, HelaAppState appState) {
    appState.toggleSaveHaven(haven);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "${haven.title}" from Saved'),
        action: SnackBarAction(
          label: 'Undo',
          textColor: HelaColors.tertiaryFixed,
          onPressed: () {
            appState.toggleSaveHaven(haven);
          },
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context, HelaAppState appState) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: HelaColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Clear Saved Items?',
          style: TextStyle(fontWeight: FontWeight.w800, color: HelaColors.primary),
        ),
        content: const Text(
          'Are you sure you want to remove all saved smart tours, havens, stays, and experiences from your wishlist?',
          style: TextStyle(color: HelaColors.onSurfaceVariant, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: HelaColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              for (final t in List<TourPlan>.from(appState.savedTours)) {
                appState.removeSavedTour(t.id);
              }
              for (final h in List<HavenItem>.from(appState.savedHavens)) {
                appState.removeSavedHaven(h.title);
              }
              for (final s in List<StayHaven>.from(appState.savedStays)) {
                appState.removeSavedStay(s.title);
              }
              for (final e in List<ExperienceItem>.from(appState.savedExperiences)) {
                appState.removeSavedExperience(e.title);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                label: 'Explore',
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore_rounded,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HelaHomePage()),
                  );
                },
              ),
              _buildNavItem(
                index: 1,
                label: 'Saved',
                icon: Icons.bookmark_border_rounded,
                activeIcon: Icons.bookmark_rounded,
              ),
              _buildNavItem(
                index: 2,
                label: 'Discover',
                icon: Icons.travel_explore_outlined,
                activeIcon: Icons.travel_explore_rounded,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const TravelPreferencesPage()),
                  );
                },
              ),
              _buildNavItem(
                index: 3,
                label: 'Journeys',
                icon: Icons.route_outlined,
                activeIcon: Icons.route_rounded,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const TripPlannerPage()),
                  );
                },
              ),
              _buildNavItem(
                index: 4,
                label: 'Profile',
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    VoidCallback? onTap,
  }) {
    final isActive = _selectedNavIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? HelaColors.primary : HelaColors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive ? HelaColors.primary : HelaColors.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
