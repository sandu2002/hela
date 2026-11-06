import 'package:flutter/material.dart';
import 'package:hela/pages/trip_planner_page.dart';
import 'package:hela/pages/stays_page.dart';
import 'package:hela/pages/fair_ride_page.dart';
import 'package:hela/pages/cultural_guide/cultural_guide_page.dart';
import 'package:hela/pages/profile_page.dart';
import 'package:hela/pages/saved_page.dart';
import 'package:hela/pages/travel_preferences_page.dart';
import 'package:hela/widgets/haven_card.dart';
import 'package:hela/pages/smart_tour/smart_tour_home_page.dart';
import 'package:hela/models/destination.dart';
import 'package:hela/services/place_service.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/models/haven_item.dart';
import 'package:hela/widgets/theme_switch_button.dart';
import 'package:hela/widgets/hela_drawer.dart';
export 'package:hela/models/haven_item.dart';

// Re-export HelaColors from canonical location for backward compatibility
import 'package:hela/theme/hela_colors.dart';
export 'package:hela/theme/hela_colors.dart';

class CategoryChipData {
  final String label;
  final IconData icon;

  const CategoryChipData({required this.label, required this.icon});
}

class HelaHomePage extends StatefulWidget {
  const HelaHomePage({super.key});

  @override
  State<HelaHomePage> createState() => _HelaHomePageState();
}

