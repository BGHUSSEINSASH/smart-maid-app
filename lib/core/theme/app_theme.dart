import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Primary Green palette
  static const Color primary = Color(0xFF1BFFFF); // Royal Glass cyan
  static const Color primaryDark = Color(0xFF2E3192); // Royal Glass deep blue
  static const Color primaryLight = Color(0xFFE6FFFF); // Royal Glass light
  static const Color primaryLighter = Color(0xFFF2FFFF);

  // Accent colors (new)
  static const Color accentTeal = Color(0xFFA8E6D0);
  static const Color accentWarm = Color(0xFFF0E8E0);
  static const Color accentDark = Color(0xFF1A5E4F);

  // Neutrals
  static const Color bg = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF8FAFC);
  static const Color surfaceAlt = Color(0xFFF0F4FF);
  static const Color ink = Color(0xFF1A1F36);
  static const Color muted = Color(0xFF8A94A6);
  static const Color stroke = Color(0xFFE2E8F0);

  // Semantic colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1F5E8);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDEE6F8);
  static const Color amber = Color(0xFFFFC107);

  // Dark palette
  static const Color darkBg = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF1A1D27);
  static const Color darkSurfaceSoft = Color(0xFF252836);
  static const Color darkSurfaceAlt = Color(0xFF1F2937);
  static const Color darkInk = Color(0xFFF0F4FF);
  static const Color darkMuted = Color(0xFF6B7280);
  static const Color darkStroke = Color(0xFF2D3149);
}

class AppShadow {
  AppShadow._();

  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 24, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> deep = [
    BoxShadow(color: Color(0x26000000), blurRadius: 40, offset: Offset(0, 12)),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(color: Color(0x12000000), blurRadius: 20, offset: Offset(0, 6)),
  ];
}

class AppTheme {
  AppTheme._();

  static TextTheme _cairoText(Color color) =>
      GoogleFonts.cairoTextTheme().apply(bodyColor: color, displayColor: color);

  static ThemeData get light => _build(false);
  static ThemeData get dark => _build(true);

  static ThemeData _build(bool isDark) {
    final bg = isDark ? AppColors.darkBg : AppColors.bg;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final surfaceSoft = isDark
        ? AppColors.darkSurfaceSoft
        : AppColors.surfaceSoft;
    final ink = isDark ? AppColors.darkInk : AppColors.ink;
    final muted = isDark ? AppColors.darkMuted : AppColors.muted;
    final stroke = isDark ? AppColors.darkStroke : AppColors.stroke;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: isDark ? Brightness.dark : Brightness.light,
            surface: surface,
          ).copyWith(
            surface: surface,
            onSurface: ink,
            surfaceContainerHighest: surfaceSoft,
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
      scaffoldBackgroundColor: bg,
      textTheme: _cairoText(ink),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 2,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: GoogleFonts.cairo(
          color: ink,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
        iconTheme: IconThemeData(color: ink, size: 24),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: stroke, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: stroke, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.error, width: 2.5),
        ),
        hintStyle: TextStyle(
          color: muted,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        labelStyle: TextStyle(color: ink, fontWeight: FontWeight.w600),
        suffixIconColor: WidgetStateColor.resolveWith(
          (states) =>
              states.contains(WidgetState.focused) ? AppColors.primary : muted,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: AppColors.primary.withAlpha(60),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: stroke, width: 1),
        ),
        shadowColor: const Color(0x00000000),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        elevation: 8,
        shadowColor: Color(0x26000000),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 8,
        titleTextStyle: GoogleFonts.cairo(
          color: ink,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurfaceSoft : AppColors.ink,
        contentTextStyle: GoogleFonts.cairo(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.primary : muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primaryLight
              : stroke,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        thumbColor: AppColors.primary,
        inactiveTrackColor: stroke,
        overlayColor: AppColors.primary.withAlpha(40),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 12,
          elevation: 2,
        ),
      ),
      dividerTheme: DividerThemeData(color: stroke, thickness: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 8,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryLight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.cairo(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            );
          }
          return GoogleFonts.cairo(
            color: muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return IconThemeData(color: muted, size: 24);
        }),
      ),
    );
  }
}
