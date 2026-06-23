import 'package:flutter/material.dart';

class AdaptiveLayout {
  AdaptiveLayout._();

  static bool isLandscape(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.landscape;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide >= 600;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).height;
  }

  static const double _designWidth = 393.0;
  static const double _designHeight = 852.0;

  static double w(BuildContext context, double width) {
    return width * (screenWidth(context) / _designWidth);
  }

  static double h(BuildContext context, double height) {
    return height * (screenHeight(context) / _designHeight);
  }

  static double sp(BuildContext context, double fontSize) {
    final scale = screenWidth(context) / _designWidth;
    return fontSize * (isTablet(context) ? scale * 0.85 : scale);
  }

  static double padding(BuildContext context, double val) {
    return val * (screenWidth(context) / _designWidth);
  }

  /// Maximum width for page content on tablets.
  /// Keeps content centred and readable on wide screens (iPad, iPad Pro).
  static double maxContentWidth(BuildContext context) {
    return isTablet(context) ? 480.0 : double.infinity;
  }

  /// Horizontal padding that increases on wider screens.
  static double responsiveHorizontalPadding(BuildContext context) {
    final w = screenWidth(context);
    if (w >= 768) return (w - 480) / 2;   // iPad: centre the content column
    if (w >= 600) return 40.0;             // Small tablet
    return 0.0;                            // Phone: callers use their own padding
  }
}

