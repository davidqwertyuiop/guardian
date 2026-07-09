import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/features/home/presentation/bloc/home_state.dart';

class ProfileHero extends StatelessWidget {
  const ProfileHero({
    super.key,
    required this.homeState,
    this.phone = '',
    this.onEditAvatar,
    this.avatarUploading = false,
  });

  final HomeState homeState;
  final String phone;
  final VoidCallback? onEditAvatar;
  final bool avatarUploading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  width: 2.5,
                ),
              ),
              child: avatarUploading
                  ? const CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.transparent,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : CircleAvatar(
                      radius: 36,
                      backgroundImage: homeState.avatarUrl.isNotEmpty
                          ? NetworkImage(homeState.avatarUrl)
                          : const AssetImage(AppAssets.avatarTop)
                              as ImageProvider,
                    ),
            ),
            GestureDetector(
              onTap: onEditAvatar,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          homeState.userName.isEmpty ? 'Guardian user' : homeState.userName,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AppColors.text(context),
          ),
        ),
        if (phone.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            phone,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: AppColors.mutedText(context),
            ),
          ),
        ],
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 8),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.mutedText(context),
      ),
    ),
  );
}
