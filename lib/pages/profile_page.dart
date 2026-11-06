import 'package:flutter/material.dart';
import 'package:hela/pages/profile/edit_profile_page.dart';
import 'package:hela/pages/home_page.dart';
import 'package:hela/pages/trip_planner_page.dart';
import 'package:hela/pages/saved_page.dart';
import 'package:hela/pages/travel_preferences_page.dart';
import 'package:hela/state/app_state.dart';

/// TripAdvisor-grade professional Profile & Comprehensive Settings Page
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedNavIndex = 4; // "Profile" tab is active in bottom bar
  int _selectedTabIndex = 0; // 0: Settings & Preferences, 1: Saved Itineraries, 2: Badges & Reviews

  // ── Interactive Settings State ───────────────────────────────────────────
  String _currency = 'USD (\$)';
  String _language = 'English (US)';
  String _distanceUnit = 'Kilometers (km)';
  String _travelPace = 'Balanced';
  String _profileVisibility = 'Public (All Explorers)';

  bool _biometricEnabled = true;
  bool _twoFactorEnabled = true;
  bool _pushNotifications = true;
  bool _itineraryAlerts = true;
  bool _dealAlerts = false;
  bool _weatherAlerts = true;
  bool _locationServices = true;
  bool _offlineCache = true;

  // ── Network Image with Robust Error Handling ─────────────────────────────
  Widget _buildNetworkImage(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: HelaColors.primaryContainer,
          child: const Center(
            child: Icon(Icons.person_rounded, color: HelaColors.onPrimaryContainer, size: 36),
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
              constraints: const BoxConstraints(maxWidth: 540),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildTripAdvisorHeroCard(),
                    const SizedBox(height: 14),
                    _buildEcoImpactWidget(),
                    const SizedBox(height: 18),
                    _buildTabNavigation(),
                    const SizedBox(height: 16),
                    _buildActiveTabContent(),
                    const SizedBox(height: 24),
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

  // ── Top App Bar ──────────────────────────────────────────────────────────
  PreferredSizeWidget _buildTopAppBar() {
    return AppBar(
      backgroundColor: HelaColors.surface.withValues(alpha: 0.94),
      elevation: 0,
      scrolledUnderElevation: 1.5,
      shadowColor: Colors.black12,
      toolbarHeight: 60,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: HelaColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.travel_explore_rounded, color: HelaColors.primary, size: 22),
                ),
                const SizedBox(width: 8),
                const Text(
                  'HELA TRAVELER',
                  style: TextStyle(
                    color: HelaColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // Share profile button
                IconButton(
                  tooltip: 'Share Profile',
                  icon: const Icon(Icons.share_outlined, color: HelaColors.primary, size: 21),
                  onPressed: _showShareProfileSheet,
                ),
                // Settings quick switch
                IconButton(
                  tooltip: 'Settings & Preferences',
                  icon: Icon(
                    _selectedTabIndex == 0 ? Icons.settings_rounded : Icons.settings_outlined,
                    color: HelaColors.primary,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() => _selectedTabIndex = 0);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── TripAdvisor Traveler Hero Card ───────────────────────────────────────
  Widget _buildTripAdvisorHeroCard() {
    final appState = HelaAppStateProvider.of(context);
    final displayName = appState.userName.isNotEmpty ? appState.userName : 'Kavinda Wickramasinghe';
    final userTitle = appState.userTitle.isNotEmpty ? appState.userTitle : '🌿 Tea Country Pathfinder · Level 4';
    final userLocation = appState.userLocation.isNotEmpty ? appState.userLocation : 'Kandy, Central Province';
    final userBio = appState.userBio.isNotEmpty
        ? appState.userBio
        : 'Explorer of Ceylon highlands, tea estates, and ancient sanctuaries.';
    final photoUrl = appState.userPhotoUrl ??
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCb49WhjEvtkcNC5SxIgicaFGy0FHajTwhLvSgls2jKJllxIgCm3GtnkBey5ISjUv1a3RBHYRJDux9aTGEuQRD2PRzQ7NQpcvmB23kcn9IUgKDRsKdgyX64gwLDMholuf3EBAmflHGPMYYyBMAcXUVZYTfptDrW3y9Os02is22iH1TXaD6SAOV7pDCQz_K7hNqQjavBUoHUUSiFUtmOeylpDB6d6w3LDISl_r_VyPAoA96T32aE2nQtbA';

    return Container(
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2EBE4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Panoramic Cover Banner ────────────────────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 115,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E3A24), Color(0xFF3B6344), Color(0xFF709876)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1546708973-b339540b5162?w=1200&auto=format&fit=crop&q=80',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.black.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24, width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.photo_camera_outlined, size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Highlands, Sri Lanka',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Overlapping Avatar (TripAdvisor Signature) ──────────────
                Positioned(
                  bottom: -38,
                  left: 18,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const EditProfilePage()),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.14),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _buildNetworkImage(
                              photoUrl,
                              width: 75,
                              height: 75,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: HelaColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Space below banner for overlapping avatar
            const SizedBox(height: 44),

            // ── Profile Body Content ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFC8E6C9)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.verified_rounded, size: 13, color: Color(0xFF2E7D32)),
                            SizedBox(width: 4),
                            Text(
                              'Verified Resident Explorer',
                              style: TextStyle(
                                color: Color(0xFF1B5E20),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFECB3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.military_tech_rounded, size: 14, color: Color(0xFFB78103)),
                            SizedBox(width: 3),
                            Text(
                              'Level 4 Contributor',
                              style: TextStyle(
                                color: Color(0xFF7A5400),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // User Display Name
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: HelaColors.primary,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // Title & Location
                  Text(
                    userTitle,
                    style: const TextStyle(
                      color: HelaColors.secondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 13, color: HelaColors.outline),
                      const SizedBox(width: 3),
                      Text(
                        userLocation,
                        style: const TextStyle(
                          color: HelaColors.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (userBio.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      userBio,
                      style: const TextStyle(
                        color: HelaColors.onSurfaceVariant,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Action Buttons: Edit Profile & Share
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const EditProfilePage()),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined, size: 15),
                          label: const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HelaColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: _showShareProfileSheet,
                        icon: const Icon(Icons.share_outlined, size: 15),
                        label: const Text(
                          'Share',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: HelaColors.primary,
                          side: const BorderSide(color: Color(0xFFCFDCD0), width: 1.2),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ── TripAdvisor Stats Section (Clean & High Contrast) ─────────
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF6F8F6),
                border: Border(
                  top: BorderSide(color: Color(0xFFE5EDE6), width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              child: Row(
                children: [
                  _buildStatItem('12', 'Havens'),
                  _buildDivider(),
                  _buildStatItem('3', 'Expeditions'),
                  _buildDivider(),
                  _buildStatItem('4.9 ★', 'Traveler Score'),
                  _buildDivider(),
                  _buildStatItem('2,450', 'Points'),
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
              color: HelaColors.primary,
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: HelaColors.onSurfaceVariant,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: const Color(0xFFDCE5DD),
    );
  }

  // ── Eco Impact Widget ────────────────────────────────────────────────────
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
            width: 42,
            height: 42,
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
                _showEcoImpactDialog();
              },
              child: const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: HelaColors.primary,
                  size: 19,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab Navigation ───────────────────────────────────────────────────────
  Widget _buildTabNavigation() {
    final tabs = [
      {'label': 'Settings', 'icon': Icons.tune_rounded},
      {'label': 'Saved Itineraries', 'icon': Icons.bookmark_rounded},
      {'label': 'Badges & Stats', 'icon': Icons.military_tech_rounded},
    ];

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2EBE4), width: 1.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          final tab = tabs[index];

          return InkWell(
            onTap: () {
              setState(() => _selectedTabIndex = index);
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 11, left: 8, right: 8),
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
                      const SizedBox(width: 6),
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
                      bottom: -12.5,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: HelaColors.primary,
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

  Widget _buildActiveTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildComprehensiveSettingsView();
      case 1:
        return _buildSavedItinerariesView();
      case 2:
        return _buildBadgesAndReviewsView();
      default:
        return _buildComprehensiveSettingsView();
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // ── TAB 0: COMPREHENSIVE SETTINGS VIEW (TripAdvisor Standard) ─────────────
  // ═════════════════════════════════════════════════════════════════════════
  Widget _buildComprehensiveSettingsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section: Account & Security
        _buildSettingsSectionHeader('Account & Security', Icons.security_rounded),
        _buildSettingsCard([
          _buildSettingsTile(
            icon: Icons.person_outline_rounded,
            title: 'Personal Information',
            subtitle: 'Name, phone, bio & passport details',
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: HelaColors.onSurfaceVariant),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
          ),
          _buildSettingsDivider(),
          _buildSettingsTile(
            icon: Icons.mail_outline_rounded,
            title: 'Email Address',
            subtitle: 'kavinda.w@gmail.com',
            trailing: _buildVerifiedPill(),
          ),
          _buildSettingsDivider(),
          _buildSettingsTile(
            icon: Icons.fingerprint_rounded,
            title: 'Biometric App Lock',
            subtitle: 'Secure app with Fingerprint / Face ID',
            trailing: Switch.adaptive(
              value: _biometricEnabled,
              activeTrackColor: HelaColors.primary,
              onChanged: (val) {
                setState(() => _biometricEnabled = val);
                _showToast(val ? 'Biometric Lock enabled' : 'Biometric Lock disabled');
              },
            ),
          ),
          _buildSettingsDivider(),
          _buildSettingsTile(
            icon: Icons.lock_clock_outlined,
            title: 'Two-Factor Authentication',
            subtitle: 'Extra security for payments & bookings',
            trailing: Switch.adaptive(
              value: _twoFactorEnabled,
              activeTrackColor: HelaColors.primary,
              onChanged: (val) {
                setState(() => _twoFactorEnabled = val);
                _showToast(val ? '2FA Enabled' : '2FA Disabled');
              },
            ),
          ),
        ]),
        const SizedBox(height: 18),

        // Section: Travel Preferences & Localization
        _buildSettingsSectionHeader('Travel & Regional Preferences', Icons.tune_rounded),
        _buildSettingsCard([
          _buildSettingsTile(
            icon: Icons.monetization_on_outlined,
            title: 'Preferred Currency',
            subtitle: _currency,
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: HelaColors.onSurfaceVariant),
            onTap: _showCurrencyPicker,
          ),
          _buildSettingsDivider(),
          _buildSettingsTile(
            icon: Icons.translate_rounded,
            title: 'Language',
            subtitle: _language,
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: HelaColors.onSurfaceVariant),
            onTap: _showLanguagePicker,
          ),
          _buildSettingsDivider(),
          _buildSettingsTile(
            icon: Icons.straighten_rounded,
            title: 'Distance Units',
            subtitle: _distanceUnit,
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: HelaColors.onSurfaceVariant),
            onTap: _showDistanceUnitPicker,
          ),
          _buildSettingsDivider(),
          _buildSettingsTile(
            icon: Icons.explore_outlined,
            title: 'AI Travel Preferences',
            subtitle: 'Dietary needs, stays & vibe',
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: HelaColors.onSurfaceVariant),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TravelPreferencesPage()),
              );
            },
          ),
          _buildSettingsDivider(),
          _buildSettingsTile(
            icon: Icons.speed_rounded,
            title: 'Travel Pacing',
            subtitle: _travelPace,
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: HelaColors.onSurfaceVariant),
            onTap: _showTravelPacePicker,
          ),
        ]),
        const SizedBox(height: 18),

        // Section: Notifications & Alerts
        _buildSettingsSectionHeader('Notifications & Travel Alerts', Icons.notifications_active_outlined),
        _buildSettingsCard([
          _buildSettingsTile(
            icon: Icons.notifications_none_rounded,
            title: 'Push Notifications',
            subtitle: 'Trip updates, messages & reminders',
            trailing: Switch.adaptive(
              value: _pushNotifications,
              activeTrackColor: HelaColors.primary,
              onChanged: (val) {
                setState(() => _pushNotifications = val);
              },
            ),
          ),
          _buildSettingsDivider(),
          _buildSettingsTile(
            icon: Icons.calendar_month_outlined,
            title: 'Itinerary Schedule Alerts',
            subtitle: 'Day-by-day morning briefing & reminders',
            trailing: Switch.adaptive(
              value: _itineraryAlerts,
              activeTrackColor: HelaColors.primary,
              onChanged: (val) {
                setState(() => _itineraryAlerts = val);
              },
            ),
          ),
          _buildSettingsDivider(),
          _buildSettingsTile(
            icon: Icons.local_offer_outlined,
            title: 'Price Drops & Exclusive Deals',
            subtitle: 'Special discounts on boutique stays & rides',
            trailing: Switch.adaptive(
              value: _dealAlerts,
              activeTrackColor: HelaColors.primary,
              onChanged: (val) {
                setState(() => _dealAlerts = val);
              },
            ),
          ),
          _buildSettingsDivider(),
          _buildSettingsTile(
            icon: Icons.cloud_outlined,
            title: 'Weather & Ocean Safety Warnings',
            subtitle: 'Monsoon advisories and surf conditions',
            trailing: Switch.adaptive(
              value: _weatherAlerts,
              activeTrackColor: HelaColors.primary,
              onChanged: (val) {
                setState(() => _weatherAlerts = val);
              },
            ),
          ),
        ]),
        const SizedBox(height: 18),

        // Section: Privacy, Location & Storage
        _buildSettingsSectionHeader('Privacy, Location & Storage', Icons.shield_outlined),
        _buildSettingsCard([
          _buildSettingsTile(
            icon: Icons.visibility_outlined,
            title: 'Profile Visibility',
            subtitle: _profileVisibility,
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: HelaColors.onSurfaceVariant),
            onTap: _showVisibilityPicker,
          ),
          _buildSettingsDivider(),
          _buildSettingsTile(
            icon: Icons.location_searching_rounded,
            title: 'Real-Time Location (GPS)',
            subtitle: 'Used for nearby haven & fair-ride pricing',
            trailing: Switch.adaptive(
              value: _locationServices,
              activeTrackColor: HelaColors.primary,
              onChanged: (val) {
                setState(() => _locationServices = val);
              },
            ),
          ),
          _buildSettingsDivider(),
          _buildSettingsTile(
            icon: Icons.offline_pin_outlined,
            title: 'Offline Maps & Guides Cache',
            subtitle: 'Allow downloading maps for hill country trips',
            trailing: Switch.adaptive(
              value: _offlineCache,
              activeTrackColor: HelaColors.primary,
              onChanged: (val) {
                setState(() => _offlineCache = val);
              },
            ),
          ),
          _buildSettingsDivider(),
          _buildSettingsTile(
            icon: Icons.cleaning_services_outlined,
            title: 'Clear Cache & Temp Data',
            subtitle: '42.8 MB currently cached',
            trailing: const Icon(Icons.delete_outline_rounded, size: 18, color: HelaColors.onSurfaceVariant),
            onTap: _showClearCacheDialog,
          ),
          _buildSettingsDivider(),
          _buildSettingsTile(
            icon: Icons.download_rounded,
            title: 'Download My Travel Data',
            subtitle: 'Export trips, bookmarks & reviews as JSON',
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: HelaColors.onSurfaceVariant),
            onTap: _showExportDataDialog,
          ),
        ]),
        const SizedBox(height: 18),

        // Section: Appearance & Theme
        _buildSettingsSectionHeader('Display & Appearance', Icons.palette_outlined),
        _buildSettingsCard([
          _buildThemeSelectorTile(),
        ]),
        const SizedBox(height: 18),

        // Section: Support, Legal & About
        _buildSettingsSectionHeader('Support, Legal & About', Icons.help_outline_rounded),
        _buildSettingsCard([
          _buildSettingsTile(
            icon: Icons.headset_mic_outlined,
            title: '24/7 Traveler Assistance',
            subtitle: 'Sri Lanka Tourist Police (1912) & Hela Support',
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: HelaColors.onSurfaceVariant),
            onTap: _showSupportDialog,
          ),
          _buildSettingsDivider(),
          _buildSettingsTile(
            icon: Icons.gavel_rounded,
            title: 'Community Guidelines',
            subtitle: 'Ethical & respectful travel standards',
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: HelaColors.onSurfaceVariant),
            onTap: _showCommunityGuidelinesDialog,
          ),
          _buildSettingsDivider(),
          _buildSettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service & Privacy Policy',
            subtitle: 'Legal agreements & data practices',
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: HelaColors.onSurfaceVariant),
            onTap: _showTermsDialog,
          ),
          _buildSettingsDivider(),
          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'App Version',
            subtitle: 'Hela Travel v2.4.2 · Build 2026.11',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: HelaColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Up to date',
                style: TextStyle(
                  color: HelaColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 24),

        // Section: Account Actions (Logout & Delete)
        _buildAccountActionsCard(),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // ── TAB 1: SAVED ITINERARIES (TripAdvisor Style clean access) ─────────────
  // ═════════════════════════════════════════════════════════════════════════
  Widget _buildSavedItinerariesView() {
    final appState = HelaAppStateProvider.of(context);
    final totalCount = appState.totalSavedCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Quick Access Card to Saved Page
        Container(
          decoration: BoxDecoration(
            color: HelaColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2EBE4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: HelaColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bookmark_rounded, color: HelaColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Saved Itineraries & Places',
                            style: TextStyle(
                              color: HelaColors.primary,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            totalCount == 0
                                ? 'No saved items yet. Tap bookmark on any card!'
                                : '$totalCount item${totalCount == 1 ? '' : 's'} bookmarked for your trip',
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SavedPage()),
                      );
                    },
                    icon: const Icon(Icons.bookmark_added_rounded, size: 18),
                    label: const Text(
                      'Open Saved Collection',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HelaColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Category breakdown tiles
        const Text(
          'Saved Breakdown',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: HelaColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildBreakdownCard(
                icon: Icons.landscape_rounded,
                title: 'Havens',
                count: '${appState.savedHavens.length}',
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SavedPage()));
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBreakdownCard(
                icon: Icons.surfing_rounded,
                title: 'Experiences',
                count: '${appState.savedExperiences.length}',
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SavedPage()));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildBreakdownCard(
                icon: Icons.hotel_rounded,
                title: 'Stays',
                count: '${appState.savedStays.length}',
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SavedPage()));
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBreakdownCard(
                icon: Icons.route_rounded,
                title: 'Smart Tours',
                count: '${appState.savedTours.length}',
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SavedPage()));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Helpful Traveler Tip Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: HelaColors.tertiaryFixed.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: HelaColors.tertiaryFixedDim.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.lightbulb_outline_rounded, color: HelaColors.tertiary, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tip: All your saved locations sync automatically across devices. You can also export or share them anytime from the Settings tab.',
                  style: TextStyle(
                    fontSize: 12,
                    color: HelaColors.tertiary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownCard({
    required IconData icon,
    required String title,
    required String count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: HelaColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2EBE4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: HelaColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: HelaColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: HelaColors.primary,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: HelaColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: HelaColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // ── TAB 2: BADGES & REVIEWS (TripAdvisor Explorer Standards) ──────────────
  // ═════════════════════════════════════════════════════════════════════════
  Widget _buildBadgesAndReviewsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Level Progress Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: HelaColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2EBE4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: HelaColors.tertiaryFixed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.military_tech_rounded, color: HelaColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Level 4 Contributor',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: HelaColors.primary,
                            ),
                          ),
                          Text(
                            'Top 5% Sri Lanka Travel Reviewer',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: HelaColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Text(
                    '2,450 / 3,000 pts',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: HelaColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: const LinearProgressIndicator(
                  value: 2450 / 3000,
                  minHeight: 7,
                  backgroundColor: Color(0xFFE2EBE4),
                  valueColor: AlwaysStoppedAnimation<Color>(HelaColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Earn 550 more points by leaving a verified haven review to unlock Level 5 Master Pathfinder status.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: HelaColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Badges Grid
        const Text(
          'Unlocked Explorer Badges',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: HelaColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        _buildBadgeTile(
          icon: Icons.coffee_rounded,
          iconBg: const Color(0xFFD4E8D6),
          title: 'Ceylon Tea Pioneer',
          level: 'Level 4 Badge',
          description: 'Hiked through 5+ tea estates in Nuwara Eliya & Ella Gap',
        ),
        const SizedBox(height: 10),
        _buildBadgeTile(
          icon: Icons.surfing_rounded,
          iconBg: const Color(0xFFCFE5F8),
          title: 'Southern Coast Scout',
          level: 'Level 3 Badge',
          description: 'Explored blue whale sanctuaries & surf bays in Mirissa & Weligama',
        ),
        const SizedBox(height: 10),
        _buildBadgeTile(
          icon: Icons.temple_buddhist_rounded,
          iconBg: const Color(0xFFFDE8C7),
          title: 'Citadel Master',
          level: 'Level 5 Badge',
          description: 'Documented sacred historic shrines across Cultural Triangle',
        ),
        const SizedBox(height: 10),
        _buildBadgeTile(
          icon: Icons.forest_rounded,
          iconBg: const Color(0xFFE3EDBE),
          title: 'Ceylon Eco Guardian',
          level: 'Special Honors',
          description: 'Carbon-neutral explorer with plastic offset credentials',
        ),
      ],
    );
  }

  Widget _buildBadgeTile({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String level,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EBE4)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: HelaColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: HelaColors.primary,
                      ),
                    ),
                    Text(
                      level,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: HelaColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: HelaColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // ── REUSABLE SETTINGS WIDGETS ─────────────────────────────────────────────
  // ═════════════════════════════════════════════════════════════════════════
  Widget _buildSettingsSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: HelaColors.primary),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: HelaColors.primary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2EBE4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: HelaColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: HelaColors.primary, size: 19),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: HelaColors.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: HelaColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF0F3F0),
      indent: 62,
    );
  }

  Widget _buildVerifiedPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE1F5E3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF2E7D32)),
          SizedBox(width: 3),
          Text(
            'Verified',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  // ── Theme Selector Tile ──────────────────────────────────────────────────
  Widget _buildThemeSelectorTile() {
    final appState = HelaAppStateProvider.of(context);
    final currentMode = appState.themeMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: HelaColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.brightness_medium_rounded, color: HelaColors.primary, size: 19),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Theme',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: HelaColors.onSurface,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Select color palette mode',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: HelaColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildThemeOptionPill(
                label: 'Light',
                icon: Icons.light_mode_rounded,
                isSelected: currentMode == ThemeMode.light,
                onTap: () => appState.setThemeMode(ThemeMode.light),
              ),
              const SizedBox(width: 8),
              _buildThemeOptionPill(
                label: 'Dark',
                icon: Icons.dark_mode_rounded,
                isSelected: currentMode == ThemeMode.dark,
                onTap: () => appState.setThemeMode(ThemeMode.dark),
              ),
              const SizedBox(width: 8),
              _buildThemeOptionPill(
                label: 'System',
                icon: Icons.settings_brightness_rounded,
                isSelected: currentMode == ThemeMode.system,
                onTap: () => appState.setThemeMode(ThemeMode.system),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOptionPill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? HelaColors.primary : HelaColors.surfaceContainerHigh.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? HelaColors.primary : const Color(0xFFE2EBE4),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : HelaColors.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : HelaColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Account Actions Card (Log Out & Delete) ──────────────────────────────
  Widget _buildAccountActionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2EBE4)),
      ),
      child: Column(
        children: [
          // Log Out Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              onTap: _showLogoutDialog,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: const [
                    Icon(Icons.logout_rounded, color: Color(0xFFC62828), size: 20),
                    SizedBox(width: 14),
                    Text(
                      'Log Out of Account',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC62828),
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFFC62828)),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F3F0)),
          // Delete Account Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
              onTap: _showDeleteAccountDialog,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: const [
                    Icon(Icons.no_accounts_outlined, color: HelaColors.outline, size: 20),
                    SizedBox(width: 14),
                    Text(
                      'Delete Account & Data',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: HelaColors.outline,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded, size: 13, color: HelaColors.outline),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // ── INTERACTIVE MODAL SHEETS & DIALOGS ────────────────────────────────────
  // ═════════════════════════════════════════════════════════════════════════

  void _showCurrencyPicker() {
    final currencies = [
      {'code': 'USD (\$)', 'name': 'US Dollar'},
      {'code': 'LKR (Rs)', 'name': 'Sri Lankan Rupee'},
      {'code': 'EUR (€)', 'name': 'Euro'},
      {'code': 'GBP (£)', 'name': 'British Pound'},
      {'code': 'AUD (\$)', 'name': 'Australian Dollar'},
      {'code': 'INR (₹)', 'name': 'Indian Rupee'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Currency',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: HelaColors.primary),
                ),
                const SizedBox(height: 12),
                ...currencies.map((c) {
                  final isSelected = _currency == c['code'];
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${c['code']} - ${c['name']}',
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? HelaColors.primary : HelaColors.onSurface,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: HelaColors.primary)
                        : null,
                    onTap: () {
                      setState(() => _currency = c['code']!);
                      Navigator.pop(ctx);
                      _showToast('Currency set to $_currency');
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTravelPacePicker() {
    final paces = [
      {'pace': 'Relaxed', 'desc': 'Slow, mindful travel with plenty of leisure time'},
      {'pace': 'Balanced', 'desc': 'Comfortable balance of excursions and downtime'},
      {'pace': 'High-Energy Adventurer', 'desc': 'Action-packed daily itineraries with sunrise hikes'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Travel Pacing',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: HelaColors.primary),
                ),
                const SizedBox(height: 12),
                ...paces.map((p) {
                  final isSelected = _travelPace == p['pace'];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      p['pace']!,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? HelaColors.primary : HelaColors.onSurface,
                      ),
                    ),
                    subtitle: Text(p['desc']!, style: const TextStyle(fontSize: 12)),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: HelaColors.primary)
                        : null,
                    onTap: () {
                      setState(() => _travelPace = p['pace']!);
                      Navigator.pop(ctx);
                      _showToast('Pace set to $_travelPace');
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguagePicker() {
    final languages = [
      'English (US)',
      'සිංහල (Sinhala)',
      'தமிழ் (Tamil)',
      'Français (French)',
      'Deutsch (German)',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Language',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: HelaColors.primary),
                ),
                const SizedBox(height: 12),
                ...languages.map((lang) {
                  final isSelected = _language == lang;
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      lang,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? HelaColors.primary : HelaColors.onSurface,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: HelaColors.primary)
                        : null,
                    onTap: () {
                      setState(() => _language = lang);
                      Navigator.pop(ctx);
                      _showToast('Language updated to $lang');
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDistanceUnitPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Distance & Measurements',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: HelaColors.primary),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Kilometers (km) - Sri Lanka standard'),
                  trailing: _distanceUnit == 'Kilometers (km)'
                      ? const Icon(Icons.check_circle_rounded, color: HelaColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _distanceUnit = 'Kilometers (km)');
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  title: const Text('Miles (mi) - Imperial'),
                  trailing: _distanceUnit == 'Miles (mi)'
                      ? const Icon(Icons.check_circle_rounded, color: HelaColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _distanceUnit = 'Miles (mi)');
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showVisibilityPicker() {
    final options = [
      'Public (All Explorers)',
      'Verified Travelers Only',
      'Private (Only Me)',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile Visibility',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: HelaColors.primary),
                ),
                const SizedBox(height: 12),
                ...options.map((opt) {
                  final isSelected = _profileVisibility == opt;
                  return ListTile(
                    title: Text(opt),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: HelaColors.primary)
                        : null,
                    onTap: () {
                      setState(() => _profileVisibility = opt);
                      Navigator.pop(ctx);
                      _showToast('Visibility set to $opt');
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Clear App Cache?'),
        content: const Text(
          'This will remove temporary map tiles, cached photo previews, and offline itineraries. Your saved bookmarks will remain safe.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HelaColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _showToast('Cache cleared successfully! 42.8 MB freed.');
            },
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Export Travel Data'),
        content: const Text(
          'Your profile information, saved havens, custom AI itineraries, and Ceylon eco-pledge records have been prepared for export as encrypted JSON.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: HelaColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Download File'),
            onPressed: () {
              Navigator.pop(ctx);
              _showToast('Travel archive downloaded: hela_data_backup.json');
            },
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: const [
            Icon(Icons.headset_mic_rounded, color: HelaColors.primary),
            SizedBox(width: 8),
            Text('Traveler Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Emergency Contacts in Sri Lanka:',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text('• Tourist Police Hotline: 1912 (24/7)'),
            Text('• Police Emergency: 119'),
            Text('• National Ambulance Service: 1990'),
            SizedBox(height: 12),
            Text(
              'Hela Traveler Concierge:',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text('• In-App Live Support: support@hela.travel'),
            Text('• Dedicated WhatsApp: +94 77 123 4567'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showCommunityGuidelinesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Community Guidelines'),
        content: const SingleChildScrollView(
          child: Text(
            '1. Respect Cultural Heritage:\nAlways dress modestly at temples, remove footwear and headgear, and do not pose with your back to sacred statues.\n\n'
            '2. Protect Wildlife:\nMaintain safe distances in Yala, Udawalawe, and ocean whale watching. Never feed wild elephants.\n\n'
            '3. Genuine Reviews:\nShare authentic, firsthand experiences to help fellow explorers navigate Ceylon fairly.\n\n'
            '4. Support Local Communities:\nEncourage fair wages for local drivers, tuk-tuk guides, and artisan tea pluckers.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Terms & Privacy'),
        content: const Text(
          'Hela is committed to traveler privacy and fair-ride transparency. We protect your location data, do not sell private information to third parties, and guarantee transparent, unmanipulated meter rates for island travel.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Log Out of Hela?'),
        content: const Text(
          'Are you sure you want to log out? Your saved trips, eco-pledge records, and preferences are safely synchronized to the cloud.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _showToast('You have been logged out.');
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Account?'),
        content: const Text(
          'This action is irreversible. All your custom itineraries, review contributions, and Ceylon points will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFC62828)),
            onPressed: () {
              Navigator.pop(ctx);
              _showToast('Account deletion request submitted.');
            },
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  void _showShareProfileSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Share Explorer Profile',
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: HelaColors.primary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Share your verified traveler passport & reviews with friends:',
                style: TextStyle(fontSize: 12.5, color: HelaColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: HelaColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link_rounded, size: 20, color: HelaColors.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'https://hela.travel/@kavinda_w',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HelaColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showToast('Profile link copied to clipboard!');
                      },
                      child: const Text('Copy', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showEcoImpactDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: const [
            Icon(Icons.eco_rounded, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text('Ceylon Eco-Impact'),
          ],
        ),
        content: const Text(
          'Through Hela\'s sustainable partnership with local environmental conservation groups across Sri Lanka, your trips contribute directly to removing non-biodegradable plastics from sacred trailheads and protecting coral reefs in the south.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        persist: false,
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Bottom Navigation Bar ────────────────────────────────────────────────
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest.withValues(alpha: 0.96),
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
                    MaterialPageRoute(builder: (_) => const SavedPage()),
                  );
                },
              ),
              _buildNavItem(
                index: 2,
                label: 'Discover',
                icon: Icons.travel_explore_outlined,
                activeIcon: Icons.travel_explore_rounded,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const TravelPreferencesPage()),
                  );
                },
              ),
              _buildNavItem(
                index: 3,
                label: 'Journeys',
                icon: Icons.route_outlined,
                activeIcon: Icons.route_rounded,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const TripPlannerPage()),
                  );
                },
              ),
              _buildNavItem(
                index: 4,
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
