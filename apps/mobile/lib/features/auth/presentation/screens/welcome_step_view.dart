import 'package:flutter/material.dart';

import 'package:guardian/export.dart';
import 'package:guardian/features/auth/presentation/widgets/welcome_card.dart';

class WelcomeStepView extends StatelessWidget {
  const WelcomeStepView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLandscape = AdaptiveLayout.isLandscape(context);
    final isShort = MediaQuery.sizeOf(context).height < 720;

    final content = Column(
      children: [
        const WelcomeCard(),
        if (isLandscape || isShort)
          SizedBox(height: AdaptiveLayout.h(context, 24))
        else
          const Spacer(),
        _buildButtons(context, isDark),
      ],
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Welcome screen is root of onboarding, back does nothing.
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF080808) : Colors.white,
        body: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: AdaptiveLayout.padding(context, 16),
              right: AdaptiveLayout.padding(context, 16),
              bottom: AdaptiveLayout.padding(context, 16),
              top:
                  MediaQuery.paddingOf(context).top +
                  AdaptiveLayout.padding(context, 12),
            ),
            child: (isLandscape || isShort)
                ? SingleChildScrollView(
                    child: SizedBox(height: 440, child: content),
                  )
                : content,
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: AdaptiveLayout.h(context, 54),
          child: ElevatedButton(
            onPressed: () =>
                context.read<AuthBloc>().add(const NavigateToLogin()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Create an account',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontSize: AdaptiveLayout.sp(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: AdaptiveLayout.h(context, 12)),
        SizedBox(
          width: double.infinity,
          height: AdaptiveLayout.h(context, 54),
          child: TextButton(
            onPressed: () =>
                context.read<AuthBloc>().add(const ClickInviteLink()),
            style: TextButton.styleFrom(
              backgroundColor: isDark
                  ? const Color(0xFF1E1E22)
                  : const Color(0xFFF3F3F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'I have an invite link',
              style: TextStyle(
                fontFamily: 'Inter',
                color: isDark ? Colors.white : Colors.black,
                fontSize: AdaptiveLayout.sp(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
