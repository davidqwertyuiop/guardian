import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AvatarItem extends StatelessWidget {
  final String imagePath;
  final double size;
  final Color borderColor;

  const AvatarItem({
    super.key,
    required this.imagePath,
    required this.size,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.primary.withValues(alpha: 0.2),
            child: Icon(
              Icons.person_outline,
              size: size * 0.5,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
