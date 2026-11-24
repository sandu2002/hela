import 'package:flutter/material.dart';
import 'package:hela/pages/home_page.dart';
import 'package:hela/widgets/real_time_map.dart';

/// Model representing a Ceylon vehicle option
class VehicleOption {
  final String id;
  final String title;
  final String subtitle;
  final String capacity;
  final int fareLkr;
  final double fareUsd;
  final IconData icon;

  const VehicleOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.capacity,
    required this.fareLkr,
    required this.fareUsd,
    required this.icon,
  });
}

class FairRidePage extends StatefulWidget {
  const FairRidePage({super.key});

  @override
  State<FairRidePage> createState() => _FairRidePageState();
}

class _FairRidePageState extends State<FairRidePage> {
  String _selectedVehicleId = 'tuktuk';

  final List<VehicleOption> _vehicles = const [
    VehicleOption(
      id: 'tuktuk',
      title: 'Tuk-Tuk',
      subtitle: 'Official Meter Rate · Agile',
      capacity: '1-3 Seats',
      fareLkr: 1450,
      fareUsd: 4.80,
      icon: Icons.electric_rickshaw_rounded,
    ),
    VehicleOption(
      id: 'nanocar',
      title: 'Nano Car',
      subtitle: 'Budget AC · Tight trails',
      capacity: '1-3 Seats',
      fareLkr: 2100,
      fareUsd: 6.90,
      icon: Icons.directions_car_filled_rounded,
    ),
    VehicleOption(
      id: 'sedan',
      title: 'Sedan Car',
      subtitle: 'Standard AC · Luggage boot',
      capacity: '1-4 Seats',
      fareLkr: 2800,
      fareUsd: 9.20,
      icon: Icons.directions_car_rounded,
    ),
    VehicleOption(
      id: 'van',
      title: 'Safari Van',
      subtitle: 'Spacious group & surfboard rack',
      capacity: '1-7 Seats',
      fareLkr: 4200,
      fareUsd: 13.80,
      icon: Icons.airport_shuttle_rounded,
    ),
  ];