class _HelaHomePageState extends State<HelaHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedNavIndex = 0;
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<CategoryChipData> _categories = const [
    CategoryChipData(label: 'All', icon: Icons.explore_rounded),
    CategoryChipData(label: 'Hill Country', icon: Icons.landscape_rounded),
    CategoryChipData(label: 'Beaches', icon: Icons.beach_access_rounded),
    CategoryChipData(label: 'Culture', icon: Icons.temple_buddhist_rounded),
    CategoryChipData(label: 'Adventure', icon: Icons.hiking_rounded),
    CategoryChipData(label: 'Wildlife', icon: Icons.pets_rounded),
    CategoryChipData(label: 'Waterfalls', icon: Icons.waterfall_chart_rounded),
  ];

  String? get _selectedCategoryLabel {
    if (_selectedCategoryIndex <= 0 || _selectedCategoryIndex >= _categories.length) {
      return null;
    }
    return _categories[_selectedCategoryIndex].label;
  }

  List<HavenItem> get _filteredHavens {
    final cat = _selectedCategoryLabel;
    if (cat == null) return _featuredHavens;
    return _featuredHavens.where((h) => h.filterCategory == cat).toList();
  }

  List<ExperienceItem> get _filteredExperiences {
    final cat = _selectedCategoryLabel;
    if (cat == null) return _trendingExperiences;
    return _trendingExperiences.where((e) => e.filterCategory == cat).toList();
  }

  final List<HavenItem> _featuredHavens = const [
    // ── Hill Country ──────────────────────────────────────────────
    HavenItem(
      title: 'Nine Arch Bridge & Demodara Tea Valley',
      location: 'Ella, Highlands',
      category: 'Guided Excursion',
      price: '\$45',
      rating: 4.90,
      badgeText: '240+ Verified Explorers',
      filterCategory: 'Hill Country',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDvJryELDH6m-aPQfsWTQ16312Y8rBu_auTNO6RdIu6gbV4Pwcooer456mtq4aG-SyKDYKNNg8-VWK0IuqWCpQQjHRKu2phfsvLM138y7tF4c0JEFCRImFso5Q05zKJanq1aBD3Q1iC30zFwaKYXyE_RgKZ0emUZlFa6Gh0qIs2uXJmMge8Zy3FlYNN0tmbm3Q7KzAXiBPuXo-9JhDuJpvmkQQWVWLd7RjEZbw3TYlMvhBaoZt8cQ-eog',
    ),
    HavenItem(
      title: 'Little Adam\'s Peak & Flying Ravana Ridge',
      location: 'Ella, Highlands',
      category: 'Scenic Mountain Trek',
      price: '\$55',
      rating: 4.92,
      badgeText: 'Panoramic Vista',
      filterCategory: 'Hill Country',
      imageUrl:
          'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
    ),
    HavenItem(
      title: 'Nuwara Eliya Tea Trails & Pedro Estate',
      location: 'Nuwara Eliya, Highlands',
      category: 'Heritage Tea Estate',
      price: '\$48',
      rating: 4.88,
      badgeText: 'Ceylon Tea Route',
      filterCategory: 'Hill Country',
      imageUrl:
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&auto=format&fit=crop&q=80',
    ),

    // ── Beaches ───────────────────────────────────────────────────
    HavenItem(
      title: 'Palm Coast & Blue Whale Watch Cruise',
      location: 'Mirissa, South Coast',
      category: 'Coastal Safari',
      price: '\$75',
      rating: 4.88,
      badgeText: 'Ocean Sanctuary',
      filterCategory: 'Beaches',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCdCzzTCfcf96RAY1SbWTlAyxIfFy3sjrYH6c5VUEQnBtz-eqUZsAB6nACMhkwopIPaH431tO5N6rNtmoGQUznd8HwSb0tLMr98CYTP8NgH1ESYJ85k3FQRQsShcSRo2OJhFITaoJkg8ip-J14rP0c5Ma6KyAz8ThZ645a-64Qblmcye38mylwbD-3KX_l-H15_SGoWP6VS53FmY8Eic5Cxwc6vKPpHFCJZCS1bXMJ08GZCO6ATKK6RDw',
    ),
    HavenItem(
      title: 'Arugam Bay Surf & Sunset Sand Dunes',
      location: 'Arugam Bay, East Coast',
      category: 'Surf & Ocean Camp',
      price: '\$42',
      rating: 4.93,
      badgeText: 'World Surf Reserve',
      filterCategory: 'Beaches',
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
    ),
    HavenItem(
      title: 'Tangalle Secret Coves & Sea Turtle Watch',
      location: 'Tangalle, South Coast',
      category: 'Coastal Hideaway',
      price: '\$60',
      rating: 4.91,
      badgeText: 'Marine Sanctuary',
      filterCategory: 'Beaches',
      imageUrl:
          'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800&auto=format&fit=crop&q=80',
    ),

    // ── Culture ───────────────────────────────────────────────────
    HavenItem(
      title: 'Ancient Citadel & Sky Palace Ascent',
      location: 'Sigiriya, Cultural Triangle',
      category: 'Heritage Tour',
      price: '\$60',
      rating: 4.95,
      badgeText: 'UNESCO Heritage',
      filterCategory: 'Culture',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAk9mgmweMowAekofzD0DuGrOAM90Q02qbvbSwJ1NfOp_TaTXxz2Noje8nYZerSfDgtvec2fuPDUjyvYWJLayoiDs5yQ4jtV1h14rFarsPaM-hU6LqyLC6UAUGjJw_J4rCjTuDKdMu79p07dxX754f0hvSNi9nWIkZq7Oq6_ReD9ebgcFLX3wztGHOi1lICWZV8WR4VuoyfU1_gN-wLu7Kml64bjQFLF1l4ZkZ_fGb_spDYlqdXwkPjuA',
    ),
    HavenItem(
      title: 'Temple of the Sacred Tooth & Royal City',
      location: 'Kandy, Central Province',
      category: 'Sacred Heritage',
      price: '\$38',
      rating: 4.94,
      badgeText: 'Living Tradition',
      filterCategory: 'Culture',
      imageUrl:
          'https://images.unsplash.com/photo-1588598198321-9735fd52455b?w=800&auto=format&fit=crop&q=80',
    ),
    HavenItem(
      title: 'Polonnaruwa Ancient Kingdom & Gal Vihara',
      location: 'Polonnaruwa, North Central',
      category: 'Royal Ruins Tour',
      price: '\$52',
      rating: 4.91,
      badgeText: 'Medieval Wonder',
      filterCategory: 'Culture',
      imageUrl:
          'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800&auto=format&fit=crop&q=80',
    ),

    // ── Adventure ─────────────────────────────────────────────────
    HavenItem(
      title: 'Kitulgala White Water Rafting & Canyon Jump',
      location: 'Kitulgala, Kelani River',
      category: 'Whitewater Expedition',
      price: '\$65',
      rating: 4.93,
      badgeText: 'Adrenaline Rush',
      filterCategory: 'Adventure',
      imageUrl:
          'https://images.unsplash.com/photo-1530866495561-507c9faab2ed?w=800&auto=format&fit=crop&q=80',
    ),
    HavenItem(
      title: 'Ella Rock Dawn Expedition & Ravana Cave',
      location: 'Ella, Highlands',
      category: 'Mountain Expedition',
      price: '\$50',
      rating: 4.90,
      badgeText: 'Epic Heights',
      filterCategory: 'Adventure',
      imageUrl:
          'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
    ),
    HavenItem(
      title: 'Adam\'s Peak Midnight Pilgrimage Summit',
      location: 'Nallathanniya, Peak Wilderness',
      category: 'Sacred Night Summit',
      price: '\$45',
      rating: 4.96,
      badgeText: 'Holy Sunrise',
      filterCategory: 'Adventure',
      imageUrl:
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800&auto=format&fit=crop&q=80',
    ),

    // ── Wildlife ──────────────────────────────────────────────────
    HavenItem(
      title: 'Yala Leopard Safari at Dawn & Deep Jungles',
      location: 'Yala National Park, Southeast',
      category: 'Big Cat Safari',
      price: '\$95',
      rating: 4.96,
      badgeText: 'High Leopard Density',
      filterCategory: 'Wildlife',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDzX3rEG6vFdMVPdR2IYkb722eLQezhkZlI9-A9h7Id0Xe0tc0XBU3AGMCVpq5OaMFrUZpLK8_ANGsNvGc22u4ZDrosNecG2dQR58pzzFp11iTNtp1nZexE_3rbuxEW9xvc0AvYy3aaJEey7NHg2HIlk7OKKuSeTtKIQLWW-6cm9EMVysGfzpppGGAymEqvqu562Kxmq3DJyRqnszhtNHHwlp49NwCJ6VN-V657OYR7yjq6c8P-IaCr6w',
    ),
    HavenItem(
      title: 'Minneriya Elephant Gathering by Open 4x4',
      location: 'Minneriya National Park',
      category: 'Elephant Safari',
      price: '\$70',
      rating: 4.93,
      badgeText: 'Asia\'s Greatest Gathering',
      filterCategory: 'Wildlife',
      imageUrl:
          'https://images.unsplash.com/photo-1561731216-c3a4d99437d5?w=800&auto=format&fit=crop&q=80',
    ),
    HavenItem(
      title: 'Udawalawe Transit Home & Plains Safari',
      location: 'Udawalawe, Sabaragamuwa',
      category: 'Conservation Tour',
      price: '\$62',
      rating: 4.90,
      badgeText: 'Rescue Sanctuary',
      filterCategory: 'Wildlife',
      imageUrl:
          'https://images.unsplash.com/photo-1557050543-4d5f4e07ef46?w=800&auto=format&fit=crop&q=80',
    ),

    // ── Waterfalls ────────────────────────────────────────────────
    HavenItem(
      title: 'Diyaluma Falls Upper Natural Infinity Pools',
      location: 'Koslanda, Badulla',
      category: 'Waterfall Odyssey',
      price: '\$42',
      rating: 4.95,
      badgeText: 'Natural Rock Pools',
      filterCategory: 'Waterfalls',
      imageUrl:
          'https://images.unsplash.com/photo-1432405972618-c60b0225b8f9?w=800&auto=format&fit=crop&q=80',
    ),
    HavenItem(
      title: 'Bambarakanda & Hidden Lanka Ella Cascades',
      location: 'Kalupahana, Ohiya Valley',
      category: 'Tallest Falls Trek',
      price: '\$48',
      rating: 4.91,
      badgeText: '263m Cascade',
      filterCategory: 'Waterfalls',
      imageUrl:
          'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
    ),
    HavenItem(
      title: 'Ramboda Triple Falls & Tea Terraces',
      location: 'Ramboda Pass, Pussellawa',
      category: 'Mountain Waterfall',
      price: '\$36',
      rating: 4.88,
      badgeText: 'Highland Vistas',
      filterCategory: 'Waterfalls',
      imageUrl:
          'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800&auto=format&fit=crop&q=80',
    ),
  ];

  final List<ExperienceItem> _trendingExperiences = const [
    // ── Hill Country ──────────────────────────────────────────────
    ExperienceItem(
      title: 'Sunrise Hike & Kandy Tea Tasting',
      category: 'Highland Terroir',
      duration: '4.5 Hours',
      price: '\$38',
      rating: 4.9,
      reviewsCount: 88,
      categoryIcon: Icons.local_florist_rounded,
      filterCategory: 'Hill Country',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAWc-k1WtCHy2mQ1-JC2KOqg6jy7fs-iXGjjBHckRO8Qmfu3IMmJ__G5Okib5t4lz7hbkIBF1ELU1Vs2v844gjLpMTwiObEkSOh7XHpZZ8dd3Btj3j91sQg9l1CRMGUVu_gfQwIdCwvMPolRTdX7BN9nQFj7BneThOvXuG3aiOtTlz-R4nG2WOc156rKiHSiPeRrIU_nvWG59HwNgvWOuxfamgg4bbPy4krrZT7v38-qykE9u9dKRmMWg',
    ),
    ExperienceItem(
      title: 'Horton Plains & World\'s End Trek',
      category: 'Cloud Forest Trail',
      duration: '5.0 Hours',
      price: '\$50',
      rating: 4.94,
      reviewsCount: 112,
      categoryIcon: Icons.terrain_rounded,
      filterCategory: 'Hill Country',
      imageUrl:
          'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
    ),

    // ── Beaches ───────────────────────────────────────────────────
    ExperienceItem(
      title: 'Bentota Mangrove Lagoon & Water Skiing',
      category: 'Lagoon Adventures',
      duration: '3.5 Hours',
      price: '\$45',
      rating: 4.87,
      reviewsCount: 64,
      categoryIcon: Icons.surfing_rounded,
      filterCategory: 'Beaches',
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
    ),
    ExperienceItem(
      title: 'Unawatuna Coral Reef Snorkel & Catamaran',
      category: 'Reef Exploration',
      duration: '4.0 Hours',
      price: '\$55',
      rating: 4.92,
      reviewsCount: 98,
      categoryIcon: Icons.sailing_rounded,
      filterCategory: 'Beaches',
      imageUrl:
          'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800&auto=format&fit=crop&q=80',
    ),

    // ── Culture ───────────────────────────────────────────────────
    ExperienceItem(
      title: 'Galle Fort Sunset Walk & Spices',
      category: 'Culinary Heritage',
      duration: '3.0 Hours',
      price: '\$42',
      rating: 4.89,
      reviewsCount: 75,
      categoryIcon: Icons.restaurant_rounded,
      filterCategory: 'Culture',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAnsMut8vukazOQQk1YyZCGBLo9YbXlxSvpljkSzTetlNv3S90zTSLVj93s5Ei7ruW9FItfWdv7SRHLba73k0w4GyqyAQYGdhkCc1o4whnZtFwV8Abb_yI23ZzIPm8gDdO_2nT5d6oCv9ULCcpJ2kpwQX-lLLuW3ARIM12y0b5KBn6WwpmleF7f_Gtf9E_ea8_J1ItwLULkwuuwgBd-GdluE3jJgzvYwrwzEE37TaTxbZsfu2ve_Ax6Bw',
    ),
    ExperienceItem(
      title: 'Dambulla Cave Temple Monastic Art Tour',
      category: 'Sacred Murals',
      duration: '2.5 Hours',
      price: '\$35',
      rating: 4.93,
      reviewsCount: 130,
      categoryIcon: Icons.temple_buddhist_rounded,
      filterCategory: 'Culture',
      imageUrl:
          'https://images.unsplash.com/photo-1588598198321-9735fd52455b?w=800&auto=format&fit=crop&q=80',
    ),

    // ── Adventure ─────────────────────────────────────────────────
    ExperienceItem(
      title: 'Knuckles Mountain Cloud Forest Trek',
      category: 'Alpine Wilderness',
      duration: '6.5 Hours',
      price: '\$70',
      rating: 4.95,
      reviewsCount: 104,
      categoryIcon: Icons.hiking_rounded,
      filterCategory: 'Adventure',
      imageUrl:
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800&auto=format&fit=crop&q=80',
    ),
    ExperienceItem(
      title: 'Sinharaja Virgin Rainforest Canopy Hike',
      category: 'Jungle Survival',
      duration: '5.0 Hours',
      price: '\$52',
      rating: 4.91,
      reviewsCount: 86,
      categoryIcon: Icons.forest_rounded,
      filterCategory: 'Adventure',
      imageUrl:
          'https://images.unsplash.com/photo-1530866495561-507c9faab2ed?w=800&auto=format&fit=crop&q=80',
    ),

    // ── Wildlife ──────────────────────────────────────────────────
    ExperienceItem(
      title: 'Yala Leopard Safari at Dawn',
      category: 'Wildlife Reserve',
      duration: '6.0 Hours',
      price: '\$92',
      rating: 4.96,
      reviewsCount: 142,
      categoryIcon: Icons.landscape_rounded,
      filterCategory: 'Wildlife',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDzX3rEG6vFdMVPdR2IYkb722eLQezhkZlI9-A9h7Id0Xe0tc0XBU3AGMCVpq5OaMFrUZpLK8_ANGsNvGc22u4ZDrosNecG2dQR58pzzFp11iTNtp1nZexE_3rbuxEW9xvc0AvYy3aaJEey7NHg2HIlk7OKKuSeTtKIQLWW-6cm9EMVysGfzpppGGAymEqvqu562Kxmq3DJyRqnszhtNHHwlp49NwCJ6VN-V657OYR7yjq6c8P-IaCr6w',
    ),
    ExperienceItem(
      title: 'Kalpitiya Dolphin & Sperm Whale Encounter',
      category: 'Marine Expedition',
      duration: '4.0 Hours',
      price: '\$68',
      rating: 4.89,
      reviewsCount: 79,
      categoryIcon: Icons.water_rounded,
      filterCategory: 'Wildlife',
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
    ),

    // ── Waterfalls ────────────────────────────────────────────────
    ExperienceItem(
      title: 'Ravana Falls Cave & Secret Pool Dip',
      category: 'Legendary Cascades',
      duration: '3.0 Hours',
      price: '\$32',
      rating: 4.87,
      reviewsCount: 94,
      categoryIcon: Icons.waterfall_chart_rounded,
      filterCategory: 'Waterfalls',
      imageUrl:
          'https://images.unsplash.com/photo-1432405972618-c60b0225b8f9?w=800&auto=format&fit=crop&q=80',
    ),
    ExperienceItem(
      title: 'St. Clair\'s & Devon Falls Valley Panorama',
      category: 'Twin Falls Vista',
      duration: '3.5 Hours',
      price: '\$35',
      rating: 4.89,
      reviewsCount: 68,
      categoryIcon: Icons.filter_hdr_rounded,
      filterCategory: 'Waterfalls',
      imageUrl:
          'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800&auto=format&fit=crop&q=80',
    ),
  ];

  Widget _buildNetworkImageWithFallback(String url, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    final colors = HelaColors.of(context);
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: colors.surfaceContainerHigh,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.secondary,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.primaryContainer, colors.primary],
            ),
          ),
          child: Center(
            child: Icon(Icons.image_outlined, color: colors.onPrimaryContainer, size: 32),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: const HelaNavigationDrawer(),
      backgroundColor: colors.background,
      appBar: _buildAppBar(),
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
                    _buildGreetingSection(),
                    const SizedBox(height: 18),
                    _buildSearchSection(),
                    const SizedBox(height: 16),
                    if (_searchQuery.isNotEmpty) ...[
                      _buildSearchResultsSection(),
                    ] else ...[
                      _buildCategoriesSection(),
                      const SizedBox(height: 24),
                      _buildFeaturedHavensSection(),
                      const SizedBox(height: 22),
                      _buildAuthenticityBanner(),
                      const SizedBox(height: 24),
                      _buildTrendingSection(),
                      const SizedBox(height: 24),
                      _buildCustomJourneyCard(),
                    ],
                    const SizedBox(height: 20),
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

  PreferredSizeWidget _buildAppBar() {
    final colors = HelaColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: colors.surface.withValues(alpha: isDark ? 0.94 : 0.92),
      elevation: 0,
      scrolledUnderElevation: 1.5,
      shadowColor: Colors.black12,
      toolbarHeight: 64,
      titleSpacing: 16,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.menu_rounded, color: colors.primary, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'HELA',
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.electric_rickshaw_rounded, color: colors.primary, size: 24),
          tooltip: 'Fair Ride Ceylon',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FairRidePage()),
            );
          },
        ),
        // Matching Place 1: Top AppBar Action Bar Switch Icon!
        const HelaThemeSwitchButton(size: 36),
        const SizedBox(width: 2),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: colors.primary, size: 24),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No new notifications')),
                );
              },
            ),
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 4),
          child: Tooltip(
            message: 'Profile',
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.secondary.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: _buildNetworkImageWithFallback(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAYaDOlpE1923DxKMHjTzrGSSaCxwudP2YkvXacPtlfANGQK9Hz9BBI9D9gs00_CjlWdXxfej4-wfKki4-K1xTwGSrLGLTZYKqPLbNiNaRnNjdx3ECnnXdsyuf8R4KDMLritAUq3JYUYf2jibgDLxyajwEvfVebj8wVV1Bgt8JEq2mZEq4-Ff3SdcX4aNxV1I8Xb6UusllqkYnuv4rzk7RZ4EawOB9C5ZXz1k2je2LbM7-fsA8b3x6Prw',
                      width: 36,
                      height: 36,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingSection() {
    final colors = HelaColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discover Sri Lanka',
          style: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 27,
            letterSpacing: -0.6,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Lush highlands, untamed safaris & ancient royal sanctuaries.',
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    final colors = HelaColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: colors.searchBackground,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 10),
            child: Icon(
              Icons.search_rounded,
              color: colors.primary,
              size: 22,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 14.5,
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
              onSubmitted: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Where do you want to explore?',
                hintStyle: TextStyle(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.65),
                  fontSize: 14.5,
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
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close_rounded, size: 20, color: colors.outline),
              tooltip: 'Clear search',
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Material(
              color: colors.primaryContainer,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _searchQuery = _searchController.text.trim();
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: Icon(
                    Icons.search_rounded,
                    color: colors.onPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsSection() {
    final colors = HelaColors.of(context);
    final query = _searchQuery.toLowerCase();

    // Filter matching havens
    final matchedHavens = _featuredHavens.where((h) {
      return h.title.toLowerCase().contains(query) ||
          h.location.toLowerCase().contains(query) ||
          h.category.toLowerCase().contains(query);
    }).toList();

    // Filter matching experiences
    final matchedExperiences = _trendingExperiences.where((e) {
      return e.title.toLowerCase().contains(query) ||
          e.category.toLowerCase().contains(query);
    }).toList();

    // Filter matching curated destinations (e.g. Galle Dutch Fort, etc.)
    final matchedPlaces = PlaceService.curatedSriLankaPlaces.where((p) {
      return p.name.toLowerCase().contains(query) ||
          p.region.toLowerCase().contains(query) ||
          p.description.toLowerCase().contains(query) ||
          p.categories.any((c) => c.toLowerCase().contains(query));
    }).toList();

    final totalCount =
        matchedHavens.length + matchedExperiences.length + matchedPlaces.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Results for "$_searchQuery"',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Text('Clear', style: TextStyle(color: colors.secondary)),
            ),
          ],
        ),
        Text(
          '$totalCount place${totalCount != 1 ? 's' : ''} found in Sri Lanka',
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 14),

        if (totalCount == 0) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.travel_explore_rounded,
                    size: 48, color: colors.outline),
                const SizedBox(height: 12),
                Text(
                  'No places found for "$_searchQuery"',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Try searching for "Galle", "Ella", "Sigiriya", "Kandy", or "Yala"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Matched Curated Places
          ...matchedPlaces.map((place) => _buildPlaceResultCard(place)),

          // Matched Havens
          ...matchedHavens.map((haven) => _buildHavenResultCard(haven)),

          // Matched Experiences
          ...matchedExperiences.map((exp) => _buildExperienceResultCard(exp)),
        ],
      ],
    );
  }

  Widget _buildPlaceResultCard(Destination place) {
    final colors = HelaColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SmartTourHomePage(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: place.imageUrl.isNotEmpty
                    ? _buildNetworkImageWithFallback(
                        place.imageUrl,
                        width: 86,
                        height: 86,
                      )
                    : Container(
                        width: 86,
                        height: 86,
                        color: colors.surfaceContainerHigh,
                        child: Icon(Icons.place_rounded, color: colors.primary),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'DESTINATION',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD4A017)),
                        const SizedBox(width: 2),
                        const Text(
                          '4.9',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 12, color: colors.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            place.region,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: colors.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      place.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colors.onSurfaceVariant,
                        height: 1.3,
                      ),
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

  Widget _buildHavenResultCard(HavenItem haven) {
    final colors = HelaColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const StaysPage()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildNetworkImageWithFallback(
                  haven.imageUrl,
                  width: 86,
                  height: 86,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.secondary.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            haven.category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: colors.secondary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD4A017)),
                        const SizedBox(width: 2),
                        Text(
                          haven.rating.toString(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      haven.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 12, color: colors.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Text(
                          haven.location,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${haven.price} / person',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: colors.primary,
                      ),
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

  Widget _buildExperienceResultCard(ExperienceItem exp) {
    final colors = HelaColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildNetworkImageWithFallback(
                exp.imageUrl,
                width: 86,
                height: 86,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: HelaColors.tertiaryFixed.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          exp.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1D00),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD4A017)),
                      const SizedBox(width: 2),
                      Text(
                        exp.rating.toString(),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exp.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: HelaColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 12, color: HelaColors.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text(
                        exp.duration,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: HelaColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${exp.price} / person',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
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

  Widget _buildCategoriesSection() {
    final colors = HelaColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          final category = _categories[index];

          final bgColor = isSelected
              ? colors.primary
              : (isDark ? colors.surfaceContainer : colors.surfaceContainerHigh);

          final fgColor = isSelected
              ? colors.onPrimary
              : (isDark ? colors.onSurface : colors.primary);

          final borderColor = isSelected
              ? colors.primary
              : (isDark
                  ? colors.outlineVariant.withValues(alpha: 0.6)
                  : colors.outlineVariant.withValues(alpha: 0.8));

          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              setState(() {
                if (_selectedCategoryIndex == index && index != 0) {
                  _selectedCategoryIndex = 0; // Deselect to All
                } else {
                  _selectedCategoryIndex = index;
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: isDark ? 0.4 : 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category.icon,
                    size: 16,
                    color: fgColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category.label,
                    style: TextStyle(
                      color: fgColor,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedHavensSection() {
    final colors = HelaColors.of(context);
    final selectedCat = _selectedCategoryLabel;
    final havens = _filteredHavens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedCat == null ? 'Featured Havens' : '$selectedCat Tours & Havens',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedCat == null
                        ? 'Iconic sanctuaries of Ceylon'
                        : 'Curated $selectedCat journeys (${havens.length} available)',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (selectedCat != null)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedCategoryIndex = 0;
                  });
                },
                icon: Icon(Icons.close_rounded, size: 14, color: colors.secondary),
                label: Text(
                  'Show All',
                  style: TextStyle(
                    color: colors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
            else
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StaysPage()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: colors.secondary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'See All',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded, size: 14),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 380,
          child: ListView.separated(
            key: ValueKey('havens_list_${selectedCat ?? "all"}'),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: havens.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final haven = havens[index];
              final appState = HelaAppStateProvider.of(context);
              final isBookmarked = appState.isHavenSaved(haven.title);

              return HavenCard.fromHavenItem(
                haven,
                isBookmarked: isBookmarked,
                onBookmarkTap: () {
                  appState.toggleSaveHaven(haven);
                  final isNowSaved = appState.isHavenSaved(haven.title);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            isNowSaved
                                ? Icons.bookmark_added_rounded
                                : Icons.bookmark_remove_rounded,
                            color: isNowSaved ? colors.tertiaryFixed : Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isNowSaved
                                  ? 'Saved "${haven.title}" to Saved Page'
                                  : 'Removed "${haven.title}" from Saved Page',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      action: isNowSaved
                          ? SnackBarAction(
                              label: 'View Saved',
                              textColor: colors.tertiaryFixed,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const SavedPage()),
                                );
                              },
                            )
                          : null,
                      duration: const Duration(seconds: 2),
                      persist: false,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                onExploreTap: () {
                  if (haven.category.contains('Heritage') ||
                      haven.title.contains('Citadel') ||
                      haven.title.contains('Temple') ||
                      haven.title.contains('Ancient')) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CulturalGuidePage(),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const StaysPage(),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAuthenticityBanner() {
    final colors = HelaColors.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.bannerBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.verified_rounded,
                color: colors.onSecondaryContainer,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ceylon Heritage Certified',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '100% vetted local indigenous hosts & eco-guides.',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            color: colors.secondary,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection() {
    final colors = HelaColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedCat = _selectedCategoryLabel;
    final experiences = _filteredExperiences;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedCat == null ? 'Trending This Week' : 'Trending $selectedCat',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedCat == null
                        ? 'Handcrafted slow-travel expeditions'
                        : 'Authentic $selectedCat experiences (${experiences.length})',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: colors.secondary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward_rounded, size: 14),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 236,
          child: ListView.separated(
            key: ValueKey('exp_list_${selectedCat ?? "all"}'),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: experiences.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final exp = experiences[index];
              final appState = HelaAppStateProvider.of(context);
              final isBookmarked = appState.isExperienceSaved(exp.title);

              return Container(
                width: 250,
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Image with duration badge and bookmark
                      SizedBox(
                        height: 132,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: _buildNetworkImageWithFallback(
                                exp.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Bookmark button
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Material(
                                color: colors.surfaceContainer.withValues(alpha: 0.85),
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () {
                                    appState.toggleSaveExperience(exp);
                                    final isNowSaved = appState.isExperienceSaved(exp.title);
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isNowSaved
                                              ? 'Saved "${exp.title}" to Saved Page'
                                              : 'Removed "${exp.title}" from Saved Page',
                                        ),
                                        action: isNowSaved
                                            ? SnackBarAction(
                                                label: 'View Saved',
                                                textColor: colors.tertiaryFixed,
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(builder: (_) => const SavedPage()),
                                                  );
                                                },
                                              )
                                            : null,
                                        duration: const Duration(seconds: 2),
                      persist: false,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Icon(
                                      isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                      size: 16,
                                      color: isBookmarked ? colors.primary : colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Duration badge
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer.withValues(alpha: 0.88),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 12,
                                      color: colors.onPrimary,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      exp.duration,
                                      style: TextStyle(
                                        color: colors.onPrimary,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        exp.categoryIcon,
                                        size: 13,
                                        color: colors.secondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        exp.category,
                                        style: TextStyle(
                                          color: colors.secondary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    exp.title,
                                    style: TextStyle(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.only(top: 6),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: colors.outlineVariant.withValues(alpha: 0.4),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: exp.price,
                                              style: TextStyle(
                                                color: colors.primary,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                              ),
                                            ),
                                            TextSpan(
                                              text: index == 1 ? ' / jeep' : ' / guest',
                                              style: TextStyle(
                                                color: colors.onSurfaceVariant,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          size: 14,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${exp.rating} (${exp.reviewsCount})',
                                          style: TextStyle(
                                            color: colors.onSurface,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
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

  Widget _buildCustomJourneyCard() {
    final colors = HelaColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainer : HelaColors.primary,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: colors.primary.withValues(alpha: 0.35)) : null,
        boxShadow: [
          BoxShadow(
            color: isDark ? colors.primary.withValues(alpha: 0.15) : HelaColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative organic radial glow
            Positioned(
              right: -30,
              bottom: -30,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isDark ? colors.primary : HelaColors.secondary).withValues(alpha: 0.25),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TAILORED ITINERARIES',
                    style: TextStyle(
                      color: colors.tertiaryFixed,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Need a custom private journey through Ceylon?',
                    style: TextStyle(
                      color: isDark ? colors.onSurface : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Our native destination specialists curate immersive bespoke routes with private chauffeur guides.',
                    style: TextStyle(
                      color: isDark ? colors.onSurfaceVariant : HelaColors.surfaceContainerHigh,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SmartTourHomePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.tertiaryFixed,
                      foregroundColor: const Color(0xFF19331F),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Start Planning',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
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

  Widget _buildBottomNavBar() {
    final colors = HelaColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: colors.navBarBackground.withValues(alpha: isDark ? 0.96 : 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: isDark
            ? Border(
                top: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.6),
                  width: 1,
                ),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.07),
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
              _buildNavItem(index: 0, label: 'Explore', icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded, colors: colors),
              _buildNavItem(
                index: 1,
                label: 'Saved',
                icon: Icons.bookmark_border_rounded,
                activeIcon: Icons.bookmark_rounded,
                colors: colors,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SavedPage()),
                  );
                },
              ),
              _buildNavItem(
                index: 2,
                label: 'Discover',
                icon: Icons.travel_explore_outlined,
                activeIcon: Icons.travel_explore_rounded,
                colors: colors,
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
                colors: colors,
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
                colors: colors,
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
    required HelaColorPalette colors,
    VoidCallback? onTap,
  }) {
    final isActive = _selectedNavIndex == index;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ??
            () {
              setState(() {
                _selectedNavIndex = index;
              });
            },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? colors.primary : colors.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? colors.primary : colors.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
