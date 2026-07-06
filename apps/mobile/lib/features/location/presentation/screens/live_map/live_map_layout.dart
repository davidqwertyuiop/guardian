part of '../live_map_screen.dart';

extension _LiveMapLayout on _LiveMapScreenState {
  Widget buildLiveMapLayout(HomeState state) {
    final isFull = state.mapDisplayState == MapDisplayState.full;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => _bloc.add(const LoadHomeData()),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: isFull
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: isFull ? 0 : 120),
                child: BlocBuilder<JourneyBloc, JourneyState>(
                  builder: (context, journeyState) =>
                      buildJourneyContent(state, journeyState),
                ),
              ),
            ),
            buildTopOverlay(state),
          ],
        ),
      ),
    );
  }

  Widget buildJourneyContent(HomeState state, JourneyState journeyState) {
    final isActive = journeyState.status == JourneyStatus.active;
    final isCompact = state.mapDisplayState == MapDisplayState.compact;
    final isExpanded = state.mapDisplayState == MapDisplayState.expanded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeaderSpacer(),
        buildWelcomeHeader(state, isActive),
        buildCollapsedGap(),
        if (isActive && isCompact) ...[
          BroadcastControls(
            journeyState: journeyState,
            onStopPressed: showStopBroadcastSheet,
            padding: EdgeInsets.symmetric(horizontal: context.w(20)),
          ),
          const SizedBox(height: 16),
        ],
        buildMapCard(state),
        const SizedBox(height: 16),
        if (isActive && isExpanded)
          buildExpandedBroadcastPanel(state, journeyState)
        else if (isActive)
          buildBroadcastingHomeSections(state)
        else
          buildDefaultHomeSections(state),
      ],
    );
  }
}
