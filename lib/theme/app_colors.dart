import 'package:flutter/material.dart';

/// Tara Swim Arena Workout - Brand Colors extracted from logo
class AppColors {
  // Primary brand navy tones (exact match with logo background)
  static const Color navyBackground = Color(0xFF071C3D);
  static const Color navyDark = Color(0xFF041124);
  static const Color navyLight = Color(0xFF0E2A54);
  static const Color navySurface = Color(0xFF0B2144);

  // Vibrant wave / aquatic accents (exact match with logo wave)
  static const Color waveCyan = Color(0xFF00B0C9);
  static const Color waveCyanLight = Color(0xFF38D5EC);
  static const Color waveCyanDark = Color(0xFF008FA3);
  static const Color waveCyanSoft = Color(0xFFE0F7FA);

  // Swimmer energetic accents (exact match with logo swimmer)
  static const Color swimmerOrange = Color(0xFFFE6034);
  static const Color swimmerCoral = Color(0xFFFD354D);
  static const Color swimmerCoralSoft = Color(0xFFFFEBEE);

  // Light dashboard surfaces & neutrals
  static const Color scaffoldLight = Color(0xFFF3F7FA);
  static const Color cardSurface = Colors.white;
  static const Color textPrimary = Color(0xFF071C3D);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Dark inputs (for Login Page)
  static const Color inputFillDark = Color(0xFF0D254C);
  static const Color inputBorderDark = Color(0xFF1B3B6F);
  static const Color inputHintDark = Color(0xFF7E97B8);

  // Brand Gradients
  static const LinearGradient swimmerGradient = LinearGradient(
    colors: [swimmerOrange, swimmerCoral],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient waveGradient = LinearGradient(
    colors: [Color(0xFF0091B5), waveCyan],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient loginBackgroundGradient = LinearGradient(
    colors: [Color(0xFF0B2247), navyBackground, Color(0xFF041124)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient drawerHeaderGradient = LinearGradient(
    colors: [navyBackground, Color(0xFF0E2E5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
