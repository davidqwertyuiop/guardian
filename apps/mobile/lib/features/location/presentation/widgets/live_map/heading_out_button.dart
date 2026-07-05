import 'package:flutter/material.dart';
import 'heading_out_bottom_sheet.dart';

class HeadingOutButton extends StatelessWidget {
  final String circleId;
  final String circleName;
  final List<dynamic> members;

  const HeadingOutButton({
    super.key,
    required this.circleId,
    required this.circleName,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.white : Colors.black;
    final fgColor = isDark ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: isDark
                  ? const BorderSide(color: Colors.white)
                  : BorderSide.none,
            ),
            elevation: 0,
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => HeadingOutBottomSheet(
                initialCircleId: circleId,
                initialCircleName: circleName,
                initialMembers: members,
              ),
            );
          },
          child: const Text(
            "I'm heading out",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
