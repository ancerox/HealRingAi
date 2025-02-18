import 'package:flutter/material.dart';

class CustomTheme {
  // Success Color
  static const Color successColor = Color(0xFF7FC855);

  // Icon color used in bluetooth icon
  static const Color iconColor = Colors.white;

  // Primary default color
  static const Color primaryDefault = Color(0xFF24DBC9);

  // Black color
  static const Color black = Color(0xFF060606);

  // Form colors
  static const Color formBackground = Color(0xFF202020);
  static const Color formBorder = Color(0xFF303030);

  // Typography Styles
  static const TextStyle headerXLarge = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontFamily: 'SFProDisplay',
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headerLarge = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontFamily: 'SFProDisplay',
    fontWeight: FontWeight.w600,
  );

  static const TextStyle textLarge = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontFamily: 'SFProText',
    fontWeight: FontWeight.w400,
  );

  static const TextStyle headerNormal = TextStyle(
    color: Colors.white,
    fontSize: 16,
    height: 22 / 16,
    fontFamily: 'SFProDisplay',
    fontWeight: FontWeight.w600,
  );

  static const TextStyle textNormal = TextStyle(
    color: Colors.white,
    fontSize: 16,
    height: 22 / 16,
    fontFamily: 'SFProText',
    fontWeight: FontWeight.w400,
  );

  static const TextStyle textSmallBold = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontFamily: 'SFProText',
    fontWeight: FontWeight.w600,
  );

  static const TextStyle textSmall = TextStyle(
    color: Color(0xFFAEAEB2),
    fontSize: 14,
    fontFamily: 'SFProText',
    fontWeight: FontWeight.w400,
  );

  static const TextStyle textXSmallBold = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontFamily: 'SFProText',
    fontWeight: FontWeight.w600,
  );

  static const TextStyle textXSmall = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontFamily: 'SFProText',
    fontWeight: FontWeight.w400,
  );

  // Button styling
  static const BorderSide buttonBorderSide = BorderSide(
    color: Colors.white,
    width: 1.0,
  );

  static final RoundedRectangleBorder buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(25.0),
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontFamily: 'SFProText',
    color: Colors.black,
  );

  // Ring glow effect
  static final BoxShadow ringGlow = BoxShadow(
    color: primaryDefault.withOpacity(0.4),
    blurRadius: 40,
    spreadRadius: 10,
  );

  static RadialGradient get radialGradient {
    return const RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        Color.fromARGB(255, 9, 66, 65), // Central color
        Color(0xFF111111), // Dark color towards the edges
      ],
      stops: [0.1, 1],
    );
  }

  // Surface colors
  static const Color surfacePrimary = Color(0xFF4B4B4B);
  static const Color surfaceSecondary = Color(0xFF151515);
  static const Color surfaceTertiary = Color(0xFF202020);

  static const Color textColorSecondary = Color(0xFFAEAEB2);
}
