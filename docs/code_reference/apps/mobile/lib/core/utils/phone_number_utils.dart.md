# phone_number_utils.dart

* **File Path:** `apps/mobile/lib/core/utils/phone_number_utils.dart`
* **Type:** `DART`

---

```dart
/// Per-country subscriber number length rules.
///
/// Values represent the expected number of *subscriber* digits (the part
/// that comes after the dial code). Falls back to 15 (E.164 max minus country
/// code) when a dial code is not in the map.
class PhoneNumberUtils {
  PhoneNumberUtils._();

  /// Map of dial code → expected subscriber digit count.
  /// Where a range exists the maximum is used as the cap.
  static const Map<String, int> _digitMap = {
    // ── Africa ──────────────────────────────────────────────
    '+234': 10, // Nigeria
    '+233': 9, // Ghana
    '+254': 9, // Kenya
    '+256': 9, // Uganda
    '+255': 9, // Tanzania
    '+251': 9, // Ethiopia
    '+212': 9, // Morocco
    '+20': 10, // Egypt
    '+27': 9, // South Africa
    '+263': 9, // Zimbabwe
    '+260': 9, // Zambia
    '+225': 10, // Côte d'Ivoire
    '+221': 9, // Senegal
    '+237': 9, // Cameroon
    '+243': 9, // DR Congo
    '+228': 8, // Togo
    '+229': 8, // Benin
    '+226': 8, // Burkina Faso
    '+224': 9, // Guinea
    '+232': 8, // Sierra Leone
    '+231': 7, // Liberia
    '+240': 9, // Equatorial Guinea
    '+241': 7, // Gabon
    '+242': 9, // Republic of Congo
    // ── Americas ─────────────────────────────────────────────
    '+1': 10, // USA / Canada / Caribbean
    '+52': 10, // Mexico
    '+55': 11, // Brazil
    '+54': 10, // Argentina
    '+57': 10, // Colombia
    '+56': 9, // Chile
    '+51': 9, // Peru
    '+58': 10, // Venezuela
    '+593': 9, // Ecuador
    '+591': 8, // Bolivia
    // ── Europe ───────────────────────────────────────────────
    '+44': 10, // UK
    '+49': 11, // Germany (max)
    '+33': 9, // France
    '+34': 9, // Spain
    '+39': 10, // Italy
    '+31': 9, // Netherlands
    '+32': 9, // Belgium
    '+41': 9, // Switzerland
    '+43': 11, // Austria
    '+46': 9, // Sweden
    '+47': 8, // Norway
    '+45': 8, // Denmark
    '+48': 9, // Poland
    '+380': 9, // Ukraine
    '+7': 10, // Russia / Kazakhstan
    '+30': 10, // Greece
    '+351': 9, // Portugal
    '+353': 9, // Ireland
    '+358': 10, // Finland
    // ── Middle East ──────────────────────────────────────────
    '+966': 9, // Saudi Arabia
    '+971': 9, // UAE
    '+970': 9, // Palestine
    '+962': 9, // Jordan
    '+961': 8, // Lebanon
    '+964': 10, // Iraq
    '+98': 10, // Iran
    '+90': 10, // Turkey
    // ── Asia Pacific ─────────────────────────────────────────
    '+91': 10, // India
    '+86': 11, // China
    '+81': 10, // Japan
    '+82': 10, // South Korea
    '+65': 8, // Singapore
    '+60': 9, // Malaysia
    '+62': 12, // Indonesia (max)
    '+63': 10, // Philippines
    '+66': 9, // Thailand
    '+84': 9, // Vietnam
    '+880': 10, // Bangladesh
    '+92': 10, // Pakistan
    '+94': 9, // Sri Lanka
    '+61': 9, // Australia
    '+64': 9, // New Zealand
    '+852': 8, // Hong Kong
    '+853': 8, // Macau
  };

  /// Returns the expected subscriber digit count for the given dial code.
  /// Falls back to 15 if the country is unknown.
  static int getMaxDigits(String dialCode) {
    return _digitMap[dialCode] ?? 15;
  }

  /// Returns true when [digits] has exactly the expected length for [dialCode].
  /// If the country is unknown (max = 15), any non-empty string is accepted.
  static bool isPhoneComplete(String dialCode, String digits) {
    final max = _digitMap[dialCode];
    if (max == null) return digits.isNotEmpty;
    return digits.length == max;
  }

  /// Returns a hint string, e.g. "10-digit number" for display in the field.
  static String hintForDialCode(String dialCode) {
    final max = _digitMap[dialCode];
    if (max == null) return 'Mobile number';
    return '$max-digit number';
  }
}

```
