import 'package:flutter/material.dart';

// Paleta de marca e status (acentos que valem em tema claro e escuro).
class SizebayColors {
  static const Color coral = Color(0xFFBF512B);
  static const Color coralClaro = Color(0xFFF7663D);
  static const Color azulClaro = Color(0xFFD2ECFF);
  static const Color bege = Color(0xFFE6D6CD);

  static const Color verde = Color(0xFF4CAF50);
  static const Color laranja = Color(0xFFFFA726);
  static const Color vermelho = Color(0xFFEF5350);
  static const Color azul = Color(0xFF1E88E5);

  // Neutros legados — em migração para o colorScheme (dark mode).
  static const Color preto = Color(0xFF000000);
  static const Color offWhite = Color(0xFFF0F6F7);
  static const Color cinzaClaro = Color(0xFFF5F5F5);
  static const Color cinzaMedio = Color(0xFF9E9E9E);
}

// Tokens de design compartilhados pelo visual "soft".
class AppRadius {
  static const double card = 20;
  static const double chip = 10;
  static const double field = 14;
}

ThemeData getSizebayTheme() => _buildTheme(
  ColorScheme.fromSeed(
    seedColor: SizebayColors.coral,
    brightness: Brightness.light,
  ).copyWith(primary: SizebayColors.coral),
);

ThemeData getSizebayDarkTheme() => _buildTheme(
  ColorScheme.fromSeed(
    seedColor: SizebayColors.coral,
    brightness: Brightness.dark,
  ),
);

ThemeData _buildTheme(ColorScheme scheme) {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surfaceContainerLow,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surfaceContainerLow,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primaryContainer,
      elevation: 3,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: scheme.primary),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
    textTheme: _textTheme,
  );
}

// Escala tipográfica (sem cor fixa — a cor vem do colorScheme, p/ dark mode).
const TextTheme _textTheme = TextTheme(
  displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
  displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
  headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
  titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
);
