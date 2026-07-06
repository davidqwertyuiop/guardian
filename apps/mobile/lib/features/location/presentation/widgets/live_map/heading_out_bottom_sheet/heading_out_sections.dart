part of '../heading_out_bottom_sheet.dart';

extension _HeadingOutSections on _HeadingOutBottomSheetState {
  Widget buildDestinationSection(
    bool isDark,
    Color textColor,
    Color borderColor,
  ) {
    return HeadingOutFormSection(
      label: "Where are you headed?",
      textColor: textColor,
      child: Column(
        children: [
          buildDropdown(
            value: _selectedDestination,
            options: _destinationOptions,
            borderColor: borderColor,
            textColor: textColor,
            isDark: isDark,
            onChanged: updateDestination,
          ),
          if (_selectedDestination == 'Custom') ...[
            const SizedBox(height: 12),
            HeadingOutCustomField(
              controller: _customDestController,
              hintText: "Enter destination",
              borderColor: borderColor,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget buildDurationSection(bool isDark, Color textColor, Color borderColor) {
    return HeadingOutFormSection(
      label: "How long should we track you?",
      textColor: textColor,
      child: Column(
        children: [
          buildDropdown(
            value: _selectedDuration,
            options: _durationOptions,
            borderColor: borderColor,
            textColor: textColor,
            isDark: isDark,
            onChanged: updateDuration,
          ),
          if (_selectedDuration == 'Custom') ...[
            const SizedBox(height: 12),
            HeadingOutCustomField(
              controller: _customDurController,
              hintText: "e.g., 30 mins, 4 hours",
              borderColor: borderColor,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }
}
