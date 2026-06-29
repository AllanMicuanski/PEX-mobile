import 'package:flutter/material.dart';

// Paleta Sizebay
class SizebayColors {
  static const Color coral = Color(0xFFBF512B); // Primária
  static const Color azulClaro = Color(0xFFD2ECFF); // Secundária
  static const Color bege = Color(0xFFE6D6CD); // Terciária
  static const Color offWhite = Color(0xFFF0F6F7); // Fundo
  static const Color preto = Color(0xFF000000); // Texto

  // Utilitárias
  static const Color verde = Color(0xFF4CAF50);
  static const Color laranja = Color(0xFFFFA726);
  static const Color vermelho = Color(0xFFEF5350);
  static const Color cinzaClaro = Color(0xFFF5F5F5);
  static const Color cinzaMedio = Color(0xFF9E9E9E);
  static const Color azul = Color(0xFF1E88E5);
}

// Theme Data
ThemeData getSizebayTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: SizebayColors.coral,
      onPrimary: Colors.white,
      primaryContainer: SizebayColors.azulClaro,
      onPrimaryContainer: SizebayColors.preto,
      secondary: SizebayColors.azulClaro,
      onSecondary: SizebayColors.preto,
      secondaryContainer: SizebayColors.bege,
      onSecondaryContainer: SizebayColors.preto,
      tertiary: SizebayColors.bege,
      onTertiary: SizebayColors.preto,
      error: SizebayColors.vermelho,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: SizebayColors.preto,
    ),
    scaffoldBackgroundColor: SizebayColors.offWhite,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: SizebayColors.preto,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: SizebayColors.coral,
      unselectedItemColor: SizebayColors.cinzaMedio,
      elevation: 8,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: SizebayColors.coral,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SizebayColors.coral,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: SizebayColors.coral),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: SizebayColors.preto,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: SizebayColors.preto,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: SizebayColors.preto,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: SizebayColors.preto,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: SizebayColors.preto,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: SizebayColors.preto,
      ),
    ),
  );
}
