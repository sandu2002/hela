import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hela/data/place_details_catalog.dart';
import 'package:hela/models/haven_item.dart';
import 'package:hela/pages/ask_hela_page.dart';
import 'package:hela/pages/profile_page.dart';
import 'package:hela/pages/trip_planner_page.dart';
import 'package:hela/services/route_map_service.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/theme/hela_colors.dart';
import 'package:hela/widgets/live_route_overview_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

/// Place / Destination Details Screen matching the HELA Stitch UI:
/// - Floating back, favorite (synced with HelaAppState), and profile controls
/// - Swipeable Hero Photo Carousel with badges, Local Lore audio guide, and photo counter
/// - Title, subtitle, Sinhala script name, verified rating pill & location/prestige banner
/// - 2x2 Quick Info Specs grid
/// - Interactive 3-segment tabs: Highlights | History | Visit Tips
/// - Live Location & Geography OpenStreetMap with GPS distance and Route trigger
/// - Clickable Nearby Discoveries horizontal cards
/// - Ask HELA Travel Intelligence dark-emerald card with topic pills
/// - Sticky bottom bar with Get Directions & Add to My Trip actions
class PlaceDetailsPage extends StatefulWidget {
  final PlaceDetailData place;

  const PlaceDetailsPage({
    super.key,
    required this.place,
  });

  @override
  State<PlaceDetailsPage> createState() => _PlaceDetailsPageState();
}

class _PlaceDetailsPageState extends State<PlaceDetailsPage> {
  final PageController _photoController = PageController();
  final MapController _miniMapController = MapController();

  int _currentPhotoIndex = 0;
  int _selectedTabIndex = 0; // 0: Highlights, 1: History, 2: Visit Tips
  bool _isLorePlaying = false;
  bool _localFavorite = false;
  LatLng? _liveUserLocation;

  @override
  void initState() {
    super.initState();
    _resolveLiveGpsDistance();
  }

  @override
  void dispose() {
    _photoController.dispose();
    _miniMapController.dispose();
    super.dispose();
  }

  Future<void> _resolveLiveGpsDistance() async {
    final result = await RouteMapService.fetchCurrentGpsPosition(
      requestPermission: false,
    );
    if (!mounted) return;
    if (result.position != null) {
      setState(() => _liveUserLocation = result.position);
    }
  }

  bool _isFavorite(BuildContext context) {
    final appState = HelaAppStateProvider.maybeOf(context);
    if (appState != null) {
      return appState.isHavenSaved(widget.place.title);
    }
    return _localFavorite;
  }

