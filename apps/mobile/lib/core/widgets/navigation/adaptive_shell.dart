import 'dart:io';
import 'package:flutter/material.dart';
import 'android_nav_bar.dart';
import 'ios_tab_bar.dart';

export 'android_nav_bar.dart';
export 'ios_tab_bar.dart';

/// Platform-adaptive navigation shell.
///
/// Wraps your page body with the correct nav bar for the running platform:
/// - **iOS**     → [IosTabBar]     (3-tab gradient pill, Cupertino feel)
/// - **Android** → [AndroidNavBar] (5-tab dark capsule, Material 3 feel)
///
/// Usage in your HomeScreen:
/// ```dart
/// AdaptiveShell(
///   currentIndex: _currentIndex,
///   onTabChanged: (i) => setState(() => _currentIndex = i),
///   body: _pages[_currentIndex],
/// )
/// ```
class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onTabChanged,
    this.profileImageUrl,
  });

  /// The page content displayed above the nav bar.
  final Widget body;

  /// Index of the currently selected tab.
  final int currentIndex;

  /// Called when the user taps a tab.
  final ValueChanged<int> onTabChanged;

  /// Optional profile image URL passed through to [IosTabBar].
  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          body,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Platform.isIOS
                ? IosTabBar(
                    currentIndex: currentIndex,
                    onTap: onTabChanged,
                    profileImageUrl: profileImageUrl,
                  )
                : AndroidNavBar(
                    currentIndex: currentIndex,
                    onTap: onTabChanged,
                    profileImageUrl: profileImageUrl,
                  ),
          ),
        ],
      ),
    );
  }
}
