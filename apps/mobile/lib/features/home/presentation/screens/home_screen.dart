import 'package:flutter/material.dart';
import 'package:guardian/core/services/notification_service.dart';
import 'package:guardian/export.dart';
import 'package:guardian/features/notifications/data/models/app_notification.dart';
import 'package:guardian/features/notifications/presentation/bloc/notification_bloc.dart';

/// The parent screen managing unified iOS/Android tabs using HomeBloc.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final HomeBloc _homeBloc;
  bool _showNavigation = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _homeBloc = context.read<HomeBloc>();
    _homeBloc.add(const LoadHomeData());
    NotificationService.registerDeviceToken();
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
      FamilyCircleScreen(
        onNavigationVisibilityChanged: (visible) {
          if (_showNavigation == visible) return;
          setState(() => _showNavigation = visible);
        },
      ),
      const SettingsScreen(),
    ];

    return BlocListener<NotificationBloc, NotificationState>(
      listenWhen: (previous, current) =>
          previous.pendingOpen != current.pendingOpen &&
          current.pendingOpen != null,
      listener: (context, state) => _openNotification(state.pendingOpen!),
      child: BlocBuilder<HomeBloc, HomeState>(
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
            profileImageUrl: state.avatarUrl.isNotEmpty
                ? state.avatarUrl
                : null,
            showNavigation: _showNavigation,
            body: IndexedStack(index: state.currentIndex, children: pages),
          );
        },
      ),
    );
  }

  void _openNotification(AppNotification notification) {
    if (notification.route == 'circle') {
      _homeBloc.add(ChangeTab(1));
    } else {
      _homeBloc.add(ChangeTab(0));
    }
    final circleId = notification.circleId;
    if (notification.kind.startsWith('sos') && circleId != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SosBroadcastsScreen(circleId: circleId),
        ),
      );
    }
    context.read<NotificationBloc>().add(const NotificationOpenHandled());
  }
}
