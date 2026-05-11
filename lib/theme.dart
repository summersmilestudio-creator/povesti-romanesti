import 'package:flutter/material.dart';

class AppColors {
  static const Color cream = Color(0xFFFFF8F0);
  static const Color warmBrown = Color(0xFF4A3728);
  static const Color lightBrown = Color(0xFF6B5344);
  static const Color forestGreen = Color(0xFF2D5F2D);
  static const Color golden = Color(0xFFD4A574);
  static const Color lightGolden = Color(0xFFE8C99B);
  static const Color softPink = Color(0xFFF5E1D0);
  static const Color cardBackground = Color(0xFFFFF3E6);

  // Night mode colors
  static const Color nightBackground = Color(0xFF2C2416);
  static const Color nightCard = Color(0xFF3D3226);
  static const Color nightText = Color(0xFFE8D5C0);
  static const Color nightAccent = Color(0xFFD4A574);
}

ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.cream,
    colorScheme: ColorScheme.light(
      primary: AppColors.forestGreen,
      secondary: AppColors.golden,
      surface: AppColors.cream,
      onPrimary: Colors.white,
      onSecondary: AppColors.warmBrown,
      onSurface: AppColors.warmBrown,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cream,
      foregroundColor: AppColors.warmBrown,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.warmBrown,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: 2,
      shadowColor: AppColors.golden.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.cream,
      selectedItemColor: AppColors.forestGreen,
      unselectedItemColor: AppColors.lightBrown,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.warmBrown,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.warmBrown,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: AppColors.warmBrown,
        fontSize: 18,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        color: AppColors.lightBrown,
        fontSize: 16,
      ),
    ),
  );
}

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.nightBackground,
    colorScheme: ColorScheme.dark(
      primary: AppColors.nightAccent,
      secondary: AppColors.golden,
      surface: AppColors.nightBackground,
      onPrimary: AppColors.nightBackground,
      onSecondary: AppColors.nightText,
      onSurface: AppColors.nightText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.nightBackground,
      foregroundColor: AppColors.nightText,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.nightText,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.nightCard,
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.nightBackground,
      selectedItemColor: AppColors.nightAccent,
      unselectedItemColor: AppColors.nightText,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.nightText,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.nightText,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: AppColors.nightText,
        fontSize: 18,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        color: AppColors.nightText,
        fontSize: 16,
      ),
    ),
  );
}
