import 'package:flutter/material.dart';
import 'package:hela/pages/home_page.dart';
import 'package:hela/pages/trip_planner_page.dart';
import 'package:hela/pages/stays_page.dart';
import 'package:hela/state/app_state.dart';

/// Data models for Profile & Saved Trips
class SavedTripCardData {
  final String title;
  final String routeSubtitle;
  final String durationText;
  final String badgeText;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final IconData badgeIcon;
  final IconData routeIcon;
  final String progressText;
  final double progressValue;
  final Color progressColor;
  final String statusText;
  final IconData? statusIcon;
  final String buttonText;
  final Color buttonBgColor;
  final Color buttonTextColor;
  final bool isButtonOutlined;
  final String imageUrl;

  const SavedTripCardData({
    required this.title,
    required this.routeSubtitle,
    required this.durationText,
    required this.badgeText,
    required this.badgeBgColor,
    required this.badgeTextColor,
    required this.badgeIcon,
    required this.routeIcon,
    required this.progressText,
    required this.progressValue,
    required this.progressColor,
    required this.statusText,
    this.statusIcon,
    required this.buttonText,
    required this.buttonBgColor,
    required this.buttonTextColor,
    this.isButtonOutlined = false,
    required this.imageUrl,
  });
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedNavIndex = 3; // "Profile" tab is active by default
  int _selectedTabIndex = 0; // 0: Saved Itineraries, 1: Booking History, 2: Rewards
  final Set<int> _bookmarkedTrips = {0, 1, 2};

  final List<SavedTripCardData> _savedTrips = const [
    SavedTripCardData(
      title: 'Highland Sanctuary & Mist Route',
      routeSubtitle: 'Ella to Nuwara Eliya',
      durationText: 'Departing Nov 12, 2025 · 5 Days',
      badgeText: 'Upcoming',
      badgeBgColor: HelaColors.tertiaryFixed,
      badgeTextColor: HelaColors.onTertiaryFixed,
      badgeIcon: Icons.schedule_rounded,
      routeIcon: Icons.route_rounded,
      progressText: '75% Planned',
      progressValue: 0.75,
      progressColor: HelaColors.primary,
      statusText: '3 of 4 Stays Confirmed',
      statusIcon: Icons.check_circle_rounded,
      buttonText: 'View Itinerary',
      buttonBgColor: HelaColors.tertiaryFixed,
      buttonTextColor: HelaColors.onTertiaryFixed,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCXroS8KSMz2LNtBOBqIw_XXE6QnIOZHnIjabVLSU6yAbv9YxBwAfjjFXsjpMN6UtHRmDd_SDEeydujaML8L-ltgoDLBNiFfy0vhzWCNlFJFkjVNQgMRfGEcOdFXwhr7EohL4oG_xvw1IMUndxs5bqXUlOA_LotH8L66CuiD98M333oxQft_v3S4KFWPpZBINjLV4ud71F7heY2uyEuCGtmcWS_KFI5qltVNgp5X8oDLdklFB0PEnsh2w',
    ),
    SavedTripCardData(
      title: 'Sacred Cultural Triangle Expedition',
      routeSubtitle: '2 days saved in drafts',
      durationText: 'Sigiriya & Dambulla · 4 Days',
      badgeText: 'Draft Itinerary',
      badgeBgColor: Colors.black45,
      badgeTextColor: Colors.white,
      badgeIcon: Icons.edit_calendar_rounded,
      routeIcon: Icons.hotel_rounded,
      progressText: '40% Complete',
      progressValue: 0.40,
      progressColor: HelaColors.secondary,
      statusText: 'Next: Select Heritage Lodge',
      buttonText: 'Continue Planning',
      buttonBgColor: HelaColors.primaryContainer,
      buttonTextColor: HelaColors.onPrimary,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDgOYedH7-ydEeYXkRTFJwk1V4codyhWik4hOcCqE7tOBbIcR_XDEBqt-EYH8gcoHqtRjOxZ19JeoVs6w6cG7g8MnLX4FUJ1fAABo_0lVOfSFqQH9iP4oTVuZhdMXG5Sq80jWeVctsbSxG7yoMwpLK_8NFHYryureu_QY5fUK5R59ot_td9m8TbeMOjTn_kkVgF3Hk1dPYCTIl7n1V7plw-WOOUtgy8l_Wt0iQFvqMItMxsxUg9nR9jGA',
    ),
    SavedTripCardData(
      title: 'Southern Coast & Whale Trail',
      routeSubtitle: 'Mirissa to Galle Fort',
      durationText: 'Completed March 2025 · 3 Days',
      badgeText: 'Past Journey',
      badgeBgColor: Color(0xD92F4A34),
      badgeTextColor: HelaColors.secondaryFixed,
      badgeIcon: Icons.task_alt_rounded,
      routeIcon: Icons.sailing_rounded,
      progressText: '100% Completed',
      progressValue: 1.0,
      progressColor: HelaColors.primary,
      statusText: '24 Photos Archived',
      statusIcon: Icons.photo_camera_rounded,
      buttonText: 'Trip Memories',
      buttonBgColor: Colors.transparent,
      buttonTextColor: HelaColors.primary,
      isButtonOutlined: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAoH9xCf6GfInbX7AbZwXivccuabug63np00zlZux6K6x_Ka5ncZ_IMpfT2T_lkskmEzAHk_9KX6oJ7UrsqqpGMNKNeUMG-7MAJsNEbYBYhK7S4VwAVg8Et7s1mhZ5WL-8RRtOYwPffvjhBSrSgZgcK-AV6YHRbvMCWI617maSfVKe4fS8AyycvJN1loR8x2823OQo0vuTRWVQMfm-_xnUtUmmpfsOl4Gfia7eh-vlhJNRBChaMxSKk5Q',
    ),
  ];

