import 'package:flutter/material.dart';
import 'package:hela/pages/ask_hela/ask_hela_page.dart';
import 'package:hela/pages/auth/signup_page.dart';
import 'package:hela/pages/bookings/bookings_page.dart';
import 'package:hela/pages/profile/edit_profile_page.dart';
import 'package:hela/pages/saved/saved_page.dart';
import 'package:hela/services/insforge_auth_service.dart';
import 'package:hela/l10n/localization_service.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/theme/hela_colors.dart';
import 'package:hela/widgets/navigation/hela_bottom_nav_bar.dart';
import 'package:hela/widgets/common/hela_logo.dart';
import 'package:hela/widgets/common/language_picker_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

/// HELA Traveler Profile, Travel Hub, Preferences & 24/7 Assistance Page.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color _mintPageBg = Color(0xFFEAF8F4);
  static const Color _deepTeal = Color(0xFF0B4D42);
  static const Color _darkInk = Color(0xFF0B2D25);
  static const Color _mutedTeal = Color(0xFF4C756A);
  static const Color _softMintTile = Color(0xFFE5F4F0);
  static const Color _cardBorder = Color(0xFFDCEEE8);

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
          color: const Color(0xFFD4EFE7),
          child: const Center(
            child: Icon(Icons.person_rounded, color: _deepTeal, size: 30),
          ),
        );
      },
    );
  }

  String _countryCodeFromPhone(String phone) {
    final trimmed = phone.trim();
    if (trimmed.startsWith('+94')) return 'LK';
    if (trimmed.startsWith('+44')) return 'GB';
    if (trimmed.startsWith('+1')) return 'US';
    if (trimmed.startsWith('+61')) return 'AU';
    if (trimmed.startsWith('+91')) return 'IN';
    return 'LK';
  }

  Future<void> _dialNumber(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    try {
      final launched = await launchUrl(uri);
      if (!launched && mounted) {
        _showToast('Emergency hotline: Dial $number');
      }
    } catch (_) {
      if (mounted) {
        _showToast('Emergency hotline: Dial $number');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = HelaAppStateProvider.of(context);
    final colors = HelaColors.of(context);
    final isDark = colors.isDark;

    return Scaffold(
      backgroundColor: isDark ? colors.surface : _mintPageBg,
      appBar: _buildTopAppBar(appState, colors, isDark),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroProfileCard(appState, colors, isDark),
                  const SizedBox(height: 20),
                  _buildSectionHeader(
                    appState.tr('my_travel_hub'),
                    appState.tr('active_passports_itineraries'),
                    colors,
                  ),
                  const SizedBox(height: 10),
                  _buildTravelHubCard(appState, colors, isDark),
                  const SizedBox(height: 22),
                  _buildSectionHeader(
                    appState.tr('preferences'),
                    appState.tr('locale_connectivity'),
                    colors,
                  ),
                  const SizedBox(height: 10),
                  _buildPreferencesCard(appState, colors, isDark),
                  const SizedBox(height: 22),
                  _buildSectionHeader(
                    appState.tr('assistance_legal'),
                    appState.tr('support_24_7_active'),
                    colors,
                    trailingColor: const Color(0xFF0F766E),
                  ),
                  const SizedBox(height: 10),
                  _buildAssistanceLegalCard(appState, colors, isDark),
                  const SizedBox(height: 18),
                  _buildLogoutButton(appState, isDark),
                  const SizedBox(height: 18),
                  _buildFooterBranding(appState, colors),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const HelaBottomNavBar(currentIndex: 4),
    );
  }

  // ── Top App Bar ──────────────────────────────────────────────────────────
  PreferredSizeWidget _buildTopAppBar(
    HelaAppState appState,
    HelaColorPalette colors,
    bool isDark,
  ) {
    return AppBar(
      backgroundColor: isDark ? colors.surface : _mintPageBg,
      elevation: 0,
      scrolledUnderElevation: 1,
      toolbarHeight: 64,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Text(
        appState.tr('profile'),
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: isDark ? colors.onSurface : _darkInk,
          letterSpacing: -0.8,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
      actions: const [
        SizedBox(width: 16),
      ],
    );
  }

  // ── 1. Hero Profile Card ─────────────────────────────────────────────────
  Widget _buildHeroProfileCard(
    HelaAppState appState,
    HelaColorPalette colors,
    bool isDark,
  ) {
    final displayName = appState.userName.isNotEmpty
        ? appState.userName
        : 'Kavinda Wickramasinghe';
    final displayEmail = appState.userEmail.isNotEmpty
        ? appState.userEmail
        : 'kavinda.w@gmail.com';
    final displayPhone = appState.userPhone.isNotEmpty
        ? appState.userPhone
        : '+94 77 123 4567';
    final displayLocation = appState.userLocation.isNotEmpty
        ? appState.userLocation
        : 'Colombo, Sri Lanka';
    final displayTitle = (appState.userTitle.isNotEmpty
            ? appState.userTitle
            : 'Sri Lanka Traveler')
        .replaceAll('🌿', '')
        .trim();
    final currencyCode = appState.preferredCurrency.split(' ').first;
    final photoUrl =
        appState.userPhotoUrl ??
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80';
    final destinationsCount = 7 + appState.savedHavens.length;
    final tripsCount = appState.savedTours.length;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colors.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? colors.architecturalBorder : _cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B4D42).withValues(alpha: isDark ? 0.22 : 0.08),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Emerald Passport Header ───────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const [Color(0xFF0A3830), Color(0xFF105246)]
                      : const [Color(0xFF0A473D), Color(0xFF13685A)],
                ),
              ),
              child: Stack(
                children: [
                  // Subtle decorative glow circles
                  Positioned(
                    top: -28,
                    right: -22,
                    child: Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -36,
                    left: -18,
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF34D399).withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar + Badges, Name & Location
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const EditProfilePage(),
                                  ),
                                );
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 68,
                                    height: 68,
                                    padding: const EdgeInsets.all(2.5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: _buildNetworkImage(
                                        photoUrl,
                                        width: 62,
                                        height: 62,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: -2,
                                    bottom: -2,
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF0C5246),
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.verified_rounded,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.4,
                                      height: 1.15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        size: 13.5,
                                        color: const Color(0xFF6EE7B7),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          displayLocation,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withValues(alpha: 0.86),
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
                        const SizedBox(height: 14),

                        // Frosted Personal Details & Contact Card
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.11),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Traveler ID
                              Row(
                                children: [
                                  Icon(
                                    Icons.badge_outlined,
                                    size: 14.5,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      appState.tr('sltda_id'),
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withValues(alpha: 0.94),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Contact Email & Phone
                              Row(
                                children: [
                                  Icon(
                                    Icons.mail_outline_rounded,
                                    size: 14.5,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      displayEmail,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withValues(alpha: 0.94),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      _countryCodeFromPhone(displayPhone),
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      displayPhone,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withValues(alpha: 0.94),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                child: Divider(
                                  height: 1,
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                              ),

                              // 2-Column Traveler Role & Preferences Row
                              IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'TRAVELER ROLE',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.6,
                                              color: Colors.white.withValues(alpha: 0.65),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            displayTitle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      margin: const EdgeInsets.symmetric(horizontal: 10),
                                      color: Colors.white.withValues(alpha: 0.16),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'LANG · CURRENCY',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.6,
                                              color: Colors.white.withValues(alpha: 0.65),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${appState.selectedLanguage} · $currencyCode',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Stats Strip & Edit Profile CTA ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? colors.surfaceContainer
                          : const Color(0xFFF3FAF7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? colors.architecturalBorder
                            : const Color(0xFFD7EDE5),
                      ),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatBox(
                              icon: Icons.wb_sunny_rounded,
                              iconColor: const Color(0xFFD97706),
                              iconBg: const Color(0xFFFEF3C7),
                              value: '14',
                              label: appState.tr('days_in_lanka'),
                              isDark: isDark,
                              colors: colors,
                            ),
                          ),
                          Container(
                            width: 1,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: isDark
                                ? colors.architecturalBorder
                                : const Color(0xFFD2E8DF),
                          ),
                          Expanded(
                            child: _buildStatBox(
                              icon: Icons.explore_rounded,
                              iconColor: _deepTeal,
                              iconBg: const Color(0xFFDDF3EC),
                              value: '$destinationsCount',
                              label: appState.tr('destinations_stat'),
                              isDark: isDark,
                              colors: colors,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SavedPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            width: 1,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: isDark
                                ? colors.architecturalBorder
                                : const Color(0xFFD2E8DF),
                          ),
                          Expanded(
                            child: _buildStatBox(
                              icon: Icons.route_rounded,
                              iconColor: const Color(0xFF0284C7),
                              iconBg: const Color(0xFFE0F2FE),
                              value: '$tripsCount',
                              label: 'Saved Trips',
                              isDark: isDark,
                              colors: colors,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SavedPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            width: 1,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: isDark
                                ? colors.architecturalBorder
                                : const Color(0xFFD2E8DF),
                          ),
                          Expanded(
                            child: _buildStatBox(
                              icon: Icons.eco_rounded,
                              iconColor: const Color(0xFF059669),
                              iconBg: const Color(0xFFD1FAE5),
                              value: '100%',
                              label: appState.tr('carbon_offset'),
                              isDark: isDark,
                              colors: colors,
                              onTap: _showEcoImpactDialog,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Edit Personal Profile Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EditProfilePage(),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.edit_note_rounded,
                        size: 20,
                        color: isDark ? colors.onSecondaryContainer : _deepTeal,
                      ),
                      label: Text(
                        appState.tr('edit_personal_profile'),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? colors.onSecondaryContainer : _deepTeal,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? colors.secondaryContainer
                            : const Color(0xFFE7F5F0),
                        elevation: 0,
                        side: BorderSide(
                          color: isDark
                              ? colors.architecturalBorder
                              : const Color(0xFFC7E6DC),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
    required bool isDark,
    required HelaColorPalette colors,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDark ? iconColor.withValues(alpha: 0.18) : iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 14,
                color: isDark ? iconBg : iconColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isDark ? colors.onSurface : _darkInk,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                height: 1.15,
                fontWeight: FontWeight.w600,
                color: isDark ? colors.onSurfaceVariant : _mutedTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Header ───────────────────────────────────────────────────────
  Widget _buildSectionHeader(
    String title,
    String subtitle,
    HelaColorPalette colors, {
    Color? trailingColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: colors.isDark ? colors.onSurface : _darkInk,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color:
                  trailingColor ??
                  (colors.isDark ? colors.onSurfaceVariant : _mutedTeal),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. MY TRAVEL HUB Card ────────────────────────────────────────────────
  Widget _buildTravelHubCard(
    HelaAppState appState,
    HelaColorPalette colors,
    bool isDark,
  ) {
    final savedDestCount = appState.savedHavens.isNotEmpty
        ? appState.savedHavens.length
        : 12;
    final savedDestSubtitle = appState.savedHavens.isNotEmpty
        ? appState.savedHavens.map((h) => h.title).take(3).join(', ')
        : 'Mirissa, Sigiriya, Ella & Galle';

    final savedToursCount = appState.savedTours.isNotEmpty
        ? appState.savedTours.length
        : 3;
    final savedToursSubtitle = appState.savedTours.isNotEmpty
        ? appState.savedTours.map((t) => t.title).take(2).join(' · ')
        : 'Scenic Rail & Heritage Loops';

    return _buildGroupedCard(
      colors: colors,
      isDark: isDark,
      children: [
        _buildHubRow(
          icon: Icons.bookmark_outline_rounded,
          title: appState.tr('saved_destinations'),
          subtitle: savedDestSubtitle,
          badgeText: '$savedDestCount ${appState.tr('places_count')}',
          isDark: isDark,
          colors: colors,
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SavedPage()));
          },
        ),
        _buildRowDivider(isDark, colors),
        _buildHubRow(
          icon: Icons.map_outlined,
          title: appState.tr('saved_itineraries'),
          subtitle: savedToursSubtitle,
          badgeText: '$savedToursCount ${appState.tr('trips_count')}',
          isDark: isDark,
          colors: colors,
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SavedPage()));
          },
        ),
        _buildRowDivider(isDark, colors),
        _buildHubRow(
          icon: Icons.confirmation_number_outlined,
          title: appState.tr('my_active_bookings'),
          subtitle: 'Blue Train 1st Class & Villa',
          badgeText: '2 ${appState.tr('upcoming_count')}',
          isPrimaryBadge: true,
          isDark: isDark,
          colors: colors,
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const BookingsPage()));
          },
        ),
        _buildRowDivider(isDark, colors),
        _buildHubRow(
          icon: Icons.history_rounded,
          title: appState.tr('island_travel_history'),
          subtitle: '5 past rides, safaris & homestays',
          isDark: isDark,
          colors: colors,
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const BookingsPage()));
          },
        ),
      ],
    );
  }

  // ── 4. PREFERENCES Card ──────────────────────────────────────────────────
  Widget _buildPreferencesCard(
    HelaAppState appState,
    HelaColorPalette colors,
    bool isDark,
  ) {
    final activeLangName = LocalizationService.getLanguage(
      appState.selectedLanguage,
    ).nativeName;
    final isUsd = appState.preferredCurrency.startsWith('USD');

    return _buildGroupedCard(
      colors: colors,
      isDark: isDark,
      children: [
        // Language
        _buildRowShell(
          icon: Icons.translate_rounded,
          title: appState.tr('language'),
          subtitle: appState.tr('language_sub'),
          isDark: isDark,
          colors: colors,
          onTap: _showLanguagePicker,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                activeLangName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? colors.onSurface : _darkInk,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.unfold_more_rounded,
                size: 16,
                color: isDark ? colors.onSurfaceVariant : _mutedTeal,
              ),
            ],
          ),
        ),
        _buildRowDivider(isDark, colors),

        // Currency Display Segmented Toggle
        _buildRowShell(
          icon: Icons.currency_exchange_rounded,
          title: appState.tr('currency_display'),
          subtitle: appState.tr('dual_live_rate'),
          isDark: isDark,
          colors: colors,
          trailing: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? colors.surfaceContainer : _softMintTile,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCurrencyOption(
                  label: 'USD (\$)',
                  selected: isUsd,
                  onTap: () {
                    appState.setPreferredCurrency('USD (\$)');
                    _showToast('Currency set to USD (\$)');
                  },
                ),
                _buildCurrencyOption(
                  label: 'LKR (Rs)',
                  selected: !isUsd,
                  onTap: () {
                    appState.setPreferredCurrency('LKR (Rs)');
                    _showToast('Currency set to LKR (Rs)');
                  },
                ),
              ],
            ),
          ),
        ),
        _buildRowDivider(isDark, colors),

        // Smart Travel Alerts Switch
        _buildRowShell(
          icon: Icons.notifications_active_outlined,
          title: appState.tr('smart_travel_alerts'),
          subtitle: appState.tr('alerts_sub'),
          isDark: isDark,
          colors: colors,
          trailing: Switch.adaptive(
            value: appState.smartTravelAlerts,
            activeTrackColor: _deepTeal,
            onChanged: (val) {
              appState.setSmartTravelAlerts(val);
              _showToast(
                val
                    ? 'Smart Travel Alerts enabled'
                    : 'Smart Travel Alerts paused',
              );
            },
          ),
        ),
        _buildRowDivider(isDark, colors),

        // Map Rendering
        _buildRowShell(
          icon: Icons.explore_outlined,
          title: appState.tr('map_rendering'),
          subtitle: appState.tr('map_rendering_sub'),
          isDark: isDark,
          colors: colors,
          onTap: () => _showMapRenderingPicker(appState),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                appState.mapRendering,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? colors.onSurface : _darkInk,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDark ? colors.onSurfaceVariant : _mutedTeal,
              ),
            ],
          ),
        ),
        _buildRowDivider(isDark, colors),

        // Offline Island Guide
        _buildRowShell(
          icon: Icons.check_circle_outline_rounded,
          title: appState.tr('offline_island_guide'),
          subtitle: appState.tr('offline_guide_sub'),
          isDark: isDark,
          colors: colors,
          onTap: () => _showOfflineGuideDialog(appState),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? colors.surfaceContainer : _softMintTile,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  appState.offlineGuideCached
                      ? '${appState.offlineGuideSizeMb} MB Cached'
                      : 'Not Cached',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? colors.primary : _deepTeal,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                appState.offlineGuideCached
                    ? Icons.download_done_rounded
                    : Icons.download_rounded,
                size: 17,
                color: isDark ? colors.onSurfaceVariant : _mutedTeal,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? _darkInk : _mutedTeal,
          ),
        ),
      ),
    );
  }

  // ── 5. ASSISTANCE & LEGAL Card ───────────────────────────────────────────
  Widget _buildAssistanceLegalCard(
    HelaAppState appState,
    HelaColorPalette colors,
    bool isDark,
  ) {
    return _buildGroupedCard(
      colors: colors,
      isDark: isDark,
      children: [
        _buildRowShell(
          icon: Icons.support_agent_rounded,
          title: appState.tr('help_centre_concierge'),
          subtitle: appState.tr('concierge_sub'),
          isDark: isDark,
          colors: colors,
          onTap: _showConciergeSheet,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.circle, size: 7, color: Color(0xFF10B981)),
              const SizedBox(width: 4),
              Text(
                appState.tr('online'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? colors.onSurface : _darkInk,
                ),
              ),
              const SizedBox(width: 3),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDark ? colors.onSurfaceVariant : _mutedTeal,
              ),
            ],
          ),
        ),
        _buildRowDivider(isDark, colors),
        _buildRowShell(
          icon: Icons.phone_outlined,
          title: appState.tr('tourist_police_hotline'),
          subtitle: appState.tr('dial_1912'),
          isDark: isDark,
          colors: colors,
          onTap: () => _dialNumber('1912'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              '1912',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF92400E),
              ),
            ),
          ),
        ),
        _buildRowDivider(isDark, colors),
        _buildRowShell(
          icon: Icons.quiz_outlined,
          title: appState.tr('faq_title'),
          subtitle: appState.tr('faq_sub'),
          isDark: isDark,
          colors: colors,
          onTap: _showFaqSheet,
          trailing: Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: isDark ? colors.onSurfaceVariant : _mutedTeal,
          ),
        ),
        _buildRowDivider(isDark, colors),
        // Bottom legal strip
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildLegalLink(
                  icon: Icons.alternate_email_rounded,
                  label: appState.tr('privacy_policy'),
                  onTap: () => _showLegalInfoDialog(
                    'Privacy Policy',
                    'HELA protects your location telemetry, travel preferences, and identity under strict end-to-end encryption. We never sell personal data to third parties.',
                  ),
                  colors: colors,
                ),
                _buildLegalLink(
                  icon: Icons.gavel_rounded,
                  label: appState.tr('terms_conditions'),
                  onTap: () => _showLegalInfoDialog(
                    'Terms & Conditions',
                    'HELA provides curated travel routes, fair-ride estimates, and SLTDA-registered partner bookings with transparent pricing and 24h cancellation support.',
                  ),
                  colors: colors,
                ),
                _buildLegalLink(
                  icon: Icons.verified_user_outlined,
                  label: appState.tr('trust_safety'),
                  onTap: () => _showLegalInfoDialog(
                    'Trust & Safety',
                    'All drivers, guides, and eco-stays displayed with verified badges undergo SLTDA credential screening and 24/7 emergency dispatch coverage via 1912.',
                  ),
                  colors: colors,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegalLink({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required HelaColorPalette colors,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: colors.isDark ? colors.onSurfaceVariant : _mutedTeal,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.15,
                  fontWeight: FontWeight.w600,
                  color: colors.isDark ? colors.onSurfaceVariant : _mutedTeal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 6. Log Out Button & SLTDA Footer ─────────────────────────────────────
  Widget _buildLogoutButton(HelaAppState appState, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(
          Icons.logout_rounded,
          size: 19,
          color: Color(0xFFDC2626),
        ),
        label: Text(
          appState.tr('logout_account'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFFDC2626),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark
              ? const Color(0xFF3F1D1D)
              : const Color(0xFFFDECEB),
          side: BorderSide(
            color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFF6C8C4),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterBranding(HelaAppState appState, HelaColorPalette colors) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const HelaLogo(size: 18),
              const SizedBox(width: 6),
              Text(
                'HELA Sri Lanka v2.4.1',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.isDark
                      ? colors.onSurfaceVariant
                      : const Color(0xFF385A52),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            appState.tr('sltda_footer'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              height: 1.35,
              color: colors.isDark ? colors.onSurfaceVariant : _mutedTeal,
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared Card & Row Builders ───────────────────────────────────────────
  Widget _buildGroupedCard({
    required List<Widget> children,
    required HelaColorPalette colors,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? colors.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? colors.architecturalBorder : _cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B4D42).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildHubRow({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badgeText,
    bool isPrimaryBadge = false,
    required bool isDark,
    required HelaColorPalette colors,
    required VoidCallback onTap,
  }) {
    return _buildRowShell(
      icon: icon,
      title: title,
      subtitle: subtitle,
      isDark: isDark,
      colors: colors,
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badgeText != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: isPrimaryBadge
                    ? _deepTeal
                    : (isDark ? colors.surfaceContainer : _softMintTile),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isPrimaryBadge
                      ? Colors.white
                      : (isDark ? colors.onSurface : _deepTeal),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: isDark ? colors.onSurfaceVariant : _mutedTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildRowShell({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required bool isDark,
    required HelaColorPalette colors,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? colors.surfaceContainer : _softMintTile,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                size: 19,
                color: isDark ? colors.primary : _deepTeal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? colors.onSurface : _darkInk,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.25,
                      color: isDark ? colors.onSurfaceVariant : _mutedTeal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildRowDivider(bool isDark, HelaColorPalette colors) {
    return Divider(
      height: 1,
      indent: 64,
      endIndent: 14,
      color: isDark ? colors.architecturalBorder : const Color(0xFFEAF4F0),
    );
  }

  // ── Interactive Sheets & Dialogs ─────────────────────────────────────────
  void _showLanguagePicker() {
    final appState = HelaAppStateProvider.of(context);
    showHelaLanguagePickerSheet(
      context,
      onLanguageSelected: (lang) {
        if (!mounted) return;
        _showToast('${appState.tr('language_updated')} ${lang.nativeName}');
      },
    );
  }

  void _showMapRenderingPicker(HelaAppState appState) {
    const modes = [
      ('Hybrid', 'Satellite imagery with roads & tuk-tuk trails'),
      ('Topographic', 'Elevation contours for hill country hikes'),
      ('Standard', 'Clean high-contrast vector streets'),
      ('Offline Vector', 'Zero-data mountain & coast map tiles'),
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Map Rendering Mode',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: _darkInk,
                ),
              ),
              const SizedBox(height: 10),
              ...modes.map((m) {
                final isSelected = appState.mapRendering == m.$1;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    m.$1,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isSelected ? _deepTeal : _darkInk,
                    ),
                  ),
                  subtitle: Text(m.$2, style: const TextStyle(fontSize: 12)),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: _deepTeal)
                      : null,
                  onTap: () {
                    appState.setMapRendering(m.$1);
                    Navigator.pop(ctx);
                    _showToast('Map rendering set to ${m.$1}');
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showOfflineGuideDialog(HelaAppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Offline Island Guide'),
        content: Text(
          appState.offlineGuideCached
              ? 'Central Hill Country & South Coast offline maps, audio lore, and emergency numbers (${appState.offlineGuideSizeMb} MB) are cached for signal-free zones.'
              : 'Download 340 MB of Central Hill Country & South Coast maps and cultural guides for offline mountain travel.',
        ),
        actions: [
          if (appState.offlineGuideCached)
            TextButton(
              onPressed: () {
                appState.setOfflineGuideCache(cached: false, sizeMb: 0);
                Navigator.pop(ctx);
                _showToast('Offline cache cleared.');
              },
              child: const Text('Clear Cache'),
            )
          else
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _deepTeal,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              appState.setOfflineGuideCache(cached: true, sizeMb: 340);
              Navigator.pop(ctx);
              _showToast('Offline Island Guide synced (340 MB).');
            },
            child: Text(
              appState.offlineGuideCached ? 'Sync Updates' : 'Download 340 MB',
            ),
          ),
        ],
      ),
    );
  }

  void _showConciergeSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Help Centre & 24/7 Concierge',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _darkInk,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Colombo Operations Desk • Online & ready to help.',
                style: TextStyle(fontSize: 12.5, color: _mutedTeal),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: _softMintTile,
                  child: Icon(Icons.auto_awesome_rounded, color: _deepTeal),
                ),
                title: const Text(
                  'Instant Chat with Ask HELA AI',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('24/7 routes, fares & cultural guidance'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AskHelaPage()),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFEF3C7),
                  child: Icon(Icons.phone_rounded, color: Color(0xFF92400E)),
                ),
                title: const Text(
                  'Call Colombo Support Desk',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('+94 11 244 1912 • Direct Concierge'),
                trailing: const Icon(Icons.call_rounded, color: _deepTeal),
                onTap: () {
                  Navigator.pop(ctx);
                  _dialNumber('+94112441912');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFaqSheet() {
    const faqs = [
      (
        'What is the tipping etiquette in Sri Lanka?',
        'Tipping 10% at restaurants (when no service charge is added), LKR 1,500–2,500/day for private drivers, and small LKR 200–500 tips for hotel porters is appreciated.',
      ),
      (
        'How do I book Kandy–Ella scenic train tickets?',
        '1st & 2nd class observation seats open 30 days ahead via the Sri Lanka Railways online portal (seatreservation.railway.gov.lk).',
      ),
      (
        'Which tourist SIM card should I get?',
        'Dialog and Mobitel both have 24/7 counters at Bandaranaike Intl Airport (CMB) Arrivals offering tourist 4G/5G eSIMs and physical data packs.',
      ),
      (
        'What should I wear at sacred Buddhist temples?',
        'Cover both shoulders and knees, remove shoes and hats before entering inner courtyards, and avoid posing with your back to Buddha statues.',
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sri Lanka Travel FAQs',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _darkInk,
                ),
              ),
              const SizedBox(height: 12),
              ...faqs.map(
                (item) => ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 10),
                  title: Text(
                    item.$1,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: _darkInk,
                    ),
                  ),
                  children: [
                    Text(
                      item.$2,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: _mutedTeal,
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

  void _showEcoImpactDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.eco_rounded, color: Color(0xFF10B981)),
            SizedBox(width: 8),
            Text('100% Carbon Offset'),
          ],
        ),
        content: const Text(
          'Your HELA journeys support certified Sri Lankan mangrove restoration and trailhead plastic removal across the Central Highlands and Southern Coast.',
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

  void _showLegalInfoDialog(String title, String body) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title),
        content: Text(body, style: const TextStyle(height: 1.4)),
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
        title: const Text('Log Out of HELA Account?'),
        content: const Text(
          'Your saved destinations, itineraries, and preferences stay safely synced for when you sign back in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await InsForgeAuthService.instance.signOut();
              if (!mounted) return;
              HelaAppStateProvider.of(context).signOut();
              _showToast('Logged out of HELA Account.');
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) =>
                      const SignUpPage(initialMode: AuthMode.signIn),
                ),
                (route) => false,
              );
            },
            child: const Text('Log Out'),
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
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
