part of '../heading_out_bottom_sheet.dart';

extension _HeadingOutDropdown on _HeadingOutBottomSheetState {
  void showIosPicker({
    required BuildContext context,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => HeadingOutIosPicker(
        currentValue: currentValue,
        options: options,
        onChanged: onChanged,
        isDark: isDark,
      ),
    );
  }

  Widget buildDropdown({
    required String value,
    required List<String> options,
    required Color borderColor,
    required Color textColor,
    required bool isDark,
    required ValueChanged<String?> onChanged,
  }) {
    if (Platform.isIOS) {
      return HeadingOutIosDropdown(
        value: value,
        borderColor: borderColor,
        textColor: textColor,
        isDark: isDark,
        onTap: () => showIosPicker(
          context: context,
          currentValue: value,
          options: options,
          isDark: isDark,
          onChanged: onChanged,
        ),
      );
    }

    return HeadingOutMaterialDropdown(
      value: value,
      options: options,
      borderColor: borderColor,
      textColor: textColor,
      isDark: isDark,
      onChanged: onChanged,
    );
  }
}
