part of '../live_map_screen.dart';

extension _LiveMapTopOverlay on _LiveMapScreenState {
  Widget buildTopOverlay(HomeState state) {
    return AnimatedBuilder(
      animation: _mapAnim,
      builder: (context, child) {
        final displayState = state.mapDisplayState;
        final shouldShowTopBar =
            displayState != MapDisplayState.compact || !_isHomeScrolled;
        if (!shouldShowTopBar) return const SizedBox.shrink();

        return Positioned(
          top: MediaQuery.paddingOf(context).top + 24,
          left: 0,
          right: 0,
          child: LiveMapTopBar(
            showSearch: displayState != MapDisplayState.compact,
            onSosTap: showSosSheet,
            latitude: state.userLatitude,
            longitude: state.userLongitude,
            searchController: _searchController,
            onSearchChanged: onSearchChanged,
            onClearSearch: clearSearch,
            searchFocusNode: _searchFocusNode,
            showBackButton: displayState == MapDisplayState.full,
            onBackPressed: closeFullMap,
            isSosActive: _isLocalSosActive,
          ),
        );
      },
    );
  }
}
