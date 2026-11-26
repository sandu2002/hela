import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hela/models/destination.dart';
import 'package:hela/models/tour_preferences.dart';
import 'package:hela/pages/home/home_page.dart';
import 'package:hela/pages/smart_tour/smart_tour_home_page.dart';
import 'package:hela/services/place_service.dart';
import 'package:hela/widgets/navigation/hela_bottom_nav_bar.dart';

class TravelPreferencesPage extends StatefulWidget {
  const TravelPreferencesPage({super.key});

  @override
  State<TravelPreferencesPage> createState() => _TravelPreferencesPageState();
}

class _TravelPreferencesPageState extends State<TravelPreferencesPage>
    with TickerProviderStateMixin {

  // ── Selected Preferences ──────────────────────────────────────────
  final Set<TravelInterest> _selectedInterests = {};
  BudgetLevel _selectedBudget = BudgetLevel.medium;
  TravelPace _selectedPace = TravelPace.moderate;
  TravelDuration _selectedDuration = TravelDuration.threeDays;

  // ── Map ───────────────────────────────────────────────────────────
  final MapController _mapController = MapController();
  Destination? _selectedDestination;

  // ── Animation ─────────────────────────────────────────────────────
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ── Filter destinations based on selected interests ───────────────
  List<Destination> get _filteredDestinations {
    final all = PlaceService.curatedSriLankaPlaces;
    if (_selectedInterests.isEmpty) return all;

    final interestLabels =
        _selectedInterests.map((i) => i.label.toLowerCase()).toSet();

    return all.where((d) {
      final text =
          '${d.name} ${d.description} ${d.categories.join(' ')} ${d.region}'
              .toLowerCase();
      return interestLabels.any((interest) => text.contains(interest));
    }).toList();
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  _buildHeaderBanner(),
                  const SizedBox(height: 20),
                  _buildLiveMapSection(),
                  const SizedBox(height: 22),
                  _buildInterestsSection(),
                  const SizedBox(height: 20),
                  _buildBudgetSection(),
                  const SizedBox(height: 20),
                  _buildPaceSection(),
                  const SizedBox(height: 20),
                  _buildDurationSection(),
                  const SizedBox(height: 24),
                  _buildCTAButton(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const HelaBottomNavBar(currentIndex: 2),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: HelaColors.surface.withValues(alpha: 0.94),
      elevation: 0,
      scrolledUnderElevation: 1.5,
      shadowColor: Colors.black12,
      toolbarHeight: 64,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: HelaColors.secondaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.travel_explore_rounded,
              color: HelaColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Discover Ceylon',
                style: TextStyle(
                  color: HelaColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.4,
                ),
              ),
              Text(
                'Personalise your Sri Lanka journey',
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
        if (_selectedInterests.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedInterests.clear();
                });
              },
              icon: const Icon(Icons.refresh_rounded, size: 16, color: HelaColors.secondary),
              label: const Text(
                'Reset',
                style: TextStyle(
                  color: HelaColors.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeaderBanner() {
    final count = _filteredDestinations.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [HelaColors.primaryContainer, HelaColors.primary],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: HelaColors.primary.withValues(alpha: 0.22),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: HelaColors.tertiaryFixed,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '$count SANCTUARIES ON MAP',
                      style: const TextStyle(
                        color: HelaColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your Perfect Ceylon Journey',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pick your interests below and watch the map come alive with matching destinations.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.map_rounded,
                  color: HelaColors.tertiaryFixed,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  LIVE MAP
  // ─────────────────────────────────────────────────────────────────
  Widget _buildLiveMapSection() {
    final destinations = _filteredDestinations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'Live Destination Map',
                style: TextStyle(
                  color: HelaColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: HelaColors.tertiaryFixed.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${destinations.length} spots',
                  style: const TextStyle(
                    color: HelaColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  _mapController.move(
                    const LatLng(7.8731, 80.7718),
                    6.5,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: HelaColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: HelaColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.center_focus_strong_rounded,
                          size: 14, color: HelaColors.secondary),
                      SizedBox(width: 5),
                      Text(
                        'Reset View',
                        style: TextStyle(
                          color: HelaColors.secondary,
                          fontSize: 12,
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
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 300,
              child: Stack(
                children: [
                  // ── Flutter Map ────────────────────────────────
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: const LatLng(7.8731, 80.7718),
                      initialZoom: 6.5,
                      minZoom: 5.0,
                      maxZoom: 16.0,
                      onTap: (_, tp) {
                        setState(() {
                          _selectedDestination = null;
                        });
                      },
                    ),
                    children: [
                      // OpenStreetMap tile layer
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.hela.travel',
                        maxNativeZoom: 19,
                      ),
                      // Destination markers
                      MarkerLayer(
                        markers: destinations.map((dest) {
                          final isSelected = _selectedDestination?.sourceId == dest.sourceId;
                          return Marker(
                            point: LatLng(dest.latitude, dest.longitude),
                            width: isSelected ? 42 : 34,
                            height: isSelected ? 42 : 34,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDestination = dest;
                                });
                                _mapController.move(
                                  LatLng(dest.latitude - 0.15, dest.longitude),
                                  8.0,
                                );
                                _showDestinationBottomSheet(dest);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: isSelected ? 42 : 34,
                                height: isSelected ? 42 : 34,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? HelaColors.primary
                                      : HelaColors.primaryContainer,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: isSelected ? 2.5 : 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: HelaColors.primary
                                          .withValues(alpha: isSelected ? 0.45 : 0.2),
                                      blurRadius: isSelected ? 12 : 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    _destinationIcon(dest.categories),
                                    size: isSelected ? 20 : 16,
                                    color: isSelected
                                        ? HelaColors.tertiaryFixed
                                        : HelaColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  // ── Attribution overlay ────────────────────────
                  Positioned(
                    bottom: 4,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '© OpenStreetMap contributors',
                        style: TextStyle(fontSize: 9, color: Colors.black87),
                      ),
                    ),
                  ),

                  // ── Zoom buttons ───────────────────────────────
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Column(
                      children: [
                        _buildMapButton(
                          icon: Icons.add_rounded,
                          onTap: () {
                            _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom + 1,
                            );
                          },
                        ),
                        const SizedBox(height: 6),
                        _buildMapButton(
                          icon: Icons.remove_rounded,
                          onTap: () {
                            _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom - 1,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // ── Empty state overlay ────────────────────────
                  if (destinations.isEmpty)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.45),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.location_off_rounded,
                                  size: 36, color: Colors.white70),
                              SizedBox(height: 8),
                              Text(
                                'No destinations match\nyour selected interests',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
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
          ),
        ),

        // ── Destination pill list below map ────────────────────────
        if (destinations.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: destinations.length,
              separatorBuilder: (_, i) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final dest = destinations[index];
                final isSelected =
                    _selectedDestination?.sourceId == dest.sourceId;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDestination = dest;
                    });
                    _mapController.move(
                      LatLng(dest.latitude - 0.15, dest.longitude),
                      8.5,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? HelaColors.primaryContainer
                          : HelaColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? HelaColors.primaryContainer
                            : HelaColors.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _destinationIcon(dest.categories),
                          size: 13,
                          color: isSelected
                              ? HelaColors.onPrimary
                              : HelaColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dest.name.split(' ').take(2).join(' '),
                          style: TextStyle(
                            color: isSelected
                                ? HelaColors.onPrimary
                                : HelaColors.onSurface,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
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
      ],
    );
  }

  Widget _buildMapButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(icon, size: 18, color: HelaColors.primary),
        ),
      ),
    );
  }

  IconData _destinationIcon(List<String> categories) {
    final text = categories.join(' ').toLowerCase();
    if (text.contains('wildlife') || text.contains('safari')) {
      return Icons.pets_rounded;
    } else if (text.contains('beach') || text.contains('coast') || text.contains('marine')) {
      return Icons.beach_access_rounded;
    } else if (text.contains('historic') || text.contains('heritage') ||
        text.contains('archaeology')) {
      return Icons.account_balance_rounded;
    } else if (text.contains('hik') || text.contains('trek') ||
        text.contains('highland')) {
      return Icons.hiking_rounded;
    } else if (text.contains('spiritual') || text.contains('temple')) {
      return Icons.temple_buddhist_rounded;
    } else if (text.contains('tea') || text.contains('nature')) {
      return Icons.local_florist_rounded;
    } else {
      return Icons.place_rounded;
    }
  }

  void _showDestinationBottomSheet(Destination dest) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DestinationBottomSheet(destination: dest),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  INTERESTS
  // ─────────────────────────────────────────────────────────────────
  Widget _buildInterestsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(
            Icons.interests_rounded,
            'Travel Interests',
            'Select all that resonate with you',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TravelInterest.values.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedInterests.remove(interest);
                    } else {
                      _selectedInterests.add(interest);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? HelaColors.primaryContainer
                        : HelaColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected
                          ? HelaColors.primaryContainer
                          : HelaColors.outlineVariant.withValues(alpha: 0.6),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color:
                                  HelaColors.primaryContainer.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(interest.emoji, style: const TextStyle(fontSize: 15)),
                      const SizedBox(width: 6),
                      Text(
                        interest.label,
                        style: TextStyle(
                          color: isSelected
                              ? HelaColors.onPrimary
                              : HelaColors.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  BUDGET
  // ─────────────────────────────────────────────────────────────────
  Widget _buildBudgetSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(
            Icons.account_balance_wallet_rounded,
            'Budget Level',
            'Estimated daily spend per person',
          ),
          const SizedBox(height: 12),
          Row(
            children: BudgetLevel.values.map((level) {
              final isSelected = _selectedBudget == level;
              IconData icon;
              switch (level) {
                case BudgetLevel.low:
                  icon = Icons.savings_rounded;
                  break;
                case BudgetLevel.medium:
                  icon = Icons.wallet_rounded;
                  break;
                case BudgetLevel.high:
                  icon = Icons.diamond_rounded;
                  break;
              }
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: level != BudgetLevel.values.last ? 8 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedBudget = level;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? HelaColors.primaryContainer
                            : HelaColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? HelaColors.primaryContainer
                              : HelaColors.outlineVariant.withValues(alpha: 0.5),
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: HelaColors.primaryContainer
                                      .withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 22,
                            color: isSelected
                                ? HelaColors.onPrimary
                                : HelaColors.onSurfaceVariant,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            level.label,
                            style: TextStyle(
                              color: isSelected
                                  ? HelaColors.onPrimary
                                  : HelaColors.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            level.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? HelaColors.onPrimary.withValues(alpha: 0.8)
                                  : HelaColors.onSurfaceVariant,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  TRAVEL PACE
  // ─────────────────────────────────────────────────────────────────
  Widget _buildPaceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(
            Icons.speed_rounded,
            'Travel Pace',
            'How fast do you like to explore?',
          ),
          const SizedBox(height: 12),
          Row(
            children: TravelPace.values.map((pace) {
              final isSelected = _selectedPace == pace;
              IconData icon;
              switch (pace) {
                case TravelPace.relaxed:
                  icon = Icons.self_improvement_rounded;
                  break;
                case TravelPace.moderate:
                  icon = Icons.directions_walk_rounded;
                  break;
                case TravelPace.active:
                  icon = Icons.directions_run_rounded;
                  break;
              }
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: pace != TravelPace.values.last ? 8 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPace = pace;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? HelaColors.secondaryContainer
                            : HelaColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? HelaColors.secondary.withValues(alpha: 0.5)
                              : HelaColors.outlineVariant.withValues(alpha: 0.5),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 22,
                            color: isSelected
                                ? HelaColors.secondary
                                : HelaColors.onSurfaceVariant,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            pace.label,
                            style: TextStyle(
                              color: isSelected
                                  ? HelaColors.secondary
                                  : HelaColors.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            pace.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? HelaColors.secondary.withValues(alpha: 0.8)
                                  : HelaColors.onSurfaceVariant,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  DURATION
  // ─────────────────────────────────────────────────────────────────
  Widget _buildDurationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(
            Icons.calendar_today_rounded,
            'Trip Duration',
            'How long is your Ceylon adventure?',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TravelDuration.values
                .where((d) => d != TravelDuration.custom)
                .map((duration) {
              final isSelected = _selectedDuration == duration;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDuration = duration;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? HelaColors.tertiaryFixed
                        : HelaColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected
                          ? HelaColors.tertiaryFixed
                          : HelaColors.outlineVariant.withValues(alpha: 0.6),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: HelaColors.tertiaryFixed.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        duration.label,
                        style: TextStyle(
                          color: isSelected
                              ? HelaColors.primary
                              : HelaColors.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      if (duration.days > 1)
                        Text(
                          '${duration.days} destinations',
                          style: TextStyle(
                            color: isSelected
                                ? HelaColors.primary.withValues(alpha: 0.7)
                                : HelaColors.onSurfaceVariant,
                            fontSize: 10.5,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  CTA BUTTON
  // ─────────────────────────────────────────────────────────────────
  Widget _buildCTAButton() {
    final hasPreferences = _selectedInterests.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SmartTourHomePage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: HelaColors.primary,
                foregroundColor: HelaColors.onPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    hasPreferences
                        ? 'Build My Personalised Itinerary'
                        : 'Explore AI Itineraries',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!hasPreferences) ...[
            const SizedBox(height: 10),
            const Text(
              'Select at least one interest to personalise your itinerary',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: HelaColors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: HelaColors.tertiaryFixed.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: HelaColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: HelaColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.5,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: HelaColors.onSurfaceVariant,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Destination Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _DestinationBottomSheet extends StatelessWidget {
  final Destination destination;

  const _DestinationBottomSheet({required this.destination});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: HelaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: HelaColors.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Image header
          if (destination.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        destination.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, e, st) => Container(
                          color: HelaColors.surfaceContainerHigh,
                          child: const Center(
                            child: Icon(Icons.landscape_rounded,
                                color: HelaColors.primary, size: 36),
                          ),
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
                    Positioned(
                      bottom: 12,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: HelaColors.tertiaryFixed,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              destination.categories.isNotEmpty
                                  ? destination.categories.first
                                      .toUpperCase()
                                  : 'ATTRACTION',
                              style: const TextStyle(
                                color: HelaColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            destination.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              shadows: [
                                Shadow(
                                    blurRadius: 8,
                                    color: Colors.black54,
                                    offset: Offset(0, 2))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (destination.imageUrl.isEmpty)
                  Text(
                    destination.name,
                    style: const TextStyle(
                      color: HelaColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: -0.3,
                    ),
                  ),

                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 14, color: HelaColors.secondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        destination.region,
                        style: const TextStyle(
                          color: HelaColors.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.star_rounded,
                        size: 14, color: Color(0xFFD4A017)),
                    const SizedBox(width: 3),
                    Text(
                      destination.relevanceScore.toStringAsFixed(2),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Description
                if (destination.description.isNotEmpty) ...[
                  Text(
                    destination.description,
                    style: const TextStyle(
                      color: HelaColors.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.45,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                ],

                // Category chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: destination.categories.map((cat) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: HelaColors.tertiaryFixed.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        cat,
                        style: const TextStyle(
                          color: HelaColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // CTA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const SmartTourHomePage()),
                      );
                    },
                    icon: const Icon(Icons.explore_rounded, size: 18),
                    label: const Text(
                      'Plan a Tour Here',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HelaColors.primary,
                      foregroundColor: HelaColors.onPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),

                // Attribution
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    destination.attribution,
                    style: const TextStyle(
                      color: HelaColors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
