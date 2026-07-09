import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:guardian/export.dart';
import 'package:guardian/features/settings/presentation/widgets/settings_privacy_page.dart';

class LoginBottomSheetHeader extends StatelessWidget {
  const LoginBottomSheetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final closeBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);
    final closeIconColor = isDark ? Colors.white70 : Colors.black54;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () => context.read<AuthBloc>().add(const NavigateBack()),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: closeBg, shape: BoxShape.circle),
            child: Icon(Icons.close, color: closeIconColor, size: 18),
          ),
        ),
      ],
    );
  }
}

class LoginBottomSheetTerms extends StatelessWidget {
  const LoginBottomSheetTerms({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'By continuing, you agree to our ',
        children: [
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      body: SafeArea(
                        child: SettingsPrivacyPage(
                          onBack: () => Navigator.pop(context),
                          isTerms: true,
                        ),
                      ),
                    ),
                  ),
                );
              },
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      body: SafeArea(
                        child: SettingsPrivacyPage(
                          onBack: () => Navigator.pop(context),
                          isTerms: false,
                        ),
                      ),
                    ),
                  ),
                );
              },
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: AdaptiveLayout.sp(context, 12),
        color: Colors.grey[500],
      ),
    );
  }
}

class LoginContinueButton extends StatelessWidget {
  final bool isLoading;
  final bool enabled;
  final VoidCallback? onPressed;

  const LoginContinueButton({
    super.key,
    required this.isLoading,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AdaptiveLayout.h(context, 54),
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'Continue',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontSize: AdaptiveLayout.sp(context, 16),
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
