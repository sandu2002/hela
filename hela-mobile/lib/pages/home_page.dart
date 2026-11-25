import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hela/data/place_details_catalog.dart';
import 'package:hela/widgets/hela_network_image.dart';
import 'package:hela/pages/fair_ride_page.dart';
import 'package:hela/pages/cultural_guide/cultural_guide_page.dart';
import 'package:hela/pages/explore_page.dart';
import 'package:hela/pages/place_details_page.dart';
import 'package:hela/pages/trip_planner_page.dart';
import 'package:hela/pages/profile_page.dart';
import 'package:hela/services/live_weather_service.dart';
import 'package:hela/widgets/featured_destination_card.dart';
import 'package:hela/widgets/hela_drawer.dart';
import 'package:hela/widgets/hela_bottom_nav_bar.dart';
import 'package:hela/state/app_state.dart';

// Re-exports for backward compatibility
export 'package:hela/models/featured_destination_item.dart';
export 'package:hela/models/haven_item.dart';
import 'package:hela/theme/hela_colors.dart';
export 'package:hela/theme/hela_colors.dart';

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
  final LiveWeatherService? weatherService;

  const HelaHomePage({super.key, this.weatherService});

  @override
  State<HelaHomePage> createState() => _HelaHomePageState();
}

class _HelaHomePageState extends State<HelaHomePage> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  late final LiveWeatherService _locationService;
  String _searchQuery = '';
  String _currentCity = 'Colombo';
  bool _isLocating = false;
  bool _hasManualCityOverride = false;
  int _selectedExperienceChipIndex = 0; // 0: Nature & Wildlife, 1: Beaches, 2: Cultural Heritage, 3: Hill Country, 4: All

  final List<String> _experienceFilters = const [
    'Nature & Wildlife',
    'Beaches',
    'Cultural Heritage',
    'Hill Country',
    'All',
  ];

  void _openPlaceDetailsFromDestination(FeaturedDestinationItem item) {
    final details = PlaceDetailCatalog.resolveForFeaturedDestination(item);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlaceDetailsPage(place: details)),
    );
  }

  void _openPlaceDetailsFromExperience(HomeExperienceItem exp) {
    final details = PlaceDetailCatalog.resolveByIdOrTitle(
      exp.title,
      fallbackSubtitle: exp.subtitle,
      fallbackRating: exp.rating,
      fallbackImageUrl: exp.imageUrl,
      fallbackCategory: exp.category,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlaceDetailsPage(place: details)),
    );
  }

  final List<HomeExperienceItem> _experiences = const [
    HomeExperienceItem(
      title: 'Minneriya Elephant Gathering & Yala Safaris',
      subtitle: 'Witness majestic wild elephant herds & elusive leopards',
      category: 'NATURE & WILDLIFE',
      rating: '4.9',
      filterCategory: 'Nature & Wildlife',
      imageUrl:
          'https://images.unsplash.com/photo-1557050543-4d5f4e07ef46?w=800&auto=format&fit=crop&q=80',
    ),
    HomeExperienceItem(
      title: 'Ceylon Spice Trail & Hopper Feast',
      subtitle: 'Authentic culinary secrets & aromatic street flavours',
      category: 'FOOD EXPERIENCES',
      rating: '4.8',
      filterCategory: 'Cultural Heritage',
      imageUrl:
          'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=800&auto=format&fit=crop&q=80',
    ),
    HomeExperienceItem(
      title: 'Weligama Surfing & Tangalle Bays',
      subtitle: 'Pristine breaks, secluded lagoons & coastal bliss',
      category: 'BEACHES & OCEAN',
      rating: '4.9',
      filterCategory: 'Beaches',
      imageUrl:
          'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=800&auto=format&fit=crop&q=80',
    ),
    HomeExperienceItem(
      title: 'Nine Arch Bridge & Demodara Tea Valley',
      subtitle: 'Colonial railway arches shrouded in morning mountain mist',
      category: 'HILL COUNTRY',
      rating: '4.9',
      filterCategory: 'Hill Country',
      imageUrl:
          'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _locationService = widget.weatherService ?? LiveWeatherService();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cachedCity = HelaAppStateProvider.of(context).detectedCurrentCity;
      if (cachedCity != null && cachedCity.isNotEmpty) {
        setState(() => _currentCity = cachedCity);
      }
      _detectCurrentLocation(requestPermissionIfNeeded: true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_hasManualCityOverride) {
      _detectCurrentLocation(requestPermissionIfNeeded: false);
    }
  }

  Future<void> _detectCurrentLocation({
    required bool requestPermissionIfNeeded,
    bool showSettingsPromptOnDeny = false,
  }) async {
    if (!mounted) return;
    final appState = HelaAppStateProvider.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isLocating = true);

    if (showSettingsPromptOnDeny) {
      try {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled && mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: const Text('Please enable phone GPS/location services.'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => Geolocator.openLocationSettings(),
              ),
            ),
          );
        } else {
          final permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.deniedForever && mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: const Text('Location permission is blocked. Enable it in App Settings.'),
                action: SnackBarAction(
                  label: 'App Settings',
                  onPressed: () => Geolocator.openAppSettings(),
                ),
              ),
            );
          }
        }
      } catch (_) {
        // Ignore on platforms/tests without native Geolocator plugin
      }
    }

    final profileFallback = appState.userLocation.split(',').first.trim();
    final resolved = await _locationService.resolveUserLocation(
      fallbackLocationName: profileFallback.isNotEmpty ? profileFallback : _currentCity,
      requestPermissionIfNeeded: requestPermissionIfNeeded,
    );

    if (!mounted) return;
    setState(() {
      if (!_hasManualCityOverride || showSettingsPromptOnDeny) {
        _currentCity = resolved.cityName;
        appState.setDetectedCurrentCity(resolved.cityName);
      }
      _isLocating = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  void _openLocationPicker() {
    final cities = ['Colombo', 'Kandy', 'Galle', 'Ella', 'Sigiriya', 'Mirissa', 'Nuwara Eliya', 'Trincomalee'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final colors = HelaColors.of(context);
        return Material(
          color: colors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: SafeArea(
              top: false,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.75,
                ),
                child: SingleChildScrollView(
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
                        HelaAppStateProvider.of(ctx).tr('select_current_location'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: colors.primary.withValues(alpha: 0.12),
                          child: Icon(Icons.my_location_rounded, size: 18, color: colors.primary),
                        ),
                        title: Text(
                          HelaAppStateProvider.of(ctx).tr('use_gps_location'),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                        subtitle: Text(
                          HelaAppStateProvider.of(ctx).tr('detect_gps_sub'),
                          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          _hasManualCityOverride = false;
                          _detectCurrentLocation(
                            requestPermissionIfNeeded: true,
                            showSettingsPromptOnDeny: true,
                          );
                        },
                      ),
                      Divider(color: colors.architecturalBorder),
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
                            setState(() {
                              _hasManualCityOverride = true;
                              _currentCity = city;
                            });
                            HelaAppStateProvider.of(context).setDetectedCurrentCity(city);
                            Navigator.pop(ctx);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNetworkImage(String url, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    return HelaNetworkImage(
      imageUrl: url,
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                HelaAppStateProvider.of(context).tr('hello_traveller'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                HelaAppStateProvider.of(context).tr('explore_pearl'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: _openLocationPicker,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 160),
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
                Flexible(
                  child: Text(
                    _currentCity,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ),
                if (_isLocating) ...[
                  const SizedBox(width: 5),
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.6,
                      color: colors.primary,
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 2),
                  Icon(Icons.expand_more_rounded, size: 14, color: colors.onSurfaceVariant),
                ],
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
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
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
              'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=1200&auto=format&fit=crop&q=85',
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
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          HelaAppStateProvider.of(context).tr('instant_ai'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
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
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      HelaAppStateProvider.of(context).tr('featured_destinations'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                        fontFamily: 'Inter',
                      ),
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
            itemCount: kFeaturedDestinations.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = kFeaturedDestinations[index];
              return FeaturedDestinationCard(
                item: item,
                onTap: () => _openPlaceDetailsFromDestination(item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExperiencesSection(HelaColorPalette colors, List<HomeExperienceItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
    return GestureDetector(
      onTap: () => _openPlaceDetailsFromExperience(exp),
      child: Container(
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
      ),
    );
  }

  Widget _buildAiAssistantPromoBanner(HelaColorPalette colors) {
    return InkWell(
      onTap: () {
        HelaBottomNavBar.openAskHelaSheet(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
      ),
    );
  }
}
