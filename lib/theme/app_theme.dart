import 'package:flutter/material.dart';

class AppColors {
  static const green = Color(0xFF008000);
  static const greenDark = Color(0xFF006000);
  static const greenLight = Color(0xFFE8F5E9);
  static const greenMid = Color(0xFFC8E6C9);
  static const blue = Color(0xFF1565C0);
  static const blueLight = Color(0xFFE3F2FD);
  static const purple = Color(0xFF6A1B9A);
  static const purpleLight = Color(0xFFF3E5F5);
  static const orange = Color(0xFFE65100);
  static const orangeLight = Color(0xFFFFF3E0);
  static const red = Color(0xFFC62828);
  static const redLight = Color(0xFFFFEBEE);
  static const bg = Color(0xFFF5F8F5);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE0EDE0);
  static const textPrimary = Color(0xFF1A2E1A);
  static const textSub = Color(0xFF546E54);
  static const textMuted = Color(0xFF90A890);
}

ThemeData buildAppTheme({bool dark = false}) {
  final colorScheme = dark
      ? ColorScheme.dark(
          primary: AppColors.green,
          secondary: AppColors.greenLight,
          surface: const Color(0xFF1A2E1A),
          onSurface: const Color(0xFFE8F5E8),
          surfaceContainerHighest: const Color(0xFF0D1F0D),
        )
      : ColorScheme.light(
          primary: AppColors.green,
          secondary: AppColors.greenLight,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          surfaceContainerHighest: AppColors.bg,
        );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: 'sans-serif',
    scaffoldBackgroundColor: dark ? const Color(0xFF0D1F0D) : AppColors.bg,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: dark ? const Color(0xFF1A2E1A) : AppColors.surface,
      foregroundColor: dark ? const Color(0xFFE8F5E8) : AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: dark ? const Color(0xFF1A2E1A) : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: dark ? const Color(0xFF2A3F2A) : AppColors.border),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.green,
        side: const BorderSide(color: AppColors.green, width: 1.5),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? const Color(0xFF112011) : AppColors.bg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.green, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.green,
      unselectedItemColor: AppColors.textMuted,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
      unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, space: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.green),
  );
}
