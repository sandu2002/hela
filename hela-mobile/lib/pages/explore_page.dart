import 'package:flutter/material.dart';
import 'package:hela/pages/cultural_guide/cultural_guide_page.dart';
import 'package:hela/pages/profile_page.dart';
import 'package:hela/pages/saved_page.dart';
import 'package:hela/theme/hela_colors.dart';
import 'package:hela/widgets/hela_bottom_nav_bar.dart';
import 'package:hela/widgets/hela_drawer.dart';
import 'package:hela/widgets/real_time_map.dart';
import 'package:hela/widgets/theme_switch_button.dart';

/// Data models for the Explore Sri Lanka Screen
class ExploreDestination {
  final String id;
  final String name;
  final String subtitle;
  final String region;
  final String rating;
  final String badge;
  final String priceTag;
  final String footerTag;
  final String imageUrl;
  final String category;

  const ExploreDestination({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.region,
    required this.rating,
    required this.badge,
    required this.priceTag,
    required this.footerTag,
    required this.imageUrl,
    required this.category,
  });
}

class HiddenGemItem {
  final String id;
  final String title;
  final String subtitle;
  final String badge;
  final String distance;
  final String rating;
  final String imageUrl;
  final String category;

  const HiddenGemItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.distance,
    required this.rating,
    required this.imageUrl,
    required this.category,
  });
}

class CulturalExperienceItem {
  final String id;
  final String title;
  final String subtitle;
  final String duration;
  final String price;
  final String tag;
  final String verifiedNote;
  final String ctaText;
  final String imageUrl;
  final String category;

  const CulturalExperienceItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.price,
    required this.tag,
    required this.verifiedNote,
    required this.ctaText,
    required this.imageUrl,
    required this.category,
  });
}

class NearbyPlaceItem {
  final String title;
  final String subtitle;
  final String distance;
  final String status;
  final String imageUrl;

  const NearbyPlaceItem({
    required this.title,
    required this.subtitle,
    required this.distance,
    required this.status,
    required this.imageUrl,
  });
}

