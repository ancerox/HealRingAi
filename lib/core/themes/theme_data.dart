import 'package:flutter/material.dart';

class CustomTheme {
  //Success Color
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

  // Text style for headings
  static const TextStyle headingStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  // iOS/Text Small style
  static TextStyle iosTextSmall = const TextStyle(
    color: Color.fromRGBO(174, 174, 178, 1),
    fontFamily: 'SF Pro Text',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 16.71 / 14, // Line height 16.71px
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
  static const Color surfacePrimary =
      Color(0xFF4B4B4B); // was calendarSelectedDay
  static const Color surfaceSecondary =
      Color(0xFF151515); // was calendarFutureDay
  static const Color surfaceTertiary = Color(0xFF202020); // was calendarPastDay

  static const Color textColorSecondary = Color(0xFFAEAEB2);
}
