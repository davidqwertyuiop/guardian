import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

class FamilyOverviewHeader extends StatelessWidget {
  const FamilyOverviewHeader({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: context.w(20),
            right: context.w(20),
            top: context.w(40),
            bottom: context.w(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _topIcon(context),
              Text('My Circle', style: _text(context.sp(18), FontWeight.w800)),
              SizedBox(width: context.w(40), height: context.w(40)),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(24)),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Welcome to\ncircles.',
                  style: _text(
                    context.sp(32),
                    FontWeight.w800,
                  ).copyWith(height: 1.1),
                ),
              ),
              Container(
                width: context.w(96),
                height: context.w(96),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.92)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(context.w(28)),
                ),
                child: Image.asset(AppAssets.circlesIconPng, fit: BoxFit.contain),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _topIcon(BuildContext context) => Container(
    width: context.w(60),
    height: context.w(40),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.15),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Image.asset(
        AppAssets.appCenterHomeIcon,
        width: context.w(40),
        height: context.w(40),
      ),
    ),
  );

  TextStyle _text(double size, FontWeight weight) => TextStyle(
    fontFamily: 'Inter',
    fontSize: size,
    fontWeight: weight,
    color: isDark ? Colors.white : Colors.black,
  );
}
