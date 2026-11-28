import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hela/theme/hela_colors.dart';

/// Central theme definitions for the HELA application.
/// Conforms strictly to the Lankan Tropical Modernism design system.
class HelaTheme {
  // ── Light Theme ───────────────────────────────────────────────────
  static ThemeData get lightTheme {
    const palette = HelaColors.lightPalette;

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      primaryContainer: palette.primaryContainer,
      onPrimaryContainer: palette.onPrimaryContainer,
      secondary: palette.secondary,
      onSecondary: palette.onSecondary,
      secondaryContainer: palette.secondaryContainer,
      onSecondaryContainer: palette.onSecondaryContainer,
      tertiary: palette.tertiary,
      onTertiary: palette.onTertiary,
      error: palette.error,
      onError: palette.onError,
      surface: palette.surface,
      onSurface: palette.onSurface,
      onSurfaceVariant: palette.onSurfaceVariant,
      outline: palette.outline,
      outlineVariant: palette.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Plus Jakarta Sans',
      scaffoldBackgroundColor: palette.background,
      colorScheme: colorScheme,
      canvasColor: palette.background,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.surface,
        foregroundColor: palette.primary,
        elevation: 0,
        scrolledUnderElevation: 1.0,
        shadowColor: Colors.black12,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: palette.primary, size: 24),
        actionsIconTheme: IconThemeData(color: palette.primary, size: 24),
        titleTextStyle: TextStyle(
          color: palette.primary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Plus Jakarta Sans',
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.cardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.architecturalBorder, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceContainerLowest,
        disabledColor: palette.surfaceDim,
        selectedColor: palette.primaryContainer,
        secondarySelectedColor: palette.secondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        labelStyle: TextStyle(
          color: palette.onSurfaceVariant,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          fontFamily: 'Plus Jakarta Sans',
        ),
        secondaryLabelStyle: TextStyle(
          color: palette.onSecondaryContainer,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Plus Jakarta Sans',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
          side: BorderSide(color: palette.architecturalBorder),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.navBarBackground,
        selectedItemColor: palette.primary,
        unselectedItemColor: palette.onSurfaceVariant,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          fontFamily: 'Plus Jakarta Sans',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: palette.surface,
        elevation: 16,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surfaceContainerLowest,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          color: palette.primary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Plus Jakarta Sans',
        ),
        contentTextStyle: TextStyle(
          color: palette.onSurfaceVariant,
          fontSize: 14,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.primary,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Plus Jakarta Sans',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceContainerLowest,
        hintStyle: TextStyle(
          color: palette.outline,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: 'Plus Jakarta Sans',
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.primaryContainer, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          side: BorderSide(color: palette.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.outlineVariant.withValues(alpha: 0.4),
        thickness: 1,
        space: 1,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.surfaceContainerLowest,
        textStyle: TextStyle(
          color: palette.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
  }

  // ── Dark Theme (Ceylon Emerald Night) ──────────────────────────────
  static ThemeData get darkTheme {
    const palette = HelaColors.darkPalette;

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      primaryContainer: palette.primaryContainer,
      onPrimaryContainer: palette.onPrimaryContainer,
      secondary: palette.secondary,
      onSecondary: palette.onSecondary,
      secondaryContainer: palette.secondaryContainer,
      onSecondaryContainer: palette.onSecondaryContainer,
      tertiary: palette.tertiary,
      onTertiary: palette.onTertiary,
      error: palette.error,
      onError: palette.onError,
      surface: palette.surface,
      onSurface: palette.onSurface,
      onSurfaceVariant: palette.onSurfaceVariant,
      outline: palette.outline,
      outlineVariant: palette.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Plus Jakarta Sans',
      scaffoldBackgroundColor: palette.background,
      colorScheme: colorScheme,
      canvasColor: palette.background,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.surface,
        foregroundColor: palette.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2.0,
        shadowColor: Colors.black45,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: palette.primary, size: 24),
        actionsIconTheme: IconThemeData(color: palette.primary, size: 24),
        titleTextStyle: TextStyle(
          color: palette.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Plus Jakarta Sans',
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.cardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: palette.outlineVariant.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceContainer,
        disabledColor: palette.surfaceDim,
        selectedColor: palette.primaryContainer,
        secondarySelectedColor: palette.secondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        labelStyle: TextStyle(
          color: palette.onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          fontFamily: 'Plus Jakarta Sans',
        ),
        secondaryLabelStyle: TextStyle(
          color: palette.onSecondaryContainer,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Plus Jakarta Sans',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
          side: BorderSide(
            color: palette.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.navBarBackground,
        selectedItemColor: palette.primary,
        unselectedItemColor: palette.onSurfaceVariant,
        elevation: 12,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          fontFamily: 'Plus Jakarta Sans',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: palette.surface,
        elevation: 20,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surfaceContainer,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          color: palette.primary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Plus Jakarta Sans',
        ),
        contentTextStyle: TextStyle(
          color: palette.onSurfaceVariant,
          fontSize: 14,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surfaceContainerHigh,
        contentTextStyle: TextStyle(
          color: palette.onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Plus Jakarta Sans',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: palette.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.searchBackground,
        hintStyle: TextStyle(
          color: palette.onSurfaceVariant.withValues(alpha: 0.6),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: 'Plus Jakarta Sans',
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: palette.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.secondary,
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          side: BorderSide(color: palette.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.surfaceContainer,
        textStyle: TextStyle(
          color: palette.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
  }
}
