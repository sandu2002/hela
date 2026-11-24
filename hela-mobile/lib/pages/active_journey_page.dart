import 'package:flutter/material.dart';
import 'package:hela/theme/hela_colors.dart';
import 'package:hela/widgets/hela_bottom_nav_bar.dart';
import 'package:hela/widgets/real_time_map.dart';

/// Active Live Journey & GPS Turn-by-Turn Tour Navigator
///
/// Launched when the traveller taps "Start My Journey" from Itinerary Details.
class ActiveJourneyPage extends StatefulWidget {
  final int dayNumber;
  final String dateText;
  final String routeTitle;
  final String origin;
  final String destination;

  const ActiveJourneyPage({
    super.key,
    this.dayNumber = 1,
    this.dateText = 'Oct 14, 2025',
    this.routeTitle = 'Colombo CMB → Kurunegala → Sigiriya',
    this.origin = 'Bandaranaike Intl Airport (CMB)',
    this.destination = 'Sigiriya Lion Rock Citadel',
  });

  @override
  State<ActiveJourneyPage> createState() => _ActiveJourneyPageState();
}

class _ActiveJourneyPageState extends State<ActiveJourneyPage> {
  int _activeStopIndex = 1; // Stop 2: Kurunegala Feast is currently in progress
  bool _isAudioPlaying = false;

