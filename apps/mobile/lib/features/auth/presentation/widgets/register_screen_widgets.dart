import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';

class RegisterNameInput extends StatelessWidget {
  final TextEditingController controller;
  const RegisterNameInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF3F3F6),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        cursorColor: isDark ? Colors.white : Colors.black,
        style: TextStyle(
          fontFamily: 'Inter',
          color: isDark ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          hintText: "e.g. non-olem",
          hintStyle: TextStyle(fontFamily: 'Inter', color: Colors.grey[400]),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class CircleCreatureImage extends StatelessWidget {
  const CircleCreatureImage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget image = Image.asset(
      AppAssets.mapIntro,
      height: AdaptiveLayout.h(context, 180),
      fit: BoxFit.contain,
    );
    if (isDark) {
      image = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          -1.0,
          0.0,
          0.0,
          0.0,
          255.0,
          0.0,
          -1.0,
          0.0,
          0.0,
          255.0,
          0.0,
          0.0,
          -1.0,
          0.0,
          255.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ]),
        child: image,
      );
    }
    return Center(child: image);
  }
}

class RegisterButtons extends StatelessWidget {
  final VoidCallback onPressed;
  const RegisterButtons({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: AdaptiveLayout.h(context, 54),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Continue',
              style: TextStyle(
                fontFamily: 'Inter',
                color: isDark ? Colors.black : Colors.white,
                fontSize: AdaptiveLayout.sp(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: AdaptiveLayout.h(context, 12)),
        TextButton(
          onPressed: onPressed,
          child: Text(
            'Skip for now',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.grey[500],
              fontSize: AdaptiveLayout.sp(context, 15),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
