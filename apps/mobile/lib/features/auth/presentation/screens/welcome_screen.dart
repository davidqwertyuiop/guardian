import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';
import 'package:guardian/core/utils/fade_route.dart';
import 'package:guardian/features/auth/presentation/widgets/welcome_card.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLandscape = AdaptiveLayout.isLandscape(context);
    final isShort = MediaQuery.sizeOf(context).height < 720;
    
    final content = Column(
      children: [
        const WelcomeCard(),
        const Spacer(),
        _buildButtons(context, isDark),
      ],
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF080808) : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AdaptiveLayout.padding(context, 16)),
          child: (isLandscape || isShort)
              ? SingleChildScrollView(child: SizedBox(height: 720, child: content)) 
              : content,
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
            onPressed: () => Navigator.of(context).push(FadeRoute(page: const LoginScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              'Create an account',
              style: GoogleFonts.inter(
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
            onPressed: () => Navigator.of(context).push(FadeRoute(page: const LoginScreen())),
            style: TextButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF3F3F6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'I have an invite link',
              style: GoogleFonts.inter(
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
