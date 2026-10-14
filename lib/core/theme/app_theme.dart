import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TSportColors {
  // Exact Design System Tokens:
  static const Color vantablack = Color(0xFF000000); // #000000 True Pitch Black
  static const Color charcoal = Color(0xFF141414); // #141414 Card & Surface
  static const Color darkGrey = Color(0xFF1E1E1E); // #1E1E1E Elevated Surface
  static const Color border = Color(0xFF282828); // #282828 Subtle Borders

  // Primary Sports Brand Accents
  static const Color orange =
      Color(0xFFFF5500); // #FF5500 Pure High-Energy Orange Accent
  static const Color orangeGlow = Color(0x33FF5500); // 20% Alpha Glow

  // Status & Matrix Indicators
  static const Color limeGreen =
      Color(0xFFCCFF00); // #CCFF00 Volt Lime (Available slot indicator)
  static const Color green = Color(0xFF00E676); // Confirmed match status
  static const Color amber = Color(0xFFFF9900); // Cash reservation hold
  static const Color amberWarning = amber; // Alias for cash hold
  static const Color errorRed = Color(0xFFFF3333); // Errors / cancellations

  // Typography Tokens
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF888888);
  static const Color textDim = Color(0xFF555555);

  // Backward-compatibility aliases
  static const Color trueBlack = vantablack;
  static const Color gunmetal = charcoal;
  static const Color acidYellow = orange;
  static const Color electricVolt = orange;
  static const Color midnightBg = vantablack;
  static const Color slateCard = charcoal;
  static const Color slateElevated = darkGrey;
  static const Color slateBorder = border;
  static const Color textPrimary = textWhite;
  static const Color textSecondary = textMuted;
  static const Color textTertiary = textDim;
}

class AppTheme {
  static ThemeData get darkTheme => getTheme(const Locale('en'));

  static ThemeData getTheme(Locale locale) {
    final isAr = locale.languageCode == 'ar';

    final textTheme = isAr
        ? GoogleFonts.cairoTextTheme().copyWith(
            displayLarge: GoogleFonts.cairo(
              color: TSportColors.textWhite,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
            displayMedium: GoogleFonts.cairo(
              color: TSportColors.textWhite,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
            titleLarge: GoogleFonts.cairo(
              color: TSportColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            bodyLarge: GoogleFonts.cairo(
              color: TSportColors.textWhite,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            bodyMedium: GoogleFonts.cairo(
              color: TSportColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            bodySmall: GoogleFonts.cairo(
              color: TSportColors.textDim,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            labelLarge: GoogleFonts.cairo(
              color: TSportColors.textWhite,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          )
        : GoogleFonts.outfitTextTheme().copyWith(
            displayLarge: GoogleFonts.outfit(
              color: TSportColors.textWhite,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
            displayMedium: GoogleFonts.outfit(
              color: TSportColors.textWhite,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
            titleLarge: GoogleFonts.outfit(
              color: TSportColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            bodyLarge: GoogleFonts.outfit(
              color: TSportColors.textWhite,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            bodyMedium: GoogleFonts.outfit(
              color: TSportColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            bodySmall: GoogleFonts.outfit(
              color: TSportColors.textDim,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            labelLarge: GoogleFonts.outfit(
              color: TSportColors.textWhite,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TSportColors.vantablack,
      primaryColor: TSportColors.orange,
      fontFamily: isAr
          ? GoogleFonts.cairo().fontFamily
          : GoogleFonts.outfit().fontFamily,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: TSportColors.orange,
        surface: TSportColors.charcoal,
        error: TSportColors.errorRed,
        onPrimary: TSportColors.textWhite,
        onSurface: TSportColors.textWhite,
      ),
      cardTheme: CardTheme(
        color: TSportColors.charcoal,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: TSportColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TSportColors.orange,
          foregroundColor: TSportColors.textWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: isAr
              ? GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 15)
              : GoogleFonts.outfit(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 0.5),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: TSportColors.vantablack,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: TSportColors.textWhite),
      ),
    );
  }
}
