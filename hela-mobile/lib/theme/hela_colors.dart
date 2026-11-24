import 'package:flutter/material.dart';

/// Complete palette contract for both Light and Dark modes.
/// Conforms to the Stitch Lankan Tropical Modernism design system.
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
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color tertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixed;
  final Color onTertiaryFixedVariant;

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
  final Color warmSand;
  final Color goldenAmber;
  final Color coralSunrise;
  final Color architecturalBorder;

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
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.tertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixed,
    required this.onTertiaryFixedVariant,
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
    required this.warmSand,
    required this.goldenAmber,
    required this.coralSunrise,
    required this.architecturalBorder,
    required this.cardBackground,
    required this.searchBackground,
    required this.navBarBackground,
    required this.bannerBackground,
    required this.activeTabColor,
    required this.inactiveTabColor,
  });

  bool get isDark => brightness == Brightness.dark;

  Color get onBackground => onSurface;
}

/// Theme Color Palette from Design Tokens (Lankan Tropical Modernism).
class HelaColors {
  // ── Light Theme Tokens (Lankan Tropical Modernism) ────────────────
  static const Color primary = Color(0xFF00443E); // Deep Ocean Teal
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(
    0xFF0B5D56,
  ); // Primary Interaction Teal
  static const Color onPrimaryContainer = Color(0xFF8ED3CA);
  static const Color primaryFixed = Color(0xFFAAF0E6);
  static const Color primaryFixedDim = Color(0xFF8ED3CA);
  static const Color onPrimaryFixed = Color(0xFF00201D);
  static const Color onPrimaryFixedVariant = Color(0xFF00504A);

