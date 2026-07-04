import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

/// The parent screen managing unified iOS/Android tabs using HomeBloc.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _homeBloc = context.read<HomeBloc>();
    _homeBloc.add(const LoadHomeData());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _homeBloc.add(const LoadHomeData());
    }
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
            if (index == 0 && state.currentIndex == 0) {
              _homeBloc.add(const ChangeMapState(MapDisplayState.compact));
            } else if (index != 0) {
              _homeBloc.add(const ChangeMapState(MapDisplayState.compact));
            }
            _homeBloc.add(ChangeTab(index));
          },
          profileImageUrl: state.avatarUrl.isNotEmpty ? state.avatarUrl : null,
          body: IndexedStack(index: state.currentIndex, children: pages),
        );
      },
    );
  }
}
