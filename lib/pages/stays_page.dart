import 'package:flutter/material.dart';
import 'package:hela/pages/home_page.dart';
import 'package:hela/pages/saved_page.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/widgets/stay_card.dart';
import 'package:hela/widgets/hela_bottom_nav_bar.dart';

/// Model representing an Eco-Haven / Stay item
class StayHaven {
  final String title;
  final String location;
  final double rating;
  final int reviewsCount;
  final String ratingLabel;
  final int pricePerNight;
  final String feeNote;
  final String imageUrl;
  final List<StayAmenity> amenities;
  final bool hasPagerDots;
  final Color buttonBgColor;
  final Color buttonTextColor;

  const StayHaven({
    required this.title,
    required this.location,
    required this.rating,
    required this.reviewsCount,
    required this.ratingLabel,
    required this.pricePerNight,
    required this.feeNote,
    required this.imageUrl,
    required this.amenities,
    this.hasPagerDots = false,
    this.buttonBgColor = HelaColors.primaryContainer,
    this.buttonTextColor = HelaColors.onPrimary,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StayHaven && runtimeType == other.runtimeType && title == other.title;

  @override
  int get hashCode => title.hashCode;
}

class StayAmenity {
  final String label;
  final IconData icon;

  const StayAmenity({required this.label, required this.icon});
}

class StayFilterChipData {
  final String label;
  final IconData? icon;
  final bool hasDropdown;

  const StayFilterChipData({
    required this.label,
    this.icon,
    this.hasDropdown = false,
  });
}

class StaysPage extends StatefulWidget {
  const StaysPage({super.key});

  @override
  State<StaysPage> createState() => _StaysPageState();
}

class _StaysPageState extends State<StaysPage> {
  int _selectedFilterIndex = 1; // "4.8+ Top Rated" active by default

  final List<StayFilterChipData> _filterChips = const [
    StayFilterChipData(label: 'Under \$120', hasDropdown: true),
    StayFilterChipData(label: '4.8+ Top Rated', icon: Icons.star_rounded),
    StayFilterChipData(label: 'Tea Estate & Forest', icon: Icons.forest_rounded),
    StayFilterChipData(label: 'Free Breakfast', icon: Icons.coffee_rounded),
    StayFilterChipData(label: 'Infinity Pool', icon: Icons.pool_rounded),
    StayFilterChipData(label: 'Eco-Certified', icon: Icons.eco_rounded),
  ];

  final List<StayHaven> _stays = const [
    StayHaven(
      title: '98 Acres Luxury Tea Pavilion',
      location: 'Ella Gap, Badulla · 1.2 km to Ravana Falls',
      rating: 4.96,
      reviewsCount: 340,
      ratingLabel: 'Exceptional',
      pricePerNight: 148,
      feeNote: 'taxes and estate fees included',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA4vF5Vi6-wJ5WCIM27AWVEhd6FYREc7OSSEdKCmAXJK2MXpwJSvGTYeO5vBMTh8vMNT65ogPXz1xWFfEMthgVJrhErItaCXvUl8dvZfsRVuHItTtMGzi9l8-IAOL2qEIHCFDUJ5DtQ8HZFhI3McjzNF1WlpY1k9f4-zguKrzY4Uvm6nAQcEuxTb99anzcl1X9s5DGYA_5a0zc6caeJsJ_7bQa__h7khQlgzmdIPyZ3QBVwVWdVJjiw6g',
      hasPagerDots: true,
      buttonBgColor: HelaColors.tertiaryFixedDim,
      buttonTextColor: HelaColors.primary,
      amenities: [
        StayAmenity(label: 'Infinity Pool', icon: Icons.pool_rounded),
        StayAmenity(label: 'Estate Tea Tour Included', icon: Icons.local_cafe_rounded),
        StayAmenity(label: 'Ayurveda Spa', icon: Icons.spa_rounded),
      ],
    ),
    StayHaven(
      title: 'Amba Organic Farm & Heritage Lodge',
      location: 'Ambagamuwa, Highlands · Mountain View',
      rating: 4.88,
      reviewsCount: 190,
      ratingLabel: 'Eco-Pioneer',
      pricePerNight: 85,
      feeNote: 'Free cancellation · No pre-payment',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAmI8PrdgRx9TUZee-t2Qba4VOjkCo57xxKbbdaJYgEiEdykkKEsbftTlfn2FV2SkbbNrGOYjtig2Lbx_XpBVQPozL700F8w-KVLwYAgRh2JUnKmTe_Ala5iBHzImoF6ROPvPaarQYIQgg5LFtd0uFZEswppS0pcSSaOG6J3cPBiPAweweQjoqyeHo74ceXOW4TxMlKjpmNY0hmuEFiuM5BWsCLtVkZ6iYKKh5DIS2WFQwNZmzLch1qiw',
      buttonBgColor: HelaColors.primaryContainer,
      buttonTextColor: HelaColors.onPrimary,
      amenities: [
        StayAmenity(label: 'Farm-to-Table Dining', icon: Icons.restaurant_rounded),
        StayAmenity(label: 'Waterfalls Trek', icon: Icons.hiking_rounded),
        StayAmenity(label: 'Solar Powered', icon: Icons.solar_power_rounded),
      ],
    ),
    StayHaven(
      title: 'Madulkelle Tea Eco Sanctuary',
      location: 'Knuckles Mountain Range, Kandy',
      rating: 4.92,
      reviewsCount: 215,
      ratingLabel: 'Panoramic Ridge',
      pricePerNight: 195,
      feeNote: 'Estate breakfast & high tea included',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBiuhiB1a4OTsD5h0-pNgyzwhS0ib1JSQEf8ZqosoYyBqnJeVmNPjvFw4T8Do9gacqBs3U2jJJkljl0PKyhHV__3a2q4RdRzbPGQQn4Wh6tBhcwr616wJkRPIlR2NKHl0eTz4qRS6L_bmyEoISTn5yXV5s0zS5ZXYkUwEORd3IZ0TIa9NydgLPGuX2LdvSxaI6JE-T-wTGZElLs_T5iUquRY0KKyAztlQMcm4vYHKJ65bWEyD5VsUKOdQ',
      buttonBgColor: HelaColors.primaryContainer,
      buttonTextColor: HelaColors.onPrimary,
      amenities: [
        StayAmenity(label: 'Luxury Tented Chalet', icon: Icons.cabin_rounded),
        StayAmenity(label: 'Valley Infinity Edge', icon: Icons.landscape_rounded),
      ],
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HelaColors.background,
      appBar: _buildTopAppBar(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 96),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterBar(),
                  _buildResultsMeta(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _stays.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 20),
                      itemBuilder: (context, index) => _buildStayCard(index),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const HelaBottomNavBar(currentIndex: 0),
    );
  }

  PreferredSizeWidget _buildTopAppBar() {
    return AppBar(
      backgroundColor: HelaColors.surface.withValues(alpha: 0.92),
      elevation: 0,
      scrolledUnderElevation: 1.5,
      shadowColor: Colors.black12,
      toolbarHeight: 116,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Back button, Title, Map Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  const Text(
                    'Sanctuaries & Stays',
                    style: TextStyle(
                      color: HelaColors.primary,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Toggling map view...')),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.map_outlined, color: HelaColors.primary, size: 24),
                      ),
                    ),
                  ),
                ],
              ),

              // Search & Date Summary Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: HelaColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: HelaColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.nature_people_rounded,
                      size: 18,
                      color: HelaColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Ella & Central Highlands · Oct 15-18, 2 Guests',
                        style: TextStyle(
                          color: HelaColors.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Editing search criteria...')),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.tune_rounded,
                            size: 18,
                            color: HelaColors.primary,
                          ),
                        ),
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
  }

  Widget _buildFilterBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: HelaColors.surface.withValues(alpha: 0.6),
        border: Border(
          bottom: BorderSide(
            color: HelaColors.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _filterChips.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final filter = _filterChips[index];
            final isSelected = _selectedFilterIndex == index;

            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isSelected ? HelaColors.primaryContainer : HelaColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? HelaColors.primaryContainer
                        : HelaColors.outlineVariant.withValues(alpha: 0.6),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: HelaColors.primaryContainer.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (filter.icon != null) ...[
                      Icon(
                        filter.icon,
                        size: 14,
                        color: isSelected ? HelaColors.tertiaryFixed : HelaColors.secondary,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      filter.label,
                      style: TextStyle(
                        color: isSelected ? HelaColors.onPrimary : HelaColors.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (filter.hasDropdown) ...[
                      const SizedBox(width: 3),
                      Icon(
                        Icons.expand_more_rounded,
                        size: 16,
                        color: isSelected ? HelaColors.onPrimary : HelaColors.onSurfaceVariant,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultsMeta() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '28 Eco-Havens',
                style: TextStyle(
                  color: HelaColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'in Ella & Central Highlands',
                style: TextStyle(
                  color: HelaColors.onSurfaceVariant,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sort options opened')),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: const [
                  Text(
                    'Sort: Recommended',
                    style: TextStyle(
                      color: HelaColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(Icons.swap_vert_rounded, size: 16, color: HelaColors.secondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStayCard(int index) {
    final stay = _stays[index];
    final appState = HelaAppStateProvider.of(context);
    final isBookmarked = appState.isStaySaved(stay.title);

    return StayCard.fromStayHaven(
      stay,
      isBookmarked: isBookmarked,
      onBookmarkTap: () {
        appState.toggleSaveStay(stay);
        final isNowSaved = appState.isStaySaved(stay.title);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isNowSaved
                  ? 'Saved "${stay.title}" to Saved Page'
                  : 'Removed "${stay.title}" from Saved Page',
            ),
            action: isNowSaved
                ? SnackBarAction(
                    label: 'View Saved',
                    textColor: HelaColors.tertiaryFixed,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SavedPage()),
                      );
                    },
                  )
                : null,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onViewTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening details for ${stay.title}')),
        );
      },
    );
  }
}
