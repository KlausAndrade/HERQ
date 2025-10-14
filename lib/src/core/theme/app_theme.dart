import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors - Blue
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // Secondary Colors - Green (Success)
  static const Color secondaryColor = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);

  // Accent Colors - Amber (Energy/Warning)
  static const Color accentColor = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);
  static const Color accentDark = Color(0xFFD97706);

  // Additional Colors
  static const Color errorColor = Color(0xFFEF4444);
  static const Color purpleColor = Color(0xFF8B5CF6); // Premium/Progress
  static const Color pinkColor = Color(0xFFEC4899); // Goals/Achievements

  // Light Theme Colors - Revamped for better readability
  static const Color backgroundLight =
      Color(0xFFF5F7FA); // Subtle blue-gray tint
  static const Color surfaceLight = Colors.white;
  static const Color surfaceVariantLight =
      Color(0xFFF8F9FA); // Slightly off-white
  static const Color onSurfaceLight =
      Color(0xFF0F172A); // Deeper, more readable dark blue-gray
  static const Color onSurfaceVariantLight =
      Color(0xFF475569); // Medium gray for secondary text
  static const Color outlineLight = Color(0xFFE2E8F0); // Subtle borders
  static const Color outlineVariantLight =
      Color(0xFFCBD5E1); // More visible borders

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF0F0F0F);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color onSurfaceDark = Color(0xFFF9FAFB);

  // HERQ Brand Colors
  static const Color herqGraphite =
      Color(0xFF1B1D21); // Primary Dark - Strength, focus
  static const Color herqTeal =
      Color(0xFF00BFA6); // Primary Accent - Modern energy
  static const Color herqLime =
      Color(0xFFD4FF4D); // Secondary Accent - Vitality, contrast
  static const Color herqCharcoal =
      Color(0xFF141516); // Background - Professional contrast
  static const Color herqWhite = Color(0xFFF8F8FA); // Text - Clean typography

  // HERQ Gradient
  static const LinearGradient herqGradient = LinearGradient(
    colors: [herqTeal, herqLime],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [secondaryLight, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentLight, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Spacing
  static const double spacingXS = 4;
  static const double spacingSM = 8;
  static const double spacingMD = 16;
  static const double spacingLG = 24;
  static const double spacingXL = 32;
  static const double spacingXXL = 48;

  // Border Radius
  static const double radiusSM = 8;
  static const double radiusMD = 12;
  static const double radiusLG = 16;
  static const double radiusXL = 24;

  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withAlpha((0.1 * 255).round()),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: primaryColor.withAlpha((0.3 * 255).round()),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          secondary: secondaryColor,
          tertiary: accentColor,
          error: errorColor,
          surfaceContainerHighest: surfaceVariantLight,
          onSecondary: Colors.white,
          onTertiary: Colors.white,
          onSurface: onSurfaceLight,
          onSurfaceVariant: onSurfaceVariantLight,
          outline: outlineLight,
          outlineVariant: outlineVariantLight,
        ),
        typography: Typography.material2021(),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            height: 1.2,
            color: onSurfaceLight,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            height: 1.2,
            color: onSurfaceLight,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.25,
            height: 1.3,
            color: onSurfaceLight,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.4,
            color: onSurfaceLight,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.4,
            color: onSurfaceLight,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
            height: 1.5,
            color: onSurfaceLight,
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            height: 1.4,
            color: onSurfaceVariantLight,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.15,
            height: 1.5,
            color: onSurfaceLight,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.25,
            height: 1.5,
            color: onSurfaceLight,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.4,
            height: 1.5,
            color: onSurfaceVariantLight,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            height: 1.4,
            color: onSurfaceLight,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            height: 1.4,
            color: onSurfaceVariantLight,
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: backgroundLight,
          foregroundColor: onSurfaceLight,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: onSurfaceLight,
            letterSpacing: 0,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: surfaceLight,
          shadowColor: Colors.black.withAlpha((0.05 * 255).round()),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
            side: const BorderSide(color: outlineLight),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shadowColor: primaryColor.withAlpha((0.3 * 255).round()),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSM),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingLG,
              vertical: spacingMD,
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSM),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingLG,
              vertical: spacingMD,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSM),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingLG,
              vertical: spacingMD,
            ),
            side: const BorderSide(color: primaryColor, width: 1.5),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusSM),
            borderSide:
                const BorderSide(color: outlineVariantLight, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusSM),
            borderSide:
                const BorderSide(color: outlineVariantLight, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusSM),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusSM),
            borderSide: const BorderSide(color: errorColor, width: 1.5),
          ),
          labelStyle: const TextStyle(
            color: onSurfaceVariantLight,
            fontSize: 14,
          ),
          hintStyle: const TextStyle(
            color: onSurfaceVariantLight,
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: spacingMD,
            vertical: spacingMD,
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: surfaceVariantLight,
          selectedColor: primaryLight.withAlpha((0.15 * 255).round()),
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.25,
            color: onSurfaceLight,
          ),
          side: const BorderSide(color: outlineLight),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingSM,
            vertical: spacingXS,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSM),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryColor,
          unselectedItemColor: onSurfaceVariantLight,
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: outlineLight,
          thickness: 1,
          space: 1,
        ),
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: spacingMD),
          textColor: onSurfaceLight,
          iconColor: onSurfaceVariantLight,
        ),
        dialogTheme: DialogThemeData(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLG),
          ),
          backgroundColor: surfaceLight,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSM),
          ),
          backgroundColor: onSurfaceLight,
          contentTextStyle: const TextStyle(
            color: surfaceLight,
            fontSize: 14,
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: primaryLight,
          secondary: secondaryLight,
          tertiary: accentLight,
          error: errorColor,
          surface: surfaceDark,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onTertiary: Colors.black,
          onError: Colors.white,
          onSurface: onSurfaceDark,
        ),
        typography: Typography.material2021(),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            height: 1.2,
            color: onSurfaceDark,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            height: 1.2,
            color: onSurfaceDark,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.25,
            height: 1.3,
            color: onSurfaceDark,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.4,
            color: onSurfaceDark,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.4,
            color: onSurfaceDark,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
            height: 1.5,
            color: onSurfaceDark,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.15,
            height: 1.5,
            color: onSurfaceDark,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.25,
            height: 1.5,
            color: onSurfaceDark,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            height: 1.4,
            color: onSurfaceDark,
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: backgroundDark,
          foregroundColor: onSurfaceDark,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: onSurfaceDark,
            letterSpacing: 0,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          color: surfaceDark,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            backgroundColor: primaryLight,
            foregroundColor: Colors.white,
            shadowColor: primaryLight.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSM),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingLG,
              vertical: spacingMD,
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            elevation: 0,
            backgroundColor: primaryLight,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSM),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingLG,
              vertical: spacingMD,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSM),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingLG,
              vertical: spacingMD,
            ),
            side: const BorderSide(color: primaryLight, width: 1.5),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusSM),
            borderSide: BorderSide(color: Colors.grey.shade800),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusSM),
            borderSide: BorderSide(color: Colors.grey.shade800),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusSM),
            borderSide: const BorderSide(color: primaryLight, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusSM),
            borderSide: const BorderSide(color: errorColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: spacingMD,
            vertical: spacingMD,
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.grey.shade900,
          selectedColor: primaryLight.withOpacity(0.2),
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.25,
            color: onSurfaceDark,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingSM,
            vertical: spacingXS,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSM),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 4,
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          backgroundColor: surfaceDark,
          selectedItemColor: primaryLight,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
      );

  // HERQ Light Theme - Professional, clean with HERQ brand colors
  static ThemeData get herqLightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: herqTeal,
          secondary: herqLime,
          tertiary: herqGraphite,
          error: errorColor,
          surface: herqWhite,
          surfaceContainerHighest: Color(0xFFF0F0F2),
          onPrimary: herqGraphite,
          onSecondary: herqGraphite,
          onTertiary: herqWhite,
          onSurface: herqGraphite,
          onSurfaceVariant: Color(0xFF6B6D71),
          outline: Color(0xFFD0D2D6),
          outlineVariant: Color(0xFFE5E7EB),
        ),
        typography: Typography.material2021(),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            height: 1.2,
            color: herqGraphite,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            height: 1.2,
            color: herqGraphite,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.25,
            height: 1.3,
            color: herqGraphite,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.4,
            color: herqGraphite,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.4,
            color: herqGraphite,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
            height: 1.5,
            color: herqGraphite,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.15,
            height: 1.5,
            color: herqGraphite,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.25,
            height: 1.5,
            color: herqGraphite,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            height: 1.4,
            color: herqGraphite,
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: herqWhite,
          foregroundColor: herqGraphite,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: herqGraphite,
            letterSpacing: 0,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          color: herqWhite,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            backgroundColor: herqTeal,
            foregroundColor: herqGraphite,
            shadowColor: herqTeal.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSM),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingLG,
              vertical: spacingMD,
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            elevation: 0,
            backgroundColor: herqTeal,
            foregroundColor: herqGraphite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSM),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingLG,
              vertical: spacingMD,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            elevation: 0,
            foregroundColor: herqTeal,
            side: const BorderSide(color: herqTeal, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSM),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingLG,
              vertical: spacingMD,
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: herqTeal,
          foregroundColor: herqGraphite,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLG),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          backgroundColor: herqWhite,
          selectedItemColor: herqTeal,
          unselectedItemColor: Color(0xFF6B6D71),
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
      );

  // HERQ Dark Theme - Bold, modern with HERQ brand colors
  static ThemeData get herqDarkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: herqTeal,
          secondary: herqLime,
          tertiary: herqTeal,
          error: errorColor,
          surface: herqGraphite,
          surfaceContainerHighest: Color(0xFF23252A),
          onPrimary: herqGraphite,
          onSecondary: herqGraphite,
          onTertiary: herqGraphite,
          onError: Colors.white,
          onSurface: herqWhite,
          onSurfaceVariant: Color(0xFFB8BABD),
          outline: Color(0xFF3A3C41),
          outlineVariant: Color(0xFF2A2C31),
        ),
        typography: Typography.material2021(),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            height: 1.2,
            color: herqWhite,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            height: 1.2,
            color: herqWhite,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.25,
            height: 1.3,
            color: herqWhite,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.4,
            color: herqWhite,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.4,
            color: herqWhite,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
            height: 1.5,
            color: herqWhite,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.15,
            height: 1.5,
            color: herqWhite,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.25,
            height: 1.5,
            color: herqWhite,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            height: 1.4,
            color: herqWhite,
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: herqCharcoal,
          foregroundColor: herqWhite,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: herqWhite,
            letterSpacing: 0,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          color: herqGraphite,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            backgroundColor: herqTeal,
            foregroundColor: herqGraphite,
            shadowColor: herqTeal.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSM),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingLG,
              vertical: spacingMD,
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            elevation: 0,
            backgroundColor: herqTeal,
            foregroundColor: herqGraphite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSM),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingLG,
              vertical: spacingMD,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            elevation: 0,
            foregroundColor: herqTeal,
            side: const BorderSide(color: herqTeal, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSM),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingLG,
              vertical: spacingMD,
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: herqTeal,
          foregroundColor: herqGraphite,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLG),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          backgroundColor: herqGraphite,
          selectedItemColor: herqTeal,
          unselectedItemColor: Color(0xFF6B6D71),
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
      );
}
