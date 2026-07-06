part of '../live_map_screen.dart';

extension _LiveMapHomeSections on _LiveMapScreenState {
  Widget buildBroadcastingHomeSections(HomeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildCircleCard(state),
        const SizedBox(height: 28),
        buildSosBroadcasts(state),
      ],
    );
  }

  Widget buildDefaultHomeSections(HomeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildCircleCard(state),
        const SizedBox(height: 16),
        HeadingOutButton(
          circleId: state.circleId,
          circleName: state.circleName,
          members: state.members,
        ),
        const SizedBox(height: 28),
        buildSosBroadcasts(state),
      ],
    );
  }

  Widget buildCircleCard(HomeState state) {
    return CircleCard(
      circleName: state.circleName,
      members: state.members,
      isLoading: state.status == HomeStatus.loading,
    );
  }

  Widget buildSosBroadcasts(HomeState state) {
    return SosBroadcastsSection(
      broadcasts: state.sosBroadcasts,
      onSeeAllTap: () => openSosBroadcasts(state.circleId),
    );
  }

  void openSosBroadcasts(String circleId) {
    if (circleId.isEmpty) return;
    Navigator.push(
      context,
      FadeRoute(page: SosBroadcastsScreen(circleId: circleId)),
    );
  }
}
