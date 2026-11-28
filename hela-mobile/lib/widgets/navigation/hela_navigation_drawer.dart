import 'package:flutter/material.dart';
import 'package:hela/l10n/localization_service.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/theme/hela_colors.dart';
import 'package:hela/widgets/common/hela_logo.dart';
import 'package:hela/widgets/common/language_picker_sheet.dart';
import 'package:hela/pages/bookings/stays_page.dart';
import 'package:hela/pages/bookings/fair_ride_page.dart';
import 'package:hela/pages/cultural_guide/cultural_guide_page.dart';
import 'package:hela/pages/smart_tour/smart_tour_home_page.dart';
import 'package:hela/pages/saved/saved_page.dart';
import 'package:hela/pages/profile/profile_page.dart';

/// Customized Navigation Drawer for HELA with dedicated Theme Switcher.
class HelaNavigationDrawer extends StatelessWidget {
  const HelaNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);
    final appState = HelaAppStateProvider.of(context);
    final isDark = appState.isDarkMode;

    return Drawer(
      backgroundColor: colors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // ── Drawer Header ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: isDark
                    ? colors.surfaceContainer
                    : colors.primaryContainer.withValues(alpha: 0.12),
                border: Border(
                  bottom: BorderSide(
                    color: colors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      HelaLogo(
                        size: 46,
                        framed: true,
                        isCircle: true,
                        padding: 5,
                        borderColor: colors.outlineVariant.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HELA',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: colors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              appState.tr('discover_sri_lanka'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? colors.primary.withValues(alpha: 0.15)
                          : colors.secondaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          size: 14,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            appState.userName.isNotEmpty
                                ? appState.userName
                                : 'Ceylon Pathfinder',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable Body ────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  // ── Theme Switch Section ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              appState.tr('appearance'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: colors.secondary,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                isDark
                                    ? appState.tr('emerald_night')
                                    : appState.tr('daylight'),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colors.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildThemeOption(
                                context: context,
                                label: appState.tr('light'),
                                icon: Icons.wb_sunny_rounded,
                                isSelected:
                                    appState.themeMode == ThemeMode.light,
                                onTap: () =>
                                    appState.setThemeMode(ThemeMode.light),
                                colors: colors,
                              ),
                              _buildThemeOption(
                                context: context,
                                label: appState.tr('dark'),
                                icon: Icons.nightlight_round,
                                isSelected:
                                    appState.themeMode == ThemeMode.dark,
                                onTap: () =>
                                    appState.setThemeMode(ThemeMode.dark),
                                colors: colors,
                              ),
                              _buildThemeOption(
                                context: context,
                                label: appState.tr('auto'),
                                icon: Icons.brightness_auto_rounded,
                                isSelected:
                                    appState.themeMode == ThemeMode.system,
                                onTap: () =>
                                    appState.setThemeMode(ThemeMode.system),
                                colors: colors,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 24),

                  // ── App Navigation Links ──────────────────────────
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.explore_rounded,
                    title: appState.tr('explore_ceylon_havens'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    colors: colors,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.hotel_rounded,
                    title: appState.tr('stays_eco_lodges'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StaysPage()),
                      );
                    },
                    colors: colors,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.electric_rickshaw_rounded,
                    title: appState.tr('fair_ride_ceylon'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FairRidePage()),
                      );
                    },
                    colors: colors,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.temple_buddhist_rounded,
                    title: appState.tr('cultural_heritage_guide'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CulturalGuidePage(),
                        ),
                      );
                    },
                    colors: colors,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.smart_toy_rounded,
                    title: appState.tr('smart_tour_ai_planner'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SmartTourHomePage(),
                        ),
                      );
                    },
                    colors: colors,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.bookmark_rounded,
                    title: appState.tr('saved_havens_trips'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SavedPage()),
                      );
                    },
                    colors: colors,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.person_rounded,
                    title: appState.tr('explorer_profile'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    },
                    colors: colors,
                  ),
                  const Divider(height: 20),
                  ListTile(
                    leading: Icon(
                      Icons.translate_rounded,
                      color: colors.primary,
                      size: 22,
                    ),
                    title: Text(
                      appState.tr('language'),
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    trailing: Text(
                      LocalizationService.getLanguage(
                        appState.selectedLanguage,
                      ).nativeName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    onTap: () {
                      Navigator.pop(context);
                      showHelaLanguagePickerSheet(context);
                    },
                  ),
                ],
              ),
            ),

            // ── Drawer Footer ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'HELA v1.0 · Ceylon OS',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.eco_outlined,
                    size: 16,
                    color: colors.primary.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required HelaColorPalette colors,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? colors.onPrimary
                      : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required HelaColorPalette colors,
  }) {
    return ListTile(
      leading: Icon(icon, color: colors.primary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: colors.onSurface,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: colors.onSurfaceVariant.withValues(alpha: 0.6),
      ),
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      onTap: onTap,
    );
  }
}
