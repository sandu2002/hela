import 'package:flutter/material.dart';
import 'package:hela/pages/trip_planner_page.dart';
import 'package:hela/pages/stays_page.dart';
import 'package:hela/pages/fair_ride_page.dart';
import 'package:hela/pages/cultural_guide/cultural_guide_page.dart';
import 'package:hela/pages/profile_page.dart';
import 'package:hela/widgets/haven_card.dart';
import 'package:hela/pages/smart_tour/smart_tour_home_page.dart';
import 'package:hela/models/destination.dart';
import 'package:hela/services/place_service.dart';

// Re-export HelaColors from canonical location for backward compatibility
import 'package:hela/theme/hela_colors.dart';
export 'package:hela/theme/hela_colors.dart';


/// Data Models
class HavenItem {
  final String title;
  final String location;
  final String category;
  final String price;
  final double rating;
  final String badgeText;
  final String imageUrl;

  const HavenItem({
    required this.title,
    required this.location,
    required this.category,
    required this.price,
    required this.rating,
    required this.badgeText,
    required this.imageUrl,
  });
}

class ExperienceItem {
  final String title;
  final String category;
  final String duration;
  final String price;
  final double rating;
  final int reviewsCount;
  final IconData categoryIcon;
  final String imageUrl;

  const ExperienceItem({
    required this.title,
    required this.category,
    required this.duration,
    required this.price,
    required this.rating,
    required this.reviewsCount,
    required this.categoryIcon,
    required this.imageUrl,
  });
}

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
  int _selectedNavIndex = 0;
  int _selectedCategoryIndex = 0;
  final Set<int> _bookmarkedHavens = <int>{};
  final Set<int> _bookmarkedExp = <int>{};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<CategoryChipData> _categories = const [
    CategoryChipData(label: 'Hill Country', icon: Icons.landscape_rounded),
    CategoryChipData(label: 'Beaches', icon: Icons.beach_access_rounded),
    CategoryChipData(label: 'Culture', icon: Icons.temple_buddhist_rounded),
    CategoryChipData(label: 'Adventure', icon: Icons.hiking_rounded),
    CategoryChipData(label: 'Wildlife', icon: Icons.pets_rounded),
    CategoryChipData(label: 'Waterfalls', icon: Icons.waterfall_chart_rounded),
  ];

  final List<HavenItem> _featuredHavens = const [
    HavenItem(
      title: 'Nine Arch Bridge & Demodara Tea Valley',
      location: 'Ella, Highlands',
      category: 'Guided Excursion',
      price: '\$45',
      rating: 4.90,
      badgeText: '240+ Verified Explorers',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDvJryELDH6m-aPQfsWTQ16312Y8rBu_auTNO6RdIu6gbV4Pwcooer456mtq4aG-SyKDYKNNg8-VWK0IuqWCpQQjHRKu2phfsvLM138y7tF4c0JEFCRImFso5Q05zKJanq1aBD3Q1iC30zFwaKYXyE_RgKZ0emUZlFa6Gh0qIs2uXJmMge8Zy3FlYNN0tmbm3Q7KzAXiBPuXo-9JhDuJpvmkQQWVWLd7RjEZbw3TYlMvhBaoZt8cQ-eog',
    ),
    HavenItem(
      title: 'Ancient Citadel & Sky Palace Ascent',
      location: 'Sigiriya, Cultural Triangle',
      category: 'Heritage Tour',
      price: '\$60',
      rating: 4.95,
      badgeText: 'UNESCO Heritage',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAk9mgmweMowAekofzD0DuGrOAM90Q02qbvbSwJ1NfOp_TaTXxz2Noje8nYZerSfDgtvec2fuPDUjyvYWJLayoiDs5yQ4jtV1h14rFarsPaM-hU6LqyLC6UAUGjJw_J4rCjTuDKdMu79p07dxX754f0hvSNi9nWIkZq7Oq6_ReD9ebgcFLX3wztGHOi1lICWZV8WR4VuoyfU1_gN-wLu7Kml64bjQFLF1l4ZkZ_fGb_spDYlqdXwkPjuA',
    ),
    HavenItem(
      title: 'Palm Coast & Blue Whale Watch Cruise',
      location: 'Mirissa, South Coast',
      category: 'Coastal Safari',
      price: '\$75',
      rating: 4.88,
      badgeText: 'Ocean Sanctuary',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCdCzzTCfcf96RAY1SbWTlAyxIfFy3sjrYH6c5VUEQnBtz-eqUZsAB6nACMhkwopIPaH431tO5N6rNtmoGQUznd8HwSb0tLMr98CYTP8NgH1ESYJ85k3FQRQsShcSRo2OJhFITaoJkg8ip-J14rP0c5Ma6KyAz8ThZ645a-64Qblmcye38mylwbD-3KX_l-H15_SGoWP6VS53FmY8Eic5Cxwc6vKPpHFCJZCS1bXMJ08GZCO6ATKK6RDw',
    ),
  ];

  final List<ExperienceItem> _trendingExperiences = const [
    ExperienceItem(
      title: 'Sunrise Hike & Kandy Tea Tasting',
      category: 'Highland Terroir',
      duration: '4.5 Hours',
      price: '\$38',
      rating: 4.9,
      reviewsCount: 88,
      categoryIcon: Icons.local_florist_rounded,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAWc-k1WtCHy2mQ1-JC2KOqg6jy7fs-iXGjjBHckRO8Qmfu3IMmJ__G5Okib5t4lz7hbkIBF1ELU1Vs2v844gjLpMTwiObEkSOh7XHpZZ8dd3Btj3j91sQg9l1CRMGUVu_gfQwIdCwvMPolRTdX7BN9nQFj7BneThOvXuG3aiOtTlz-R4nG2WOc156rKiHSiPeRrIU_nvWG59HwNgvWOuxfamgg4bbPy4krrZT7v38-qykE9u9dKRmMWg',
    ),
    ExperienceItem(
      title: 'Yala Leopard Safari at Dawn',
      category: 'Wildlife Reserve',
      duration: '6.0 Hours',
      price: '\$92',
      rating: 4.96,
      reviewsCount: 142,
      categoryIcon: Icons.landscape_rounded,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDzX3rEG6vFdMVPdR2IYkb722eLQezhkZlI9-A9h7Id0Xe0tc0XBU3AGMCVpq5OaMFrUZpLK8_ANGsNvGc22u4ZDrosNecG2dQR58pzzFp11iTNtp1nZexE_3rbuxEW9xvc0AvYy3aaJEey7NHg2HIlk7OKKuSeTtKIQLWW-6cm9EMVysGfzpppGGAymEqvqu562Kxmq3DJyRqnszhtNHHwlp49NwCJ6VN-V657OYR7yjq6c8P-IaCr6w',
    ),
    ExperienceItem(
      title: 'Galle Fort Sunset Walk & Spices',
      category: 'Culinary Heritage',
      duration: '3.0 Hours',
      price: '\$42',
      rating: 4.89,
      reviewsCount: 75,
      categoryIcon: Icons.restaurant_rounded,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAnsMut8vukazOQQk1YyZCGBLo9YbXlxSvpljkSzTetlNv3S90zTSLVj93s5Ei7ruW9FItfWdv7SRHLba73k0w4GyqyAQYGdhkCc1o4whnZtFwV8Abb_yI23ZzIPm8gDdO_2nT5d6oCv9ULCcpJ2kpwQX-lLLuW3ARIM12y0b5KBn6WwpmleF7f_Gtf9E_ea8_J1ItwLULkwuuwgBd-GdluE3jJgzvYwrwzEE37TaTxbZsfu2ve_Ax6Bw',
    ),
  ];

  Widget _buildNetworkImageWithFallback(String url, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
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
          color: HelaColors.surfaceContainerHigh,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: HelaColors.secondary,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [HelaColors.primaryContainer, HelaColors.primary],
            ),
          ),
          child: const Center(
            child: Icon(Icons.image_outlined, color: HelaColors.onPrimaryContainer, size: 32),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HelaColors.background,
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
    return AppBar(
      backgroundColor: HelaColors.surface.withValues(alpha: 0.92),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Menu tapped')),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.menu_rounded, color: HelaColors.primary, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'HELA',
            style: TextStyle(
              color: HelaColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.electric_rickshaw_rounded, color: HelaColors.primary, size: 24),
          tooltip: 'Fair Ride Ceylon',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FairRidePage()),
            );
          },
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: HelaColors.primary, size: 24),
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
                  color: HelaColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: HelaColors.surface, width: 1.5),
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
                      color: HelaColors.secondary.withValues(alpha: 0.35),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'AYUBOWAN, EXPLORER',
              style: TextStyle(
                color: HelaColors.secondary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 1.1,
              ),
            ),
            SizedBox(width: 4),
            Text('👋', style: TextStyle(fontSize: 14)),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Discover Sri Lanka',
          style: TextStyle(
            color: HelaColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 27,
            letterSpacing: -0.6,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Lush highlands, untamed safaris & ancient royal sanctuaries.',
          style: TextStyle(
            color: HelaColors.onSurfaceVariant,
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: HelaColors.outlineVariant.withValues(alpha: 0.7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 10),
            child: Icon(
              Icons.search_rounded,
              color: HelaColors.primaryContainer,
              size: 22,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
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
              decoration: const InputDecoration(
                hintText: 'Where do you want to explore?',
                hintStyle: TextStyle(
                  color: Color(0x99424842),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20, color: HelaColors.outline),
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
              color: HelaColors.primaryContainer,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _searchQuery = _searchController.text.trim();
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.all(9.0),
                  child: Icon(
                    Icons.search_rounded,
                    color: HelaColors.onPrimary,
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
              style: const TextStyle(
                color: HelaColors.primary,
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
              child: const Text('Clear', style: TextStyle(color: HelaColors.secondary)),
            ),
          ],
        ),
        Text(
          '$totalCount place${totalCount != 1 ? 's' : ''} found in Sri Lanka',
          style: const TextStyle(
            color: HelaColors.onSurfaceVariant,
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
              color: HelaColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: HelaColors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.travel_explore_rounded,
                    size: 48, color: HelaColors.outline),
                const SizedBox(height: 12),
                Text(
                  'No places found for "$_searchQuery"',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: HelaColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Try searching for "Galle", "Ella", "Sigiriya", "Kandy", or "Yala"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: HelaColors.onSurfaceVariant,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HelaColors.outlineVariant.withValues(alpha: 0.4),
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
                        color: HelaColors.surfaceContainerHigh,
                        child: const Icon(Icons.place_rounded, color: HelaColors.primary),
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
                            color: HelaColors.primaryContainer.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'DESTINATION',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: HelaColors.primary,
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: HelaColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: HelaColors.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            place.region,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: HelaColors.onSurfaceVariant,
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
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: HelaColors.onSurfaceVariant,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HelaColors.outlineVariant.withValues(alpha: 0.4),
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
                            color: HelaColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            haven.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: HelaColors.secondary,
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: HelaColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: HelaColors.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Text(
                          haven.location,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: HelaColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${haven.price} / person',
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
      ),
    );
  }

  Widget _buildExperienceResultCard(ExperienceItem exp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HelaColors.outlineVariant.withValues(alpha: 0.4),
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
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          final category = _categories[index];
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
              if (category.label == 'Culture') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CulturalGuidePage()),
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? HelaColors.tertiaryFixed : HelaColors.secondary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: HelaColors.tertiaryFixed.withValues(alpha: 0.4),
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
                    color: isSelected ? HelaColors.primary : HelaColors.onSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category.label,
                    style: TextStyle(
                      color: isSelected ? HelaColors.primary : HelaColors.onSecondary,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Featured Havens',
                  style: TextStyle(
                    color: HelaColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Iconic sanctuaries of Ceylon',
                  style: TextStyle(
                    color: HelaColors.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StaysPage()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: HelaColors.secondary,
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
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _featuredHavens.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final haven = _featuredHavens[index];
              final isBookmarked = _bookmarkedHavens.contains(index);

              return HavenCard.fromHavenItem(
                haven,
                isBookmarked: isBookmarked,
                onBookmarkTap: () {
                  setState(() {
                    if (isBookmarked) {
                      _bookmarkedHavens.remove(index);
                    } else {
                      _bookmarkedHavens.add(index);
                    }
                  });
                },
                onExploreTap: () {
                  if (index == 1) {
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HelaColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: HelaColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.verified_rounded,
                color: HelaColors.primary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Ceylon Heritage Certified',
                  style: TextStyle(
                    color: HelaColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '100% vetted local indigenous hosts & eco-guides.',
                  style: TextStyle(
                    color: HelaColors.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: HelaColors.secondary,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Trending This Week',
                  style: TextStyle(
                    color: HelaColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Handcrafted slow-travel expeditions',
                  style: TextStyle(
                    color: HelaColors.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: HelaColors.secondary,
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
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _trendingExperiences.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final exp = _trendingExperiences[index];
              final isBookmarked = _bookmarkedExp.contains(index);

              return Container(
                width: 250,
                decoration: BoxDecoration(
                  color: HelaColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: HelaColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
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
                                color: HelaColors.surfaceContainerLowest.withValues(alpha: 0.85),
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () {
                                    setState(() {
                                      if (isBookmarked) {
                                        _bookmarkedExp.remove(index);
                                      } else {
                                        _bookmarkedExp.add(index);
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Icon(
                                      isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                      size: 16,
                                      color: HelaColors.primary,
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
                                  color: HelaColors.primaryContainer.withValues(alpha: 0.88),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.schedule_rounded,
                                      size: 12,
                                      color: HelaColors.onPrimary,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      exp.duration,
                                      style: const TextStyle(
                                        color: HelaColors.onPrimary,
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
                                        color: HelaColors.secondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        exp.category,
                                        style: const TextStyle(
                                          color: HelaColors.secondary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    exp.title,
                                    style: const TextStyle(
                                      color: HelaColors.primary,
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
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: HelaColors.surfaceContainer,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: exp.price,
                                            style: const TextStyle(
                                              color: HelaColors.primary,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                            ),
                                          ),
                                          TextSpan(
                                            text: index == 1 ? ' / jeep' : ' / guest',
                                            style: const TextStyle(
                                              color: HelaColors.onSurfaceVariant,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
                                          style: const TextStyle(
                                            color: HelaColors.primary,
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
    return Container(
      decoration: BoxDecoration(
        color: HelaColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: HelaColors.primary.withValues(alpha: 0.3),
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
                  color: HelaColors.secondary.withValues(alpha: 0.35),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TAILORED ITINERARIES',
                    style: TextStyle(
                      color: HelaColors.tertiaryFixed,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Need a custom private journey through Ceylon?',
                    style: TextStyle(
                      color: HelaColors.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Our native destination specialists curate immersive bespoke routes with private chauffeur guides.',
                    style: TextStyle(
                      color: HelaColors.surfaceContainerHigh,
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
                      backgroundColor: HelaColors.tertiaryFixed,
                      foregroundColor: HelaColors.primary,
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
              _buildNavItem(index: 0, label: 'Explore', icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded),
              _buildNavItem(
                index: 1,
                label: 'Saved',
                icon: Icons.bookmark_border_rounded,
                activeIcon: Icons.bookmark_rounded,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const StaysPage()),
                  );
                },
              ),
              _buildNavItem(
                index: 2,
                label: 'Journeys',
                icon: Icons.map_outlined,
                activeIcon: Icons.map_rounded,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const TripPlannerPage()),
                  );
                },
              ),
              _buildNavItem(
                index: 3,
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
      onTap: onTap ??
          () {
            setState(() {
              _selectedNavIndex = index;
            });
          },
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
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
