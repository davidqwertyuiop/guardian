import 'dart:io';

void main() {
  final file = File('lib/features/location/presentation/screens/live_map_screen.dart');
  String content = file.readAsStringSync();

  // We want to wrap the children of the main Column in a JourneyBloc builder, or just move the JourneyBloc up.
  // Actually, the easiest is to replace the start of the Column and the existing BlocBuilder.

  // Let's replace:
  // "child: Column(\n                        crossAxisAlignment: CrossAxisAlignment.start,\n                        children: ["
  // with
  // "child: BlocBuilder<JourneyBloc, JourneyState>(builder: (context, journeyState) {\n                      final isActive = journeyState.status == JourneyStatus.active;\n                      return Column(\n                        crossAxisAlignment: CrossAxisAlignment.start,\n                        children: ["

  content = content.replaceFirst(
    '''                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [''',
    '''                      child: BlocBuilder<JourneyBloc, JourneyState>(
                        builder: (context, journeyState) {
                          final isActive = journeyState.status == JourneyStatus.active;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: ['''
  );

  // Hide WelcomeHeader if isActive
  content = content.replaceFirst(
    '''                            child: WelcomeHeader(
                              userName: state.userName,
                              weatherGreeting: state.weatherGreeting,
                              isLoading: state.status == HomeStatus.loading,
                            ),''',
    '''                            child: isActive
                                ? const SizedBox.shrink()
                                : WelcomeHeader(
                                    userName: state.userName,
                                    weatherGreeting: state.weatherGreeting,
                                    isLoading: state.status == HomeStatus.loading,
                                  ),'''
  );

  // Move the Orange Box and Stop Box ABOVE MapCard
  // Find the start of MapCard
  final mapCardStart = "                          MapCard(";
  
  final orangeBoxCode = '''                          if (isActive)
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0),
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
                                            final remainingText = remaining > 0 ? '\$remaining min remaining' : 'completed';
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
''';

  content = content.replaceFirst(mapCardStart, orangeBoxCode + mapCardStart);

  // Now we need to remove the existing BlocBuilder block below MapCard,
  // AND return just the CircleCard, HeadingOutButton, and SosBroadcastsSection.
  
  // Existing block starts at: "                          BlocBuilder<JourneyBloc, JourneyState>("
  // and ends with its matching closing tag before "                        ],"
  
  // It's easier to use a regex or string extraction to find the existing block and replace it.
  final startToken = "                          BlocBuilder<JourneyBloc, JourneyState>(";
  final startIndex = content.indexOf(startToken);
  
  if (startIndex != -1) {
    // Find the end of this BlocBuilder
    // We can just replace the whole section manually since we know the content.
    final blockToReplace = '''                          BlocBuilder<JourneyBloc, JourneyState>(
                            builder: (context, journeyState) {
                              final isActive =
                                  journeyState.status == JourneyStatus.active;
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 16),
                                  if (isActive)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Orange Box: Broadcasting status info
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFFF99000,
                                              ), // Vibrant orange
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Color(
                                                          0xFF00FF66,
                                                        ), // Green dot
                                                        shape: BoxShape.circle,
                                                      ),
                                                ),
                                                const SizedBox(width: 8),
                                                Builder(
                                                  builder: (context) {
                                                    final now = DateTime.now();
                                                    final start =
                                                        journeyState
                                                            .startTime ??
                                                        now;
                                                    final duration =
                                                        journeyState
                                                            .durationMinutes ??
                                                        30;
                                                    final elapsed = now
                                                        .difference(start)
                                                        .inMinutes;
                                                    final remaining =
                                                        duration - elapsed;
                                                    final remainingText =
                                                        remaining > 0
                                                        ? '\$remaining min remaining'
                                                        : 'completed';
                                                    return Text(
                                                      'Broadcasting · \$remainingText',
                                                      style: const TextStyle(
                                                        fontFamily: 'Outfit',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              onPressed: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  builder: (context) =>
                                                      const YouAreLiveBottomSheet(
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
                                    isLoading:
                                        state.status == HomeStatus.loading,
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
                          ),''';
                          
    final replacement = '''                                  const SizedBox(height: 16),
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
                                  ),''';
                                  
    content = content.replaceFirst(blockToReplace, replacement);
  }

  // Close the new JourneyBloc builder around the Column
  // We need to add "});" after the Column ends.
  content = content.replaceFirst(
    '''                        ],
                      ),
                    ),
                  ),''',
    '''                        ],
                          );
                        },
                      ),
                    ),
                  ),'''
  );

  file.writeAsStringSync(content);
}
