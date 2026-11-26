import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hela/data/place_details_catalog.dart';
import 'package:hela/data/sri_lanka_images.dart';
import 'package:hela/widgets/hela_network_image.dart';
import 'package:hela/pages/fair_ride_page.dart';
import 'package:hela/pages/explore_page.dart';
import 'package:hela/pages/place_details_page.dart';
import 'package:hela/pages/trip_planner_page.dart';
import 'package:hela/services/live_weather_service.dart';
import 'package:hela/services/sri_lanka_places_search_service.dart';
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

class _HelaHomePageState extends State<HelaHomePage>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  late final LiveWeatherService _locationService;
  String _searchQuery = '';
  List<FeaturedDestinationItem> _searchedDestinations = [];
  bool _isLiveSearching = false;
  String _currentCity = 'Colombo';
  int _selectedExperienceChipIndex =
      0; // 0: All, 1: Beaches, 2: Cultural Heritage, 3: Nature & Wildlife, 4: Adventure

  final List<String> _experienceFilters = const [
    'All',
    'Beaches',
    'Cultural Heritage',
    'Nature & Wildlife',
    'Adventure',
  ];

  void _openPlaceDetailsFromDestination(FeaturedDestinationItem item) {
    final details = PlaceDetailCatalog.resolveForFeaturedDestination(item);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlaceDetailsPage(place: details)),
    );
  }

  void _onSearchChanged(String val) {
    setState(() {
      _searchQuery = val;
      _searchedDestinations = SriLankaPlacesSearchService.searchLocal(val);
    });

    if (val.trim().length >= 2) {
      _performLiveSearch(val.trim());
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchedDestinations = [];
      _isLiveSearching = false;
    });
  }

  void _performLiveSearch(String q) async {
    _isLiveSearching = true;
    try {
      final liveResults = await SriLankaPlacesSearchService.searchLive(q);
      if (mounted && _searchQuery.trim().toLowerCase() == q.toLowerCase()) {
        setState(() {
          _searchedDestinations = liveResults;
          _isLiveSearching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLiveSearching = false);
    }
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
    // Curated most famous places in Sri Lanka (Google-verified ratings & details)
    // Shown in full under "All" (16 destinations) and filtered by category tab.
    HomeExperienceItem(
      title: 'Sigiriya Lion Rock Fortress',
      subtitle: '5th-century UNESCO sky citadel, water gardens & ancient frescoes',
      category: 'CULTURAL HERITAGE',
      rating: '4.7',
      filterCategory: 'Cultural Heritage',
      imageUrl: SriLankaImages.sigiriya,
    ),
    HomeExperienceItem(
      title: 'Mirissa Beach & Coconut Tree Hill',
      subtitle: 'Blue whale watching hub, palm headland & golden tropical bay',
      category: 'BEACHES',
      rating: '4.6',
      filterCategory: 'Beaches',
      imageUrl: SriLankaImages.mirissa,
    ),
    HomeExperienceItem(
      title: 'Minneriya Elephant Gathering & Yala Safaris',
      subtitle: 'Wild Asian elephant herds & world-famous leopard safaris',
      category: 'NATURE & WILDLIFE',
      rating: '4.7',
      filterCategory: 'Nature & Wildlife',
      imageUrl: SriLankaImages.elephant,
    ),
    HomeExperienceItem(
      title: 'Galle Dutch Fort',
      subtitle: '17th-century UNESCO ocean ramparts, lighthouse & colonial streets',
      category: 'CULTURAL HERITAGE',
      rating: '4.8',
      filterCategory: 'Cultural Heritage',
      imageUrl: SriLankaImages.galleFort,
    ),
    HomeExperienceItem(
      title: 'Nine Arch Bridge & Flying Ravana Zipline',
      subtitle: '80 km/h tea valley mega zipline, Ella Rock hikes & iconic rail bridge',
      category: 'ADVENTURE',
      rating: '4.8',
      filterCategory: 'Adventure',
      imageUrl: SriLankaImages.nineArchBridge,
    ),
    HomeExperienceItem(
      title: 'Temple of the Sacred Tooth Relic, Kandy',
      subtitle: 'Sacred golden-roofed royal Buddhist shrine beside Kandy Lake',
      category: 'CULTURAL HERITAGE',
      rating: '4.6',
      filterCategory: 'Cultural Heritage',
      imageUrl: SriLankaImages.templeOfTheTooth,
    ),
    HomeExperienceItem(
      title: 'Arugam Bay Surf Capital',
      subtitle: 'World-renowned east coast surf point breaks & bohemian cabanas',
      category: 'BEACHES',
      rating: '4.6',
      filterCategory: 'Beaches',
      imageUrl: SriLankaImages.arugamBay,
    ),
    HomeExperienceItem(
      title: 'Udawalawe National Park',
      subtitle: 'Open savannah plains famous for guaranteed wild elephant herds',
      category: 'NATURE & WILDLIFE',
      rating: '4.8',
      filterCategory: 'Nature & Wildlife',
      imageUrl: SriLankaImages.udawalawe,
    ),
    HomeExperienceItem(
      title: 'Adam\'s Peak (Sri Pada) Night Trek',
      subtitle: '2,243m sacred summit pilgrimage climb for breathtaking sunrise views',
      category: 'ADVENTURE',
      rating: '4.8',
      filterCategory: 'Adventure',
      imageUrl: SriLankaImages.adamsPeak,
    ),
    HomeExperienceItem(
      title: 'Weligama Surfing & Tangalle Bays',
      subtitle: 'Gentle beginner surf bay, stilt fishermen & secluded southern coves',
      category: 'BEACHES',
      rating: '4.6',
      filterCategory: 'Beaches',
      imageUrl: SriLankaImages.weligama,
    ),
    HomeExperienceItem(
      title: 'Horton Plains & World\'s End',
      subtitle: '2,100m UNESCO cloud forest plateau with dramatic 870m cliff drop',
      category: 'NATURE & WILDLIFE',
      rating: '4.7',
      filterCategory: 'Nature & Wildlife',
      imageUrl: SriLankaImages.hortonPlains,
    ),
    HomeExperienceItem(
      title: 'Kitulgala White-Water Rafting',
      subtitle: 'Kelani River Grade 2–3 rapids, canyoning & rainforest cliff jumps',
      category: 'ADVENTURE',
      rating: '4.7',
      filterCategory: 'Adventure',
      imageUrl: SriLankaImages.kitulgala,
    ),
    HomeExperienceItem(
      title: 'Ancient City of Polonnaruwa',
      subtitle: '12th-century UNESCO royal capital with Gal Vihara rock Buddhas',
      category: 'CULTURAL HERITAGE',
      rating: '4.6',
      filterCategory: 'Cultural Heritage',
      imageUrl: SriLankaImages.polonnaruwa,
    ),
    HomeExperienceItem(
      title: 'Unawatuna Beach & Coral Reef',
      subtitle: 'Calm turquoise horseshoe bay ideal for reef swimming & snorkeling',
      category: 'BEACHES',
      rating: '4.5',
      filterCategory: 'Beaches',
      imageUrl: SriLankaImages.unawatuna,
    ),
    HomeExperienceItem(
      title: 'Sinharaja Rainforest Reserve',
      subtitle: 'UNESCO virgin lowland tropical rainforest & endemic bird sanctuary',
      category: 'NATURE & WILDLIFE',
      rating: '4.8',
      filterCategory: 'Nature & Wildlife',
      imageUrl: SriLankaImages.sinharaja,
    ),
    HomeExperienceItem(
      title: 'Knuckles Mountain Range Trek',
      subtitle: 'Rugged cloud-forest peaks, hidden waterfalls & remote village trails',
      category: 'ADVENTURE',
      rating: '4.8',
      filterCategory: 'Adventure',
      imageUrl: SriLankaImages.knucklesRange,
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
    if (state == AppLifecycleState.resumed) {
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
                content: const Text(
                  'Location permission is blocked. Enable it in App Settings.',
                ),
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
      fallbackLocationName: profileFallback.isNotEmpty
          ? profileFallback
          : _currentCity,
      requestPermissionIfNeeded: requestPermissionIfNeeded,
    );

    if (!mounted) return;
    setState(() {
      _currentCity = resolved.cityName;
      appState.setDetectedCurrentCity(resolved.cityName);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildNetworkImage(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
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
          child: Icon(
            Icons.landscape_rounded,
            color: Color(0xFF0B5D56),
            size: 32,
          ),
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
        : _experiences
              .where((e) => e.filterCategory == selectedFilter)
              .toList();
    final displayedExperiences = query.isEmpty
        ? baseExperiences
        : baseExperiences
              .where(
                (e) =>
                    e.title.toLowerCase().contains(query) ||
                    e.subtitle.toLowerCase().contains(query),
              )
              .toList();

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
                        const SizedBox(height: 8),

                        // Search Interaction Bar
                        _buildSearchBar(colors),
                        const SizedBox(height: 18),

                        // If searching, display matching Featured Destinations with real-time data immediately
                        if (_searchQuery.trim().isNotEmpty) ...[
                          _buildFeaturedDestinationsSection(colors),
                          const SizedBox(height: 22),
                        ],

                        // Hero Section: Smart Itinerary Card (with Plan My Trip & Taxi actions)
                        _buildHeroSmartItineraryCard(colors),
                        const SizedBox(height: 24),

                        // When not searching, keep Featured Destinations in its default place
                        if (_searchQuery.trim().isEmpty) ...[
                          _buildFeaturedDestinationsSection(colors),
                          const SizedBox(height: 26),
                        ],

                        // Experiences You Will Love Section
                        _buildExperiencesSection(colors, displayedExperiences),
                        const SizedBox(height: 22),

                        // AI Assistant Promo Banner
                        _buildAiAssistantPromoBanner(colors),
                        const SizedBox(height: 52),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Floating "Ask HELA" Action Capsule in Bottom Right
            Positioned(
              bottom: 20,
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
      scrolledUnderElevation: 0,
      toolbarHeight: 68,
      titleSpacing: 16,
      automaticallyImplyLeading: false,
      title: Text(
        'Where to?',
        style: TextStyle(
          color: colors.onSurface,
          fontSize: 34,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
          fontFamily: 'Inter',
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new travel notifications')),
              );
            },
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surfaceContainer,
                border: Border.all(
                  color: colors.architecturalBorder.withValues(alpha: 0.6),
                ),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: colors.onSurface,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(HelaColorPalette colors) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colors.architecturalBorder.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18, right: 12),
            child: Icon(
              Icons.search_rounded,
              color: colors.onSurface,
              size: 22,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchChanged,
              style: TextStyle(
                fontSize: 14.5,
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
                hintText: 'Places to go, things to do, hotels...',
                hintStyle: TextStyle(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: _clearSearch,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
              ),
            )
          else
            const SizedBox(width: 18),
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
            _buildNetworkImage(SriLankaImages.sigiriya),
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    HelaAppStateProvider.of(context).tr('discover_title'),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: -0.3,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          offset: Offset(0, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    HelaAppStateProvider.of(context).tr('hero_subtitle'),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w500,
                      shadows: const [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TripPlannerPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primaryFixed,
                          foregroundColor: colors.primary,
                          elevation: 2,
                          shadowColor: Colors.black.withValues(alpha: 0.2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              HelaAppStateProvider.of(
                                context,
                              ).tr('plan_my_trip'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FairRidePage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.96),
                          foregroundColor: const Color(0xFF00382E),
                          elevation: 2,
                          shadowColor: Colors.black.withValues(alpha: 0.2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.local_taxi_rounded,
                              size: 16,
                              color: Color(0xFF00382E),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Taxi',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF00382E),
                              ),
                            ),
                          ],
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

  Widget _buildFeaturedDestinationsSection(HelaColorPalette colors) {
    final isSearching = _searchQuery.trim().isNotEmpty;
    final destinations = isSearching
        ? _searchedDestinations
        : kFeaturedDestinations;

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
                      HelaAppStateProvider.of(
                        context,
                      ).tr('featured_destinations'),
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
                      color: isSearching
                          ? const Color(0xFF00E676)
                          : colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (isSearching) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isLiveSearching) ...[
                            SizedBox(
                              width: 8,
                              height: 8,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: colors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            'Real-Time (${destinations.length})',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isSearching)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExplorePage()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: colors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  HelaAppStateProvider.of(context).tr('see_all'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              )
            else
              TextButton(
                onPressed: _clearSearch,
                style: TextButton.styleFrom(
                  foregroundColor: colors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Clear',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal Carousel
        SizedBox(
          height: 235,
          child: destinations.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'No destinations found for "$_searchQuery". Try searching Sigiriya, Ella, Kandy, Galle, or Nuwara Eliya.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: destinations.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = destinations[index];
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

  Widget _buildExperiencesSection(
    HelaColorPalette colors,
    List<HomeExperienceItem> items,
  ) {
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
                  onTap: () =>
                      setState(() => _selectedExperienceChipIndex = idx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.primary
                          : colors.cardBackground,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isSelected
                            ? colors.primary
                            : colors.architecturalBorder,
                      ),
                    ),
                    child: Text(
                      _experienceFilters[idx],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : colors.onSurfaceVariant,
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
                          Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: colors.goldenAmber,
                          ),
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
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colors.outlineVariant,
            ),
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
              child: Icon(
                Icons.smart_toy_rounded,
                size: 22,
                color: colors.goldenAmber,
              ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                elevation: 1,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    HelaAppStateProvider.of(context).tr('ask_hela'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
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
