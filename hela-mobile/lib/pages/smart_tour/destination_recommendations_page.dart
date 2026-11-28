import 'package:flutter/material.dart';
import 'package:hela/theme/hela_colors.dart';
import 'package:hela/models/destination.dart';
import 'package:hela/models/tour_preferences.dart';
import 'package:hela/services/tour_api_service.dart';
import 'package:hela/pages/smart_tour/tour_plan_details_page.dart';

/// Screen displaying AI-discovered destination recommendations in Sri Lanka.
class DestinationRecommendationsPage extends StatefulWidget {
  final TourPreferences preferences;
  final List<Destination> destinations;

  const DestinationRecommendationsPage({
    super.key,
    required this.preferences,
    required this.destinations,
  });

  @override
  State<DestinationRecommendationsPage> createState() =>
      _DestinationRecommendationsPageState();
}

class _DestinationRecommendationsPageState
    extends State<DestinationRecommendationsPage> {
  late Set<String> _selectedIds;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Pre-select top destinations (up to 5)
    _selectedIds = widget.destinations.take(5).map((d) => d.sourceId).toSet();
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        if (_selectedIds.length > 1) {
          _selectedIds.remove(id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select at least one destination.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _generateItinerary() async {
    setState(() => _isGenerating = true);

    final selectedPlaces = widget.destinations
        .where((d) => _selectedIds.contains(d.sourceId))
        .toList();

    try {
      final tourPlan = await TourApiService().generateItinerary(
        preferences: widget.preferences,
        selectedDestinations: selectedPlaces,
      );

      if (!mounted) return;
      setState(() => _isGenerating = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TourPlanDetailsPage(
            plan: tourPlan,
            preferences: widget.preferences,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Generation note: $e'),
          backgroundColor: HelaColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.preferences.duration == TravelDuration.custom
        ? widget.preferences.customDays
        : widget.preferences.duration.days;

    return Scaffold(
      backgroundColor: HelaColors.surface,
      appBar: AppBar(
        backgroundColor: HelaColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: HelaColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discovered Places',
              style: TextStyle(
                color: HelaColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Text(
              'Curated for your travel style',
              style: TextStyle(
                color: HelaColors.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: HelaColors.tertiaryFixed.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 13,
                  color: Color(0xFF1A1D00),
                ),
                const SizedBox(width: 4),
                Text(
                  '$days Days Plan',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1D00),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: HelaColors.primaryContainer.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: HelaColors.primaryContainer.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.tips_and_updates_rounded,
                      color: HelaColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Select the spots you want in your itinerary. Our Gemini AI will craft the optimal route and schedule.',
                        style: TextStyle(
                          color: HelaColors.primary.withValues(alpha: 0.9),
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Destinations list
              ...widget.destinations.map((dest) {
                final isSelected = _selectedIds.contains(dest.sourceId);
                final matchPercent = (dest.relevanceScore * 100).toInt();

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: isSelected ? 2 : 0,
                  color: isSelected
                      ? HelaColors.surfaceContainerLowest
                      : HelaColors.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: isSelected
                          ? HelaColors.primary
                          : HelaColors.outlineVariant.withValues(alpha: 0.4),
                      width: isSelected ? 1.8 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _toggleSelection(dest.sourceId),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top header: Name + Match score + Checkbox
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dest.name,
                                      style: const TextStyle(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w700,
                                        color: HelaColors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: HelaColors.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            dest.region,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color:
                                                  HelaColors.onSurfaceVariant,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Match Score Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: HelaColors.tertiaryFixed,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$matchPercent% Match',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1A1D00),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Checkbox
                              Checkbox(
                                value: isSelected,
                                activeColor: HelaColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (_) =>
                                    _toggleSelection(dest.sourceId),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Description
                          Text(
                            dest.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: HelaColors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Categories & attribution
                          Row(
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: dest.categories.take(3).map((cat) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: HelaColors.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        cat,
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          color: HelaColors.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              Text(
                                dest.attribution,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: HelaColors.outline.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),

          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: HelaColors.surfaceContainerLowest.withValues(
                  alpha: 0.95,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedIds.length} of ${widget.destinations.length} selected',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: HelaColors.onSurface,
                            ),
                          ),
                          const Text(
                            'Tap to customize stops',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: HelaColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isGenerating ? null : _generateItinerary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HelaColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: _isGenerating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome_rounded, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Generate Tour',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