  Widget _buildNetworkImage(String url, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: HelaColors.surfaceContainerHigh,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: HelaColors.secondary,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [HelaColors.primaryContainer, HelaColors.primary],
            ),
          ),
          child: const Center(
            child: Icon(Icons.image_outlined, color: HelaColors.onPrimaryContainer, size: 32),
          ),
        );
      },
    );
  }

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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildProfileHeaderCard(),
                    const SizedBox(height: 16),
                    _buildEcoImpactWidget(),
                    const SizedBox(height: 20),
                    _buildTabNavigation(),
                    const SizedBox(height: 16),
                    _buildTabContent(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
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
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Menu tapped')),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.menu_rounded, color: HelaColors.primary, size: 24),
                ),
              ),
            ),
            const Text(
              'HELA',
              style: TextStyle(
                color: HelaColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No new notifications')),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.notifications_outlined, color: HelaColors.primary, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard() {
    return Container(
      decoration: BoxDecoration(
        color: HelaColors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: HelaColors.primaryContainer.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative Mandala Radial Circles
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: HelaColors.tertiaryFixedDim.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: HelaColors.tertiaryFixedDim.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            // Card Inner Content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Verified Badge & Settings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: HelaColors.tertiaryFixed,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Verified Resident Explorer',
                              style: TextStyle(
                                color: HelaColors.tertiaryFixed,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening settings...')),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(7.0),
                            child: Icon(
                              Icons.settings_rounded,
                              size: 18,
                              color: HelaColors.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Avatar & Name & Role
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar with gradient border & floral badge
                      Stack(
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            padding: const EdgeInsets.all(2.5),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFB8C34A), Color(0xFF7FA88A)],
                              ),
                            ),
                            child: ClipOval(
                              child: _buildNetworkImage(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuCb49WhjEvtkcNC5SxIgicaFGy0FHajTwhLvSgls2jKJllxIgCm3GtnkBey5ISjUv1a3RBHYRJDux9aTGEuQRD2PRzQ7NQpcvmB23kcn9IUgKDRsKdgyX64gwLDMholuf3EBAmflHGPMYYyBMAcXUVZYTfptDrW3y9Os02is22iH1TXaD6SAOV7pDCQz_K7hNqQjavBUoHUUSiFUtmOeylpDB6d6w3LDISl_r_VyPAoA96T32aE2nQtbA',
                                width: 72,
                                height: 72,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Color(0xFFB8C34A),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.local_florist_rounded,
                                size: 15,
                                color: HelaColors.tertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      // Name, Badge & Edit Button
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Builder(
                              builder: (context) {
                                String displayName = 'Kavinda Wickramasinghe';
                                try {
                                  final appState = HelaAppStateProvider.of(context);
                                  if (appState.isAuthenticated) {
                                    displayName = appState.userName;
                                  }
                                } catch (_) {}
                                return Text(
                                  displayName,
                                  style: const TextStyle(
                                    color: HelaColors.onPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              '🌿 Tea Country Pathfinder · Level 4',
                              style: TextStyle(
                                color: HelaColors.secondaryFixed,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Edit Profile tapped')),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.edit_rounded,
                                      size: 13,
                                      color: HelaColors.onPrimary,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        color: HelaColors.onPrimary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Quick Stats Row (3 Columns)
                  Container(
                    padding: const EdgeInsets.only(top: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildStatItem('3', 'Expeditions'),
                        Container(
                          width: 1,
                          height: 28,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        _buildStatItem('12', 'Havens Visited'),
                        Container(
                          width: 1,
                          height: 28,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        _buildStatItem('2,450', 'Ceylon Points'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
              color: HelaColors.tertiaryFixed,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9AB99D),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoImpactWidget() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2EBE4),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2E24).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: HelaColors.secondaryFixed,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.eco_rounded,
                color: HelaColors.primary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Ceylon Eco-Pledge',
                      style: TextStyle(
                        color: HelaColors.primary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFB8C34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  '14 kg plastic offset across your trips',
                  style: TextStyle(
                    color: HelaColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Viewing Eco-Impact Certificate...')),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: HelaColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    final tabs = [
      {'label': 'Saved Itineraries', 'icon': Icons.bookmark_rounded},
      {'label': 'Booking History', 'icon': Icons.history_rounded},
      {'label': 'Rewards', 'icon': Icons.military_tech_rounded},
    ];

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2EBE4), width: 1.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          final tab = tabs[index];

          return InkWell(
            onTap: () {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab['icon'] as IconData,
                        size: 17,
                        color: isSelected ? HelaColors.primary : HelaColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        tab['label'] as String,
                        style: TextStyle(
                          color: isSelected ? HelaColors.primary : HelaColors.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (isSelected)
                    Positioned(
                      bottom: -11.5,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB8C34A),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedTabIndex == 1) {
      return Container(
        padding: const EdgeInsets.all(28),
        alignment: Alignment.center,
        child: Column(
          children: const [
            Icon(Icons.history_rounded, size: 40, color: HelaColors.secondary),
            SizedBox(height: 8),
            Text(
              'No recent bookings',
              style: TextStyle(
                color: HelaColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Your completed and active reservations will appear here.',
              style: TextStyle(
                color: HelaColors.onSurfaceVariant,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else if (_selectedTabIndex == 2) {
      return Container(
        padding: const EdgeInsets.all(28),
        alignment: Alignment.center,
        child: Column(
          children: const [
            Icon(Icons.military_tech_rounded, size: 40, color: HelaColors.tertiaryFixedDim),
            SizedBox(height: 8),
            Text(
              '2,450 Ceylon Points',
              style: TextStyle(
                color: HelaColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Earn 200 more points to reach Pathfinder Level 5.',
              style: TextStyle(
                color: HelaColors.onSurfaceVariant,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Default: Saved Itineraries
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _savedTrips.length,
      separatorBuilder: (context, index) => const SizedBox(height: 18),
      itemBuilder: (context, index) => _buildSavedTripCard(index),
    );
  }

  Widget _buildSavedTripCard(int index) {
    final trip = _savedTrips[index];
    final isBookmarked = _bookmarkedTrips.contains(index);

    return Container(
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2EBE4),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2E24).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image Banner
            SizedBox(
              height: 176,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _buildNetworkImage(
                      trip.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Dark Vignette Gradient
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.4, 0.7, 1.0],
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Top-Left Status Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: trip.badgeBgColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            trip.badgeIcon,
                            size: 13,
                            color: trip.badgeTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            trip.badgeText,
                            style: TextStyle(
                              color: trip.badgeTextColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top-Right Bookmark Button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          setState(() {
                            if (isBookmarked) {
                              _bookmarkedTrips.remove(index);
                            } else {
                              _bookmarkedTrips.add(index);
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: Icon(
                            isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Title & Duration Over Image
                  Positioned(
                    bottom: 12,
                    left: 14,
                    right: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 13,
                              color: HelaColors.tertiaryFixed,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              trip.durationText,
                              style: const TextStyle(
                                color: HelaColors.tertiaryFixed,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          trip.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Card Body Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            trip.routeIcon,
                            size: 16,
                            color: HelaColors.secondary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            trip.routeSubtitle,
                            style: const TextStyle(
                              color: HelaColors.onSurfaceVariant,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        trip.progressText,
                        style: const TextStyle(
                          color: HelaColors.primary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: trip.progressValue,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE2EBE4),
                      valueColor: AlwaysStoppedAnimation<Color>(trip.progressColor),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bottom Action Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (trip.statusIcon != null) ...[
                            Icon(
                              trip.statusIcon,
                              size: 15,
                              color: HelaColors.secondary,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            trip.statusText,
                            style: const TextStyle(
                              color: HelaColors.onSurfaceVariant,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trip.isButtonOutlined
                          ? OutlinedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Opening ${trip.buttonText} for ${trip.title}')),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: trip.buttonTextColor,
                                side: const BorderSide(color: Color(0xFFE2EBE4)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                trip.buttonText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Opening ${trip.buttonText} for ${trip.title}')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: trip.buttonBgColor,
                                foregroundColor: trip.buttonTextColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                trip.buttonText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore_rounded,
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
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const TripPlannerPage()),
                  );
                },
              ),
              _buildNavItem(
                index: 3,
                label: 'Profile',
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
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
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? HelaColors.primary : HelaColors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive ? HelaColors.primary : HelaColors.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: HelaColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
