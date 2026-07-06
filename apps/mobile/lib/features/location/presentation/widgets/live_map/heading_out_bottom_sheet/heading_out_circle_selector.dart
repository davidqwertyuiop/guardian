part of '../heading_out_bottom_sheet.dart';

class HeadingOutCircleSelector extends StatelessWidget {
  final HomeState homeState;
  final String selectedCircleId;

  const HeadingOutCircleSelector({super.key, 
    required this.homeState,
    required this.selectedCircleId,
  });

  @override
  Widget build(BuildContext context) {
    final circles = homeState.circles;
    if (circles.isEmpty && homeState.status == HomeStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (circles.isEmpty) return const Text("No circles found.");

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: circles.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final circle = circles[index];
          final isSelected = circle['id'] == selectedCircleId;
          final members = isSelected
              ? homeState.members
              : (circle['members'] ?? []);
          return HeadingOutCircleCard(
            name: circle['name'] ?? '',
            members: members,
            isSelected: isSelected,
            onTap: () =>
                context.read<HomeBloc>().add(SelectCircle(circle['id'])),
          );
        },
      ),
    );
  }
}
