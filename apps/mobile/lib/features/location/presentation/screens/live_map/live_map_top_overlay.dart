part of '../live_map_screen.dart';

extension _LiveMapTopOverlay on _LiveMapScreenState {
  Widget buildTopOverlay(HomeState state) {
    return AnimatedBuilder(
      animation: _mapAnim,
      builder: (context, child) {
        final displayState = state.mapDisplayState;

        return Positioned(
          top: MediaQuery.paddingOf(context).top + 24,
          left: 0,
          right: 0,
          child: LiveMapTopBar(
            onSosTap: showSosSheet,
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
