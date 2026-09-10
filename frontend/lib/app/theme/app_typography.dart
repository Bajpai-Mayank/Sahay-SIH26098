import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SAHAY-AI Typography System powered by Google Fonts Inter.
/// Clean, human-centered typography hierarchy with comfortable line heights.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color textColor, Color secondaryColor) {
    return GoogleFonts.interTextTheme(
      TextTheme(
        // Display: 28–32 px
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: -0.6,
          height: 1.25,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: -0.4,
          height: 1.3,
        ),

        // Page title: 24–28 px
        headlineLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: -0.3,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: -0.2,
          height: 1.3,
        ),

        // Section title: 18–20 px
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: -0.1,
          height: 1.35,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1.35,
        ),

        // Card title: 15–17 px
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1.4,
        ),

        // Body: 14–16 px
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textColor,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textColor,
          height: 1.45,
        ),

        // Secondary: 12–14 px
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: secondaryColor,
          height: 1.4,
        ),

        // Caption: 11–12 px
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: secondaryColor,
          letterSpacing: 0.2,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
