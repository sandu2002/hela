import 'package:flutter/material.dart';
import 'package:hela/pages/fair_ride_page.dart';
import 'package:hela/pages/cultural_guide/cultural_guide_page.dart';
import 'package:hela/pages/explore_page.dart';
import 'package:hela/pages/trip_planner_page.dart';
import 'package:hela/pages/profile_page.dart';
import 'package:hela/widgets/theme_switch_button.dart';
import 'package:hela/widgets/hela_drawer.dart';
import 'package:hela/widgets/hela_bottom_nav_bar.dart';
import 'package:hela/state/app_state.dart';

// Re-exports for backward compatibility
export 'package:hela/models/haven_item.dart';
import 'package:hela/theme/hela_colors.dart';
export 'package:hela/theme/hela_colors.dart';

/// Featured Destination model for Stitch Home Dashboard
class FeaturedDestinationItem {
  final String title;
  final String subtitle;
  final String rating;
  final String badge;
  final String footerTag;
  final String imageUrl;

  const FeaturedDestinationItem({
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.badge,
    required this.footerTag,
    required this.imageUrl,
  });
}

/// Handcrafted Experience model for Stitch Home Dashboard
class HomeExperienceItem {
  final String title;
  final String subtitle;
  final String category;
  final String rating;
  final String imageUrl;
  final String filterCategory;

  const HomeExperienceItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.rating,
    required this.imageUrl,
    required this.filterCategory,
  });
}

class HelaHomePage extends StatefulWidget {
  const HelaHomePage({super.key});

  @override
  State<HelaHomePage> createState() => _HelaHomePageState();
}

