import 'package:flutter/material.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/theme/hela_colors.dart';

/// An animated, premium Theme Mode Toggle Button.
///
/// Switches between Light Mode and Dark Mode with smooth icon rotation,
/// scaling, and ambient glow effects matching the HELA aesthetic.
class HelaThemeSwitchButton extends StatelessWidget {
  /// Size of the button's outer container (defaults to 38 for AppBar).
  final double size;

  /// Optional custom tooltip message.
  final String? tooltip;

  /// Whether to show a compact pill with text label.
  final bool showLabel;

  const HelaThemeSwitchButton({
    super.key,
    this.size = 38,
    this.tooltip,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final appState = HelaAppStateProvider.of(context);
    final colors = HelaColors.of(context);
    final isDark = appState.isDarkMode;

    final defaultTooltip = isDark
        ? 'Switch to Light Theme (Ceylon Sunlight)'
        : 'Switch to Dark Theme (Emerald Night)';

    if (showLabel) {
      return Tooltip(
        message: tooltip ?? defaultTooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              appState.toggleTheme();
              _showThemeSnackBar(context, !isDark);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? colors.primary.withValues(alpha: 0.16)
                    : colors.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? colors.primary.withValues(alpha: 0.45)
                      : colors.secondary.withValues(alpha: 0.25),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AnimatedThemeIcon(isDark: isDark, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    isDark ? 'Dark Mode' : 'Light Mode',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? colors.primary : colors.secondary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Tooltip(
      message: tooltip ?? defaultTooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: () {
            appState.toggleTheme();
            _showThemeSnackBar(context, !isDark);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? colors.surfaceContainerHigh
                  : colors.surfaceContainerLow,
              border: Border.all(
                color: isDark
                    ? colors.primary.withValues(alpha: 0.4)
                    : colors.outlineVariant.withValues(alpha: 0.7),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? colors.primary.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: isDark ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: _AnimatedThemeIcon(isDark: isDark, size: size * 0.52),
            ),
          ),
        ),
      ),
    );
  }

  void _showThemeSnackBar(BuildContext context, bool switchedToDark) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              switchedToDark
                  ? Icons.nightlight_round
                  : Icons.wb_sunny_rounded,
              color: switchedToDark
                  ? const Color(0xFF7ED994)
                  : const Color(0xFFDFEB6D),
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              switchedToDark
                  ? '🌙 Activated Emerald Dark Theme'
                  : '☀️ Activated Highland Light Theme',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _AnimatedThemeIcon extends StatelessWidget {
  final bool isDark;
  final double size;

  const _AnimatedThemeIcon({required this.isDark, required this.size});

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      transitionBuilder: (child, animation) {
        return RotationTransition(
          turns: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: isDark
          ? Icon(
              Icons.nightlight_round,
              key: const ValueKey('moon_icon'),
              size: size,
              color: colors.primary,
            )
          : Icon(
              Icons.wb_sunny_rounded,
              key: const ValueKey('sun_icon'),
              size: size,
              color: const Color(0xFFD49A00),
            ),
    );
  }
}
