import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class CountryInfo {
  final String name;
  final String flag;
  final String code;
  final String dialCode;

  const CountryInfo({
    required this.name,
    required this.flag,
    required this.code,
    required this.dialCode,
  });
}

const List<CountryInfo> countries = [
  CountryInfo(name: 'United Kingdom', flag: '🇬🇧', code: 'GB', dialCode: '+44'),
  CountryInfo(name: 'United States', flag: '🇺🇸', code: 'US', dialCode: '+1'),
  CountryInfo(name: 'Nigeria', flag: '🇳🇬', code: 'NG', dialCode: '+234'),
  CountryInfo(name: 'Canada', flag: '🇨🇦', code: 'CA', dialCode: '+1'),
  CountryInfo(name: 'Germany', flag: '🇩🇪', code: 'DE', dialCode: '+49'),
  CountryInfo(name: 'France', flag: '🇫🇷', code: 'FR', dialCode: '+33'),
  CountryInfo(name: 'Australia', flag: '🇦🇺', code: 'AU', dialCode: '+61'),
  CountryInfo(name: 'India', flag: '🇮🇳', code: 'IN', dialCode: '+91'),
];

class CountryPickerBottomSheet extends StatelessWidget {
  final ValueChanged<CountryInfo> onCountrySelected;

  const CountryPickerBottomSheet({
    super.key,
    required this.onCountrySelected,
  });

  static void show(BuildContext context, ValueChanged<CountryInfo> onCountrySelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: isDark ? const Color(0xFF1E1E22) : Colors.white,
      builder: (modalContext) {
        return CountryPickerBottomSheet(onCountrySelected: onCountrySelected);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Country',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: countries.length,
              itemBuilder: (context, index) {
                final country = countries[index];
                return ListTile(
                  leading: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    country.name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  trailing: Text(
                    country.dialCode,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : AppColors.greyText,
                    ),
                  ),
                  onTap: () {
                    onCountrySelected(country);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