  static const Color secondary = Color(0xFF356760); // Forest Green Accent
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFB6EAE1);
  static const Color onSecondaryContainer = Color(0xFF396B64);
  static const Color secondaryFixed = Color(0xFFB9EDE4);
  static const Color secondaryFixedDim = Color(0xFF9DD0C8);
  static const Color onSecondaryFixed = Color(0xFF00201D);
  static const Color onSecondaryFixedVariant = Color(0xFF1B4F49);

  static const Color tertiary = Color(0xFF503700);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF6E4C00);
  static const Color onTertiaryContainer = Color(0xFFF5BD57);
  static const Color tertiaryFixed = Color(
    0xFFFFDEAA,
  ); // Peach / Amber highlight
  static const Color tertiaryFixedDim = Color(0xFFF5BD58);
  static const Color onTertiaryFixed = Color(0xFF271900);
  static const Color onTertiaryFixedVariant = Color(0xFF5F4100);

  // Surface hierarchy
  static const Color background = Color(0xFFE9FEF9); // Tropical Mint Canvas
  static const Color surface = Color(0xFFE9FEF9);
  static const Color surfaceContainerLowest = Color(
    0xFFFFFFFF,
  ); // Elevated cards & fields
  static const Color surfaceContainerLow = Color(0xFFE3F8F3);
  static const Color surfaceContainer = Color(0xFFDEF2ED);
  static const Color surfaceContainerHigh = Color(0xFFD8EDE7);
  static const Color surfaceContainerHighest = Color(0xFFD2E7E2);
  static const Color surfaceVariant = Color(0xFFD2E7E2);
  static const Color surfaceDim = Color(0xFFCADED9);
  static const Color surfaceBright = Color(0xFFE9FEF9);

  static const Color onSurface = Color(0xFF0C1F1C);
  static const Color onSurfaceVariant = Color(0xFF3F4947);
  static const Color outline = Color(0xFF6F7977);
  static const Color outlineVariant = Color(0xFFBEC9C6);
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);

  // Special Lankan Tropical Accent Tokens
  static const Color warmSand = Color(0xFFF3EBDD);
  static const Color goldenAmber = Color(0xFFD9A441);
  static const Color coralSunrise = Color(0xFFE47D63);
  static const Color architecturalBorder = Color(0xFFE5DFD3);

  // ── Dark Theme Tokens (Ceylon Emerald Night) ────────────────────
  static const Color darkBackground = Color(0xFF0B1715);
  static const Color darkSurface = Color(0xFF10211E);
  static const Color darkSurfaceContainerLowest = Color(0xFF07110F);
  static const Color darkSurfaceContainerLow = Color(0xFF152A26);
  static const Color darkSurfaceContainer = Color(0xFF1A332E);
  static const Color darkSurfaceContainerHigh = Color(0xFF223E38);
  static const Color darkSurfaceContainerHighest = Color(0xFF2A4A43);
  static const Color darkSurfaceVariant = Color(0xFF223E38);
  static const Color darkSurfaceDim = Color(0xFF0B1715);
  static const Color darkSurfaceBright = Color(0xFF1E3A34);

  static const Color darkPrimary = Color(0xFF8ED3CA); // Radiant Ceylon Sea Foam
  static const Color darkOnPrimary = Color(0xFF003732);
  static const Color darkPrimaryContainer = Color(0xFF0B5D56);
  static const Color darkOnPrimaryContainer = Color(0xFFAAF0E6);
  static const Color darkPrimaryFixed = Color(0xFF00504A);
  static const Color darkPrimaryFixedDim = Color(0xFF003732);

  static const Color darkSecondary = Color(0xFFB6EAE1);
  static const Color darkOnSecondary = Color(0xFF003732);
  static const Color darkSecondaryContainer = Color(0xFF1B4F49);
  static const Color darkOnSecondaryContainer = Color(0xFFB9EDE4);
  static const Color darkSecondaryFixed = Color(0xFF265B54);
  static const Color darkSecondaryFixedDim = Color(0xFF1E4B45);

  static const Color darkTertiary = Color(0xFFF5BD58);
  static const Color darkOnTertiary = Color(0xFF432C00);
  static const Color darkTertiaryContainer = Color(0xFF6E4C00);
  static const Color darkOnTertiaryContainer = Color(0xFFFFDEAA);
  static const Color darkTertiaryFixed = Color(0xFFFFDEAA);
  static const Color darkTertiaryFixedDim = Color(0xFFF5BD58);
  static const Color darkOnTertiaryFixed = Color(0xFF271900);
  static const Color darkOnTertiaryFixedVariant = Color(0xFF5F4100);

  static const Color darkOnSurface = Color(0xFFE0F5F0);
  static const Color darkOnSurfaceVariant = Color(0xFFBEC9C6);
  static const Color darkOutline = Color(0xFF899391);
  static const Color darkOutlineVariant = Color(0xFF3F4947);
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
    onTertiary: onTertiary,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    tertiaryFixed: tertiaryFixed,
    tertiaryFixedDim: tertiaryFixedDim,
    onTertiaryFixed: onTertiaryFixed,
    onTertiaryFixedVariant: onTertiaryFixedVariant,
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
    warmSand: warmSand,
    goldenAmber: goldenAmber,
    coralSunrise: coralSunrise,
    architecturalBorder: architecturalBorder,
    cardBackground: surfaceContainerLowest,
    searchBackground: surfaceContainerLowest,
    navBarBackground: surfaceContainerLowest,
    bannerBackground: surfaceContainerLow,
    activeTabColor: primaryContainer,
    inactiveTabColor: outline,
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
    tertiaryContainer: darkTertiaryContainer,
    onTertiaryContainer: darkOnTertiaryContainer,
    tertiaryFixed: darkTertiaryFixed,
    tertiaryFixedDim: darkTertiaryFixedDim,
    onTertiaryFixed: darkOnTertiaryFixed,
    onTertiaryFixedVariant: darkOnTertiaryFixedVariant,
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
    warmSand: Color(0xFF383025),
    goldenAmber: goldenAmber,
    coralSunrise: coralSunrise,
    architecturalBorder: darkOutlineVariant,
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

/// Backward compatibility typedef for HelaColorPalette
typedef HelaPalette = HelaColorPalette;

/// Convenience context extension for accessing the active theme colors.
extension HelaThemeContextExtension on BuildContext {
  HelaColorPalette get helaColors => HelaColors.of(this);
  bool get isDarkMode => HelaColors.isDark(this);
}