class _HelaHomePageState extends State<HelaHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _currentCity = 'Colombo';
  int _selectedExperienceChipIndex = 0; // 0: Nature & Wildlife, 1: Beaches, 2: Cultural Heritage, 3: Hill Country, 4: All

  final List<String> _experienceFilters = const [
    'Nature & Wildlife',
    'Beaches',
    'Cultural Heritage',
    'Hill Country',
    'All',
  ];

  final List<FeaturedDestinationItem> _destinations = const [
    FeaturedDestinationItem(
      title: 'Sigiriya',
      subtitle: 'Ancient Lion Rock fortress & royal water gardens',
      rating: '5.0',
      badge: 'UNESCO',
      footerTag: 'Cultural Wonder',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB470bfrsJ34_Zfz3mF8BpQZOUum-fhawKh51cm1K8-0n16IJnyIRDWCDo-p-4LKlIJL7eWRS6fSHiQ7Y076dniwfTg2-uSNGP-Y1fU4rUt8gQCz0RWM_EspICB8L-E9uu3ZguLz8MSZG0MZai01QaMRbw9u7NFJ6XRoYIDFwFMifvWSsy_XhyQ2UkxBFBJVs0TNFtCkUr-O7xCS0cyKCNy4TCnZZq8uzJM0M3dU9c',
    ),
    FeaturedDestinationItem(
      title: 'Ella',
      subtitle: 'Nine Arch Bridge, Little Adam\'s Peak & misty tea estates',
      rating: '4.9',
      badge: 'Highlands',
      footerTag: 'Scenic Rail & Hike',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC1-w7059r6Tx8JOuHhGLLm6spMsWw09E48ApBmOWTEe-p-IbOyd8GBmFh3Zvn60CK2ZR0YsjHx75NDRUWyT2eYsmsMBsoNsO380YPX-8NkCVlAl9L84IrpVcJskPmn7bby1SLlQNDsytKDChKgPdcmfeIa6V14oUmNsO-WDDWQZJlHl_dJvco52RzpSUA0AS2JlopPWLNhvwsNiRGcKN4YqXKlwv5GpBLlmhs9TRI',
    ),
    FeaturedDestinationItem(
      title: 'Kandy',
      subtitle: 'Sacred Temple of the Tooth & lush botanical sanctuary',
      rating: '4.8',
      badge: 'Heritage',
      footerTag: 'Spiritual Heart',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAf_ZHki056g4HPCYefzjMlcb2RDYtvjthd-ddHXXVe627O2eS1UoDIgiQ_L-HKdkLD9fKmpLz29XjJCzAX-uHg68hnR6w8d8wJJJasNuOqCFl3pVUmgcPmjQzd1eEzWMovtcNQjv5uQV-wGNks7fK8WOBUFpNVKYzvyjP0oOxlEXwSUQgjWHLC-mO86yMwUkMCo4fc0t_xHB8t1iRNYNQe3OQwojumYbhjBuANTUk',
    ),
    FeaturedDestinationItem(
      title: 'Galle',
      subtitle: '17th-century Dutch colonial ramparts & ocean fort',
      rating: '4.9',
      badge: 'Colonial Fort',
      footerTag: 'Coastal Heritage',
      imageUrl:
          'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
    ),
    FeaturedDestinationItem(
      title: 'Mirissa',
      subtitle: 'Golden palm-fringed coastlines & sunset whale watching',
      rating: '4.9',
      badge: 'South Coast',
      footerTag: 'Ocean & Whales',
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
    ),
  ];

  final List<HomeExperienceItem> _experiences = const [
    HomeExperienceItem(
      title: 'Minneriya Elephant Gathering & Yala Safaris',
      subtitle: 'Witness majestic wild elephant herds & elusive leopards',
      category: 'NATURE & WILDLIFE',
      rating: '4.9',
      filterCategory: 'Nature & Wildlife',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD0D-R82TA9_SGuSRDfEnwrE2O1k8vnQfZhJ3koSU4dn3zja8bG-1GyYpElMjx7OaMROOj5YIrG_ilEW47rcLiRGDhHJ9XTpTJm5wQdSK6ZbluVAV45sagYlIO4JtR_VMfGHBBecYiAD1gG5dir-RCgv1og-V5_c2KBOHvrr44Kfw5QelxizrzCF9Bhhj9hBwM6Qy65FCruTdgatHraZDf-6C4KhLFPlpc0DpOKZfs',
    ),
    HomeExperienceItem(
      title: 'Ceylon Spice Trail & Hopper Feast',
      subtitle: 'Authentic culinary secrets & aromatic street flavours',
      category: 'FOOD EXPERIENCES',
      rating: '4.8',
      filterCategory: 'Cultural Heritage',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD2rfOC6O1lEWNIWbhJf_r1GCl1ASdc_1ILTZsnvCFVaqHPPJVjBzyaXrPR1lsA9FFF5W9vKiAcTPRCN53Z0WEr4EqTNXW4tVKuzy04-fiYUbKBRLtuEuz-SVnjSnMumm-Dh4IVwk3eB8rMdw1axmV-frW7vrR441oE8YY6RAqBn8NgN_P5MA87481eCnW137ndaMkyTU49mPguMCtmFLjJscVS6fkCvzyZ4fi4yVA',
    ),
    HomeExperienceItem(
      title: 'Weligama Surfing & Tangalle Bays',
      subtitle: 'Pristine breaks, secluded lagoons & coastal bliss',
      category: 'BEACHES & OCEAN',
      rating: '4.9',
      filterCategory: 'Beaches',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD_mI8m7U4OG8RLk9jEVrfoZ3MLdCuXE_POyoYiKB7DwHR7fA3C56-fnoLmO3maydv5UPhaBIrOjd8xJ26dOCKDowueQ3cdc2tPTpeK0Nc44gDM1OiLGugPrOVOJipNveFhuHtwKxqF-eP1ZJJKfd_OJXhz9mlAZMNvs6ye70hBOjRqcS3XO8amh6r6tmPbWWlzqhGKW19iXSynZe8CaXaLElc5zIZgJS-YuK_HVgo',
    ),
    HomeExperienceItem(
      title: 'Nine Arch Bridge & Demodara Tea Valley',
      subtitle: 'Colonial railway arches shrouded in morning mountain mist',
      category: 'HILL COUNTRY',
      rating: '4.9',
      filterCategory: 'Hill Country',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDvJryELDH6m-aPQfsWTQ16312Y8rBu_auTNO6RdIu6gbV4Pwcooer456mtq4aG-SyKDYKNNg8-VWK0IuqWCpQQjHRKu2phfsvLM138y7tF4c0JEFCRImFso5Q05zKJanq1aBD3Q1iC30zFwaKYXyE_RgKZ0emUZlFa6Gh0qIs2uXJmMge8Zy3FlYNN0tmbm3Q7KzAXiBPuXo-9JhDuJpvmkQQWVWLd7RjEZbw3TYlMvhBaoZt8cQ-eog',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openLocationPicker() {
    final cities = ['Colombo', 'Kandy', 'Galle', 'Ella', 'Sigiriya', 'Mirissa', 'Nuwara Eliya', 'Trincomalee'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final colors = HelaColors.of(context);
        return Container(
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.architecturalBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Current Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              ...cities.map(
                (city) => ListTile(
                  leading: Icon(
                    Icons.location_on_rounded,
                    color: city == _currentCity ? colors.primary : colors.onSurfaceVariant,
                  ),
                  title: Text(
                    city,
                    style: TextStyle(
                      fontWeight: city == _currentCity ? FontWeight.w700 : FontWeight.w500,
                      color: city == _currentCity ? colors.primary : colors.onSurface,
                    ),
                  ),
                  trailing: city == _currentCity
                      ? Icon(Icons.check_rounded, color: colors.primary)
                      : null,
                  onTap: () {
                    setState(() => _currentCity = city);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        );
      },
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
        color: const Color(0xFF0B5D56).withValues(alpha: 0.15),
        child: const Center(
          child: Icon(Icons.landscape_rounded, color: Color(0xFF0B5D56), size: 32),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final query = _searchQuery.trim().toLowerCase();
    final selectedFilter = _experienceFilters[_selectedExperienceChipIndex];
    final baseExperiences = selectedFilter == 'All'
        ? _experiences
        : _experiences.where((e) => e.filterCategory == selectedFilter).toList();
    final displayedExperiences = query.isEmpty
        ? baseExperiences
        : baseExperiences.where((e) => e.title.toLowerCase().contains(query) || e.subtitle.toLowerCase().contains(query)).toList();

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

                        // Greeting & Location Subbar
                        _buildGreetingAndLocation(colors),
                        const SizedBox(height: 14),

                        // Search Interaction Bar
                        _buildSearchBar(colors),
                        const SizedBox(height: 18),

                        // Hero Section: Smart Itinerary Card
                        _buildHeroSmartItineraryCard(colors),
                        const SizedBox(height: 20),

                        // Quick Actions: 4-Column Grid
                        _buildQuickActions(colors),
                        const SizedBox(height: 24),

                        // Featured Destinations Carousel
                        _buildFeaturedDestinationsSection(colors),
                        const SizedBox(height: 26),

                        // Experiences You Will Love Section
                        _buildExperiencesSection(colors, displayedExperiences),
                        const SizedBox(height: 22),

                        // AI Assistant Promo Banner
                        _buildAiAssistantPromoBanner(colors),
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
      bottomNavigationBar: const HelaBottomNavBar(currentIndex: 0),
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
          // Monogram / Drawer Trigger
          InkWell(
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                HelaAppStateProvider.of(context).tr('home'),
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
              const SnackBar(content: Text('No new travel notifications')),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 4),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
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

  Widget _buildGreetingAndLocation(HelaColorPalette colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  HelaAppStateProvider.of(context).tr('hello_traveller'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              HelaAppStateProvider.of(context).tr('explore_pearl'),
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: _openLocationPicker,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: colors.architecturalBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_rounded, size: 15, color: colors.primary),
                const SizedBox(width: 4),
                Text(
                  _currentCity,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.expand_more_rounded, size: 14, color: colors.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(HelaColorPalette colors) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.architecturalBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(Icons.search_rounded, color: colors.primary, size: 22),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: HelaAppStateProvider.of(context).tr('where_to_go'),
                hintStyle: TextStyle(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.tune_rounded, size: 18, color: colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSmartItineraryCard(HelaColorPalette colors) {
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
            _buildNetworkImage(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCfLRS1LsxapAszLJa0etMrOi9jdUPktoyWZIMUJLEh7doMRbg20drfraJaI5G8ZirrxpePZwTqZU7JILR8-Eq0jZF0KInaY-Hsc9Vca4f_F4WwJZHI70_-J-IWqwQEPELEOhGvdamVSm4UXl-4O6Y3TK6__pIoTFUGQB1pqOvj5r66yxFmpB4W6-i7-CINSqIJnavY8Z4YbSIQWnaWrLI8d1gBJovsav4axAwuKvw',
            ),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.goldenAmber,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, size: 12, color: Color(0xFF271900)),
                        const SizedBox(width: 4),
                        Text(
                          HelaAppStateProvider.of(context).tr('smart_itinerary'),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF271900),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    HelaAppStateProvider.of(context).tr('discover_title'),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    HelaAppStateProvider.of(context).tr('hero_subtitle'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TripPlannerPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primaryFixed,
                          foregroundColor: colors.primary,
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              HelaAppStateProvider.of(context).tr('plan_my_trip'),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
                      ),
                      Text(
                        HelaAppStateProvider.of(context).tr('instant_ai'),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
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

  Widget _buildQuickActions(HelaColorPalette colors) {
    final appState = HelaAppStateProvider.of(context);
    return Row(
      children: [
        _buildActionTile(
          icon: Icons.explore_rounded,
          iconBg: colors.secondaryContainer,
          iconColor: colors.onSecondaryContainer,
          title: appState.tr('ai_travel_assistant'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TripPlannerPage()));
          },
          colors: colors,
        ),
        const SizedBox(width: 8),
        _buildActionTile(
          icon: Icons.electric_rickshaw_rounded,
          iconBg: colors.surfaceContainerHigh,
          iconColor: colors.primary,
          title: appState.tr('book_taxi'),
          badgeText: 'Meter',
          badgeColor: colors.goldenAmber,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FairRidePage()));
          },
          colors: colors,
        ),
        const SizedBox(width: 8),
        _buildActionTile(
          icon: Icons.map_rounded,
          iconBg: colors.surfaceContainerHigh,
          iconColor: colors.primary,
          title: appState.tr('find_places'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ExplorePage()));
          },
          colors: colors,
        ),
        const SizedBox(width: 8),
        _buildActionTile(
          icon: Icons.temple_buddhist_rounded,
          iconBg: colors.secondaryContainer,
          iconColor: colors.onSecondaryContainer,
          title: appState.tr('explore'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CulturalGuidePage()));
          },
          colors: colors,
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    required HelaColorPalette colors,
    String? badgeText,
    Color? badgeColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.architecturalBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  if (badgeText != null)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: badgeColor ?? colors.goldenAmber,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF271900),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedDestinationsSection(HelaColorPalette colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  HelaAppStateProvider.of(context).tr('featured_destinations'),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ExplorePage()));
              },
              style: TextButton.styleFrom(
                foregroundColor: colors.primary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                HelaAppStateProvider.of(context).tr('see_all'),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal Carousel
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _destinations.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = _destinations[index];
              return _buildDestinationCard(item, colors);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationCard(FeaturedDestinationItem item, HelaColorPalette colors) {
    return Container(
      width: 230,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
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
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header
            Stack(
              children: [
                SizedBox(
                  height: 125,
                  width: double.infinity,
                  child: _buildNetworkImage(item.imageUrl),
                ),
                // Rating pill
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star_rounded, size: 12, color: colors.goldenAmber),
                        const SizedBox(width: 2),
                        Text(
                          item.rating,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF132220),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // UNESCO / Category badge
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.badge,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
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
                      Text(
                        item.footerTag,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                      Icon(Icons.arrow_forward_rounded, size: 15, color: colors.primary),
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

  Widget _buildExperiencesSection(HelaColorPalette colors, List<HomeExperienceItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              HelaAppStateProvider.of(context).tr('experiences_love'),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              HelaAppStateProvider.of(context).tr('handcrafted'),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_experienceFilters.length, (idx) {
              final isSelected = _selectedExperienceChipIndex == idx;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedExperienceChipIndex = idx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? colors.primary : colors.cardBackground,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isSelected ? colors.primary : colors.architecturalBorder,
                      ),
                    ),
                    child: Text(
                      _experienceFilters[idx],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 14),

        // Experience Cards Stack
        ...items.map((exp) => _buildExperienceCard(exp, colors)),
      ],
    );
  }

  Widget _buildExperienceCard(HomeExperienceItem exp, HelaColorPalette colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 64,
              height: 64,
              child: _buildNetworkImage(exp.imageUrl),
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
                      exp.category,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: colors.secondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 12, color: colors.goldenAmber),
                        const SizedBox(width: 2),
                        Text(
                          exp.rating,
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
                const SizedBox(height: 2),
                Text(
                  exp.title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  exp.subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded, size: 20, color: colors.outlineVariant),
        ],
      ),
    );
  }

  Widget _buildAiAssistantPromoBanner(HelaColorPalette colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.surfaceContainerHigh, colors.surfaceContainer],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.architecturalBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.smart_toy_rounded, size: 22, color: colors.goldenAmber),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  HelaAppStateProvider.of(context).tr('need_advice'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.secondary,
                  ),
                ),
                Text(
                  HelaAppStateProvider.of(context).tr('ask_hela_desc'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              HelaBottomNavBar.openAskHelaSheet(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              elevation: 1,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  HelaAppStateProvider.of(context).tr('ask_hela'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chat_bubble_outline_rounded, size: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
