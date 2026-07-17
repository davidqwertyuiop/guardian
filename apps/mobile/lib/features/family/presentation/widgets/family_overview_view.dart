import 'package:flutter/material.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_state.dart';
import 'family_circle_tile.dart';
import 'family_overview_header.dart';

class FamilyOverviewView extends StatelessWidget {
  const FamilyOverviewView({
    super.key,
    required this.state,
    required this.onJoinPressed,
  });

  final FamilyCircleState state;
  final VoidCallback onJoinPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FamilyOverviewHeader(isDark: isDark),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('All circles', style: _text(16, FontWeight.w700, isDark)),
                TextButton.icon(
                  onPressed: onJoinPressed,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    'Join circle',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: state.status == FamilyStatus.loading && state.circles.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.circles.isEmpty
                ? Center(
                    child: Text(
                      state.status == FamilyStatus.failure
                          ? 'Unable to load circles'
                          : 'No circles yet',
                      style: _text(16, FontWeight.w600, isDark),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 104),
                    itemCount: state.circles.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final circle = state.circles[index];
                      final id = circle['id']?.toString() ?? '';
                      final members = state.membersByCircle[id] ?? const [];
                      return FamilyCircleTile(
                        circle: circle,
                        members: members,
                        isDark: isDark,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  TextStyle _text(double size, FontWeight weight, bool isDark) => TextStyle(
    fontFamily: 'Inter',
    fontSize: size,
    fontWeight: weight,
    color: isDark ? Colors.white : Colors.black,
  );
}
