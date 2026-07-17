import 'package:flutter/material.dart';

import 'package:guardian/export.dart';

class CountryPickerBottomSheet extends StatefulWidget {
  final ValueChanged<IntlCountryData> onCountrySelected;

  const CountryPickerBottomSheet({super.key, required this.onCountrySelected});

  static void show(
    BuildContext context,
    ValueChanged<IntlCountryData> onCountrySelected,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow it to resize with keyboard
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
  State<CountryPickerBottomSheet> createState() =>
      _CountryPickerBottomSheetState();
}

class _CountryPickerBottomSheetState extends State<CountryPickerBottomSheet> {
  String _searchQuery = '';
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allCountries = IntlCountryData.all();

    // Filter countries based on search query
    final filteredCountries = allCountries.where((country) {
      final query = _searchQuery.toLowerCase();
      final name = country.name.toLowerCase();
      final code = country.codeAlpha2.toLowerCase();
      final phoneCode = country.telephoneCode.toString().toLowerCase();
      return name.contains(query) ||
          code.contains(query) ||
          phoneCode.contains(query);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(
          context,
        ).viewInsets.bottom, // Avoid keyboard overlap
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        height: 450, // Slightly taller to account for search bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Country',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            // Search Bar
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        filled: false,
                        fillColor: Colors.transparent,
                        hintText: 'Search country name or code...',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          color: isDark ? Colors.white38 : Colors.grey[400],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      child: Icon(
                        Icons.clear,
                        color: isDark ? Colors.white54 : Colors.grey[600],
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredCountries.isEmpty
                  ? Center(
                      child: Text(
                        'No countries match your search',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: isDark ? Colors.white38 : Colors.grey[500],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredCountries.length,
                      itemBuilder: (context, index) {
                        final country = filteredCountries[index];
                        return ListTile(
                          leading: Text(
                            country.flag,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(
                            country.name,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          trailing: Text(
                            '+${country.telephoneCode}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.grey[400]
                                  : AppColors.greyText,
                            ),
                          ),
                          onTap: () {
                            widget.onCountrySelected(country);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
