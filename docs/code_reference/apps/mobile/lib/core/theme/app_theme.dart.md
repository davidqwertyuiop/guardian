# app_theme.dart

* **File Path:** `apps/mobile/lib/core/theme/app_theme.dart`
* **Type:** `DART`

---

```dart
import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => getLightTheme();
  static ThemeData get darkTheme => getDarkTheme();
}

```
