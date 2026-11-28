import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hela/theme/hela_colors.dart';
import 'package:hela/models/tour_preferences.dart';
import 'package:hela/state/tour_planner_state.dart';
import 'package:hela/pages/smart_tour/discovery_loading_page.dart';
import 'package:hela/services/sri_lanka_locations_service.dart';

/// Travel Preferences Page — multi-section form for trip planning.
///
/// Collects: duration, starting location, interests, budget,
/// travelers, pace, accommodation, and additional notes.
class TravelPreferencesPage extends StatefulWidget {
  const TravelPreferencesPage({super.key});

  @override
  State<TravelPreferencesPage> createState() => _TravelPreferencesPageState();
}

class _TravelPreferencesPageState extends State<TravelPreferencesPage> {
  // Form state
  TravelDuration _selectedDuration = TravelDuration.threeDays;
  int _customDays = 3;
  StartingLocationType _startLocationType = StartingLocationType.airport;
  String _startLocationName = 'Bandaranaike International Airport';
  final Set<TravelInterest> _selectedInterests = {};
  BudgetLevel _budgetLevel = BudgetLevel.medium;
  final TextEditingController _budgetController = TextEditingController();
  int _numberOfTravelers = 2;
  TravelPace _selectedPace = TravelPace.moderate;
  AccommodationType _selectedAccommodation = AccommodationType.noPreference;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _locationFocusNode = FocusNode();
  bool _isSearchingLocation = false;
  Timer? _locationDebounceTimer;
  List<SriLankaLocationResult> _liveResults = [];
  bool _isLoadingLiveResults = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _locationController.text = _startLocationName;
    _locationFocusNode.addListener(() {
      if (!_locationFocusNode.hasFocus) {
        setState(() {
          _isSearchingLocation = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _locationDebounceTimer?.cancel();
    _locationFocusNode.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    _locationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HelaColors.background,
      appBar: AppBar(
        backgroundColor: HelaColors.surface.withValues(alpha: 0.92),
        elevation: 0,
        scrolledUnderElevation: 1.5,
        shadowColor: Colors.black12,
        toolbarHeight: 60,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: HelaColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Travel Preferences',
              style: TextStyle(
                color: HelaColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Tell us about your dream trip',
              style: TextStyle(
                color: HelaColors.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSectionTitle('Trip Duration', Icons.schedule_rounded),
                  const SizedBox(height: 12),
                  _buildDurationSelector(),
                  const SizedBox(height: 28),
                  _buildSectionTitle(
                    'Starting Location',
                    Icons.location_on_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildStartingLocationSection(),
                  const SizedBox(height: 28),
                  _buildSectionTitle(
                    'Travel Interests',
                    Icons.interests_rounded,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Select all that excite you',
                    style: TextStyle(
                      color: HelaColors.onSurfaceVariant,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInterestsGrid(),
                  const SizedBox(height: 28),
                  _buildSectionTitle(
                    'Budget',
                    Icons.account_balance_wallet_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildBudgetSection(),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Travelers & Pace', Icons.group_rounded),
                  const SizedBox(height: 12),
                  _buildTravelersPaceSection(),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Accommodation', Icons.hotel_rounded),
                  const SizedBox(height: 12),
                  _buildAccommodationSection(),
                  const SizedBox(height: 28),
                  _buildSectionTitle(
                    'Additional Notes',
                    Icons.note_add_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildNotesSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomSheet: _buildBottomAction(),
    );
  }

  // ── Section Title ────────────────────────────────────────────
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: HelaColors.primaryContainer),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: HelaColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  // ── Duration Selector ────────────────────────────────────────
  Widget _buildDurationSelector() {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TravelDuration.values.map((d) {
            final isSelected = _selectedDuration == d;
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _selectedDuration = d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? HelaColors.tertiaryFixed
                      : HelaColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? HelaColors.tertiaryFixedDim
                        : HelaColors.outlineVariant.withValues(alpha: 0.5),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: HelaColors.tertiaryFixed.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  d.label,
                  style: TextStyle(
                    color: isSelected
                        ? HelaColors.onTertiaryFixed
                        : HelaColors.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13.5,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedDuration == TravelDuration.custom) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                'Number of days:',
                style: TextStyle(
                  color: HelaColors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 12),
              _buildCounterButton(
                icon: Icons.remove_rounded,
                onPressed: _customDays > 1
                    ? () => setState(() => _customDays--)
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_customDays',
                  style: const TextStyle(
                    color: HelaColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              _buildCounterButton(
                icon: Icons.add_rounded,
                onPressed: _customDays < 30
                    ? () => setState(() => _customDays++)
                    : null,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: onPressed != null
          ? HelaColors.primaryContainer
          : HelaColors.surfaceContainerHigh,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 18,
            color: onPressed != null
                ? HelaColors.onPrimary
                : HelaColors.outline,
          ),
        ),
      ),
    );
  }

  void _selectLocation(String name, StartingLocationType type) {
    _locationDebounceTimer?.cancel();
    setState(() {
      _startLocationName = name;
      _startLocationType = type;
      _locationController.text = name;
      _isSearchingLocation = false;
      _liveResults = [];
      _isLoadingLiveResults = false;
    });
    _locationFocusNode.unfocus();
  }

  void _onLocationQueryChanged(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _locationDebounceTimer?.cancel();
      setState(() {
        _isSearchingLocation = false;
        _startLocationName = '';
        _liveResults = [];
        _isLoadingLiveResults = false;
      });
      return;
    }

    final detected = SriLankaLocationsService.detectType(trimmed);

    setState(() {
      _startLocationName = trimmed;
      _startLocationType = detected;
      _isSearchingLocation = true;
    });

    // Debounce live OpenStreetMap Nominatim search to discover any sub-location, village, or landmark
    _locationDebounceTimer?.cancel();
    if (trimmed.length >= 2) {
      _locationDebounceTimer = Timer(
        const Duration(milliseconds: 320),
        () async {
          if (!mounted || _locationController.text.trim() != trimmed) return;
          setState(() => _isLoadingLiveResults = true);
          final live = await SriLankaLocationsService.searchLive(trimmed);
          if (!mounted || _locationController.text.trim() != trimmed) return;
          setState(() {
            _liveResults = live;
            _isLoadingLiveResults = false;
          });
        },
      );
    } else {
      _liveResults = [];
      _isLoadingLiveResults = false;
    }
  }

  // ── Starting Location ────────────────────────────────────────
  Widget _buildStartingLocationSection() {
    final query = _locationController.text.trim();
    final localMatches = SriLankaLocationsService.searchLocal(query);

    // Merge local matches with live OpenStreetMap Nominatim results without duplicate names
    final combinedResults = <SriLankaLocationResult>[...localMatches];
    for (final live in _liveResults) {
      final exists = combinedResults.any(
        (item) => item.name.toLowerCase() == live.name.toLowerCase(),
      );
      if (!exists) {
        combinedResults.add(live);
      }
    }

    // Check if currently selected location matches one of the popular options
    final isPopularSelected = SriLankaLocationsService.popularStartingPoints
        .any(
          (loc) => loc.name.toLowerCase() == _startLocationName.toLowerCase(),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search & Input Bar
        Container(
          decoration: BoxDecoration(
            color: HelaColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _locationFocusNode.hasFocus
                  ? HelaColors.primary
                  : HelaColors.outlineVariant.withValues(alpha: 0.6),
              width: _locationFocusNode.hasFocus ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _locationController,
            focusNode: _locationFocusNode,
            onChanged: _onLocationQueryChanged,
            onTap: () {
              if (_locationController.text.isNotEmpty &&
                  !_isSearchingLocation) {
                setState(() => _isSearchingLocation = true);
              }
            },
            style: const TextStyle(
              color: HelaColors.primary,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Search city, town, village, or hotel...',
              hintStyle: TextStyle(
                color: HelaColors.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 13.5,
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: HelaColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _startLocationType == StartingLocationType.airport
                        ? Icons.flight_takeoff_rounded
                        : (_startLocationType == StartingLocationType.city
                              ? Icons.location_city_rounded
                              : Icons.place_rounded),
                    color: HelaColors.primary,
                    size: 18,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 46,
                minHeight: 46,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoadingLiveResults)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: HelaColors.primary,
                        ),
                      ),
                    ),
                  if (_locationController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.cancel_rounded,
                        color: HelaColors.outline,
                        size: 20,
                      ),
                      onPressed: () {
                        _locationController.clear();
                        _onLocationQueryChanged('');
                      },
                    ),
                ],
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        ),

        // Live Suggestions Dropdown
        if (_isSearchingLocation && query.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: HelaColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: HelaColors.outlineVariant.withValues(alpha: 0.7),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  ...combinedResults.map(
                    (item) => InkWell(
                      onTap: () => _selectLocation(item.name, item.type),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: const BoxDecoration(
                                color: HelaColors.surfaceContainerHigh,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item.icon,
                                size: 16,
                                color: HelaColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      color: HelaColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  Text(
                                    item.subtitle,
                                    style: const TextStyle(
                                      color: HelaColors.onSurfaceVariant,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: HelaColors.outline,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Custom input fallback option
                  InkWell(
                    onTap: () => _selectLocation(query, _startLocationType),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: HelaColors.tertiaryFixed.withValues(
                                alpha: 0.3,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_location_alt_rounded,
                              size: 16,
                              color: HelaColors.onTertiaryFixed,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Use "$query" as starting point',
                              style: const TextStyle(
                                color: HelaColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // Selected Custom Location Tag
        if (!isPopularSelected &&
            _startLocationName.trim().isNotEmpty &&
            !_isSearchingLocation) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: HelaColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: HelaColors.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 15,
                  color: HelaColors.secondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Starting from: $_startLocationName',
                  style: const TextStyle(
                    color: HelaColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 14),
        const Text(
          'Popular starting points',
          style: TextStyle(
            color: HelaColors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // Popular starting points in a neat wrap
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SriLankaLocationsService.popularStartingPoints.map((loc) {
            final isSelected =
                _startLocationName.toLowerCase() == loc.name.toLowerCase() ||
                _startLocationName.toLowerCase() ==
                    (loc.shortLabel ?? loc.name).toLowerCase();
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _selectLocation(loc.name, loc.type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? HelaColors.tertiaryFixed
                      : HelaColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? HelaColors.tertiaryFixedDim
                        : HelaColors.outlineVariant.withValues(alpha: 0.5),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: HelaColors.tertiaryFixed.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      loc.shortLabel ?? loc.name,
                      style: TextStyle(
                        color: isSelected
                            ? HelaColors.onTertiaryFixed
                            : HelaColors.onSurfaceVariant,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 15,
                        color: HelaColors.onTertiaryFixed,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Interests Grid ───────────────────────────────────────────
  Widget _buildInterestsGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TravelInterest.values.map((interest) {
        final isSelected = _selectedInterests.contains(interest);
        return InkWell(
          borderRadius: BorderRadius.circular(12),
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
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? HelaColors.tertiaryFixed
                  : HelaColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? HelaColors.tertiaryFixedDim
                    : HelaColors.outlineVariant.withValues(alpha: 0.5),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: HelaColors.tertiaryFixed.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(interest.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  interest.label,
                  style: TextStyle(
                    color: isSelected
                        ? HelaColors.onTertiaryFixed
                        : HelaColors.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: HelaColors.primary,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Budget Section ───────────────────────────────────────────
  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Budget level chips
        Row(
          children: BudgetLevel.values.map((level) {
            final isSelected = _budgetLevel == level;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: level != BudgetLevel.high ? 8 : 0,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _budgetLevel = level),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? HelaColors.tertiaryFixed
                          : HelaColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? HelaColors.tertiaryFixedDim
                            : HelaColors.outlineVariant.withValues(alpha: 0.5),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          level.label,
                          style: TextStyle(
                            color: isSelected
                                ? HelaColors.onTertiaryFixed
                                : HelaColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          level.description,
                          style: TextStyle(
                            color: isSelected
                                ? HelaColors.onTertiaryFixed.withValues(
                                    alpha: 0.7,
                                  )
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
        const SizedBox(height: 14),
        // Optional specific budget input
        Container(
          decoration: BoxDecoration(
            color: HelaColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: HelaColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: HelaColors.primary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Total budget in USD (optional)',
              hintStyle: TextStyle(
                color: HelaColors.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.attach_money_rounded,
                color: HelaColors.primaryContainer,
                size: 20,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Budget estimate covers transportation, accommodation, activities, and food.',
          style: TextStyle(
            color: HelaColors.onSurfaceVariant,
            fontSize: 11.5,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  // ── Travelers & Pace ─────────────────────────────────────────
  Widget _buildTravelersPaceSection() {
    return Column(
      children: [
        // Number of travelers
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: HelaColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: HelaColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.people_rounded,
                color: HelaColors.primaryContainer,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Number of Travelers',
                  style: TextStyle(
                    color: HelaColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              _buildCounterButton(
                icon: Icons.remove_rounded,
                onPressed: _numberOfTravelers > 1
                    ? () => setState(() => _numberOfTravelers--)
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_numberOfTravelers',
                  style: const TextStyle(
                    color: HelaColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              _buildCounterButton(
                icon: Icons.add_rounded,
                onPressed: _numberOfTravelers < 20
                    ? () => setState(() => _numberOfTravelers++)
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Travel pace
        ...TravelPace.values.map((pace) {
          final isSelected = _selectedPace == pace;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _selectedPace = pace),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? HelaColors.tertiaryFixed.withValues(alpha: 0.3)
                      : HelaColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? HelaColors.tertiaryFixedDim
                        : HelaColors.outlineVariant.withValues(alpha: 0.5),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? HelaColors.primary
                              : HelaColors.outline,
                          width: 2,
                        ),
                        color: isSelected
                            ? HelaColors.primary
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pace.label,
                            style: TextStyle(
                              color: HelaColors.primary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            pace.description,
                            style: const TextStyle(
                              color: HelaColors.onSurfaceVariant,
                              fontSize: 12,
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
        }),
      ],
    );
  }

  // ── Accommodation ────────────────────────────────────────────
  Widget _buildAccommodationSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AccommodationType.values.map((type) {
        final isSelected = _selectedAccommodation == type;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _selectedAccommodation = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? HelaColors.tertiaryFixed
                  : HelaColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? HelaColors.tertiaryFixedDim
                    : HelaColors.outlineVariant.withValues(alpha: 0.5),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              type.label,
              style: TextStyle(
                color: isSelected
                    ? HelaColors.onTertiaryFixed
                    : HelaColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Notes Section ────────────────────────────────────────────
  Widget _buildNotesSection() {
    return Container(
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: HelaColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 4,
        style: const TextStyle(color: HelaColors.primary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Accessibility needs, special requests, must-see places...',
          hintStyle: TextStyle(
            color: HelaColors.onSurfaceVariant.withValues(alpha: 0.6),
            fontSize: 14,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  // ── Bottom Action Button ─────────────────────────────────────
  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selection summary
            if (_selectedInterests.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: HelaColors.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_selectedInterests.length} interest${_selectedInterests.length != 1 ? 's' : ''} · ${_selectedDuration == TravelDuration.custom ? _customDays : _selectedDuration.days} day${(_selectedDuration == TravelDuration.custom ? _customDays : _selectedDuration.days) != 1 ? 's' : ''} · $_numberOfTravelers traveler${_numberOfTravelers != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: HelaColors.onSurfaceVariant,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _selectedInterests.isNotEmpty ? _handleSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HelaColors.tertiaryFixed,
                  foregroundColor: HelaColors.onTertiaryFixed,
                  disabledBackgroundColor: HelaColors.surfaceContainerHigh,
                  disabledForegroundColor: HelaColors.outline,
                  elevation: _selectedInterests.isNotEmpty ? 4 : 0,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Discover My Tour',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: -0.2,
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
  }

  void _handleSubmit() {
    final prefs = TourPreferences(
      duration: _selectedDuration,
      customDays: _customDays,
      startingLocationType: _startLocationType,
      startingLocationName: _startLocationName,
      interests: Set.of(_selectedInterests),
      budgetLevel: _budgetLevel,
      budgetAmount: double.tryParse(_budgetController.text),
      numberOfTravelers: _numberOfTravelers,
      pace: _selectedPace,
      accommodationType: _selectedAccommodation,
      additionalNotes: _notesController.text,
    );

    final errors = prefs.validate();
    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errors.first),
          backgroundColor: HelaColors.error,
        ),
      );
      return;
    }

    // Update state and navigate to discovery loading screen
    final state = TourPlannerStateProvider.of(context);
    state.updatePreferences(prefs);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiscoveryLoadingPage(preferences: prefs),
      ),
    );
  }
}
