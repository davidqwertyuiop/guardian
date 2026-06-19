import 'dart:io';
import 'package:flutter/material.dart';
import 'package:guardian/core/widgets/navigation/adaptive_shell.dart';
import 'package:guardian/features/location/presentation/screens/live_map_screen.dart';
import 'package:guardian/features/family/presentation/screens/family_circle_screen.dart';
import 'package:guardian/features/journey/presentation/screens/start_journey_screen.dart';
import 'package:guardian/features/settings/presentation/screens/settings_screen.dart';

/// The parent stateful screen that manages shell navigation across iOS/Android tabs.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isIos = Platform.isIOS;

    final List<Widget> pages = isIos
        ? [
            const LiveMapScreen(),
            const FamilyCircleScreen(),
            const SettingsScreen(),
          ]
        : [
            const LiveMapScreen(),
            const StartJourneyScreen(),
            const Scaffold(
              backgroundColor: Color(0xFF141416),
              body: Center(
                child: Text(
                  'Safety Center Stub',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            const Scaffold(
              backgroundColor: Color(0xFF141416),
              body: Center(
                child: Text(
                  'Night Watch Stub',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            const SettingsScreen(),
          ];

    return AdaptiveShell(
      currentIndex: _currentIndex,
      onTabChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
    );
  }
}
