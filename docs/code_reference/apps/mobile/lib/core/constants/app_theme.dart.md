# app_theme.dart

* **File Path:** `apps/mobile/lib/core/constants/app_theme.dart`
* **Type:** `DART`

---

```dart
import 'package:flutter/material.dart';
import '../theme/light_theme.dart';
import '../theme/dark_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => getLightTheme();
  static ThemeData get darkTheme => getDarkTheme();
}

```
