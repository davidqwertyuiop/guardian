part of '../live_map_screen.dart';

extension _LiveMapActions on _LiveMapScreenState {
  void toggleMap() {
    final currentDisplayState = _bloc.state.mapDisplayState;
    if (currentDisplayState == MapDisplayState.full) return;

    if (currentDisplayState == MapDisplayState.compact) {
      _bloc.add(const ChangeMapState(MapDisplayState.expanded));
      _mapAnim.forward();
    } else {
      _bloc.add(const ChangeMapState(MapDisplayState.compact));
      _mapAnim.reverse();
    }
  }

  void openFullMap() {
    _bloc.add(const ChangeMapState(MapDisplayState.full));
    _fullAnim.forward();
  }

  void closeFullMap() {
    HapticFeedback.lightImpact();
    _bloc.add(const ChangeMapState(MapDisplayState.expanded));
  }

  void resizeBroadcastPanel(double delta) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final minHeight = context.w(220);
    final maxHeight = screenHeight * 0.48;

    updateUi(() {
      _broadcastPanelHeight = (_broadcastPanelHeight - delta).clamp(
        minHeight,
        maxHeight,
      );
    });
  }
}
