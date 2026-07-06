part of '../live_map_screen.dart';

extension _LiveMapSections on _LiveMapScreenState {
  Widget buildHeaderSpacer() {
    return AnimatedBuilder(
      animation: _mapAnim,
      builder: (context, child) {
        final val = _mapAnim.value;
        return SizedBox(height: context.w(100) * (1.0 - val));
      },
    );
  }

  Widget buildWelcomeHeader(HomeState state, bool isActive) {
    return AnimatedBuilder(
      animation: _mapAnim,
      builder: (context, child) {
        final val = _mapAnim.value;
        final opacity = (1.0 - val).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Align(
            alignment: Alignment.topLeft,
            heightFactor: 1.0 - val,
            child: child,
          ),
        );
      },
      child: isActive
          ? const SizedBox.shrink()
          : WelcomeHeader(
              userName: state.userName,
              weatherGreeting: state.weatherGreeting,
              isLoading: state.status == HomeStatus.loading,
            ),
    );
  }

  Widget buildCollapsedGap() {
    return AnimatedBuilder(
      animation: _mapAnim,
      builder: (context, child) {
        final val = _mapAnim.value;
        return SizedBox(height: 8.0 * (1.0 - val));
      },
    );
  }

  Widget buildMapCard(HomeState state) {
    return MapCard(
      mapState: state.mapDisplayState,
      mapAnim: _mapAnim,
      fullAnim: _fullAnim,
      onTap: toggleMap,
      onOpenMap: openFullMap,
      onSosTap: showSosSheet,
      members: state.members,
      userLatitude: state.userLatitude,
      userLongitude: state.userLongitude,
      circleId: state.circleId,
      selectedPlace: _selectedPlace,
      onClearSearch: clearSearch,
      isSosActive: _isLocalSosActive,
      activeSosAddress: _activeSosAddress,
      sosBroadcasts: state.sosBroadcasts,
    );
  }

  Widget buildExpandedBroadcastPanel(
    HomeState state,
    JourneyState journeyState,
  ) {
    return BroadcastBottomPanel(
      journeyState: journeyState,
      circleName: state.circleName,
      members: state.members,
      height: _broadcastPanelHeight,
      onDragDelta: resizeBroadcastPanel,
      onStopPressed: showStopBroadcastSheet,
      onSeeMore: () => _bloc.add(const ChangeMapState(MapDisplayState.compact)),
    );
  }
}
