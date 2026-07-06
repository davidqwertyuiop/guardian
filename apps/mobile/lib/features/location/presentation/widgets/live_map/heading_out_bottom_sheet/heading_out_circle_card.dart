part of '../heading_out_bottom_sheet.dart';

class HeadingOutCircleCard extends StatelessWidget {
  final String name;
  final List<dynamic> members;
  final bool isSelected;
  final VoidCallback onTap;

  const HeadingOutCircleCard({super.key, 
    required this.name,
    required this.members,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isSelected
        ? const Color(0xFFBB86FC)
        : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A30) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? borderColor
                : (isDark ? Colors.white12 : Colors.black12),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HeadingOutCircleName(
              name: name,
              isDark: isDark,
              isSelected: isSelected,
            ),
            MemberAvatarRow(members: members),
          ],
        ),
      ),
    );
  }
}