  final List<Map<String, dynamic>> _dayStops = [
    {
      'number': '1',
      'title': 'Arrival & Welcome at CMB',
      'location': 'Katunayake, Western Coast',
      'status': 'Completed',
      'completed': true,
      'time': '08:30 AM',
      'note': 'Chauffeur met with Thambili drink & Dialog 5G SIM',
    },
    {
      'number': '2',
      'title': 'Traditional Rice & Curry Feast',
      'location': 'Kurunegala Heritage Rest',
      'status': 'En Route • 38 km remaining',
      'completed': false,
      'time': '12:30 PM',
      'note': 'Clay-pot lunch reserved at open-air veranda',
    },
    {
      'number': '3',
      'title': 'Ascent of Sigiriya Lion Rock',
      'location': 'Sigiriya UNESCO Fortress',
      'status': 'Upcoming • 03:30 PM',
      'completed': false,
      'time': '03:30 PM',
      'note': 'Golden-hour climb scheduled after tropical heat',
    },
    {
      'number': '4',
      'title': 'Eco Heritage Villa Check-In',
      'location': 'Sigiriya Forest Villa',
      'status': 'Upcoming • 07:30 PM',
      'completed': false,
      'time': '07:30 PM',
      'note': 'Ayurvedic herbal welcome & candlelit dinner',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);
    final isDark = colors.isDark;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: _buildAppBar(colors, isDark),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Live Turn-by-Turn GPS Banner
                  _buildLiveManeuverBanner(colors),
                  const SizedBox(height: 12),

                  // 2. Real-Time Map Simulation
                  _buildMapContainer(colors),
                  const SizedBox(height: 14),

                  // 3. Driver & Quick Assistance Toolkit
                  _buildChauffeurToolkitCard(colors),
                  const SizedBox(height: 16),

                  // 4. Active Stop In-Depth Card
                  _buildCurrentLegCard(colors),
                  const SizedBox(height: 18),

                  // 5. Day Stops Live Checklist
                  _buildStopsChecklist(colors),
                  const SizedBox(height: 18),

                  // 6. Island Safety & Emergency Banner
                  _buildSafetySupportCard(colors),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(HelaColorPalette colors, bool isDark) {
    return AppBar(
      backgroundColor: colors.surface.withValues(alpha: isDark ? 0.96 : 0.94),
      elevation: 0,
      scrolledUnderElevation: 1.0,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Center(
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.cardBackground,
                shape: BoxShape.circle,
                border: Border.all(color: colors.architecturalBorder),
              ),
              child: Icon(Icons.arrow_back_rounded, size: 20, color: colors.onSurface),
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Day ${widget.dayNumber} Live Journey',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.circle, size: 6, color: Color(0xFF10B981)),
                    SizedBox(width: 4),
                    Text(
                      'GPS LIVE',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF047857)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            widget.routeTitle,
            style: TextStyle(fontSize: 10.5, color: colors.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isAudioPlaying ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
            color: _isAudioPlaying ? colors.secondary : colors.onSurfaceVariant,
          ),
          onPressed: () {
            setState(() => _isAudioPlaying = !_isAudioPlaying);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isAudioPlaying
                      ? 'Playing Ambepussa & Kurunegala Cultural Audio Narrative 🎧'
                      : 'Audio narration paused.',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  // 1. Maneuver Next Action Banner
  Widget _buildLiveManeuverBanner(HelaColorPalette colors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.turn_right_rounded, size: 24, color: colors.onSecondaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'In 1.4 km • Turn Right onto Central Link',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  'Heading towards Kurunegala bypass (A6 Highway route)',
                  style: TextStyle(fontSize: 11, color: colors.onPrimaryContainer),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '58 km/h',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: colors.secondaryContainer),
              ),
              const Text(
                'Speed',
                style: TextStyle(fontSize: 9.5, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. RealTime Google Map
  Widget _buildMapContainer(HelaColorPalette colors) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.architecturalBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: RealTimeGoogleMap(
          pickupLocation: widget.origin,
          dropoffLocation: 'Kurunegala Village Feast (Next)',
          durationText: '38 mins remaining',
          distanceText: '32 km to next stop',
          vehicleType: 'Sedan Car',
          height: 260,
        ),
      ),
    );
  }

  // 3. Driver & Quick Toolkit Card
  Widget _buildChauffeurToolkitCard(HelaColorPalette colors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.architecturalBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colors.primary,
                child: const Icon(Icons.person_rounded, size: 22, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Chaminda Perera',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: colors.onSurface),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.verified_rounded, size: 14, color: colors.primary),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Government Certified Tourist Chauffeur • ★ 4.98 (310 trips)',
                      style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calling Chaminda Perera (+94 77 123 4567)... 📞')),
                  );
                },
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.phone_in_talk_rounded, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // 4 Action Pill Tools
          Row(
            children: [
              _buildToolkitAction(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Ask HELA',
                color: colors.primary,
                colors: colors,
                onTap: () => HelaBottomNavBar.openAskHelaSheet(context),
              ),
              const SizedBox(width: 8),
              _buildToolkitAction(
                icon: Icons.headset_mic_rounded,
                label: 'Audio Guide',
                color: colors.secondary,
                colors: colors,
                onTap: () {
                  setState(() => _isAudioPlaying = !_isAudioPlaying);
                },
              ),
              const SizedBox(width: 8),
              _buildToolkitAction(
                icon: Icons.local_gas_station_rounded,
                label: 'Rest Stop',
                color: colors.tertiary,
                colors: colors,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Closest clean rest stop: Ambepussa Rest House in 6 km.')),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildToolkitAction(
                icon: Icons.sos_rounded,
                label: 'Help / SOS',
                color: const Color(0xFFDC2626),
                colors: colors,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tourist Police 1912 & HELA Emergency hotline connected.')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolkitAction({
    required IconData icon,
    required String label,
    required Color color,
    required HelaColorPalette colors,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.architecturalBorder),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: colors.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 4. Current Leg Card
  Widget _buildCurrentLegCard(HelaColorPalette colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: colors.primary.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'CURRENT LEG ${_activeStopIndex + 1} OF 4',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: colors.onSecondaryContainer),
                ),
              ),
              Text(
                'ETA: 12:30 PM',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Traditional Rice & Curry Feast at Kurunegala',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: colors.onSurface),
          ),
          const SizedBox(height: 3),
          Text(
            'Authentic clay-pot lunch featuring coconut sambol, lake fish & jackfruit curry in an open garden pavilion.',
            style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant, height: 1.35),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _activeStopIndex = 2;
                  _dayStops[1]['completed'] = true;
                  _dayStops[1]['status'] = 'Completed ✓';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Marked Stop 2 as Arrived! Proceeding to Sigiriya Citadel. 🎉')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle_outline_rounded, size: 18),
                  SizedBox(width: 6),
                  Text('Mark as Arrived at Kurunegala', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Day Stops Checklist
  Widget _buildStopsChecklist(HelaColorPalette colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Day 1 Timeline & Stops',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: colors.onSurface),
            ),
            Text(
              '4 Curated Stops',
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._dayStops.map((stop) {
          final isCompleted = stop['completed'] as bool;
          final isCurrent = stop['number'] == '2' && !isCompleted;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCurrent ? colors.surfaceContainerLow : colors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrent ? colors.primary : colors.architecturalBorder,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF10B981)
                        : (isCurrent ? colors.primary : colors.surfaceContainer),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                        : Text(
                            stop['number'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isCurrent ? Colors.white : colors.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stop['title'] as String,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stop['status'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? const Color(0xFF047857)
                              : (isCurrent ? colors.primary : colors.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  stop['time'] as String,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.secondary),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // 6. Safety & Support Card
  Widget _buildSafetySupportCard(HelaColorPalette colors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.architecturalBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_done_rounded, size: 20, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Offline Maps & Emergency Pack Active',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: colors.onSurface),
                ),
                Text(
                  'Voice guide and route cached. Works with zero cellular signal.',
                  style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
