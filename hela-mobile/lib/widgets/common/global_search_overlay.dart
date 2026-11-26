import 'package:flutter/material.dart';
import 'package:hela/data/sri_lanka_images.dart';
import 'package:hela/pages/cultural_guide/cultural_guide_page.dart';
import 'package:hela/pages/smart_tour/smart_tour_home_page.dart';
import 'package:hela/pages/bookings/stays_page.dart';
import 'package:hela/services/place_service.dart';
import 'package:hela/theme/hela_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Unified searchable data catalog
// ─────────────────────────────────────────────────────────────────────────────
class _SearchResultItem {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String? price;
  final double? rating;
  final String imageUrl;
  final IconData icon;
  final _ResultType type;

  const _SearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.price,
    this.rating,
    required this.imageUrl,
    required this.icon,
    required this.type,
  });
}

enum _ResultType { haven, stay, experience, destination }

/// All app-wide searchable data.
final List<_SearchResultItem> _allSearchData = [
  // ── Featured Havens ─────────────────────────────────────────────
  _SearchResultItem(
    id: 'haven_ella',
    title: 'Nine Arch Bridge & Demodara Tea Valley',
    subtitle: 'Ella, Highlands',
    category: 'Guided Excursion',
    price: '\$45',
    rating: 4.90,
    imageUrl: SriLankaImages.nineArchBridge,
    icon: Icons.landscape_rounded,
    type: _ResultType.haven,
  ),
  _SearchResultItem(
    id: 'haven_sigiriya',
    title: 'Ancient Citadel & Sky Palace Ascent',
    subtitle: 'Sigiriya, Cultural Triangle',
    category: 'Heritage Tour',
    price: '\$60',
    rating: 4.95,
    imageUrl: SriLankaImages.sigiriya,
    icon: Icons.account_balance_rounded,
    type: _ResultType.haven,
  ),
  _SearchResultItem(
    id: 'haven_mirissa',
    title: 'Palm Coast & Blue Whale Watch Cruise',
    subtitle: 'Mirissa, South Coast',
    category: 'Coastal Safari',
    price: '\$75',
    rating: 4.88,
    imageUrl: SriLankaImages.blueWhale,
    icon: Icons.sailing_rounded,
    type: _ResultType.haven,
  ),
  // ── Eco-Stays ───────────────────────────────────────────────────
  _SearchResultItem(
    id: 'stay_98acres',
    title: '98 Acres Luxury Tea Pavilion',
    subtitle: 'Ella Gap, Badulla',
    category: 'Eco-Stay',
    price: '\$148/night',
    rating: 4.96,
    imageUrl: SriLankaImages.ella,
    icon: Icons.hotel_rounded,
    type: _ResultType.stay,
  ),
  _SearchResultItem(
    id: 'stay_amba',
    title: 'Amba Organic Farm & Heritage Lodge',
    subtitle: 'Ambagamuwa, Highlands',
    category: 'Eco-Stay',
    price: '\$85/night',
    rating: 4.88,
    imageUrl: SriLankaImages.ceylonTea,
    icon: Icons.cottage_rounded,
    type: _ResultType.stay,
  ),
  // ── Trending Experiences ─────────────────────────────────────────
  _SearchResultItem(
    id: 'exp_sunrise',
    title: 'Sunrise Hike & Kandy Tea Tasting',
    subtitle: '4.5 Hours · Highland Terroir',
    category: 'Experience',
    price: '\$38/person',
    rating: 4.9,
    imageUrl: SriLankaImages.kandyLake,
    icon: Icons.local_florist_rounded,
    type: _ResultType.experience,
  ),
  _SearchResultItem(
    id: 'exp_yala',
    title: 'Yala Leopard Safari at Dawn',
    subtitle: '6.0 Hours · Wildlife Reserve',
    category: 'Experience',
    price: '\$92/jeep',
    rating: 4.96,
    imageUrl: SriLankaImages.leopard,
    icon: Icons.pets_rounded,
    type: _ResultType.experience,
  ),
  _SearchResultItem(
    id: 'exp_galle',
    title: 'Galle Fort Sunset Walk & Spices',
    subtitle: '3.0 Hours · Culinary Heritage',
    category: 'Experience',
    price: '\$42/person',
    rating: 4.89,
    imageUrl: SriLankaImages.galleFort,
    icon: Icons.restaurant_rounded,
    type: _ResultType.experience,
  ),
  // ── Curated OSM Destinations ────────────────────────────────────
  ..._buildDestinationItems(),
];

