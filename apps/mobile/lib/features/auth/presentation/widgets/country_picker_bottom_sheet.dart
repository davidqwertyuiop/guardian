import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_country_data/intl_country_data.dart';
import '../../../../core/constants/app_colors.dart';

class CountryPickerBottomSheet extends StatelessWidget {
  final ValueChanged<IntlCountryData> onCountrySelected;

  const CountryPickerBottomSheet({super.key, required this.onCountrySelected});

  static void show(BuildContext context, ValueChanged<IntlCountryData> onCountrySelected) {
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
    final list = IntlCountryData.all();

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
              itemCount: list.length,
              itemBuilder: (context, index) {
                final country = list[index];
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
                    '+${country.telephoneCode}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : AppColors.greyText,
                    ),
                  ),
                  onTap: () {
                    onCountrySelected(country);
                    Navigator.pop(context);
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
