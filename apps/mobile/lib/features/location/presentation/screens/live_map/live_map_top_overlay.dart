part of '../live_map_screen.dart';

extension _LiveMapTopOverlay on _LiveMapScreenState {
  Widget buildTopOverlay(HomeState state) {
    return AnimatedBuilder(
      animation: Listenable.merge([_mapAnim, _fullAnim]),
      builder: (context, child) {
        final displayState = state.mapDisplayState;

        return Positioned(
          // The content itself sheds its safe-area padding as the map enters
          // full screen. Add it back here progressively so controls remain
          // below the status indicators while map tiles extend behind them.
          top: 24 + MediaQuery.paddingOf(context).top * _fullAnim.value,
          left: 0,
          right: 0,
          child: LiveMapTopBar(
            onSosTap: showSosSheet,
            onNotificationTap: showNotificationsCenter,
            showBackButton: displayState == MapDisplayState.full,
            onBackPressed: closeFullMap,
            isSosActive: _isLocalSosActive,
            showCenterIcon: displayState == MapDisplayState.compact,
          ),
        );
      },
    );
  }
}
