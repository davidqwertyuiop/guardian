import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/widgets/navigation/adaptive_shell.dart';
import 'package:guardian/features/home/presentation/bloc/home_bloc.dart';
import 'package:guardian/features/home/presentation/bloc/home_event.dart';
import 'package:guardian/features/home/presentation/bloc/home_state.dart';
import 'package:guardian/features/location/presentation/screens/live_map_screen.dart';
import 'package:guardian/features/family/presentation/screens/family_circle_screen.dart';
import 'package:guardian/features/settings/presentation/screens/settings_screen.dart';

/// The parent screen managing unified iOS/Android tabs using HomeBloc.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = locator<HomeBloc>();
    _homeBloc.add(const LoadHomeData());
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const LiveMapScreen(),
      const FamilyCircleScreen(),
      const SettingsScreen(),
    ];

    return BlocBuilder<HomeBloc, HomeState>(
      bloc: _homeBloc,
      builder: (context, state) {
        return AdaptiveShell(
          currentIndex: state.currentIndex,
          onTabChanged: (index) {
            _homeBloc.add(ChangeTab(index));
          },
          profileImageUrl: state.avatarUrl.isNotEmpty ? state.avatarUrl : null,
          body: IndexedStack(index: state.currentIndex, children: pages),
        );
      },
    );
  }
}
