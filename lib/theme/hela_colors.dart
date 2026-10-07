import 'package:flutter/material.dart';

/// Complete palette contract for both Light and Dark modes.
class HelaColorPalette {
  final Brightness brightness;

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color primaryFixed;
  final Color primaryFixedDim;

  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color secondaryFixed;
  final Color secondaryFixedDim;

  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixed;

  final Color background;
  final Color surface;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color surfaceVariant;
  final Color surfaceDim;
  final Color surfaceBright;

  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color error;
  final Color onError;

  // Custom UI semantic helpers
  final Color cardBackground;
  final Color searchBackground;
  final Color navBarBackground;
  final Color bannerBackground;
  final Color activeTabColor;
  final Color inactiveTabColor;

  const HelaColorPalette({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.primaryFixed,
    required this.primaryFixedDim,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.secondaryFixed,
    required this.secondaryFixedDim,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixed,
    required this.background,
    required this.surface,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.surfaceVariant,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.error,
    required this.onError,
    required this.cardBackground,
    required this.searchBackground,
    required this.navBarBackground,
    required this.bannerBackground,
    required this.activeTabColor,
    required this.inactiveTabColor,
  });

  bool get isDark => brightness == Brightness.dark;
}

/// Theme Color Palette from Design Tokens with comprehensive Light and Dark mode support.
class HelaColors {
  // ── Light Theme Tokens (Canonical Default) ──────────────────────
  static const Color primary = Color(0xFF19331F);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF2F4A34);
  static const Color onPrimaryContainer = Color(0xFF9AB99D);
  static const Color primaryFixed = Color(0xFFCBEBCC);
  static const Color primaryFixedDim = Color(0xFFAFCEB1);

  static const Color secondary = Color(0xFF40674D);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFBFEAC9);
  static const Color onSecondaryContainer = Color(0xFF446B51);
  static const Color secondaryFixed = Color(0xFFC2EDCC);
  static const Color secondaryFixedDim = Color(0xFFA6D1B1);

  static const Color tertiary = Color(0xFF2C3100);
  static const Color tertiaryFixed = Color(0xFFDFEB6D);
  static const Color tertiaryFixedDim = Color(0xFFC3CF54);
  static const Color onTertiaryFixed = Color(0xFF1A1D00);

  static const Color background = Color(0xFFFAF9F3);
  static const Color surface = Color(0xFFFAF9F3);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F4EE);
  static const Color surfaceContainer = Color(0xFFEFEEE8);
  static const Color surfaceContainerHigh = Color(0xFFE9E8E2);
  static const Color surfaceContainerHighest = Color(0xFFE3E3DD);
  static const Color surfaceVariant = Color(0xFFE3E3DD);
  static const Color surfaceDim = Color(0xFFDBDAD4);
  static const Color surfaceBright = Color(0xFFFAF9F3);

  static const Color onSurface = Color(0xFF1B1C19);
  static const Color onSurfaceVariant = Color(0xFF424842);
  static const Color outline = Color(0xFF737971);
  static const Color outlineVariant = Color(0xFFC2C8C0);
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);

  // ── Dark Theme Tokens (Ceylon Emerald Night) ────────────────────
  static const Color darkBackground = Color(0xFF0D140F);
  static const Color darkSurface = Color(0xFF131B15);
  static const Color darkSurfaceContainerLowest = Color(0xFF080D0A);
  static const Color darkSurfaceContainerLow = Color(0xFF161F18);
  static const Color darkSurfaceContainer = Color(0xFF1B261E);
  static const Color darkSurfaceContainerHigh = Color(0xFF233026);
  static const Color darkSurfaceContainerHighest = Color(0xFF2B3A2E);
  static const Color darkSurfaceVariant = Color(0xFF233026);
  static const Color darkSurfaceDim = Color(0xFF0D140F);
  static const Color darkSurfaceBright = Color(0xFF1F2B22);

  static const Color darkPrimary = Color(0xFF7ED994); // Radiant Ceylon tea-leaf emerald
  static const Color darkOnPrimary = Color(0xFF003915);
  static const Color darkPrimaryContainer = Color(0xFF1D4A27);
  static const Color darkOnPrimaryContainer = Color(0xFFA6F5B9);
  static const Color darkPrimaryFixed = Color(0xFF2E5E3A);
  static const Color darkPrimaryFixedDim = Color(0xFF244A2E);

  static const Color darkSecondary = Color(0xFFA0D3B0); // Soothing sage mist
  static const Color darkOnSecondary = Color(0xFF0E381F);
  static const Color darkSecondaryContainer = Color(0xFF285137);
  static const Color darkOnSecondaryContainer = Color(0xFFC2EDCD);
  static const Color darkSecondaryFixed = Color(0xFF386546);
  static const Color darkSecondaryFixedDim = Color(0xFF2D5138);

  static const Color darkTertiary = Color(0xFFD6E464); // Warm golden citron firefly glow
  static const Color darkOnTertiary = Color(0xFF282F00);
  static const Color darkTertiaryFixed = Color(0xFFDFEB6D);
  static const Color darkTertiaryFixedDim = Color(0xFFC3CF54);
  static const Color darkOnTertiaryFixed = Color(0xFF1A1D00);

  static const Color darkOnSurface = Color(0xFFE2E5DE); // Crisp, high-contrast warm off-white
  static const Color darkOnSurfaceVariant = Color(0xFFA2A99F); // Silvery eucalyptus slate
  static const Color darkOutline = Color(0xFF6F796E);
  static const Color darkOutlineVariant = Color(0xFF2E3A2F);
  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);

  // ── Palettes ───────────────────────────────────────────────────
  static const HelaColorPalette lightPalette = HelaColorPalette(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    primaryFixed: primaryFixed,
    primaryFixedDim: primaryFixedDim,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    secondaryFixed: secondaryFixed,
    secondaryFixedDim: secondaryFixedDim,
    tertiary: tertiary,
    onTertiary: Color(0xFFFFFFFF),
    tertiaryFixed: tertiaryFixed,
    tertiaryFixedDim: tertiaryFixedDim,
    onTertiaryFixed: onTertiaryFixed,
    background: background,
    surface: surface,
    surfaceContainerLowest: surfaceContainerLowest,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainerHighest: surfaceContainerHighest,
    surfaceVariant: surfaceVariant,
    surfaceDim: surfaceDim,
    surfaceBright: surfaceBright,
    onSurface: onSurface,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    error: error,
    onError: onError,
    cardBackground: Color(0xFFFFFFFF),
    searchBackground: Color(0xFFFFFFFF),
    navBarBackground: Color(0xFFFFFFFF),
    bannerBackground: surfaceContainer,
    activeTabColor: primary,
    inactiveTabColor: onSurfaceVariant,
  );

  static const HelaColorPalette darkPalette = HelaColorPalette(
    brightness: Brightness.dark,
    primary: darkPrimary,
    onPrimary: darkOnPrimary,
    primaryContainer: darkPrimaryContainer,
    onPrimaryContainer: darkOnPrimaryContainer,
    primaryFixed: darkPrimaryFixed,
    primaryFixedDim: darkPrimaryFixedDim,
    secondary: darkSecondary,
    onSecondary: darkOnSecondary,
    secondaryContainer: darkSecondaryContainer,
    onSecondaryContainer: darkOnSecondaryContainer,
    secondaryFixed: darkSecondaryFixed,
    secondaryFixedDim: darkSecondaryFixedDim,
    tertiary: darkTertiary,
    onTertiary: darkOnTertiary,
    tertiaryFixed: darkTertiaryFixed,
    tertiaryFixedDim: darkTertiaryFixedDim,
    onTertiaryFixed: darkOnTertiaryFixed,
    background: darkBackground,
    surface: darkSurface,
    surfaceContainerLowest: darkSurfaceContainerLowest,
    surfaceContainerLow: darkSurfaceContainerLow,
    surfaceContainer: darkSurfaceContainer,
    surfaceContainerHigh: darkSurfaceContainerHigh,
    surfaceContainerHighest: darkSurfaceContainerHighest,
    surfaceVariant: darkSurfaceVariant,
    surfaceDim: darkSurfaceDim,
    surfaceBright: darkSurfaceBright,
    onSurface: darkOnSurface,
    onSurfaceVariant: darkOnSurfaceVariant,
    outline: darkOutline,
    outlineVariant: darkOutlineVariant,
    error: darkError,
    onError: darkOnError,
    cardBackground: darkSurfaceContainer,
    searchBackground: darkSurfaceContainerLow,
    navBarBackground: darkSurfaceContainerLowest,
    bannerBackground: darkSurfaceContainer,
    activeTabColor: darkPrimary,
    inactiveTabColor: darkOnSurfaceVariant,
  );

  /// Resolves the active [HelaColorPalette] based on the current context's theme brightness.
  static HelaColorPalette of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkPalette : lightPalette;
  }

  /// Returns true if the current context is running in Dark Mode.
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}

/// Convenience context extension for accessing the active theme colors.
extension HelaThemeContextExtension on BuildContext {
  HelaColorPalette get helaColors => HelaColors.of(this);
  bool get isDarkMode => HelaColors.isDark(this);
}
