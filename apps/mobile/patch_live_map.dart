import 'dart:io';

void main() {
  final file = File('lib/features/location/presentation/screens/live_map_screen.dart');
  String content = file.readAsStringSync();

  final target1 = '''
                          const SizedBox(height: 16),
                          CircleCard(
                            circleName: state.circleName,
                            members: state.members,
                            isLoading: state.status == HomeStatus.loading,
                          ),
                          const SizedBox(height: 16),
                          HeadingOutButton(
                            circleId: state.circleId,
                            circleName: state.circleName,
                            members: state.members,
                          ),
                          const SizedBox(height: 28),
                          SosBroadcastsSection(
                            broadcasts: state.sosBroadcasts,
                            onSeeAllTap: () {
                              if (state.circleId.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  FadeRoute(
                                    page: SosBroadcastsScreen(
                                      circleId: state.circleId,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
''';

  final replacement1 = '''
                          BlocBuilder<JourneyBloc, JourneyState>(
                            builder: (context, journeyState) {
                              final isActive = journeyState.status == JourneyStatus.active;
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 16),
                                  if (isActive)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Orange Box: Broadcasting status info
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF99000), // Vibrant orange
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFF00FF66), // Green dot
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Builder(
                                                  builder: (context) {
                                                    final now = DateTime.now();
                                                    final start = journeyState.startTime ?? now;
                                                    final duration = journeyState.durationMinutes ?? 30;
                                                    final elapsed = now.difference(start).inMinutes;
                                                    final remaining = duration - elapsed;
                                                    final remainingText = remaining > 0
                                                        ? '\$remaining min remaining'
                                                        : 'completed';
                                                    return Text(
                                                      'Broadcasting · \$remainingText',
                                                      style: const TextStyle(
                                                        fontFamily: 'Outfit',
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          // Black Box: Stop button
                                          SizedBox(
                                            width: double.infinity,
                                            height: 48,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              onPressed: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor: Colors.transparent,
                                                  builder: (context) => const YouAreLiveBottomSheet(
                                                    destination: '',
                                                    isConfirmStop: true,
                                                  ),
                                                );
                                              },
                                              child: const Text(
                                                'Stop',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      ),
                                    ),
                                  CircleCard(
                                    circleName: state.circleName,
                                    members: state.members,
                                    isLoading: state.status == HomeStatus.loading,
                                  ),
                                  const SizedBox(height: 16),
                                  if (!isActive)
                                    HeadingOutButton(
                                      circleId: state.circleId,
                                      circleName: state.circleName,
                                      members: state.members,
                                    ),
                                  if (!isActive) const SizedBox(height: 28),
                                  SosBroadcastsSection(
                                    broadcasts: state.sosBroadcasts,
                                    onSeeAllTap: () {
                                      if (state.circleId.isNotEmpty) {
                                        Navigator.push(
                                          context,
                                          FadeRoute(
                                            page: SosBroadcastsScreen(
                                              circleId: state.circleId,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
''';

  content = content.replaceFirst(target1, replacement1);

  final target2 = '''
                  // Floating Persistent TopBar
                  AnimatedBuilder(
''';

  final replacement2 = '''
                  // Floating Persistent Bottom Overlays when map is full
                  if (state.mapDisplayState == MapDisplayState.full)
                    Positioned(
                      bottom: Platform.isIOS ? 140.0 : 140.0,
                      left: 20,
                      right: 20,
                      child: BlocBuilder<JourneyBloc, JourneyState>(
                        builder: (context, journeyState) {
                          if (journeyState.status == JourneyStatus.active) {
                            final now = DateTime.now();
                            final start = journeyState.startTime ?? now;
                            final duration = journeyState.durationMinutes ?? 30;
                            final elapsed = now.difference(start).inMinutes;
                            final remaining = duration - elapsed;
                            final remainingText = remaining > 0
                                ? '\$remaining min remaining'
                                : 'completed';

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Orange Box: Broadcasting status info
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF99000), // Vibrant orange
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF00FF66), // Green dot
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Broadcasting · \$remainingText',
                                        style: const TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Black Box: Stop button
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) => const YouAreLiveBottomSheet(
                                          destination: '',
                                          isConfirmStop: true,
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Stop',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Circle Card with "See more"
                                _buildOverlayCircleCard(
                                  context: context,
                                  circleName: state.circleName,
                                  members: state.members,
                                  isDark: isDark,
                                  onSeeMore: () {
                                    // Handle see more: return to compact view
                                    context.read<HomeBloc>().add(
                                      const ChangeMapState(MapDisplayState.compact),
                                    );
                                    _mapAnim.reverse();
                                  },
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),

                  // Floating Persistent TopBar
                  AnimatedBuilder(
''';

  content = content.replaceFirst(target2, replacement2);

  final target3 = '''
  }
}
''';

  final replacement3 = '''
  }

  Widget _buildOverlayCircleCard({
    required BuildContext context,
    required String circleName,
    required List<dynamic> members,
    required bool isDark,
    required VoidCallback onSeeMore,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "\${members.length} members",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  circleName.isNotEmpty ? circleName : "My Circle",
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                MemberAvatarRow(members: members),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: onSeeMore,
            child: const Text(
              "See more",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
''';

  final lastIndex = content.lastIndexOf(target3);
  if (lastIndex != -1) {
    content = content.replaceRange(lastIndex, lastIndex + target3.length, replacement3);
  } else {
    print("Failed to find target 3");
  }

  file.writeAsStringSync(content);
}
