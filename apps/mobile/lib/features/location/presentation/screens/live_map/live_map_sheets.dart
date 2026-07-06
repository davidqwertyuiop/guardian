part of '../live_map_screen.dart';

extension _LiveMapSheets on _LiveMapScreenState {
  void showStopBroadcastSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          const YouAreLiveBottomSheet(destination: '', isConfirmStop: true),
    );
  }

  void showSosSheet() {
    final openActiveSheet = _isLocalSosActive;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SosBottomSheet(
        circleId: _bloc.state.circleId,
        fallbackLatitude: _bloc.state.userLatitude,
        fallbackLongitude: _bloc.state.userLongitude,
        startActive: openActiveSheet,
        initialBroadcastId: _activeSosBroadcastId,
        initialAddress: _activeSosAddress,
        onClosed: () => _bloc.add(const LoadHomeData()),
        onActivated: rememberActiveSos,
        onActiveChanged: updateSosActiveState,
      ),
    );
  }

  void rememberActiveSos(String? broadcastId, String? address) {
    if (!mounted) return;
    updateUi(() {
      _activeSosBroadcastId = broadcastId;
      _activeSosAddress = address;
    });
  }

  void updateSosActiveState(bool isActive) {
    if (!mounted) return;
    updateUi(() {
      _isLocalSosActive = isActive;
      if (!isActive) {
        _activeSosBroadcastId = null;
        _activeSosAddress = null;
      }
    });
    if (!isActive) {
      _bloc.add(const LoadHomeData());
    }
  }

  void syncMapAnimations(BuildContext context, HomeState state) {
    switch (state.mapDisplayState) {
      case MapDisplayState.compact:
        if (_fullAnim.value > 0.0) _fullAnim.reverse();
        if (_mapAnim.value > 0.0) _mapAnim.reverse();
        break;
      case MapDisplayState.expanded:
        if (_fullAnim.value > 0.0) _fullAnim.reverse();
        if (_mapAnim.value < 1.0) _mapAnim.forward();
        break;
      case MapDisplayState.full:
        if (_mapAnim.value < 1.0) _mapAnim.forward();
        if (_fullAnim.value < 1.0) _fullAnim.forward();
        break;
    }
  }
}
