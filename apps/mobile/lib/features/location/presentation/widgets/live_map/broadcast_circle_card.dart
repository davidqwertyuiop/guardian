import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

import 'member_avatar_row.dart';

class BroadcastCircleCard extends StatelessWidget {
  final String circleName;
  final List<dynamic> members;
  final VoidCallback onSeeMore;

  const BroadcastCircleCard({
    super.key,
    required this.circleName,
    required this.members,
    required this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalMargin = context.w(20);
    final availableWidth =
        MediaQuery.sizeOf(context).width - horizontalMargin * 2;
    final preferredWidth = context.w(277);
    final cardWidth = preferredWidth.clamp(0.0, availableWidth);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: cardWidth,
          constraints: BoxConstraints(
            minHeight: context.w(132),
            maxWidth: availableWidth,
          ),
          padding: EdgeInsets.all(context.w(14)),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E24) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final buttonWidth = constraints.maxWidth >= context.w(249)
                  ? context.w(89)
                  : context.w(76);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${members.length} members',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: context.sp(11),
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white60 : Colors.black45,
                            height: 1,
                          ),
                        ),
                        SizedBox(height: context.w(6)),
                        Text(
                          circleName.isNotEmpty ? circleName : 'My Circle',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: context.sp(20),
                            height: 1,
                            letterSpacing: -1.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: context.w(16)),
                        MemberAvatarRow(members: members),
                      ],
                    ),
                  ),
                  SizedBox(width: context.w(10)),
                  Padding(
                    padding: EdgeInsets.only(top: context.w(60)),
                    child: SizedBox(
                      width: buttonWidth,
                      height: context.w(43),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: context.w(14),
                            vertical: context.w(13),
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: onSeeMore,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'See more',
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: context.sp(14),
                              height: 1,
                              letterSpacing: -0.42,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
