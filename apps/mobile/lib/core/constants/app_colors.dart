import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF7C60FF);
  static const Color primaryDark = Color(0xFF6346E0);
  static const Color primaryLight = Color(0xFF9E8BFF);

  // Background colors
  static const Color darkBackground = Color(0xFF080808);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF7F7FA);
  static const Color cardDark = Color(0xFF16161A);
  static const Color elevatedDark = Color(0xFF232328);

  // Grey shades
  static const Color greyText = Color(0xFF6E6E7A);
  static const Color greyLight = Color(0xFFF3F3F6);
  static const Color greyMedium = Color(0xFFE2E2E8);
  static const Color greyDark = Color(0xFF2C2C2E);
  static const Color borderLight = Color(0xFFE4E4E8);
  static const Color borderDark = Color(0xFF34343B);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surface(BuildContext context) =>
      isDark(context) ? cardDark : Colors.white;

  static Color elevatedSurface(BuildContext context) =>
      isDark(context) ? elevatedDark : cardLight;

  static Color border(BuildContext context) =>
      isDark(context) ? borderDark : borderLight;

  static Color text(BuildContext context) =>
      isDark(context) ? Colors.white : Colors.black;

  static Color mutedText(BuildContext context) =>
      isDark(context) ? Colors.white70 : greyText;

  // Accent Colors for background blobs
  static const Color blobCream = Color(0xFFFBE4D5);
  static const Color blobGreen = Color(0xFFD4EBD6);
  static const Color blobCyan = Color(0xFFD3EDF4);
  static const Color blobPink = Color(0xFFFBCFCD);

  // Nav bar selection gradient colors
  static const List<Color> navBarGradient = [
    Color(0xFFB469E3),
    Color(0xFFFFAADE),
  ];
}