  VehicleOption get _currentVehicle =>
      _vehicles.firstWhere((v) => v.id == _selectedVehicleId, orElse: () => _vehicles.first);

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildTopAppBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              // Upper Half: Interactive Map View
              // Upper Half: Real-Time Interactive Google Map
              RealTimeGoogleMap(
                pickupLocation: '98 Acres Resort & Spa, Ella',
                dropoffLocation: 'Ravana Falls & Rock Sanctuary',
                durationText: '18 mins',
                distanceText: '8.4 km via B113',
                vehicleType: _currentVehicle.title,
                height: 315,
                onSwapLocations: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Swapped pickup and destination')),
                  );
                },
                onRecenter: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Map recentered to route')),
                  );
                },
              ),

              // Lower Half: Booking Sheet
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: HelaColors.surfaceContainerLowest,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1F2E24).withValues(alpha: 0.12),
                        blurRadius: 28,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag Handle Pill
                        Center(
                          child: Container(
                            width: 38,
                            height: 4.5,
                            decoration: BoxDecoration(
                              color: HelaColors.outlineVariant.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Section Title Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'FAIR FARE MOBILITY',
                                  style: TextStyle(
                                    color: HelaColors.secondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Select Ceylon Vehicle',
                                  style: TextStyle(
                                    color: HelaColors.primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: HelaColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.eco_rounded, size: 14, color: HelaColors.secondary),
                                  SizedBox(width: 4),
                                  Text(
                                    'Highland Verified',
                                    style: TextStyle(
                                      color: HelaColors.secondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Vehicle Cards Carousel
                        SizedBox(
                          height: 146,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _vehicles.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final vehicle = _vehicles[index];
                              final isSelected = vehicle.id == _selectedVehicleId;

                              return InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {
                                  setState(() {
                                    _selectedVehicleId = vehicle.id;
                                  });
                                },
                              child: Container(
                                width: 160,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFFAFDF9) : HelaColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected ? HelaColors.secondary : HelaColors.outlineVariant.withValues(alpha: 0.35),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: HelaColors.secondary.withValues(alpha: 0.12),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Stack(
                                  children: [
                                    if (isSelected)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: const BoxDecoration(
                                            color: HelaColors.primaryContainer,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check_rounded,
                                            size: 13,
                                            color: HelaColors.tertiaryFixed,
                                          ),
                                        ),
                                      ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? HelaColors.secondaryContainer.withValues(alpha: 0.5)
                                                    : HelaColors.surfaceContainerHigh,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                vehicle.icon,
                                                size: 22,
                                                color: isSelected ? HelaColors.primaryContainer : HelaColors.onSurfaceVariant,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? HelaColors.secondary.withValues(alpha: 0.1)
                                                    : HelaColors.surfaceVariant,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                vehicle.capacity,
                                                style: TextStyle(
                                                  color: isSelected ? HelaColors.primaryContainer : HelaColors.onSurfaceVariant,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              vehicle.title,
                                              style: TextStyle(
                                                color: isSelected ? HelaColors.primary : HelaColors.onSurface,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              vehicle.subtitle,
                                              style: const TextStyle(
                                                color: HelaColors.onSurfaceVariant,
                                                fontSize: 11,
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
                                                color: isSelected
                                                    ? HelaColors.secondary.withValues(alpha: 0.2)
                                                    : HelaColors.outlineVariant.withValues(alpha: 0.2),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'LKR ${vehicle.fareLkr}',
                                                style: TextStyle(
                                                  color: isSelected ? HelaColors.primary : HelaColors.onSurface,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              Text(
                                                '~\$${vehicle.fareUsd.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  color: HelaColors.onSurfaceVariant,
                                                  fontSize: 10.5,
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
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Guaranteed Upfront Fair Fare Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: HelaColors.primaryContainer,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: HelaColors.primaryContainer.withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.verified_rounded,
                                      size: 16,
                                      color: HelaColors.tertiaryFixed,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Guaranteed Ceylon Fair Fare',
                                      style: TextStyle(
                                        color: HelaColors.tertiaryFixed,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Regulated Rate',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'LKR ${_currentVehicle.fareLkr} ',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '(\$${_currentVehicle.fareUsd.toStringAsFixed(2)} USD)',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: const [
                                Icon(
                                  Icons.lock_clock_rounded,
                                  size: 13,
                                  color: HelaColors.tertiaryFixed,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Fixed upfront price · Zero tourist surge surcharge',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.15),
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.volunteer_activism_rounded,
                                        size: 14,
                                        color: HelaColors.tertiaryFixed,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '85% goes directly to driver',
                                        style: TextStyle(
                                          color: HelaColors.tertiaryFixed,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Fair Wage Model',
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Payment Method Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  color: HelaColors.surfaceContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.credit_card_rounded,
                                  size: 18,
                                  color: HelaColors.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Text(
                                        'Ceylon Pay / Visa',
                                        style: TextStyle(
                                          color: HelaColors.onSurface,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        '•••• 4291',
                                        style: TextStyle(
                                          color: HelaColors.onSurfaceVariant,
                                          fontSize: 12,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Text(
                                    'Automatic instant receipt',
                                    style: TextStyle(
                                      color: HelaColors.secondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Change',
                              style: TextStyle(
                                color: HelaColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Confirm Ride CTA Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => _showLiveTrackingSheet(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: colors.primary.withValues(alpha: 0.15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Confirm ${_currentVehicle.title} Ride',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Safety & Trust Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.security_rounded, size: 14, color: HelaColors.secondary),
                          SizedBox(width: 5),
                          Text(
                            '100% Vetted Local Drivers · SOS & GPS Live Protected',
                            style: TextStyle(
                              color: HelaColors.onSurfaceVariant,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  PreferredSizeWidget _buildTopAppBar() {
    final colors = HelaColors.of(context);
    final isDark = colors.isDark;
    return AppBar(
      backgroundColor: colors.surface.withValues(alpha: isDark ? 0.96 : 0.94),
      elevation: 0,
      scrolledUnderElevation: 1.0,
      shadowColor: Colors.black12,
      toolbarHeight: 64,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Material(
              color: colors.surfaceContainerLowest,
              shape: const CircleBorder(),
              elevation: 1,
              shadowColor: Colors.black12,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.of(context).maybePop(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.arrow_back_rounded, color: colors.primary, size: 20),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Fair Ride Ceylon',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.verified_user_rounded, color: colors.primary, size: 22),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('SOS & Emergency Support Active')),
                    );
                  },
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: colors.goldenAmber,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLiveTrackingSheet(BuildContext context) {
    final colors = HelaColors.of(context);
    final vehicle = _currentVehicle;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.96,
        minChildSize: 0.5,
        builder: (sheetCtx, scrollController) => Container(
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.architecturalBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Header: Status + Live GPS Badge + SOS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.primary, size: 28),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.surfaceContainerLowest,
                      shape: const CircleBorder(),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        'Driver En-Route',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF15803D),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'LIVE GPS TRACKING • RIDE #HL-4821',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF15803D),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Connected to Sri Lanka Tourist Police 1912')),
                      );
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: const Text(
                        'SOS 1912',
                        style: TextStyle(
                          color: Color(0xFF991B1B),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Simulated Live Map Viewport
              Container(
                height: 175,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F5F3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
                ),
                child: Stack(
                  children: [
                    // Map background pattern & route representation
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CustomPaint(
                          painter: _RouteMapPainter(primaryColor: colors.primary),
                        ),
                      ),
                    ),
                    // ETA Floating Pill
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined, size: 14, color: colors.primary),
                            const SizedBox(width: 5),
                            Text(
                              '3 mins away · 450m',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Start PIN Badge
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: colors.primary.withValues(alpha: 0.15), blurRadius: 8),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.pin_drop_rounded, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'START PIN: 4821',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Driver Information Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.architecturalBorder),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: colors.primary.withValues(alpha: 0.15),
                          child: Icon(Icons.person_rounded, size: 36, color: colors.primary),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Color(0xFF15803D),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 10, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Chaminda Perera',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: colors.onBackground,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colors.goldenAmber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.star_rounded, size: 12, color: colors.goldenAmber),
                                    const SizedBox(width: 2),
                                    Text(
                                      '4.95',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: colors.onBackground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${vehicle.title} • Plate WP-AA-4921',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'SLTDA Verified Chauffeur · English & Sinhala',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF15803D),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 5-Stage Stepper / Timeline
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.architecturalBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Progression',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildProgressStep(
                      title: 'Driver Assigned & Confirmed',
                      subtitle: 'Chaminda Perera accepted your booking',
                      isCompleted: true,
                      isActive: false,
                      colors: colors,
                    ),
                    _buildProgressStep(
                      title: 'Arriving at Pickup Location',
                      subtitle: 'Expected at 98 Acres Pavilion in 3 mins',
                      isCompleted: false,
                      isActive: true,
                      colors: colors,
                    ),
                    _buildProgressStep(
                      title: 'Start Ride with PIN: 4821',
                      subtitle: 'Driver will verify your secure PIN',
                      isCompleted: false,
                      isActive: false,
                      colors: colors,
                    ),
                    _buildProgressStep(
                      title: 'In Transit',
                      subtitle: 'Regulated official tourist flat meter',
                      isCompleted: false,
                      isActive: false,
                      colors: colors,
                    ),
                    _buildProgressStep(
                      title: 'Arrive at Destination',
                      subtitle: 'Mount Lavinia / Colombo',
                      isCompleted: false,
                      isActive: false,
                      isLast: true,
                      colors: colors,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons: Call, Message, Share
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Calling Chaminda Perera (+94 77 123 4821)...')),
                        );
                      },
                      icon: const Icon(Icons.phone_rounded, size: 16),
                      label: const Text('Call Driver'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.primary,
                        side: BorderSide(color: colors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Message sent to Chaminda: "I am ready at main entrance"')),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                      label: const Text('Message'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.primary,
                        side: BorderSide(color: colors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Live Tracking link copied to clipboard')),
                    );
                  },
                  icon: const Icon(Icons.share_location_rounded, size: 18),
                  label: const Text('Share Live Journey with Hotel / Family'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
    required HelaPalette colors,
    bool isLast = false,
  }) {
    final dotColor = isCompleted
        ? const Color(0xFF15803D)
        : (isActive ? colors.primary : colors.architecturalBorder);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFFDCFCE7) : (isActive ? colors.primary : Colors.transparent),
                border: Border.all(color: dotColor, width: 2),
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 11, color: Color(0xFF15803D))
                  : (isActive ? const Center(child: Icon(Icons.circle, size: 6, color: Colors.white)) : null),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: isCompleted ? const Color(0xFF15803D) : colors.architecturalBorder,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive || isCompleted ? FontWeight.w700 : FontWeight.w500,
                  color: isActive || isCompleted ? colors.onBackground : colors.onSurfaceVariant,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
              ),
              if (!isLast) const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  final Color primaryColor;
  _RouteMapPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.15)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(20, size.height * 0.8)
      ..cubicTo(size.width * 0.3, size.height * 0.7, size.width * 0.6, size.height * 0.3, size.width - 30, 30);

    canvas.drawPath(path, paint);

    // Pickup circle
    final pickupPaint = Paint()..color = const Color(0xFF15803D);
    canvas.drawCircle(Offset(20, size.height * 0.8), 6, pickupPaint);

    // Car/tuk-tuk current point
    final carPaint = Paint()..color = primaryColor;
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.5), 8, carPaint);

    // Dropoff circle
    final dropoffPaint = Paint()..color = const Color(0xFFDC2626);
    canvas.drawCircle(Offset(size.width - 30, 30), 6, dropoffPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
