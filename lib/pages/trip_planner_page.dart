import 'package:flutter/material.dart';
import 'package:hela/pages/home_page.dart';
import 'package:hela/pages/stays_page.dart';
import 'package:hela/pages/profile_page.dart';
import 'package:hela/widgets/itinerary_card.dart';
import 'package:hela/widgets/real_time_calendar.dart';

/// Data models for the planner

class TripPlannerPage extends StatefulWidget {
  const TripPlannerPage({super.key});

  @override
  State<TripPlannerPage> createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends State<TripPlannerPage> {
  int _selectedNavIndex = 2; // "Journeys" is active by default
  final Set<String> _selectedThemes = {'Culture', 'Nature', 'Food'};
  final Set<int> _bookmarkedItineraries = {0}; // Card 1 is bookmarked by default

  final List<String> _allThemes = const [
    'Culture',
    'Nature',
    'Food',
    'Adventure',
    'Wellness',
    'Wildlife',
  ];

  DateTime _travelStartDate = DateTime.now();
  late DateTime _travelEndDate = _travelStartDate.add(const Duration(days: 7));

  int get _travelDays => _travelEndDate.difference(_travelStartDate).inDays + 1;

  final List<ItineraryCardData> _itineraries = const [
    ItineraryCardData(
      title: 'Ceylon Mist & Highlands',
      subtitle: 'Through colonial tea country and dizzying hill summits',
      durationTag: '5 Days · Moderate',
      categoryTag: 'Highland',
      routeName: 'Highland Sanctuary Route',
      rating: 4.9,
      reviewsCount: 128,
      price: '\$340',
      badgeIcon: Icons.terrain_rounded,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCJM8QYoWW5_TWxP0KiOVmQ39cdSb5L1v6jE2tybVTSnkYEDVzYLErktpPUfudejeQKF1w7AwbOJL2BSV1kjuJVT_Dl8JWT_pal2OPTMwUhWHlcCDX1KaAkhRAwof9M9uP4QlCjDIAzsg8sn4BavVuEfRC-lHdihNbXECiJlYzMhSvsDQG5cG_2hpLYpkjYqXwgpTiS_dQ5Nf2ztFUx98Eg9YM9UnWtWIjhpnkrpPz1Eg1DFsFsgiUU6w',
      highlights: [
        'Nine Arch Bridge sunrise walk before morning mist lifts',
        'Private tea tasting at century-old Ceylon heritage factory',
        'Iconic scenic train ride through misty cloud forests',
      ],
    ),
    ItineraryCardData(
      title: 'Ancient Kingdoms & Sigiriya',
      subtitle: 'UNESCO rock fortresses, cave monasteries and spice trails',
      durationTag: '4 Days · Cultural',
      categoryTag: 'Culture',
      routeName: 'Sacred Cultural Triangle',
      rating: 4.9,
      reviewsCount: 94,
      price: '\$295',
      badgeIcon: Icons.account_balance_rounded,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB3TPfE29ly_doLVHss4gTPVmGb-1rxdY5LMhZ-rdq9BmyDR88L1CCx3G5VxQuk87DKMUIz2q_WsvBd3lkiPxNALhNcPcMErRI3nq7g6hLaMiA6C1NmusTbPV0ZslA1qHlL9w6L1P_jHkMMcMMzvNdJKPcXzG8eOkTt9Cyb30tAYz1xAhnii66HyH6EdJyHOAlRDdMttrXZyoV0FkkxRpNC3aksqFaGTTPGEWcApr8rt2AKy_22sKFXlA',
      highlights: [
        'Dambulla cave temple frescoes with local monastery elder',
        'Sunset climb up Lion Rock to ancient sky palace ruins',
        'Village culinary cooking masterclass using clay hearths',
      ],
    ),
    ItineraryCardData(
      title: 'Southern Wilderness & Surf',
      subtitle: 'From untamed dry-zone savannas to Dutch colonial bastions',
      durationTag: '3 Days · Wildlife',
      categoryTag: 'Wildlife',
      routeName: 'Wild Coast & Fortified Ocean',
      rating: 4.8,
      reviewsCount: 82,
      price: '\$410',
      badgeIcon: Icons.pets_rounded,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAbajlOZKkyv1hGV38UgmHD5Rua8NHn1RXo1eydWv8kJj0TIn1ydTsodc2yKuuT7AbiEJlcK18RGL7nL7RZRQFLEqyWcO9bjNnTQoO9EGvrFxjUQ1wpGS2Mm2GnFIi5U6d1_FZibaW4imf14pPjKiBXayjkQMkkGysAeL0YOUeezCyIi3FI5AI8sGTdfMM4U2HRd97iDUeRvIC3M-VyInjW116Xd7knA_EbXL7wAROEteo0Uw_VsU2ZYA',
      highlights: [
        'Dawn leopard tracker expedition into Yala Block 1',
        'Private solar catamaran Mirissa whale watching trip',
        'Galle Fort colonial architecture & gem craftsman studio walk',
      ],
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HelaColors.background,
      appBar: _buildTopAppBar(),
      body: Stack(
        children: [
          // Background ambient subtle radial gradients (mandala effect)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7FA88A).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 300,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFB8C34A).withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Scrollable Content
          SafeArea(
            top: false,
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 160),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildEditorialHeader(),
                        const SizedBox(height: 18),
                        _buildDateRangeWidget(),
                        const SizedBox(height: 20),
                        _buildFlavorsSection(),
                        const SizedBox(height: 24),
                        _buildItinerariesSection(),
                        const SizedBox(height: 28),
                        _buildHeritageFooterSeal(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Sticky Bottom CTA Floating Action Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 64, // Sits right above bottom nav
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: HelaColors.surfaceContainerLowest.withValues(alpha: 0.92),
                    border: Border(
                      top: BorderSide(
                        color: HelaColors.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1F2E24).withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected $_travelDays-day plan',
                            style: const TextStyle(
                              color: HelaColors.onSurfaceVariant,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            '\$340',
                            style: TextStyle(
                              color: HelaColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Customizing $_travelDays-day Ceylon itinerary...')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HelaColors.tertiaryFixed,
                            foregroundColor: HelaColors.onTertiaryFixed,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Customize This Trip',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14.5,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildTopAppBar() {
    return AppBar(
      backgroundColor: HelaColors.surface.withValues(alpha: 0.92),
      elevation: 0,
      scrolledUnderElevation: 1.5,
      shadowColor: Colors.black12,
      toolbarHeight: 64,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.of(context).maybePop();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_back_rounded, color: HelaColors.primary, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'HELA',
                          style: TextStyle(
                            color: HelaColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 19,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: HelaColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'AI PLANNER',
                            style: TextStyle(
                              color: HelaColors.onSecondaryContainer,
                              fontWeight: FontWeight.w800,
                              fontSize: 9.5,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'AI-Curated Journeys',
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
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filter options opened')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: HelaColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: HelaColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.tune_rounded, size: 16, color: HelaColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Filter',
                        style: TextStyle(
                          color: HelaColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
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

  Widget _buildEditorialHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.auto_awesome_rounded, size: 14, color: HelaColors.secondary),
            SizedBox(width: 5),
            Text(
              'CEYLON CONCIERGE',
              style: TextStyle(
                color: HelaColors.secondary,
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Where do you feel like wandering?',
          style: TextStyle(
            color: HelaColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 26,
            letterSpacing: -0.6,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Hand-crafted expedition routes combining misty mountain trails, wild sanctuaries, and sacred heritage.',
          style: TextStyle(
            color: HelaColors.onSurfaceVariant,
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeWidget() {
    return RealTimeCalendarCard(
      initialStartDate: _travelStartDate,
      initialEndDate: _travelEndDate,
      onDateRangeChanged: (range) {
        setState(() {
          _travelStartDate = range.start;
          _travelEndDate = range.end;
        });
      },
    );
  }

  Widget _buildFlavorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Travel Flavors & Themes',
              style: TextStyle(
                color: HelaColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 17,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              '${_selectedThemes.length} Selected',
              style: const TextStyle(
                color: HelaColors.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allThemes.map((theme) {
            final isSelected = _selectedThemes.contains(theme);

            Color bg;
            Color text;
            Border? border;

            if (isSelected) {
              if (theme == 'Culture') {
                bg = HelaColors.tertiaryFixed;
                text = HelaColors.primary;
                border = Border.all(color: HelaColors.tertiaryFixedDim);
              } else {
                bg = HelaColors.primary;
                text = HelaColors.onPrimary;
                border = Border.all(color: HelaColors.primaryContainer);
              }
            } else {
              bg = HelaColors.surfaceContainerLow;
              text = HelaColors.onSurfaceVariant;
              border = Border.all(color: HelaColors.outlineVariant.withValues(alpha: 0.4));
            }

            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedThemes.remove(theme);
                  } else {
                    _selectedThemes.add(theme);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                  border: border,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? Icons.check_rounded : Icons.add_rounded,
                      size: 15,
                      color: isSelected
                          ? (theme == 'Culture' ? HelaColors.primary : HelaColors.secondaryFixed)
                          : HelaColors.outline,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      theme,
                      style: TextStyle(
                        color: text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildItinerariesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'AI-Suggested Itineraries',
                  style: TextStyle(
                    color: HelaColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Calibrated to your seasonal window and rhythm',
                  style: TextStyle(
                    color: HelaColors.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Text(
              '3 EXPEDITIONS',
              style: TextStyle(
                color: HelaColors.secondary,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Cards List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _itineraries.length,
          separatorBuilder: (context, index) => const SizedBox(height: 18),
          itemBuilder: (context, index) {
            final itinerary = _itineraries[index];
            final isBookmarked = _bookmarkedItineraries.contains(index);

            return ItineraryCard.fromItineraryCardData(
              itinerary,
              isBookmarked: isBookmarked,
              onBookmarkTap: () {
                setState(() {
                  if (isBookmarked) {
                    _bookmarkedItineraries.remove(index);
                  } else {
                    _bookmarkedItineraries.add(index);
                  }
                });
              },
              onViewRouteTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Viewing route for ${itinerary.title}')),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeritageFooterSeal() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: HelaColors.secondaryContainer.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.spa_rounded,
              size: 18,
              color: HelaColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'RESPONSIBLY CURATED · SUPPORTING LOCAL VILLAGES',
            style: TextStyle(
              color: HelaColors.outline,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                label: 'Explore',
                icon: Icons.explore_rounded,
                activeIcon: Icons.explore,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HelaHomePage()),
                  );
                },
              ),
              _buildNavItem(
                index: 1,
                label: 'Saved',
                icon: Icons.bookmark_border_rounded,
                activeIcon: Icons.bookmark_rounded,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const StaysPage()),
                  );
                },
              ),
              _buildNavItem(
                index: 2,
                label: 'Journeys',
                icon: Icons.map_outlined,
                activeIcon: Icons.map_rounded,
                hasNotificationBadge: true,
              ),
              _buildNavItem(
                index: 3,
                label: 'Profile',
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    bool hasNotificationBadge = false,
    VoidCallback? onTap,
  }) {
    final isActive = _selectedNavIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap ??
          () {
            setState(() {
              _selectedNavIndex = index;
            });
          },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? HelaColors.primary : HelaColors.onSurfaceVariant,
                  size: 24,
                ),
                if (hasNotificationBadge)
                  Positioned(
                    top: -1,
                    right: -2,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: HelaColors.tertiaryFixed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive ? HelaColors.primary : HelaColors.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
