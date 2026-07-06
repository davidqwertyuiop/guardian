import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

class TopBarSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  const TopBarSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF23232A) : Colors.white;
    final foregroundColor = isDark ? Colors.white : const Color(0xFF222229);
    return Container(
      height: context.w(40),
      margin: EdgeInsets.symmetric(horizontal: context.w(10)),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: context.w(12)),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: foregroundColor,
            size: context.w(18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SearchTextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: Icon(
                Icons.clear_rounded,
                color: foregroundColor,
                size: context.w(16),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  const _SearchTextField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search places...',
        hintStyle: TextStyle(
          color: isDark ? Colors.white38 : Colors.black38,
          fontSize: context.sp(13),
          fontFamily: 'Inter',
        ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
        fontSize: context.sp(14),
        fontFamily: 'Inter',
      ),
    );
  }
}
