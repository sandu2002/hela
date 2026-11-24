import 'package:flutter/material.dart';
import 'package:hela/theme/hela_colors.dart';
import 'package:hela/pages/fair_ride_page.dart';
import 'package:hela/pages/home_page.dart';
import 'package:hela/widgets/hela_bottom_nav_bar.dart';

/// HELA - My Bookings Page
/// Direct implementation of Stitch Screen: HELA - My Bookings (`e85f6d85e5284180b1d74b208944bf01`)
/// Adheres to Lankan Tropical Modernism design system.
class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  int _tabIndex = 0; // 0: Upcoming (3), 1: Past (4)
  int _categoryIndex = 0; // 0: All, 1: Taxi, 2: Stays, 3: Cultural, 4: Train

  final List<String> _categories = const [
    'All',
    '🚕 Taxi',
    '🏨 Stays',
    '🏛️ Cultural',
    '🚂 Train',
  ];

  void _triggerEmergencySos() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emergency_rounded, color: Color(0xFFDC2626), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Tourist Emergency SOS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF132220),
                        ),
                      ),
                      Text(
                        'Official 24/7 Sri Lanka Tourist Protection',
                        style: TextStyle(fontSize: 12, color: Color(0xFF4A5D5A)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSosActionTile(
              icon: Icons.local_police_rounded,
              title: 'Tourist Police Hotline',
              number: '1912',
              desc: 'Dedicated rapid response for international travelers',
              color: const Color(0xFF00443E),
            ),
            const SizedBox(height: 12),
            _buildSosActionTile(
              icon: Icons.medical_services_rounded,
              title: 'Suwa Seriya Free Ambulance',
              number: '1990',
              desc: 'Island-wide emergency medical response',
              color: const Color(0xFFDC2626),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: Color(0xFFE7DFD5)),
                ),
                child: const Text('Dismiss', style: TextStyle(color: Color(0xFF4A5D5A))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSosActionTile({
    required IconData icon,
    required String title,
    required String number,
    required String desc,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7DFD5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            radius: 20,
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text(desc, style: const TextStyle(color: Color(0xFF7D8E8B), fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Call $number',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface.withValues(alpha: 0.15),
        elevation: 0,
        scrolledUnderElevation: 1.0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
              ),
              child: Row(
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
                    'HELA • BOOKINGS',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Emergency SOS Button
            InkWell(
              onTap: _triggerEmergencySos,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.phone_in_talk_rounded, size: 13, color: Color(0xFF991B1B)),
                    SizedBox(width: 4),
                    Text(
                      'SOS 1912',
                      style: TextStyle(
                        color: Color(0xFF991B1B),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Bookings',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: colors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'All your travel reservations in one place',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FairRidePage()),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('New Ride'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tab Switcher: Upcoming (3) vs Past (4)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.architecturalBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tabIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: _tabIndex == 0 ? colors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Upcoming (3)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _tabIndex == 0 ? Colors.white : colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tabIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: _tabIndex == 1 ? colors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Past (4)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _tabIndex == 1 ? Colors.white : colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Category Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_categories.length, (index) {
                  final isSelected = _categoryIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(_categories[index]),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : colors.onSurfaceVariant,
                      ),
                      backgroundColor: colors.cardBackground,
                      selectedColor: colors.primary,
                      showCheckmark: false,
                      side: BorderSide(
                        color: isSelected ? colors.primary : colors.architecturalBorder,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      onSelected: (_) => setState(() => _categoryIndex = index),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Booking Cards
            if (_tabIndex == 0) ...[
              // Card 1: Airport Express Taxi
              _buildBookingCard(
                categoryPill: 'AIRPORT TAXI',
                categoryIcon: Icons.local_taxi_rounded,
                statusPill: 'Confirmed',
                statusColor: const Color(0xFF15803D),
                statusBg: const Color(0xFFDCFCE7),
                title: 'Bandaranaike Int. Airport (CMB) → Galle Fort Heritage Villa',
                detailsRow: [
                  {'icon': Icons.calendar_today_rounded, 'text': 'Tomorrow, 09:30 AM'},
                  {'icon': Icons.directions_car_rounded, 'text': 'Sedan Class (AC)'},
                  {'icon': Icons.pin_drop_rounded, 'text': 'Start PIN: 4821'},
                ],
                priceLkr: 'LKR 14,200',
                priceUsd: '~\$45.00 USD',
                primaryCtaText: 'Track Driver',
                onPrimaryCta: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FairRidePage()),
                  );
                },
                secondaryCtaText: 'View Voucher',
                colors: colors,
              ),
              const SizedBox(height: 14),

              // Card 2: Sigiriya Resort
              _buildBookingCard(
                categoryPill: 'HERITAGE STAY',
                categoryIcon: Icons.hotel_rounded,
                statusPill: 'Upcoming',
                statusColor: const Color(0xFFD97706),
                statusBg: const Color(0xFFFEF3C7),
                title: 'Amangalla Heritage Resort & Spa · Deluxe Room',
                detailsRow: [
                  {'icon': Icons.calendar_today_rounded, 'text': 'Dec 14 – Dec 17 · 3 Nights'},
                  {'icon': Icons.people_rounded, 'text': '2 Guests · Breakfast Included'},
                  {'icon': Icons.verified_rounded, 'text': 'SLTDA Approved 5-Star'},
                ],
                priceLkr: 'LKR 185,000',
                priceUsd: '~\$590.00 USD',
                primaryCtaText: 'View E-Voucher',
                onPrimaryCta: () {},
                secondaryCtaText: 'Directions',
                colors: colors,
              ),
              const SizedBox(height: 14),

              // Card 3: Scenic Train
              _buildBookingCard(
                categoryPill: 'SCENIC TRAIN',
                categoryIcon: Icons.train_rounded,
                statusPill: 'Confirmed',
                statusColor: const Color(0xFF15803D),
                statusBg: const Color(0xFFDCFCE7),
                title: 'Kandy to Ella Blue Train via Nine Arch Bridge',
                detailsRow: [
                  {'icon': Icons.calendar_today_rounded, 'text': 'Dec 20 · 08:45 AM Departure'},
                  {'icon': Icons.airline_seat_recline_extra_rounded, 'text': '1st Class Obs. (Seat 14A, 14B)'},
                  {'icon': Icons.qr_code_rounded, 'text': 'Digital Boarding Pass Ready'},
                ],
                priceLkr: 'LKR 6,400',
                priceUsd: '~\$20.50 USD',
                primaryCtaText: 'Show QR Pass',
                onPrimaryCta: () {},
                secondaryCtaText: 'Station Info',
                colors: colors,
              ),
            ] else ...[
              // Past bookings
              _buildBookingCard(
                categoryPill: 'CULTURAL ASCENT',
                categoryIcon: Icons.landscape_rounded,
                statusPill: 'Completed',
                statusColor: const Color(0xFF4A5D5A),
                statusBg: const Color(0xFFE8ECEB),
                title: 'Sigiriya Rock Fortress Guided Dawn Ascent & Museum Tour',
                detailsRow: [
                  {'icon': Icons.calendar_today_rounded, 'text': 'Completed on Nov 18'},
                  {'icon': Icons.person_rounded, 'text': 'Guide: Ruwan Senanayake (SLTDA)'},
                ],
                priceLkr: 'LKR 11,200',
                priceUsd: '~\$36.00 USD',
                primaryCtaText: 'Leave Review',
                onPrimaryCta: () {},
                secondaryCtaText: 'Book Again',
                colors: colors,
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const HelaBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildBookingCard({
    required String categoryPill,
    required IconData categoryIcon,
    required String statusPill,
    required Color statusColor,
    required Color statusBg,
    required String title,
    required List<Map<String, dynamic>> detailsRow,
    required String priceLkr,
    required String priceUsd,
    required String primaryCtaText,
    required VoidCallback onPrimaryCta,
    required String secondaryCtaText,
    required HelaPalette colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.architecturalBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Category + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(categoryIcon, size: 13, color: colors.primary),
                    const SizedBox(width: 4),
                    Text(
                      categoryPill,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusPill,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colors.onBackground,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),

          // Metadata rows
          ...detailsRow.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  Icon(row['icon'] as IconData, size: 14, color: colors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    row['text'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Divider
          Divider(color: colors.architecturalBorder, height: 1),
          const SizedBox(height: 12),

          // Price & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    priceLkr,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                  Text(
                    priceUsd,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: colors.onSurfaceVariant,
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: Text(secondaryCtaText),
                  ),
                  ElevatedButton(
                    onPressed: onPrimaryCta,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      elevation: 1,
                    ),
                    child: Text(primaryCtaText),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