  void _toggleFavorite() {
    final appState = HelaAppStateProvider.maybeOf(context);
    final place = widget.place;
    if (appState != null) {
      appState.toggleSaveHaven(
        HavenItem(
          id: place.id,
          title: place.title,
          location: place.locationLine,
          category: place.categoryLabel,
          price: place.priceEstimate,
          rating: double.tryParse(place.rating) ?? 4.9,
          badgeText: place.categoryBadge,
          imageUrl: place.photos.first,
        ),
      );
      setState(() {});
    } else {
      setState(() => _localFavorite = !_localFavorite);
    }

    final savedNow = _isFavorite(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          savedNow
              ? '${place.title} added to your Saved Places'
              : '${place.title} removed from Saved Places',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openPhotoGallery() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (ctx) {
        int active = _currentPhotoIndex;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Stack(
              children: [
                PageView.builder(
                  controller: PageController(initialPage: _currentPhotoIndex),
                  itemCount: widget.place.photos.length,
                  onPageChanged: (idx) => setDialogState(() => active = idx),
                  itemBuilder: (_, idx) => InteractiveViewer(
                    child: Center(
                      child: Image.network(
                        widget.place.photos[idx],
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.landscape_rounded,
                          color: Colors.white54,
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 36,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${active + 1} / ${widget.place.photos.length} • ${widget.place.title}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openLoreGuideSheet() {
    setState(() => _isLorePlaying = true);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final colors = HelaColors.of(ctx);
        bool playing = true;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                top: false,
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
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              setSheetState(() => playing = !playing);
                              if (mounted) {
                                setState(() => _isLorePlaying = playing);
                              }
                            },
                            icon: Icon(
                              playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.place.loreGuideLabel,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: colors.onSurface,
                                ),
                              ),
                              Text(
                                playing
                                    ? 'Narrating ${widget.place.title} cultural story...'
                                    : 'Audio paused',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    LinearProgressIndicator(
                      value: playing ? 0.36 : 0.36,
                      backgroundColor: colors.surfaceContainer,
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.place.loreScript,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      if (mounted) setState(() => _isLorePlaying = false);
    });
  }

  List<RouteMapStop> _buildStopsToPlace() {
    final originCoords = _liveUserLocation ??
        RouteMapService.resolveKnownCoordinates(widget.place.routeOrigin) ??
        const LatLng(7.8567, 80.6492);
    final originName = _liveUserLocation != null
        ? 'Your Live Location'
        : widget.place.routeOrigin;

    return [
      RouteMapStop(
        index: 0,
        badgeText: 'S',
        title: originName,
        subtitle: _liveUserLocation != null
            ? 'Live GPS Starting Point'
            : 'Nearest Hub',
        coordinates: originCoords,
        isOrigin: true,
      ),
      RouteMapStop(
        index: 1,
        badgeText: '1',
        title: widget.place.title,
        subtitle: widget.place.locationLine,
        coordinates: widget.place.coordinates,
      ),
    ];
  }

  void _openLiveRouteMap() {
    final stops = _buildStopsToPlace();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveRouteMapPage(
          dayNumber: 1,
          dateText: widget.place.locationLine,
          routeTitle: '${stops.first.title} → ${widget.place.title}',
          origin: stops.first.title,
          destination: widget.place.title,
          stops: stops,
          initialUserLocation: _liveUserLocation,
        ),
      ),
    );
  }

  Future<void> _openExternalDirections() async {
    final lat = widget.place.latitude;
    final lon = widget.place.longitude;
    final googleUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon',
    );
    try {
      if (await canLaunchUrl(googleUri)) {
        await launchUrl(googleUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}
    if (mounted) _openLiveRouteMap();
  }

  void _openDirectionsOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final colors = HelaColors.of(ctx);
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
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
                const SizedBox(height: 14),
                Text(
                  'Directions to ${widget.place.title}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.place.formattedCoordinates,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: colors.primary.withValues(alpha: 0.12),
                    child: Icon(Icons.my_location_rounded, color: colors.primary),
                  ),
                  title: const Text(
                    'Open HELA Live GPS Route Map',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Interactive map with your live GPS position'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openLiveRouteMap();
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: colors.secondaryContainer,
                    child: Icon(Icons.map_rounded, color: colors.primary),
                  ),
                  title: const Text(
                    'Open in Google Maps',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Launch external turn-by-turn navigation'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openExternalDirections();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addToMyTrip() {
    final appState = HelaAppStateProvider.maybeOf(context);
    final place = widget.place;
    if (appState != null && !appState.isHavenSaved(place.title)) {
      appState.toggleSaveHaven(
        HavenItem(
          id: place.id,
          title: place.title,
          location: place.locationLine,
          category: place.categoryLabel,
          price: place.priceEstimate,
          rating: double.tryParse(place.rating) ?? 4.9,
          badgeText: place.categoryBadge,
          imageUrl: place.photos.first,
        ),
      );
      setState(() {});
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${place.title} saved for your trip!'),
        action: SnackBarAction(
          label: 'Plan Trip',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TripPlannerPage(
                  initialExtraNote: 'Must include ${place.title}',
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openAskHela([String? topicPrompt]) {
    final prompt = topicPrompt ??
        'Tell me insider tips, best time to visit, and guide advice for ${widget.place.title} in Sri Lanka.';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AskHelaPage(initialPrompt: prompt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);
    final place = widget.place;
    final isFav = _isFavorite(context);

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Floating Navigation Row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleActionButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onTap: () => Navigator.pop(context),
                    colors: colors,
                  ),
                  Row(
                    children: [
                      _CircleActionButton(
                        icon: isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        iconColor: isFav
                            ? const Color(0xFFE11D48)
                            : colors.onSurface,
                        tooltip: isFav ? 'Saved' : 'Save place',
                        onTap: _toggleFavorite,
                        colors: colors,
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfilePage(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(999),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: colors.primary,
                          child: const Icon(
                            Icons.person_outline_rounded,
                            size: 19,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Hero Photo Card
                        _buildHeroImageCard(colors, place),
                        const SizedBox(height: 16),

                        // 2. Title + Sinhala Script + Rating
                        _buildTitleAndRating(colors, place),
                        const SizedBox(height: 10),

                        // 3. Location Line + Prestige Pill
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                place.locationLine,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: colors.secondaryContainer.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_outlined,
                                size: 15,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  place.prestigeBadge,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 4. Editorial Description
                        Text(
                          place.description,
                          style: TextStyle(
                            fontSize: 14.5,
                            color: colors.onSurface,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 5. 2x2 Quick Specs Grid
                        _buildQuickSpecsGrid(colors, place),
                        const SizedBox(height: 20),

                        // 6. Segmented Tabs (Highlights / History / Visit Tips)
                        _buildSegmentedTabs(colors),
                        const SizedBox(height: 16),
                        _buildActiveTabContent(colors, place),
                        const SizedBox(height: 22),

                        // 7. Location & Geography Map + Route Bar
                        _buildLocationAndGeography(colors, place),
                        const SizedBox(height: 24),

                        // 8. Nearby Discoveries
                        _buildNearbyDiscoveries(colors, place),
                        const SizedBox(height: 20),

                        // 9. Ask HELA Travel Intelligence Card
                        _buildAskHelaCard(colors, place),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildStickyBottomBar(colors),
    );
  }

  Widget _buildHeroImageCard(HelaColorPalette colors, PlaceDetailData place) {
    return Container(
      height: 270,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: _openPhotoGallery,
              child: PageView.builder(
                controller: _photoController,
                itemCount: place.photos.length,
                onPageChanged: (index) {
                  setState(() => _currentPhotoIndex = index);
                },
                itemBuilder: (_, index) {
                  return Image.network(
                    place.photos[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: colors.primary.withValues(alpha: 0.14),
                      child: Center(
                        child: Icon(
                          Icons.landscape_rounded,
                          size: 48,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Subtle bottom gradient for badge legibility
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.18),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.35),
                    ],
                  ),
                ),
              ),
            ),
            // Top-left category badge
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars_rounded, size: 13, color: colors.goldenAmber),
                    const SizedBox(width: 5),
                    Text(
                      place.categoryBadge,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Top-right era badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history_edu_rounded, size: 13, color: colors.primary),
                    const SizedBox(width: 4),
                    Text(
                      place.eraBadge,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom-left Local Lore audio guide button
            Positioned(
              bottom: 12,
              left: 12,
              child: GestureDetector(
                onTap: _openLoreGuideSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _isLorePlaying
                        ? colors.primary
                        : Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isLorePlaying
                            ? Icons.graphic_eq_rounded
                            : Icons.headphones_rounded,
                        size: 15,
                        color: _isLorePlaying ? Colors.white : colors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        place.loreGuideLabel,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _isLorePlaying ? Colors.white : colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom-right photo counter
            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: _openPhotoGallery,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_library_outlined,
                        size: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${_currentPhotoIndex + 1} / ${place.photos.length} PHOTOS',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndRating(HelaColorPalette colors, PlaceDetailData place) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.title,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                  letterSpacing: -0.4,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                place.subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                place.localScriptName,
                style: TextStyle(
                  fontSize: 15,
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors.tertiaryFixed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: colors.onTertiaryFixed,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    place.rating,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: colors.onTertiaryFixed,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              place.ratingCaption,
              style: TextStyle(
                fontSize: 10.5,
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickSpecsGrid(HelaColorPalette colors, PlaceDetailData place) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: place.quickSpecs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.35,
      ),
      itemBuilder: (_, index) {
        final spec = place.quickSpecs[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.architecturalBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(spec.icon, size: 18, color: colors.primary),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      spec.label,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurfaceVariant,
                        letterSpacing: 0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      spec.value,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSegmentedTabs(HelaColorPalette colors) {
    const labels = ['Highlights', 'History', 'Visit Tips'];
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveTabContent(
    HelaColorPalette colors,
    PlaceDetailData place,
  ) {
    if (_selectedTabIndex == 1) {
      return Column(
        children: place.historyEntries.map((entry) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.architecturalBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    entry.era,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.title,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  entry.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    if (_selectedTabIndex == 2) {
      return Column(
        children: place.visitTips.map((tip) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.architecturalBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(tip.icon, size: 19, color: colors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.title,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip.description,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: colors.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    // Highlights Tab
    return Column(
      children: [
        ...place.highlightCards.map(
          (card) => Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(18),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 155,
                        width: double.infinity,
                        child: Image.network(
                          card.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: colors.primary.withValues(alpha: 0.12),
                            child: Icon(
                              Icons.landscape_rounded,
                              color: colors.primary,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            card.tag,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: colors.primary,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  card.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  card.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
        ...place.featureCallouts.map(
          (callout) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.architecturalBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: callout.isAmber
                        ? colors.tertiaryFixed
                        : colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    callout.icon,
                    size: 19,
                    color: callout.isAmber
                        ? colors.onTertiaryFixed
                        : colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        callout.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        callout.description,
                        style: TextStyle(
                          fontSize: 12.8,
                          color: colors.onSurfaceVariant,
                          height: 1.42,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationAndGeography(
    HelaColorPalette colors,
    PlaceDetailData place,
  ) {
    final liveDistanceLabel = _liveUserLocation != null
        ? '${RouteMapService.formatDistance(_liveUserLocation!, place.coordinates)} from your live GPS'
        : place.routeSummaryLine;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Location & Geography',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            Text(
              place.formattedCoordinates,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: colors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 175,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: FlutterMap(
              mapController: _miniMapController,
              options: MapOptions(
                initialCenter: place.coordinates,
                initialZoom: 12.2,
                minZoom: 5.0,
                maxZoom: 17.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                buildTestSafeOsmTileLayer(),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: place.coordinates,
                      width: 145,
                      height: 68,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.fort_rounded,
                              size: 17,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.14),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              place.mapMarkerLabel,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: colors.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_liveUserLocation != null)
                      Marker(
                        point: _liveUserLocation!,
                        width: 24,
                        height: 24,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.architecturalBorder),
          ),
          child: Row(
            children: [
              Icon(Icons.alt_route_rounded, size: 19, color: colors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_liveUserLocation != null ? 'Your Location' : place.routeOrigin} → ${place.title}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      liveDistanceLabel,
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
              const SizedBox(width: 8),
              InkWell(
                onTap: _openLiveRouteMap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Route',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyDiscoveries(
    HelaColorPalette colors,
    PlaceDetailData place,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nearby Discoveries',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            Text(
              place.nearbyRegionLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 196,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: place.nearbyDiscoveries.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final nearby = place.nearbyDiscoveries[index];
              return GestureDetector(
                onTap: () {
                  final nextPlace = PlaceDetailCatalog.resolveByIdOrTitle(
                    nearby.id,
                    fallbackSubtitle: nearby.subtitle,
                    fallbackImageUrl: nearby.imageUrl,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaceDetailsPage(place: nextPlace),
                    ),
                  );
                },
                child: Container(
                  width: 196,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.architecturalBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            SizedBox(
                              height: 98,
                              width: double.infinity,
                              child: Image.network(
                                nearby.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: colors.primary.withValues(alpha: 0.12),
                                  child: Icon(
                                    Icons.landscape_rounded,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 7,
                              left: 7,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.94),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  nearby.distanceLabel,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        nearby.title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        nearby.subtitle,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            nearby.metaIcon,
                            size: 13,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              nearby.metaLabel,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: colors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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

  Widget _buildAskHelaCard(HelaColorPalette colors, PlaceDetailData place) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.tertiaryFixed,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: colors.onTertiaryFixed,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Ask HELA Travel Intelligence',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Want live crowd estimates, certified local guide booking, or the ideal morning weather window for visiting ${place.title}?',
            style: TextStyle(
              fontSize: 12.8,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HelaTopicPill(
                icon: Icons.wb_cloudy_outlined,
                label: 'Crowd Forecasts',
                onTap: () => _openAskHela(
                  'What are the best low-crowd hours and weather windows to visit ${place.title}?',
                ),
              ),
              _HelaTopicPill(
                icon: Icons.backpack_outlined,
                label: 'Gear & Dress Code',
                onTap: () => _openAskHela(
                  'What gear, footwear, and dress code should I bring for ${place.title}?',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => _openAskHela(),
              icon: Icon(
                Icons.chat_outlined,
                size: 18,
                color: colors.onTertiaryFixed,
              ),
              label: Text(
                'Ask HELA About ${place.title}',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: colors.onTertiaryFixed,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.tertiaryFixed,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(HelaColorPalette colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.98),
        border: Border(top: BorderSide(color: colors.architecturalBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _openDirectionsOptions,
                      icon: Icon(
                        Icons.near_me_outlined,
                        size: 18,
                        color: colors.primary,
                      ),
                      label: Text(
                        'Get Directions',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.secondaryContainer,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _addToMyTrip,
                      icon: const Icon(
                        Icons.playlist_add_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Add to My Trip',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String tooltip;
  final VoidCallback onTap;
  final HelaColorPalette colors;

  const _CircleActionButton({
    required this.icon,
    this.iconColor,
    required this.tooltip,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colors.cardBackground,
            shape: BoxShape.circle,
            border: Border.all(color: colors.architecturalBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 19, color: iconColor ?? colors.onSurface),
        ),
      ),
    );
  }
}

class _HelaTopicPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HelaTopicPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
