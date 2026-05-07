import 'package:flutter/material.dart';

class AppColors {
  // Brand greens
  static const green = Color(0xFF008000);
  static const greenDark = Color(0xFF006000);
  static const greenLight = Color(0xFFE8F5E9);
  static const greenMid = Color(0xFFC8E6C9);

  // Accent colors
  static const blue = Color(0xFF1565C0);
  static const blueLight = Color(0xFFE3F2FD);
  static const purple = Color(0xFF6A1B9A);
  static const purpleLight = Color(0xFFF3E5F5);
  static const orange = Color(0xFFE65100);
  static const orangeLight = Color(0xFFFFF3E0);
  static const red = Color(0xFFC62828);
  static const redLight = Color(0xFFFFEBEE);

  // ── Light theme surfaces ──
  static const bg = Color(0xFFF5F8F5);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE0EDE0);
  static const textPrimary = Color(0xFF1A2E1A);
  static const textSub = Color(0xFF546E54);
  static const textMuted = Color(0xFF90A890);

  // ── Dark theme surfaces ──
  static const darkBg = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkSurfaceVariant = Color(0xFF162032);
  static const darkBorder = Color(0xFF334155);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSub = Color(0xFF94A3B8);
  static const darkTextMuted = Color(0xFF64748B);

  // ── Dark accent variants ──
  static const darkGreenLight = Color(0xFF1B3A1B);
  static const darkBlueLight = Color(0xFF172554);
  static const darkPurpleLight = Color(0xFF2E1065);
  static const darkOrangeLight = Color(0xFF431407);
  static const darkRedLight = Color(0xFF450A0A);
}

/// Returns appropriate colors based on the current brightness.
class AppThemeColors {
  final Brightness brightness;
  const AppThemeColors(this.brightness);

  bool get isDark => brightness == Brightness.dark;

  Color get bg => isDark ? AppColors.darkBg : AppColors.bg;
  Color get surface => isDark ? AppColors.darkSurface : AppColors.surface;
  Color get surfaceVariant => isDark ? AppColors.darkSurfaceVariant : AppColors.bg;
  Color get border => isDark ? AppColors.darkBorder : AppColors.border;
  Color get textPrimary => isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
  Color get textSub => isDark ? AppColors.darkTextSub : AppColors.textSub;
  Color get textMuted => isDark ? AppColors.darkTextMuted : AppColors.textMuted;

  Color get greenLight => isDark ? AppColors.darkGreenLight : AppColors.greenLight;
  Color get blueLight => isDark ? AppColors.darkBlueLight : AppColors.blueLight;
  Color get purpleLight => isDark ? AppColors.darkPurpleLight : AppColors.purpleLight;
  Color get orangeLight => isDark ? AppColors.darkOrangeLight : AppColors.orangeLight;
  Color get redLight => isDark ? AppColors.darkRedLight : AppColors.redLight;
}

/// Extension to easily access theme-aware colors from BuildContext.
extension AppThemeColorsExtension on BuildContext {
  AppThemeColors get appColors =>
      AppThemeColors(Theme.of(this).brightness);
}

ThemeData buildAppTheme({bool dark = false}) {
  final colorScheme = dark
      ? const ColorScheme.dark(
          primary: AppColors.green,
          secondary: AppColors.greenLight,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          surfaceContainerHighest: AppColors.darkBg,
          outline: AppColors.darkBorder,
        )
      : const ColorScheme.light(
          primary: AppColors.green,
          secondary: AppColors.greenLight,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          surfaceContainerHighest: AppColors.bg,
          outline: AppColors.border,
        );

  final bg = dark ? AppColors.darkBg : AppColors.bg;
  final surface = dark ? AppColors.darkSurface : AppColors.surface;
  final onSurface = dark ? AppColors.darkTextPrimary : AppColors.textPrimary;
  final border = dark ? AppColors.darkBorder : AppColors.border;
  final inputFill = dark ? AppColors.darkSurfaceVariant : AppColors.bg;
  final textMuted = dark ? AppColors.darkTextMuted : AppColors.textMuted;

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: 'sans-serif',
    scaffoldBackgroundColor: bg,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: surface,
      foregroundColor: onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border),
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
      fillColor: inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.green, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: textMuted),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: AppColors.green,
      unselectedItemColor: textMuted,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
    ),
    dividerTheme: DividerThemeData(color: border, space: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.green),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surface,
      contentTextStyle: TextStyle(color: onSurface),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.green,
      foregroundColor: Colors.white,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.green;
        return null;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.green.withValues(alpha: 0.5);
        return null;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.green;
        return null;
      }),
    ),
  );
}
