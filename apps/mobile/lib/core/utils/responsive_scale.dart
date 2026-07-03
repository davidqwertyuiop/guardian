import 'package:flutter/material.dart';

/// Responsive scaling helper class.
/// Automatically adjusts font, padding, and container sizes based on screen width
/// relative to the iOS design spec base width of 393.0.
class ResponsiveScale {
  ResponsiveScale._();

  /// Base layout design screen width (e.g., iPhone 15/14 Pro width)
  static const double _designWidth = 393.0;

  /// Calculates scaled dimension based on screen width.
  /// Clamps the scale factor between 0.85 and 1.3 to avoid extreme sizing on tablets or tiny screens.
  static double scaleWidth(BuildContext context, double value) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final factor = (screenWidth / _designWidth).clamp(0.85, 1.3);
    return value * factor;
  }

  /// Calculates scaled text size (SP).
  static double scaleText(BuildContext context, double value) {
    return scaleWidth(context, value);
  }
}

/// Easy-to-use extension on [BuildContext] for clean responsive layout code.
extension ResponsiveScaleExtension on BuildContext {
  /// Responsive width scaling: context.w(40)
  double w(double value) => ResponsiveScale.scaleWidth(this, value);

  /// Responsive text scaling: context.sp(16)
  double sp(double value) => ResponsiveScale.scaleText(this, value);
}
