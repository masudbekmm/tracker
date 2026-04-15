import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0F0F0F);
  static const surface = Color(0xFF1A1A1A);
  static const card = Color(0xFF222222);
  static const accent = Color(0xFF00BFA5);
  static const accentDim = Color(0xFF00897B);
  static const textPrimary = Color(0xFFEEEEEE);
  static const textSecondary = Color(0xFF888888);
  static const done = Color(0xFF00BFA5);
  static const partial = Color(0xFFFFB300);
  static const missed = Color(0xFF333333);
  static const error = Color(0xFFCF6679);
}

final appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.dark(
    surface: AppColors.surface,
    primary: AppColors.accent,
    secondary: AppColors.accentDim,
    error: AppColors.error,
  ),
  cardTheme: const CardThemeData(
    color: AppColors.card,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
    ),
    iconTheme: IconThemeData(color: AppColors.textPrimary),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.accent,
    unselectedItemColor: AppColors.textSecondary,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 24),
    titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
    titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 16),
    bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 15),
    bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 13),
    labelSmall: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 0.5),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.card,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
    ),
    hintStyle: const TextStyle(color: AppColors.textSecondary),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFF2A2A2A),
    thickness: 1,
    space: 1,
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.accent;
      return AppColors.card;
    }),
    checkColor: WidgetStateProperty.all(AppColors.background),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    side: const BorderSide(color: AppColors.textSecondary, width: 1.5),
  ),
);