List<_SearchResultItem> _buildDestinationItems() {
  return PlaceService.curatedSriLankaPlaces.map((d) {
    final text = d.categories.join(' ').toLowerCase();
    IconData icon;
    if (text.contains('wildlife') || text.contains('safari')) {
      icon = Icons.pets_rounded;
    } else if (text.contains('beach') || text.contains('coast')) {
      icon = Icons.beach_access_rounded;
    } else if (text.contains('historic') || text.contains('heritage')) {
      icon = Icons.account_balance_rounded;
    } else if (text.contains('hik') || text.contains('highland')) {
      icon = Icons.hiking_rounded;
    } else if (text.contains('spiritual') || text.contains('temple')) {
      icon = Icons.temple_buddhist_rounded;
    } else {
      icon = Icons.place_rounded;
    }
    return _SearchResultItem(
      id: d.sourceId,
      title: d.name,
      subtitle: d.region,
      category: d.categories.isNotEmpty ? d.categories.first : 'Destination',
      rating: d.relevanceScore,
      imageUrl: d.imageUrl,
      icon: icon,
      type: _ResultType.destination,
    );
  }).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
//  Floating Search Button — drop this into any Scaffold's floatingActionButton
// ─────────────────────────────────────────────────────────────────────────────
class GlobalSearchFAB extends StatelessWidget {
  const GlobalSearchFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'global_search_fab',
      onPressed: () => _openSearch(context),
      backgroundColor: HelaColors.primary,
      foregroundColor: HelaColors.onPrimary,
      elevation: 4,
      icon: const Icon(Icons.search_rounded, size: 22),
      label: const Text(
        'Search',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  static void _openSearch(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (ctx, animation, secondary) {
          return FadeTransition(
            opacity: animation,
            child: const GlobalSearchOverlay(),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Global Full-Screen Search Overlay
// ─────────────────────────────────────────────────────────────────────────────
class GlobalSearchOverlay extends StatefulWidget {
  const GlobalSearchOverlay({super.key});

  @override
  State<GlobalSearchOverlay> createState() => _GlobalSearchOverlayState();
}

class _GlobalSearchOverlayState extends State<GlobalSearchOverlay>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  String _selectedFilter = 'All';

  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  static const _filters = ['All', 'Havens', 'Stays', 'Experiences', 'Destinations'];

  // Popular quick suggestions
  static const _suggestions = [
    'Sigiriya', 'Ella', 'Galle Fort', 'Yala Safari',
    'Mirissa Beach', 'Kandy', 'Nuwara Eliya', 'Trincomalee',
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();

    // Auto-focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _slideController.dispose();
    super.dispose();
  }

  List<_SearchResultItem> get _results {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();

    return _allSearchData.where((item) {
      // Filter by category tab
      if (_selectedFilter != 'All') {
        final match = switch (_selectedFilter) {
          'Havens' => item.type == _ResultType.haven,
          'Stays' => item.type == _ResultType.stay,
          'Experiences' => item.type == _ResultType.experience,
          'Destinations' => item.type == _ResultType.destination,
          _ => true,
        };
        if (!match) return false;
      }

      // Fuzzy text match
      return item.title.toLowerCase().contains(q) ||
          item.subtitle.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Column(
          children: [
            // ── Search card ──────────────────────────────────────
            SlideTransition(
              position: _slideAnimation,
              child: _buildSearchCard(context),
            ),

            // ── Results sheet ────────────────────────────────────
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: Colors.transparent,
                  child: _query.isEmpty
                      ? _buildSuggestionsPanel()
                      : results.isEmpty
                          ? _buildEmptyState()
                          : _buildResultsList(results),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: HelaColors.surface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row ──────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: HelaColors.tertiaryFixed.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.travel_explore_rounded,
                  color: HelaColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Search Ceylon',
                      style: TextStyle(
                        color: HelaColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      'Destinations · Havens · Stays · Experiences',
                      style: TextStyle(
                        color: HelaColors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: HelaColors.onSurfaceVariant),
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: HelaColors.surfaceContainerLowest,
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Search input ───────────────────────────────────────
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: HelaColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? HelaColors.primaryContainer
                    : HelaColors.outlineVariant.withValues(alpha: 0.6),
                width: _focusNode.hasFocus ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16, right: 8),
                  child: Icon(
                    Icons.search_rounded,
                    color: HelaColors.primaryContainer,
                    size: 22,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: (val) => setState(() => _query = val.trim()),
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(
                      fontSize: 15,
                      color: HelaColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Where in Sri Lanka? Try "Ella" or "Kandy"',
                      hintStyle: TextStyle(
                        color: HelaColors.onSurfaceVariant.withValues(alpha: 0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_query.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: HelaColors.outline),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                    padding: const EdgeInsets.all(8),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Filter chips ───────────────────────────────────────
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _filters.length,
              separatorBuilder: (_, i) => const SizedBox(width: 7),
              itemBuilder: (ctx, i) {
                final f = _filters[i];
                final isSelected = _selectedFilter == f;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? HelaColors.primaryContainer
                          : HelaColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? HelaColors.primaryContainer
                            : HelaColors.outlineVariant.withValues(alpha: 0.55),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        f,
                        style: TextStyle(
                          color: isSelected
                              ? HelaColors.onPrimary
                              : HelaColors.onSurfaceVariant,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Suggestions panel (shown when query is empty) ──────────────
  Widget _buildSuggestionsPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: BoxDecoration(
        color: HelaColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded, size: 16, color: HelaColors.secondary),
                  const SizedBox(width: 6),
                  const Text(
                    'Popular in Sri Lanka',
                    style: TextStyle(
                      color: HelaColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: HelaColors.surfaceContainer),
            // Suggestion tiles
            ..._suggestions.map((sug) => InkWell(
                  onTap: () {
                    _controller.text = sug;
                    setState(() => _query = sug);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: HelaColors.tertiaryFixed.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(Icons.search_rounded,
                                size: 15, color: HelaColors.primary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            sug,
                            style: const TextStyle(
                              color: HelaColors.onSurface,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(Icons.north_west_rounded,
                            size: 14, color: HelaColors.onSurfaceVariant),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // ── Results list ───────────────────────────────────────────────
  Widget _buildResultsList(List<_SearchResultItem> results) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
      itemCount: results.length + 1,
      itemBuilder: (ctx, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 4),
            child: Text(
              '${results.length} result${results.length != 1 ? 's' : ''} for "$_query"',
              style: const TextStyle(
                color: HelaColors.onSurfaceVariant,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
        return _buildResultCard(results[i - 1]);
      },
    );
  }

  Widget _buildResultCard(_SearchResultItem item) {
    final typeColor = switch (item.type) {
      _ResultType.haven => HelaColors.secondary,
      _ResultType.stay => const Color(0xFF6B7C3A),
      _ResultType.experience => const Color(0xFF8B6914),
      _ResultType.destination => HelaColors.primaryContainer,
    };

    final typeBg = switch (item.type) {
      _ResultType.haven => HelaColors.secondaryContainer,
      _ResultType.stay => const Color(0xFFEEF2DC),
      _ResultType.experience => const Color(0xFFFFF3CD),
      _ResultType.destination => HelaColors.surfaceContainer,
    };

    final typeLabel = switch (item.type) {
      _ResultType.haven => 'HAVEN',
      _ResultType.stay => 'ECO-STAY',
      _ResultType.experience => 'EXPERIENCE',
      _ResultType.destination => 'DESTINATION',
    };

    return GestureDetector(
      onTap: () => _navigateTo(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: HelaColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
              child: SizedBox(
                width: 86,
                height: 86,
                child: item.imageUrl.isNotEmpty
                    ? Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, e, st) => _fallbackThumb(item.icon),
                      )
                    : _fallbackThumb(item.icon),
              ),
            ),

            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: typeBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            typeLabel,
                            style: TextStyle(
                              color: typeColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 9.5,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (item.rating != null) ...[
                          const Icon(Icons.star_rounded, size: 13, color: Color(0xFFD4A017)),
                          const SizedBox(width: 2),
                          Text(
                            item.rating!.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: HelaColors.onSurface,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: HelaColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 11, color: HelaColors.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            item.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: HelaColors.onSurfaceVariant,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                        if (item.price != null)
                          Text(
                            item.price!,
                            style: const TextStyle(
                              color: HelaColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Arrow
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: HelaColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackThumb(IconData icon) {
    return Container(
      color: HelaColors.surfaceContainerHigh,
      child: Center(
        child: Icon(icon, color: HelaColors.primary, size: 28),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: HelaColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: HelaColors.tertiaryFixed.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.search_off_rounded, size: 32, color: HelaColors.primary),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No results for "$_query"',
            style: const TextStyle(
              color: HelaColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try searching for a city, landmark, or activity.\nExample: "Kandy", "Safari", "Tea Estate"',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: HelaColors.onSurfaceVariant,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Navigation ────────────────────────────────────────────────
  void _navigateTo(_SearchResultItem item) {
    Navigator.of(context).pop(); // close overlay

    final ctx = context;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (item.type) {
        case _ResultType.haven:
        case _ResultType.experience:
        case _ResultType.destination:
          if (item.id.contains('sigiriya') ||
              item.title.toLowerCase().contains('citadel') ||
              item.title.toLowerCase().contains('sigiriya') ||
              item.id.contains('temple') ||
              item.title.toLowerCase().contains('cultural')) {
            Navigator.of(ctx).push(
              MaterialPageRoute(builder: (_) => const CulturalGuidePage()),
            );
          } else {
            Navigator.of(ctx).push(
              MaterialPageRoute(builder: (_) => const SmartTourHomePage()),
            );
          }
          break;
        case _ResultType.stay:
          Navigator.of(ctx).push(
            MaterialPageRoute(builder: (_) => const StaysPage()),
          );
          break;
      }
    });
  }
}
