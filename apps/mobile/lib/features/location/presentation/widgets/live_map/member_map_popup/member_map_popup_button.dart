import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_colors.dart';

class PopupButton extends StatelessWidget {
  const PopupButton({
    super.key,
    required this.label,
    required this.filled,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: filled ? _filledButton() : _outlinedButton(context),
    );
  }

  Widget _filledButton() {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: isDark ? Colors.white : Colors.black,
        foregroundColor: isDark ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(label),
    );
  }

  Widget _outlinedButton(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text(context),
        side: BorderSide(color: AppColors.border(context)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(label),
    );
  }
}
