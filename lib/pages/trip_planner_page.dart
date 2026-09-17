import 'package:flutter/material.dart';
import 'package:hela/pages/home_page.dart';
import 'package:hela/pages/stays_page.dart';
import 'package:hela/pages/profile_page.dart';
import 'package:hela/widgets/itinerary_card.dart';
import 'package:hela/widgets/real_time_calendar.dart';
import 'package:hela/models/tour_plan.dart';
import 'package:hela/models/tour_preferences.dart';
import 'package:hela/pages/tour_plan_details_page.dart';
import 'package:hela/pages/ai_chat_customization_page.dart';

/// Data models for the planner

class TripPlannerPage extends StatefulWidget {
  const TripPlannerPage({super.key});

  @override
  State<TripPlannerPage> createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends State<TripPlannerPage> {
  int _selectedNavIndex = 2; // "Journeys" is active by default
  int _selectedItineraryIndex = 0;
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


  TourPlan _buildTourPlanForItinerary(ItineraryCardData data) {
    final daysCount = _travelDays > 0 ? _travelDays : 5;

    final cleanPrice =
        double.tryParse(data.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 340.0;

    final days = List.generate(daysCount, (i) {
      final dayNum = i + 1;
      final highlight = data.highlights[i % data.highlights.length];
      return ItineraryDay(
        dayNumber: dayNum,
        title: 'Day $dayNum: ${data.routeName}',
        summary: 'Experience ${data.title} focusing on ${data.categoryTag}.',
        estimatedDayCostUsd: cleanPrice / daysCount,
        overnightStay: data.routeName,
        activities: [
          ItineraryActivity(
            title: highlight,
            description: 'Curated signature highlight of ${data.title}.',
            startTime: '08:30 AM',
            estimatedDuration: '3 hours',
            category: data.categoryTag,
            estimatedCostUsd: 25.0,
            travelTimeFromPrevious: '35 mins',
            travelMethod: 'Scenic transfer',
            tips: const ['Comfortable walking attire and camera recommended.'],
          ),
          const ItineraryActivity(
            title: 'Authentic Local Lunch & Cultural Tasting',
            description: 'Traditional Sri Lankan farm-to-table lunch.',
            startTime: '01:00 PM',
            estimatedDuration: '1.5 hours',
            category: 'Culinary',
            estimatedCostUsd: 15.0,
            tips: ['Taste seasonal tropical fruits and Ceylon tea.'],
          ),
          const ItineraryActivity(
            title: 'Sunset Viewpoint & Evening Leisure',
            description: 'Golden hour panoramic views and scenic stroll.',
            startTime: '05:00 PM',
            estimatedDuration: '2 hours',
            category: 'Leisure',
            estimatedCostUsd: 10.0,
            tips: ['Great photo spot during sunset.'],
          ),
        ],
      );
    });

    return TourPlan(
      id: 'itinerary_${data.title.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}',
      title: data.title,
      summary: data.subtitle,
      matchReason:
          'Calibrated for $_travelDays days with ${data.categoryTag} highlights.',
      durationDays: daysCount,
      estimatedTotalCostUsd: cleanPrice,
      budgetBreakdown:
          'Includes lodging, activity permits, local transit, and guided experiences.',
      budgetIncludes: const [
        'Boutique eco-stays',
        'Guided excursion permits',
        'Inter-city travel'
      ],
      budgetExcludes: const [
        'International airfare',
        'Alcoholic beverages',
        'Personal expenses'
      ],
      travelTips: const [
        'Pack layers for changing mountain and coastal climates',
        'Carry local currency (LKR) for artisanal craft purchases',
        'Respect temple dress codes (covered shoulders & knees)'
      ],
      warnings: const [
        'Check seasonal weather for high elevation hikes',
        'Mountain rail tickets should be confirmed in advance'
      ],
      dataSources: const ['HELA Curated Journeys', 'Google Gemini AI'],
      days: days,
    );
  }

  TourPreferences _buildPreferencesForItinerary(ItineraryCardData data) {
    final interests = _selectedThemes.map((t) {
      switch (t.toLowerCase()) {
        case 'culture':
          return TravelInterest.culture;
        case 'nature':
          return TravelInterest.nature;
        case 'food':
          return TravelInterest.food;
        case 'adventure':
          return TravelInterest.adventure;
        case 'wellness':
          return TravelInterest.relaxation;
        case 'wildlife':
          return TravelInterest.wildlife;
        default:
          return TravelInterest.culture;
      }
    }).toSet();

    return TourPreferences(
      duration: TravelDuration.custom,
      customDays: _travelDays,
      interests: interests,
      startingLocationName: data.routeName,
      pace: TravelPace.moderate,
    );
  }

  void _openTourDetails(ItineraryCardData itinerary) {
    final plan = _buildTourPlanForItinerary(itinerary);
    final prefs = _buildPreferencesForItinerary(itinerary);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TourPlanDetailsPage(
          plan: plan,
          preferences: prefs,
        ),
      ),
    );
  }

  Future<void> _customizeTrip(ItineraryCardData itinerary) async {
    final plan = _buildTourPlanForItinerary(itinerary);
    final prefs = _buildPreferencesForItinerary(itinerary);

    final updatedPlan = await Navigator.of(context).push<TourPlan>(
      MaterialPageRoute(
        builder: (_) => AiChatCustomizationPage(
          currentPlan: plan,
          preferences: prefs,
        ),
      ),
    );

    if (updatedPlan != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TourPlanDetailsPage(
            plan: updatedPlan,
            preferences: prefs,
          ),
        ),
      );
    }
  }

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

          // Sticky Bottom CTA Floating Action Bar (Docked cleanly above bottom nav)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: HelaColors.surfaceContainerLowest.withValues(alpha: 0.96),
                    border: Border(
                      top: BorderSide(
                        color: HelaColors.outlineVariant.withValues(alpha: 0.35),
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _itineraries[_selectedItineraryIndex].price,
                            style: const TextStyle(
                              color: HelaColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _customizeTrip(_itineraries[_selectedItineraryIndex]),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HelaColors.tertiaryFixed,
                            foregroundColor: HelaColors.onTertiaryFixed,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome_rounded, size: 18),
                              SizedBox(width: 8),
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
            final isSelected = _selectedItineraryIndex == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? HelaColors.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ItineraryCard.fromItineraryCardData(
                itinerary,
                isBookmarked: isBookmarked,
                onTap: () {
                  setState(() => _selectedItineraryIndex = index);
                },
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
                  setState(() => _selectedItineraryIndex = index);
                  _openTourDetails(itinerary);
                },
              ),
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
