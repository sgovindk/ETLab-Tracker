import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ──────────────────────────────────────────────────────────────────
///  INDUSTRIAL-GRADE DARK THEME
/// ──────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  // ── Palette ────────────────────────────────────────────────────
  static const Color background   = Color(0xFF050508);
  static const Color surface      = Color(0xFF0E0E12);
  static const Color card         = Color(0xFF15151B);
  static const Color cardBorder   = Color(0xFF24242E);
  static const Color divider      = Color(0xFF1E1E28);

  static const Color accent       = Color(0xFF00E5FF);   // cyan
  static const Color accentDim    = Color(0xFF006978);
  static const Color secondary    = Color(0xFF7C4DFF);   // deep purple
  static const Color success      = Color(0xFF00E676);
  static const Color warning      = Color(0xFFFFAB00);
  static const Color danger       = Color(0xFFFF1744);

  static const Color textPrimary   = Color(0xFFEEEEEE);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textTertiary  = Color(0xFF616161);

  // ── Radii ──────────────────────────────────────────────────────
  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 24;

  // ── Shadows ────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.35),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ── Typography helpers ─────────────────────────────────────────
  static TextStyle _inter({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = textPrimary,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle _mono({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color color = textPrimary,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  // ── Public text styles ─────────────────────────────────────────
  static TextStyle get headlineLarge =>
      _inter(size: 28, weight: FontWeight.w700, letterSpacing: -0.5);
  static TextStyle get headlineMedium =>
      _inter(size: 22, weight: FontWeight.w700, letterSpacing: -0.3);
  static TextStyle get headlineSmall =>
      _inter(size: 18, weight: FontWeight.w600);
  static TextStyle get titleMedium =>
      _inter(size: 16, weight: FontWeight.w600);
  static TextStyle get titleSmall =>
      _inter(size: 14, weight: FontWeight.w600, color: textSecondary);
  static TextStyle get bodyLarge =>
      _inter(size: 15, weight: FontWeight.w400);
  static TextStyle get bodyMedium =>
      _inter(size: 13, weight: FontWeight.w400, color: textSecondary);
  static TextStyle get bodySmall =>
      _inter(size: 11, weight: FontWeight.w400, color: textTertiary);
  static TextStyle get labelLarge =>
      _inter(size: 13, weight: FontWeight.w600, letterSpacing: 1.1);
  static TextStyle get monoLarge =>
      _mono(size: 32, weight: FontWeight.w700);
  static TextStyle get monoMedium =>
      _mono(size: 20, weight: FontWeight.w600);
  static TextStyle get monoSmall =>
      _mono(size: 14, weight: FontWeight.w500, color: textSecondary);

  // ── Card decoration ────────────────────────────────────────────
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: cardBorder, width: 1),
      );

  static BoxDecoration glowDecoration(Color glow) => BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: glow.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(color: glow.withOpacity(0.08), blurRadius: 24, spreadRadius: 2),
        ],
      );

  // ── ThemeData ──────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: secondary,
          surface: surface,
          error: danger,
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: textPrimary,
          onError: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: headlineMedium,
          iconTheme: const IconThemeData(color: textSecondary),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: accent,
          unselectedItemColor: textTertiary,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: _inter(size: 11, weight: FontWeight.w600),
          unselectedLabelStyle: _inter(size: 11, weight: FontWeight.w400),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            side: const BorderSide(color: cardBorder),
          ),
        ),
        dividerTheme: const DividerThemeData(color: divider, thickness: 1),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusSm),
            borderSide: const BorderSide(color: cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusSm),
            borderSide: const BorderSide(color: cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusSm),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
          hintStyle: _inter(size: 14, color: textTertiary),
          labelStyle: _inter(size: 14, color: textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSm),
            ),
            textStyle: _inter(size: 15, weight: FontWeight.w700),
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: accent,
            textStyle: _inter(size: 14, weight: FontWeight.w600),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: card,
          contentTextStyle: _inter(size: 14, color: textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
            side: const BorderSide(color: cardBorder),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
}
