import 'package:flutter/material.dart';
import 'package:hela/models/saved_list.dart';
import 'package:hela/models/tour_plan.dart';
import 'package:hela/pages/cultural_guide/cultural_guide_page.dart';
import 'package:hela/pages/home_page.dart';
import 'package:hela/pages/smart_tour/smart_tour_home_page.dart';
import 'package:hela/pages/smart_tour/tour_plan_details_page.dart';
import 'package:hela/pages/stays_page.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/widgets/haven_card.dart';
import 'package:hela/widgets/stay_card.dart';

/// Dedicated Saved / Wishlist Page for the HELA app.
///
/// Displays all saved Haven cards, Eco-Stays, Tours, and Experiences,
/// with support for custom user-created categorized collections/lists.
class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  int _selectedFilterIndex = 0; // 0: All, 1: Smart Tours, 2: Havens & Excursions, 3: Eco-Stays, 4: Experiences
  String? _selectedCustomListId;

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
    final selectedList = _selectedCustomListId != null
        ? appState.getCustomList(_selectedCustomListId!)
        : null;

    return Scaffold(
      backgroundColor: HelaColors.background,
      appBar: _buildAppBar(totalCount, appState),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    _buildFilterChips(
                      savedTours.length,
                      savedHavens.length,
                      savedStays.length,
                      savedExperiences.length,
                    ),
                    const SizedBox(height: 18),
                    _buildCustomCollectionsSection(appState),
                    const SizedBox(height: 18),
                    if (selectedList != null) ...[
                      _buildActiveListBanner(selectedList),
                      const SizedBox(height: 14),
                    ],
                    _buildContent(appState),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Center(
          child: Tooltip(
            message: 'Back',
            child: InkWell(
              onTap: () => Navigator.maybePop(context),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: HelaColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                  border: Border.all(color: HelaColors.architecturalBorder),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: HelaColors.primary,
                ),
              ),
            ),
          ),
        ),
      ),
      leadingWidth: 54,
      titleSpacing: 4,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: HelaColors.tertiaryFixed.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bookmark_rounded,
              color: HelaColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appState.tr('saved_collection'),
                  style: const TextStyle(
                    color: HelaColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: -0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Your Ceylon Wishlist & Bookmarks',
                  style: TextStyle(
                    color: HelaColors.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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

  Widget _buildCustomCollectionsSection(HelaAppState appState) {
    final collections = appState.customLists;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.bookmark_added_rounded, size: 18, color: HelaColors.primary),
                const SizedBox(width: 6),
                const Text(
                  'My Collections',
                  style: TextStyle(
                    color: HelaColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: -0.3,
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
                    '${collections.length}',
                    style: const TextStyle(
                      color: HelaColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => _openCreateListDialog(context, appState),
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_outline_rounded, size: 16, color: HelaColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'New List',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: HelaColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 106,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: collections.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == 0) {
                // "+ New List" card
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _openCreateListDialog(context, appState),
                  child: Container(
                    width: 116,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: HelaColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: HelaColors.primary.withValues(alpha: 0.28),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: HelaColors.tertiaryFixed.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_rounded, size: 20, color: HelaColors.primary),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '+ New List',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: HelaColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final list = collections[index - 1];
              final isSelected = _selectedCustomListId == list.id;

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  setState(() {
                    _selectedCustomListId = isSelected ? null : list.id;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? list.color.withValues(alpha: 0.12)
                        : HelaColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? list.color : HelaColors.outlineVariant.withValues(alpha: 0.5),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: list.color.withValues(alpha: 0.22),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: list.color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(list.icon, size: 16, color: list.color),
                          ),
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            iconSize: 18,
                            icon: const Icon(Icons.more_vert_rounded, color: HelaColors.onSurfaceVariant),
                            onSelected: (val) {
                              if (val == 'rename') {
                                _openCreateListDialog(context, appState, editingList: list);
                              } else if (val == 'delete') {
                                _confirmDeleteList(context, list, appState);
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'rename',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 16),
                                    SizedBox(width: 8),
                                    Text('Rename'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            list.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? list.color : HelaColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${list.itemTitles.length} saved',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? list.color : HelaColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveListBanner(CustomSavedList list) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: list.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: list.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(list.icon, size: 18, color: list.color),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12.5, color: HelaColors.onSurface),
                children: [
                  const TextSpan(text: 'Filtered by: '),
                  TextSpan(
                    text: list.name,
                    style: TextStyle(fontWeight: FontWeight.w800, color: list.color),
                  ),
                  TextSpan(text: ' (${list.itemTitles.length} items)'),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () => setState(() => _selectedCustomListId = null),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: HelaColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: HelaColors.architecturalBorder),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.close_rounded, size: 14, color: HelaColors.secondary),
                  SizedBox(width: 4),
                  Text('Clear', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: HelaColors.secondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(HelaAppState appState) {
    final selectedList = _selectedCustomListId != null ? appState.getCustomList(_selectedCustomListId!) : null;

    final showTours = _selectedFilterIndex == 0 || _selectedFilterIndex == 1;
    final showHavens = _selectedFilterIndex == 0 || _selectedFilterIndex == 2;
    final showStays = _selectedFilterIndex == 0 || _selectedFilterIndex == 3;
    final showExp = _selectedFilterIndex == 0 || _selectedFilterIndex == 4;

    final visibleTours = showTours
        ? appState.savedTours.where((t) => selectedList == null || selectedList.itemTitles.contains(t.title)).toList()
        : <TourPlan>[];
    final visibleHavens = showHavens
        ? appState.savedHavens.where((h) => selectedList == null || selectedList.itemTitles.contains(h.title)).toList()
        : <HavenItem>[];
    final visibleStays = showStays
        ? appState.savedStays.where((s) => selectedList == null || selectedList.itemTitles.contains(s.title)).toList()
        : <StayHaven>[];
    final visibleExp = showExp
        ? appState.savedExperiences.where((e) => selectedList == null || selectedList.itemTitles.contains(e.title)).toList()
        : <ExperienceItem>[];

    final totalVisible = visibleTours.length + visibleHavens.length + visibleStays.length + visibleExp.length;

    if (totalVisible == 0) {
      if (selectedList != null) {
        return _buildCustomListEmptyState(selectedList);
      }
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

  Widget _buildItemCollectionsBar(String itemTitle, HelaAppState appState) {
    final containingLists = appState.getListsContainingItem(itemTitle);

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ...containingLists.map((list) => InkWell(
                onTap: () {
                  setState(() {
                    _selectedCustomListId = list.id;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: list.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: list.color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(list.icon, size: 12, color: list.color),
                      const SizedBox(width: 4),
                      Text(
                        list.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: list.color,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          InkWell(
            onTap: () => _openManageListsSheet(context, itemTitle, appState),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: HelaColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: HelaColors.outlineVariant.withValues(alpha: 0.7)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    containingLists.isEmpty ? Icons.add_rounded : Icons.label_outline_rounded,
                    size: 13,
                    color: HelaColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    containingLists.isEmpty ? 'Add to Collection' : 'Organize',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: HelaColors.primary,
                    ),
                  ),
                ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 0),
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
        ),
        _buildItemCollectionsBar(tour.title, appState),
      ],
    );
  }

  Widget _buildHavenCardItem(HavenItem haven, HelaAppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HavenCard.fromHavenItem(
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
        _buildItemCollectionsBar(haven.title, appState),
      ],
    );
  }

  Widget _buildStayCardItem(StayHaven stay, HelaAppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StayCard.fromStayHaven(
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
        _buildItemCollectionsBar(stay.title, appState),
      ],
    );
  }

  Widget _buildExperienceCardItem(ExperienceItem exp, HelaAppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 0),
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
        ),
        _buildItemCollectionsBar(exp.title, appState),
      ],
    );
  }

  Widget _buildCustomListEmptyState(CustomSavedList list) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HelaColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: list.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(list.icon, size: 28, color: list.color),
          ),
          const SizedBox(height: 12),
          Text(
            '"${list.name}" is Empty',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: HelaColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No saved items have been added to this collection yet. You can add any tour, haven, stay, or experience to this list by tapping "Add to Collection" on its card.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: HelaColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => setState(() => _selectedCustomListId = null),
            icon: const Icon(Icons.clear_all_rounded, size: 16),
            label: const Text('Show All Saved Items'),
            style: OutlinedButton.styleFrom(
              foregroundColor: HelaColors.primary,
              side: const BorderSide(color: HelaColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
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

  void _openManageListsSheet(BuildContext context, String itemTitle, HelaAppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final lists = appState.customLists;
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: HelaColors.surfaceContainerLowest,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: HelaColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: HelaColors.tertiaryFixed.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.collections_bookmark_rounded, size: 20, color: HelaColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Organize into Collections',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: HelaColors.primary,
                              ),
                            ),
                            Text(
                              itemTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: HelaColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(sheetCtx),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (lists.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'No custom collections yet. Create your first one!',
                          style: TextStyle(color: HelaColors.onSurfaceVariant, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: lists.length,
                        itemBuilder: (context, index) {
                          final list = lists[index];
                          final isIncluded = list.itemTitles.contains(itemTitle);
                          return CheckboxListTile(
                            value: isIncluded,
                            activeColor: list.color,
                            contentPadding: EdgeInsets.zero,
                            title: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: list.color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(list.icon, size: 16, color: list.color),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    list.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: HelaColors.onSurface,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${list.itemTitles.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: HelaColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            onChanged: (bool? checked) {
                              appState.toggleItemInCustomList(list.id, itemTitle);
                              setSheetState(() {});
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        _openCreateListDialog(context, appState, initialItemTitle: itemTitle);
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Create New Collection'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: HelaColors.primary,
                        side: const BorderSide(color: HelaColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openCreateListDialog(
    BuildContext context,
    HelaAppState appState, {
    String? initialItemTitle,
    CustomSavedList? editingList,
  }) {
    final nameController = TextEditingController(text: editingList?.name ?? '');
    final descController = TextEditingController(text: editingList?.description ?? '');
    IconData selectedIcon = editingList?.icon ?? kCustomListAvailableIcons.first;
    Color selectedColor = editingList?.color ?? kCustomListAvailableColors.first;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: HelaColors.surfaceContainerLowest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 10),
            contentPadding: const EdgeInsets.symmetric(horizontal: 22),
            actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selectedColor.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(selectedIcon, color: selectedColor, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  editingList != null ? 'Edit Collection' : 'New Collection',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: HelaColors.primary),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Collection Name *',
                      hintText: 'e.g. Beach Escapes, Surf Havens',
                      filled: true,
                      fillColor: HelaColors.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: HelaColors.architecturalBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: HelaColors.architecturalBorder),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: HelaColors.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: 'Description (optional)',
                      hintText: 'e.g. My favorite spots for sunrise',
                      filled: true,
                      fillColor: HelaColors.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: HelaColors.architecturalBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: HelaColors.architecturalBorder),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: HelaColors.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose Icon',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: HelaColors.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kCustomListAvailableIcons.map((ic) {
                      final isChosen = selectedIcon == ic;
                      return InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setDialogState(() => selectedIcon = ic),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: isChosen ? selectedColor : HelaColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            ic,
                            size: 18,
                            color: isChosen ? Colors.white : HelaColors.onSurfaceVariant,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose Color Theme',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: HelaColors.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: kCustomListAvailableColors.map((col) {
                      final isChosen = selectedColor == col;
                      return InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => setDialogState(() => selectedColor = col),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: col,
                            shape: BoxShape.circle,
                            border: isChosen
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: isChosen
                                ? [
                                    BoxShadow(
                                      color: col.withValues(alpha: 0.5),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isChosen
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel', style: TextStyle(color: HelaColors.onSurfaceVariant)),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  Navigator.pop(dialogCtx);

                  if (editingList != null) {
                    appState.renameCustomList(editingList.id, name);
                  } else {
                    appState.createCustomList(
                      name: name,
                      description: descController.text.trim().isNotEmpty ? descController.text.trim() : null,
                      icon: selectedIcon,
                      color: selectedColor,
                      initialItemTitles: initialItemTitle != null ? [initialItemTitle] : null,
                    );
                  }
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HelaColors.primary,
                  foregroundColor: HelaColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(editingList != null ? 'Save' : 'Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteList(BuildContext context, CustomSavedList list, HelaAppState appState) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: HelaColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete "${list.name}"?', style: const TextStyle(fontWeight: FontWeight.w800, color: HelaColors.primary)),
        content: const Text(
          'This will remove this collection. Any saved items inside will remain in your Saved Wishlist.',
          style: TextStyle(color: HelaColors.onSurfaceVariant, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: HelaColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              if (_selectedCustomListId == list.id) {
                setState(() => _selectedCustomListId = null);
              }
              appState.deleteCustomList(list.id);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Delete'),
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
            onPressed: () => Navigator.pop(dialogCtx),
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
}
