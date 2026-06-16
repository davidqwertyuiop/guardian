import 'package:flutter/material.dart';
import '../theme/light_theme.dart';
import '../theme/dark_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => getLightTheme();
  static ThemeData get darkTheme => getDarkTheme();
}
