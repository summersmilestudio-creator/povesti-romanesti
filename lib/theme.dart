import 'package:flutter/material.dart';

/// Paletă „cosmic" — în stilul iconiței: gradient mov profund, carduri de
/// sticlă (alb translucid peste mov), accent auriu (stea) + teal (cotor carte),
/// text lavandă. Numele vechi sunt păstrate ca să nu rup ecranele existente,
/// dar valorile sunt remapate la noul stil.
class AppColors {
  // Fundaluri (mov profund, ușor diferite ca isDark să rămână valid)
  static const Color cream = Color(0xFF241046); // fundal mod „zi"
  static const Color cardBackground = Color(0x1FFFFFFF); // card sticlă (12% alb)
  static const Color softPink = Color(0xFF7E5BC4); // tentă mov pt gradiente

  // Text
  static const Color warmBrown = Color(0xFFEDE6FF); // text principal lavandă
  static const Color lightBrown = Color(0xFFB3A2D9); // text secundar lavandă

  // Accente
  static const Color golden = Color(0xFFFFD98A); // auriu stea
  static const Color lightGolden = Color(0xFFFFE9B8);
  static const Color forestGreen = Color(0xFF4DD0E1); // teal cotor carte

  // „Night mode" — variantă și mai întunecată, tot cosmic
  static const Color nightBackground = Color(0xFF160A30);
  static const Color nightCard = Color(0x1AFFFFFF); // card sticlă (10% alb)
  static const Color nightText = Color(0xFFEDE6FF);
  static const Color nightAccent = Color(0xFFFFD98A);

  // Helpers gradient (folosite de fundalul cosmic)
  static const Color cosmicTop = Color(0xFF3A1A6E);
  static const Color cosmicMid = Color(0xFF241046);
  static const Color cosmicBottom = Color(0xFF140826);
  static const Color starGlow = Color(0xFFFFC95B);
  static const Color glassStroke = Color(0x33FFFFFF);
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