/// HELA - Explore Sri Lanka Page
/// Conforms to Google Stitch Screen: HELA - Explore Sri Lanka (`12d81a19983f4073aefbbe983c1507d8`)
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isMapView = false;
  int _selectedCategoryIndex = 0; // 0: All, 1: Nature, 2: Beaches, 3: Culture, 4: Wildlife, 5: Adventure, 6: Food
  final Set<String> _savedIds = {'sigiriya', 'ritigala'};

  final List<Map<String, dynamic>> _categories = const [
    {'label': 'All', 'icon': null},
    {'label': 'Nature', 'icon': Icons.forest_rounded},
    {'label': 'Beaches', 'icon': Icons.waves_rounded},
    {'label': 'Culture', 'icon': Icons.temple_buddhist_rounded},
    {'label': 'Wildlife', 'icon': Icons.pets_rounded},
    {'label': 'Adventure', 'icon': Icons.hiking_rounded},
    {'label': 'Food', 'icon': Icons.restaurant_rounded},
  ];

  final List<ExploreDestination> _popularDestinations = const [
    ExploreDestination(
      id: 'sigiriya',
      name: 'Sigiriya',
      subtitle: 'Lion Rock & Water Gardens',
      region: 'Central Province',
      rating: '5.0 • UNESCO',
      badge: 'UNESCO',
      priceTag: '\$36 entry',
      footerTag: '1,200 Steps Climb',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB470bfrsJ34_Zfz3mF8BpQZOUum-fhawKh51cm1K8-0n16IJnyIRDWCDo-p-4LKlIJL7eWRS6fSHiQ7Y076dniwfTg2-uSNGP-Y1fU4rUt8gQCz0RWM_EspICB8L-E9uu3ZguLz8MSZG0MZai01QaMRbw9u7NFJ6XRoYIDFwFMifvWSsy_XhyQ2UkxBFBJVs0TNFtCkUr-O7xCS0cyKCNy4TCnZZq8uzJM0M3dU9c',
      category: 'Culture',
    ),
    ExploreDestination(
      id: 'ella',
      name: 'Ella',
      subtitle: 'Nine Arch Bridge & Adam\'s Peak',
      region: 'Badulla District',
      rating: '4.9 • Valleys',
      badge: 'Highlands',
      priceTag: 'Free Access',
      footerTag: 'Cloud Forest Treks',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC1-w7059r6Tx8JOuHhGLLm6spMsWw09E48ApBmOWTEe-p-IbOyd8GBmFh3Zvn60CK2ZR0YsjHx75NDRUWyT2eYsmsMBsoNsO380YPX-8NkCVlAl9L84IrpVcJskPmn7bby1SLlQNDsytKDChKgPdcmfeIa6V14oUmNsO-WDDWQZJlHl_dJvco52RzpSUA0AS2JlopPWLNhvwsNiRGcKN4YqXKlwv5GpBLlmhs9TRI',
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'kandy',
      name: 'Kandy',
      subtitle: 'Sacred Temple & Royal Gardens',
      region: 'Central Highlands',
      rating: '4.8 • Heritage',
      badge: 'Heritage',
      priceTag: '\$6 entry',
      footerTag: 'Cultural Capital',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAf_ZHki056g4HPCYefzjMlcb2RDYtvjthd-ddHXXVe627O2eS1UoDIgiQ_L-HKdkLD9fKmpLz29XjJCzAX-uHg68hnR6w8d8wJJJasNuOqCFl3pVUmgcPmjQzd1eEzWMovtcNQjv5uQV-wGNks7fK8WOBUFpNVKYzvyjP0oOxlEXwSUQgjWHLC-mO86yMwUkMCo4fc0t_xHB8t1iRNYNQe3OQwojumYbhjBuANTUk',
      category: 'Culture',
    ),
    ExploreDestination(
      id: 'galle',
      name: 'Galle Fort',
      subtitle: 'Historic Dutch Fort & Ramparts',
      region: 'Southern Coast',
      rating: '4.9 • Colonial',
      badge: 'Colonial Fort',
      priceTag: 'Open Ramparts',
      footerTag: 'Coastal History',
      imageUrl:
          'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
      category: 'Culture',
    ),
    ExploreDestination(
      id: 'mirissa',
      name: 'Mirissa',
      subtitle: 'Coconut Tree Hill & Whales',
      region: 'South Coast',
      rating: '4.9 • Marine',
      badge: 'South Coast',
      priceTag: 'Whale Watch',
      footerTag: 'Surf & Sunset',
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
      category: 'Beaches',
    ),
    ExploreDestination(
      id: 'nuwara_eliya',
      name: 'Nuwara Eliya',
      subtitle: 'Tea Factory Estates & Gregory Lake',
      region: 'Cool Highlands',
      rating: '4.8 • Highlands',
      badge: 'Tea Trails',
      priceTag: '16°C Fresh Climate',
      footerTag: 'Tea Trails',
      imageUrl:
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&auto=format&fit=crop&q=80',
      category: 'Nature',
    ),
  ];

  final List<HiddenGemItem> _hiddenGems = const [
    HiddenGemItem(
      id: 'ritigala',
      title: 'Ritigala Strict Nature Reserve',
      subtitle:
          'Ancient ruined forest monastery wrapped in giant jungle vines and mystical medicinal herbal groves.',
      badge: 'OFFBEAT SANCTUARY',
      distance: '3.5 hrs from Colombo',
      rating: '4.9',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDw7m0Jp7z4-JvFq71gT586fO3yK49d4lV04b9p3095s937y0v5F229_Vl-y4U_024b1k5-592f6b3n4n_2b3n5v08_309b5v234n10v09b4n35_283b9c9_489b489d2_0284n308945n_3b940n859_2485',
      category: 'Nature',
    ),
    HiddenGemItem(
      id: 'tangalle',
      title: 'Tangalle Silent Beach',
      subtitle:
          'Pristine secluded turquoise cove lined with wild coconut palms and crashing azure surf.',
      badge: 'UNTOUCHED HAVEN',
      distance: '2 hrs from Galle',
      rating: '4.9',
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
      category: 'Beaches',
    ),
    HiddenGemItem(
      id: 'knuckles',
      title: 'Riverston & Knuckles Range',
      subtitle:
          'The mini World\'s End cloud forest trek featuring windswept plains and cascading mountain streams.',
      badge: 'CLOUD FOREST TREK',
      distance: '1.5 hrs from Kandy',
      rating: '4.8',
      imageUrl:
          'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
      category: 'Adventure',
    ),
  ];

  final List<CulturalExperienceItem> _culturalExperiences = const [
    CulturalExperienceItem(
      id: 'dambulla',
      title: 'Dambulla Cave Temple Sanctuary',
      subtitle:
          'Five ancient sacred sanctuaries adorned with 150+ gilded Buddha statues and 2,000-year-old rock frescoes.',
      duration: '2-3 hrs',
      price: '\$7 per person',
      tag: 'Audio Guide',
      verifiedNote: 'Bilingual Guide available',
      ctaText: 'Book Experience',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDuZqkObEsz32UwPA_EzpkVa72_jKilGK4KaIUYvwiteU_R8AiDFJ53hlPk1G4Q3u2-tlTUR7VzbjKf3G9KxTPb0pzMkXGsCypGxzuLyueX60cPtiewuzkFJP62_eqlXUBWbwVuiUSxCWxWh02iyR0yO2JJ48F0DAWp8xRWg9_iF_FqbrxGelTKtq8qa-h1RCGHewkM0jxcCUJj68H1fgDReRSfX_qRBsI-a8qM2GE',
      category: 'Culture',
    ),
    CulturalExperienceItem(
      id: 'galle_trail',
      title: 'Galle Fort Historic Ramparts Trail',
      subtitle:
          '17th-century bastion ramparts, Dutch colonial architecture, maritime spice trading lore, and sunset lighthouse walk.',
      duration: '1.5-2 hrs',
      price: 'Free / Guided \$15',
      tag: 'Walking Tour',
      verifiedNote: 'Local Historian',
      ctaText: 'Explore Trail',
      imageUrl:
          'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
      category: 'Culture',
    ),
    CulturalExperienceItem(
      id: 'kandy_dance',
      title: 'Kandyan Cultural & Fire Dance Show',
      subtitle:
          'Vibrant low-country drum ceremonies, ceremonial peacock dances, and thrilling barefoot fire-walking rituals.',
      duration: '1 hr Show',
      price: '\$10 Ticket',
      tag: 'Live Theatre',
      verifiedNote: 'Reserve Seat',
      ctaText: 'View Schedule',
      imageUrl:
          'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
      category: 'Culture',
    ),
  ];

  final List<NearbyPlaceItem> _nearbyPlaces = const [
    NearbyPlaceItem(
      title: 'Gangaramaya Temple',
      subtitle: 'Eclectic Buddhist temple by Beira Lake',
      distance: '2.4 km',
      status: 'Open now • Closes 6 PM',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAsm2mS9aOxobBvTE1d80E9BTn-hH6x46Z0tIyr5jCTqGOsojeN971g0PZtNqJwutVgFpkQCDWJPETS2c3917HMAcgKXbCmCX6bRNOopQKnU5dmZFyqp5sxiyAMYEjb6rCg-YuHzEdP7tWPMISoTlVJhSP8BgBsFzNcZ8mUeaGKiDNK8NUaR7uFM9i2JV7bZbXBJ35ivIWDZIfLBVSqOQ7NBMbqgundXJUe2urCwl8',
    ),
    NearbyPlaceItem(
      title: 'Pettah & Red Mosque',
      subtitle: 'Historic vibrant spice bazaar & candy-striped mosque',
      distance: '3.8 km',
      status: 'Open now • Closes 8 PM',
      imageUrl:
          'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
    ),
    NearbyPlaceItem(
      title: 'Mount Lavinia Shore',
      subtitle: 'Colonial beachside sunset promenade',
      distance: '9.5 km',
      status: 'Open 24 hrs • Best at sunset',
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSave(String id, String title) {
    setState(() {
      if (_savedIds.contains(id)) {
        _savedIds.remove(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed "$title" from Saved Sanctuary')),
        );
      } else {
        _savedIds.add(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved "$title" to Wishlist')),
        );
      }
    });
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedCat = _categories[_selectedCategoryIndex]['label'] as String;
    final query = _searchQuery.trim().toLowerCase();

    // Filter Popular Destinations
    final filteredDestinations = _popularDestinations.where((d) {
      final matchesCat = selectedCat == 'All' || d.category == selectedCat;
      final matchesQuery = query.isEmpty ||
          d.name.toLowerCase().contains(query) ||
          d.subtitle.toLowerCase().contains(query) ||
          d.region.toLowerCase().contains(query);
      return matchesCat && matchesQuery;
    }).toList();

    // Filter Hidden Gems
    final filteredGems = _hiddenGems.where((g) {
      final matchesCat = selectedCat == 'All' || g.category == selectedCat;
      final matchesQuery = query.isEmpty ||
          g.title.toLowerCase().contains(query) ||
          g.subtitle.toLowerCase().contains(query);
      return matchesCat && matchesQuery;
    }).toList();

    // Filter Cultural Experiences
    final filteredExperiences = _culturalExperiences.where((e) {
      final matchesCat = selectedCat == 'All' || e.category == selectedCat;
      final matchesQuery = query.isEmpty ||
          e.title.toLowerCase().contains(query) ||
          e.subtitle.toLowerCase().contains(query);
      return matchesCat && matchesQuery;
    }).toList();

    return Scaffold(
      key: _scaffoldKey,
      drawer: const HelaNavigationDrawer(),
      backgroundColor: colors.background,
      appBar: _buildTopAppBar(colors, isDark),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 120),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        // Title & View Switcher Row
                        _buildTitleAndViewSwitcher(colors),
                        const SizedBox(height: 14),

                        // Search & Filter Bar
                        _buildSearchAndFilterBar(colors),
                        const SizedBox(height: 14),

                        // Category Filter Pills
                        _buildCategoryFilterPills(colors),
                        const SizedBox(height: 20),

                        if (_isMapView) ...[
                          // Interactive Map View
                          _buildInteractiveMapView(colors),
                          const SizedBox(height: 20),
                        ],

                        // SECTION 1: Popular Destinations
                        _buildPopularDestinationsSection(colors, filteredDestinations),
                        const SizedBox(height: 26),

                        // SECTION 2: Hidden Gems
                        _buildHiddenGemsSection(colors, filteredGems),
                        const SizedBox(height: 26),

                        // SECTION 3: Cultural Experiences
                        _buildCulturalExperiencesSection(colors, filteredExperiences),
                        const SizedBox(height: 26),

                        // SECTION 4: Nearby Discoveries
                        _buildNearbyDiscoveriesSection(colors),
                        const SizedBox(height: 20),

                        // Delight Banner: HELA Smart Local Assistant
                        _buildDelightAiBanner(colors),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Floating "Smart Guide • Ask HELA" Action Button in Bottom Right
            Positioned(
              bottom: 16,
              right: 16,
              child: HelaBottomNavBar.buildFloatingAskHelaButton(context),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const HelaBottomNavBar(currentIndex: 1),
    );
  }

  PreferredSizeWidget _buildTopAppBar(HelaColorPalette colors, bool isDark) {
    return AppBar(
      backgroundColor: colors.surface.withValues(alpha: isDark ? 0.96 : 0.94),
      elevation: 0,
      scrolledUnderElevation: 1.0,
      shadowColor: Colors.black12,
      toolbarHeight: 64,
      titleSpacing: 16,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          InkWell(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.explore_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HELA TRAVEL',
                style: TextStyle(
                  color: colors.secondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                'Explore',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Inter',
                  height: 1.15,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        const HelaThemeSwitchButton(size: 34),
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: colors.onSurfaceVariant, size: 22),
          tooltip: 'Notifications',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No new travel alerts')),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 4),
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
            child: CircleAvatar(
              radius: 16,
              backgroundColor: colors.primary,
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleAndViewSwitcher(HelaColorPalette colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore Sri Lanka',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                  fontFamily: 'Inter',
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Find places worth discovering.',
                style: TextStyle(
                  fontSize: 13,
                  color: colors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // List / Map View Switcher Pill
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  InkResponse(
                    key: const ValueKey('explore_list_toggle'),
                    onTap: () => setState(() => _isMapView = false),
                    radius: 18,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: !_isMapView ? colors.primary : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.format_list_bulleted_rounded,
                        size: 17,
                        color: !_isMapView ? Colors.white : colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  InkResponse(
                    key: const ValueKey('explore_map_toggle'),
                    onTap: () => setState(() => _isMapView = true),
                    radius: 18,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _isMapView ? colors.primary : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.map_rounded,
                        size: 17,
                        color: _isMapView ? Colors.white : colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Favorites Button
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedPage()));
              },
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.architecturalBorder),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.bookmark_rounded, size: 20, color: colors.secondary),
                    Positioned(
                      top: 7,
                      right: 7,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: colors.goldenAmber,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterBar(HelaColorPalette colors) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.architecturalBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, size: 20, color: colors.secondary),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: TextStyle(
                      fontSize: 13.5,
                      color: colors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      filled: false,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Search destinations, attractions...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: Icon(Icons.close_rounded, size: 18, color: colors.outline),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.architecturalBorder),
          ),
          child: IconButton(
            icon: Icon(Icons.tune_rounded, size: 20, color: colors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filter presets: All Regions, UNESCO Sites, Free Entry')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilterPills(HelaColorPalette colors) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_categories.length, (idx) {
          final isSelected = _selectedCategoryIndex == idx;
          final cat = _categories[idx];
          final icon = cat['icon'] as IconData?;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = idx),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected ? colors.primary : colors.architecturalBorder,
                  ),
                ),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 16, color: isSelected ? Colors.white : colors.secondary),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      cat['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : colors.secondary,
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

  Widget _buildInteractiveMapView(HelaColorPalette colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.architecturalBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            RealTimeGoogleMap(
              pickupLocation: 'Sigiriya Rock Sanctuary',
              dropoffLocation: 'Kandy Sacred Tooth Relic',
              durationText: '2h 15m',
              distanceText: '90 km Scenic Mountain Route',
              vehicleType: 'All Island Pins Active',
              height: 240,
              onSwapLocations: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularDestinationsSection(HelaColorPalette colors, List<ExploreDestination> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 3.5,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Popular Destinations',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                setState(() => _selectedCategoryIndex = 0);
              },
              child: Row(
                children: [
                  Text(
                    'See All (24)',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, size: 16, color: colors.primary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal Carousel
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final d = items[index];
              final isSaved = _savedIds.contains(d.id);
              return Container(
                width: 235,
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.architecturalBorder),
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
                      // Image with badges and save button
                      Stack(
                        children: [
                          SizedBox(
                            height: 135,
                            width: double.infinity,
                            child: _buildNetworkImage(d.imageUrl),
                          ),
                          // Rating Badge
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.star_rounded, size: 12, color: colors.goldenAmber),
                                  const SizedBox(width: 2),
                                  Text(
                                    d.rating,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Bookmark Heart Icon
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () => _toggleSave(d.id, d.name),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  size: 16,
                                  color: isSaved ? const Color(0xFFDC2626) : const Color(0xFF4A5D5A),
                                ),
                              ),
                            ),
                          ),
                          // Location & Fee Strip at Bottom of Image
                          Positioned(
                            bottom: 6,
                            left: 8,
                            right: 8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded, size: 10, color: Colors.white),
                                      const SizedBox(width: 2),
                                      Text(
                                        d.region,
                                        style: const TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    d.priceTag,
                                    style: const TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Destination Text
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              d.subtitle,
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.explore_outlined, size: 13, color: colors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      d.footerTag,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: colors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(Icons.arrow_forward_rounded, size: 14, color: colors.primary),
                              ],
                            ),
                          ],
                        ),
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

  Widget _buildHiddenGemsSection(HelaColorPalette colors, List<HiddenGemItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 3.5,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.goldenAmber,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Hidden Gems',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            Text(
              'Off the beaten track',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Vertical List
        ...items.map((gem) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.architecturalBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            gem.badge,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: colors.primary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${gem.distance}',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 13, color: colors.goldenAmber),
                        const SizedBox(width: 2),
                        Text(
                          gem.rating,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Body: Image + Text
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 72,
                        height: 72,
                        child: _buildNetworkImage(gem.imageUrl),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gem.title,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            gem.subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.onSurfaceVariant,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCulturalExperiencesSection(HelaColorPalette colors, List<CulturalExperienceItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 3.5,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Cultural Experiences',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            Text(
              'Authentic Heritage',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Rich Experience Cards
        ...items.map((exp) {
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.architecturalBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with Duration and Price Badges
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 140,
                        width: double.infinity,
                        child: _buildNetworkImage(exp.imageUrl),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              exp.duration,
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          exp.price,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF132220),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title + Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exp.title,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        exp.tag,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: colors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  exp.subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),

                // Verified Note & CTA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified_rounded, size: 14, color: colors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          exp.verifiedNote,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.secondary,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CulturalGuidePage()));
                      },
                      child: Row(
                        children: [
                          Text(
                            exp.ctaText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, size: 16, color: colors.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNearbyDiscoveriesSection(HelaColorPalette colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 3.5,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Nearby Discoveries',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_rounded, size: 12, color: colors.primary),
                  const SizedBox(width: 3),
                  Text(
                    'Colombo Western Coast',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Nearby List Tiles
        ..._nearbyPlaces.map((place) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(16),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: _buildNetworkImage(place.imageUrl),
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
                            place.title,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                          Text(
                            place.distance,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        place.subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF15803D),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            place.status,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: colors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, size: 20, color: colors.outlineVariant),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDelightAiBanner(HelaColorPalette colors) {
    return InkWell(
      onTap: () {
        HelaBottomNavBar.openAskHelaSheet(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.primary, colors.primaryContainer],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.tertiaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.auto_awesome_rounded, size: 20, color: colors.goldenAmber),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Unsure what to see next?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Ask HELA to build a custom day trip',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
