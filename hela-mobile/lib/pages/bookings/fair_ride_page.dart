import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hela/pages/home/home_page.dart';
import 'package:hela/widgets/maps/real_time_google_map.dart';

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
  String _paymentMethod = 'card'; // 'card' or 'cash'

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

                      // Payment Method Row (Supports both Card and Cash with interactive switcher)
                      InkWell(
                        onTap: () => _showPaymentMethodPicker(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: _paymentMethod == 'cash'
                                          ? const Color(0xFFDCFCE7)
                                          : HelaColors.surfaceContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _paymentMethod == 'cash'
                                          ? Icons.payments_rounded
                                          : Icons.credit_card_rounded,
                                      size: 19,
                                      color: _paymentMethod == 'cash'
                                          ? const Color(0xFF15803D)
                                          : HelaColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (_paymentMethod == 'cash')
                                        const Text(
                                          'Cash on Arrival (LKR)',
                                          style: TextStyle(
                                            color: HelaColors.onSurface,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      else
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
                                      Text(
                                        _paymentMethod == 'cash'
                                            ? 'Pay exact fare LKR ${_currentVehicle.fareLkr} directly to driver'
                                            : 'Automatic instant receipt',
                                        style: TextStyle(
                                          color: _paymentMethod == 'cash'
                                              ? const Color(0xFF15803D)
                                              : HelaColors.secondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () => _showPaymentMethodPicker(context),
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
                        ),
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

  void _showPaymentMethodPicker(BuildContext context) {
    final colors = HelaColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, -6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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

            // Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Payment Method',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors.onBackground,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(sheetCtx),
                  icon: Icon(Icons.close_rounded, color: colors.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Option 1: Cash on Arrival (LKR)
            _buildPaymentOptionTile(
              title: 'Cash on Arrival (LKR)',
              subtitle: 'Pay exact fare LKR ${_currentVehicle.fareLkr} directly to driver upon dropoff',
              badgeText: 'Driver Preferred',
              badgeBg: const Color(0xFFDCFCE7),
              badgeColor: const Color(0xFF15803D),
              icon: Icons.payments_rounded,
              iconColor: const Color(0xFF15803D),
              iconBg: const Color(0xFFDCFCE7),
              isSelected: _paymentMethod == 'cash',
              onTap: () {
                setState(() => _paymentMethod = 'cash');
                Navigator.pop(sheetCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFF15803D),
                    content: Text('Payment method set to Cash on Arrival (LKR)'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            // Option 2: Card / Ceylon Pay
            _buildPaymentOptionTile(
              title: 'Ceylon Pay / Visa',
              subtitle: '•••• 4291 · Automatic cashless checkout with instant receipt',
              badgeText: 'Instant Receipt',
              badgeBg: colors.secondaryContainer,
              badgeColor: colors.primary,
              icon: Icons.credit_card_rounded,
              iconColor: colors.primary,
              iconBg: colors.surfaceContainer,
              isSelected: _paymentMethod == 'card',
              onTap: () {
                setState(() => _paymentMethod = 'card');
                Navigator.pop(sheetCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: colors.primary,
                    content: const Text('Payment method set to Ceylon Pay / Visa (•••• 4291)'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptionTile({
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeBg,
    required Color badgeColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF15803D) : const Color(0xFFE5E7EB),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? const Color(0xFF15803D) : const Color(0xFF9CA3AF),
              size: 22,
            ),
          ],
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
            // High-Priority Emergency SOS Button (Replaces "Fair Ride Ceylon")
            GestureDetector(
              onTap: () => _showEmergencySosSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                  ),
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Icon(
                      Icons.emergency_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'SOS EMERGENCY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // History & Safety Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: colors.surfaceContainerLowest,
                  shape: const CircleBorder(),
                  elevation: 1,
                  shadowColor: Colors.black12,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _showRidesHistorySheet(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.history_rounded, color: colors.primary, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: const Color(0xFFFEE2E2),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _showEmergencySosSheet(context),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.shield_rounded,
                        color: Color(0xFFDC2626),
                        size: 20,
                      ),
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

  Future<void> _callEmergencyNumber(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            content: Text('Please dial emergency hotline: $number'),
          ),
        );
      }
    }
  }

  Future<void> _shareEmergencyDispatch() async {
    const text = '🚨 HELA EMERGENCY DISTRESS ALERT 🚨\n'
        'I need immediate assistance while travelling in Sri Lanka!\n\n'
        '• Current Vehicle: HELA Taxi / Tuk-Tuk Service\n'
        '• Pickup / Current Area: 98 Acres Resort & Spa, Ella\n'
        '• Destination: Ravana Falls & Rock Sanctuary\n'
        '• GPS Coordinates: 6.8667° N, 81.0466° E\n'
        '• Live Map: https://maps.google.com/?q=6.8667,81.0466\n\n'
        'Please alert Sri Lanka Police (Dial 119) or Suwa Seriya Ambulance (Dial 1990) immediately!';
    try {
      await Share.share(text, subject: '🚨 HELA Emergency Distress Dispatch');
    } catch (_) {
      await Clipboard.setData(const ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFDC2626),
            content: Text('Emergency distress text copied to clipboard! Paste into SMS or WhatsApp.'),
          ),
        );
      }
    }
  }

  Future<void> _copyGpsCoordinates() async {
    const coords = '6.8667° N, 81.0466° E (98 Acres Resort, Ella, Sri Lanka)';
    await Clipboard.setData(const ClipboardData(text: coords));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF15803D),
          content: Text('GPS Coordinates copied to clipboard!'),
        ),
      );
    }
  }

  void _triggerDistressAlarm() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFB91C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_rounded, color: Colors.white, size: 54),
            const SizedBox(height: 12),
            const Text(
              '⚠️ EMERGENCY MODE ACTIVE ⚠️',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 17,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Live GPS location, vehicle details, and route coordinates are being recorded and transmitted.\n\n'
              'Please stay calm. If in immediate danger, exit in a lit populated area and call 119 or 1990 immediately.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _callEmergencyNumber('119');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFB91C1C),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'CALL 119 POLICE',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('DISMISS'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencySosSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (ctx, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 24,
                offset: Offset(0, -6),
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
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Emergency Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.emergency_rounded,
                          color: Color(0xFFDC2626),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Emergency SOS Hub',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2937),
                              fontFamily: 'Inter',
                            ),
                          ),
                          Text(
                            '24/7 Islandwide Emergency Response',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetCtx),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF4B5563)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Active Ride Safety Beacon Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'ACTIVE TAXI SAFETY TRACKING',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF991B1B),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Location: 98 Acres Resort, Ella (Near Ravana Falls)\nGPS: 6.8667° N, 81.0466° E',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF374151),
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _shareEmergencyDispatch,
                            icon: const Icon(Icons.share_location_rounded, size: 16),
                            label: const Text('Share Location SOS'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _copyGpsCoordinates,
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text('Copy GPS'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF991B1B),
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Instant Emergency Hotlines (1-Tap Dial)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 10),

              // Hotline 1: 1990 Suwa Seriya Ambulance
              _buildEmergencyHotlineTile(
                icon: Icons.medical_services_rounded,
                iconColor: const Color(0xFF15803D),
                iconBg: const Color(0xFFDCFCE7),
                number: '1990',
                title: 'Suwa Seriya Ambulance',
                subtitle: 'Free 24/7 Islandwide Emergency Medical Care',
                onTap: () => _callEmergencyNumber('1990'),
              ),
              const SizedBox(height: 8),

              // Hotline 2: 119 Sri Lanka Police
              _buildEmergencyHotlineTile(
                icon: Icons.local_police_rounded,
                iconColor: const Color(0xFF1E40AF),
                iconBg: const Color(0xFFDBEAFE),
                number: '119',
                title: 'Police Emergency Operations',
                subtitle: 'Crime, Theft, Immediate Danger & Threat',
                onTap: () => _callEmergencyNumber('119'),
              ),
              const SizedBox(height: 8),

              // Hotline 3: 1912 Tourist Police
              _buildEmergencyHotlineTile(
                icon: Icons.shield_rounded,
                iconColor: const Color(0xFF92400E),
                iconBg: const Color(0xFFFEF3C7),
                number: '1912',
                title: 'Tourist Police & SLTDA',
                subtitle: 'Dedicated English Support for Foreign Travellers',
                onTap: () => _callEmergencyNumber('1912'),
              ),
              const SizedBox(height: 8),

              // Hotline 4: 110 Fire & Rescue
              _buildEmergencyHotlineTile(
                icon: Icons.fire_truck_rounded,
                iconColor: const Color(0xFFB45309),
                iconBg: const Color(0xFFFFEDD5),
                number: '110',
                title: 'Fire & Rescue Service',
                subtitle: 'Accident Rescue, Fire & Disaster Assistance',
                onTap: () => _callEmergencyNumber('110'),
              ),
              const SizedBox(height: 16),

              // Driver Warning / Deterrent Alarm Button
              InkWell(
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _triggerDistressAlarm();
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFFBBF24), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Trigger Distress Beacon & Deterrent',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Displays high-visibility alert screen to deter driver',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyHotlineTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String number,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Row(
          children: [
            Text(
              number,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: iconColor,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF111827),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF6B7280),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: iconColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.call_rounded, size: 14),
              SizedBox(width: 4),
              Text(
                'CALL',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ],
          ),
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
                    Navigator.pop(ctx);
                    _showRidesHistorySheet(context);
                  },
                  icon: const Icon(Icons.receipt_long_rounded, size: 18),
                  label: const Text('My Rides & History'),
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

  void _showRidesHistorySheet(BuildContext context) {
    final colors = HelaColors.of(context);
    final vehicle = _currentVehicle;

    final pastRides = [
      {
        'id': '#HL-3914',
        'date': 'Yesterday · 04:30 PM',
        'vehicle': 'Tuk-Tuk (Official Meter)',
        'plate': 'WP-AB-8123',
        'driver': 'Sunil Bandara',
        'rating': '4.92',
        'pickup': 'Ella Railway Station',
        'dropoff': 'Nine Arch Bridge Viewpoint',
        'distance': '3.2 km',
        'fareLkr': 1150,
        'fareUsd': 3.80,
        'payment': 'Cash on Arrival',
        'status': 'Completed',
      },
      {
        'id': '#HL-2802',
        'date': '23 Nov 2026 · 10:15 AM',
        'vehicle': 'Sedan Car (AC Standard)',
        'plate': 'WP-CA-3301',
        'driver': 'Nuwan Jayasinghe',
        'rating': '4.98',
        'pickup': 'Kandy City Center Hotel',
        'dropoff': 'Temple of the Sacred Tooth Relic',
        'distance': '2.1 km',
        'fareLkr': 2400,
        'fareUsd': 7.90,
        'payment': 'Ceylon Pay / Visa •••• 4291',
        'status': 'Completed',
      },
      {
        'id': '#HL-1950',
        'date': '21 Nov 2026 · 07:00 AM',
        'vehicle': 'Safari Van (Luggage Boot)',
        'plate': 'WP-NA-7788',
        'driver': 'Kasun Fernando',
        'rating': '5.0',
        'pickup': 'Bandaranaike Int. Airport (CMB)',
        'dropoff': 'Colombo Fort / Galle Face Green',
        'distance': '34.5 km via Expressway',
        'fareLkr': 9500,
        'fareUsd': 31.00,
        'payment': 'Ceylon Pay / Visa •••• 4291',
        'status': 'Completed',
      },
    ];

    int currentTab = 0; // 0: Ongoing, 1: Past

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.88,
          maxChildSize: 0.96,
          minChildSize: 0.5,
          builder: (scrollCtx, scrollController) => Container(
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 24,
                  offset: Offset(0, -6),
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
                const SizedBox(height: 16),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.local_taxi_rounded,
                            color: colors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Taxi Rides',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: colors.onBackground,
                              ),
                            ),
                            Text(
                              'Live Trips & Past Ceylon Fair Rides',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetCtx),
                      icon: Icon(Icons.close_rounded, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tabs: Ongoing (1) vs Past Rides (3)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setSheetState(() => currentTab = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: currentTab == 0 ? colors.cardBackground : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: currentTab == 0
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF15803D),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Ongoing Ride (1)',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: currentTab == 0 ? FontWeight.w800 : FontWeight.w600,
                                    color: currentTab == 0 ? colors.onSurface : colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setSheetState(() => currentTab = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: currentTab == 1 ? colors.cardBackground : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: currentTab == 1
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history_rounded, size: 14, color: colors.onSurfaceVariant),
                                const SizedBox(width: 5),
                                Text(
                                  'Past History (${pastRides.length})',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: currentTab == 1 ? FontWeight.w800 : FontWeight.w600,
                                    color: currentTab == 1 ? colors.onSurface : colors.onSurfaceVariant,
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
                const SizedBox(height: 16),

                // TAB 0: Ongoing Ride
                if (currentTab == 0) ...[
                  _buildOngoingRideCard(context, vehicle, colors, sheetCtx),
                ] else ...[
                  // TAB 1: Past Rides History
                  ...pastRides.map((ride) => _buildPastRideCard(context, ride, colors)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOngoingRideCard(
    BuildContext context,
    VehicleOption vehicle,
    HelaPalette colors,
    BuildContext sheetCtx,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.architecturalBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.directions_car_filled_rounded, size: 13, color: Color(0xFF15803D)),
                    SizedBox(width: 5),
                    Text(
                      'DRIVER EN-ROUTE • 3 MINS AWAY',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15803D),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                '#HL-4821',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6B7280),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Route Timeline
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF15803D),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 32,
                    color: colors.architecturalBorder,
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '98 Acres Resort & Spa, Ella',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Ravana Falls & Rock Sanctuary',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Driver & PIN info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.architecturalBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_rounded, size: 24, color: colors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chaminda Perera ⭐ 4.95',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                      Text(
                        '${vehicle.title} · Plate WP-AA-4921',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        'START PIN',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF92400E),
                        ),
                      ),
                      Text(
                        '4821',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF78350F),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Fare & Payment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _paymentMethod == 'cash' ? Icons.payments_rounded : Icons.credit_card_rounded,
                    size: 16,
                    color: _paymentMethod == 'cash' ? const Color(0xFF15803D) : colors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _paymentMethod == 'cash' ? 'Cash on Arrival' : 'Ceylon Pay / Visa',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Text(
                'LKR ${vehicle.fareLkr} (~\$${vehicle.fareUsd.toStringAsFixed(2)})',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetCtx);
                    _showLiveTrackingSheet(context);
                  },
                  icon: const Icon(Icons.navigation_rounded, size: 16),
                  label: const Text('Live Map View'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _callEmergencyNumber('0771234567'),
                icon: const Icon(Icons.phone_rounded, size: 16),
                label: const Text('Call'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.primary,
                  side: BorderSide(color: colors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPastRideCard(
    BuildContext context,
    Map<String, dynamic> ride,
    HelaPalette colors,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
          // Header: Date & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'COMPLETED',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15803D),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ride['id'] as String,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              Text(
                ride['date'] as String,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Route
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF15803D),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 24,
                    color: colors.architecturalBorder,
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride['pickup'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      ride['dropoff'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Vehicle & Fare summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${ride['vehicle']} · ${ride['driver']}',
                style: TextStyle(
                  fontSize: 11.5,
                  color: colors.onSurfaceVariant,
                ),
              ),
              Text(
                'LKR ${ride['fareLkr']}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action buttons: View Receipt & Rebook
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showReceiptDialog(context, ride),
                  icon: const Icon(Icons.receipt_long_rounded, size: 15),
                  label: const Text('View Receipt'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(color: colors.architecturalBorder),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: colors.primary,
                        content: Text('Rebooking ${ride['pickup']} to ${ride['dropoff']}...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.replay_rounded, size: 15),
                  label: const Text('Rebook'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.surfaceContainer,
                    foregroundColor: colors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReceiptDialog(BuildContext context, Map<String, dynamic> ride) {
    final fare = ride['fareLkr'] as int;
    final baseFare = 120;
    final distFare = fare - baseFare;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CEYLON FAIR RIDE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15803D),
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      'Official Receipt ${ride['id']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
            const Divider(height: 20),
            Text('Date: ${ride['date']}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            Text('Driver: ${ride['driver']} (${ride['plate']})', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            Text('Route: ${ride['pickup']} ➔ ${ride['dropoff']}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Official Flag Drop (1st km):', style: TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
                Text('LKR $baseFare', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Distance Fare:', style: TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
                Text('LKR $distFare', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Regulated Tourism Levy (SLTDA):', style: TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
                Text('LKR 0 (Free)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF15803D))),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount Paid:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                Text('LKR $fare', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF15803D))),
              ],
            ),
            const SizedBox(height: 4),
            Text('Payment Method: ${ride['payment']}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280))),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Receipt downloaded & saved to device')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00382E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Download Receipt PDF'),
              ),
            ),
          ],
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
