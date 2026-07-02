import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class YouAreInSheet extends StatelessWidget {
  const YouAreInSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Block back button
      },
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AdaptiveLayout.padding(context, 24),
            vertical: 24,
          ),
          child: BlocBuilder<AuthBloc, AuthState>(
            bloc: locator<AuthBloc>(),
            builder: (context, state) {
              final username = state.username.isNotEmpty
                  ? state.username
                  : 'your friend';

              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(AdaptiveLayout.padding(context, 24)),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E22) : Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Image.asset(
                      AppAssets.icon1,
                      width: AdaptiveLayout.w(context, 60),
                      height: AdaptiveLayout.h(context, 60),
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: AdaptiveLayout.h(context, 24)),

                    // Title
                    Text(
                      "You're in 👋",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: AdaptiveLayout.sp(context, 24),
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: AdaptiveLayout.h(context, 12)),

                    // Subtitle
                    Text(
                      "Welcome $username, You have joined a circle. You can now see each other's location.",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: AdaptiveLayout.sp(context, 15),
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: AdaptiveLayout.h(context, 32)),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: AdaptiveLayout.h(context, 54),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close sheet
                          locator<AuthBloc>().add(
                            const CompleteCircleOnboarding(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Go to map',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontSize: AdaptiveLayout.sp(context, 16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
