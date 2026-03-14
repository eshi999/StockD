import 'package:flutter/material.dart';

class StockDTheme {
  // Color Scheme
  static const Color bg = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color card = Color(0xFF1A1A26);
  static const Color border = Color(0xFF2A2A3E);
  static const Color sage = Color(0xFF00FFB2);
  static const Color sageGlow = Color(0x2200FFB2);
  static const Color gold = Color(0xFFFFD166);
  static const Color danger = Color(0xFFFF4060);
  static const Color info = Color(0xFF4CC9F0);
  static const Color textPrimary = Color(0xFFF0F0F8);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color textMuted = Color(0xFF44445A);

  // Gradients
  static const LinearGradient gradient = LinearGradient(
    colors: [sage, Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Typography
  static const TextStyle displayLarge = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -1.5,
    height: 1.0,
  );

  static const TextStyle headingLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.6,
  );

  static const TextStyle bodyMono = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: sage,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: textMuted,
    letterSpacing: 1.5,
  );

  // Theming
  static ThemeData get theme => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: sage,
        secondary: gold,
        error: danger,
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border),
        ),
      ));
}
