import 'package:flutter/material.dart';
import 'package:hela/pages/home_page.dart';
import 'package:hela/pages/saved_page.dart';
import 'package:hela/pages/travel_preferences_page.dart';
import 'package:hela/pages/trip_planner_page.dart';
import 'package:hela/pages/profile_page.dart';

/// Unified, consistent Bottom Navigation Bar for HELA
/// Ensures 100% identical styling, icons, spacing, and seamless zero-latency navigation across all pages.
class HelaBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTabSelected;

  const HelaBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTabSelected,
  });

  static const List<_NavItemData> _items = [
    _NavItemData(
      label: 'Explore',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
    ),
    _NavItemData(
      label: 'Saved',
      icon: Icons.bookmark_border_rounded,
      activeIcon: Icons.bookmark_rounded,
    ),
    _NavItemData(
      label: 'Discover',
      icon: Icons.travel_explore_outlined,
      activeIcon: Icons.travel_explore_rounded,
    ),
    _NavItemData(
      label: 'Journeys',
      icon: Icons.route_outlined,
      activeIcon: Icons.route_rounded,
    ),
    _NavItemData(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  void _handleTap(BuildContext context, int index) {
    if (onTabSelected != null) {
      onTabSelected!(index);
      return;
    }

    if (index == currentIndex) return;

    Widget targetPage;
    switch (index) {
      case 0:
        targetPage = const HelaHomePage();
        break;
      case 1:
        targetPage = const SavedPage();
        break;
      case 2:
        targetPage = const TravelPreferencesPage();
        break;
      case 3:
        targetPage = const TripPlannerPage();
        break;
      case 4:
        targetPage = const ProfilePage();
        break;
      default:
        return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetPage,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colors.navBarBackground.withValues(alpha: isDark ? 0.98 : 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: isDark
                ? colors.outlineVariant.withValues(alpha: 0.3)
                : const Color(0xFFE2EBE4),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isActive = currentIndex == index;

              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _handleTap(context, index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? item.activeIcon : item.icon,
                          color: isActive ? colors.primary : colors.onSurfaceVariant,
                          size: 24,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isActive ? colors.primary : colors.onSurfaceVariant,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
