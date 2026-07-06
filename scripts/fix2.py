import re

with open('lib/features/location/presentation/screens/live_map_screen.dart', 'r') as f:
    content = f.read()

# Split into _LiveMapScreenState and _MapCardState
parts = content.split('class _MapCardState extends State<_MapCard> {')
part1 = parts[0]
part2 = 'class _MapCardState extends State<_MapCard> {' + parts[1]

# In part2, remove the methods
part2 = re.sub(r'  List<MockPlace> _getPlacesForCountry\(String countryCode\) \{.*?(?=  Future<void> _onSearchChanged)', '', part2, flags=re.DOTALL)
part2 = re.sub(r'  Future<void> _onSearchChanged\(String query\) async \{.*?(?=  List<LatLng> _generateRoutingCoordinates)', '', part2, flags=re.DOTALL)

# In part2, remove the duplicate search bar
part2 = re.sub(r'                            // Top Search Bar\n                            Positioned\(\n                              top: MediaQuery.*?                            // Right controls \(Zoom In, Zoom Out, Recenter to user\)', '                            // Right controls (Zoom In, Zoom Out, Recenter to user)', part2, flags=re.DOTALL)

# In part2, replace _selectedPlace with widget.selectedPlace
part2 = part2.replace('_selectedPlace', 'widget.selectedPlace')

# Recombine
content = part1 + part2

# Pass _nearestMemberInfo to _MapDistanceBadge
content = re.sub(r'child: _MapDistanceBadge\(\),', r'child: _MapDistanceBadge(nearestMember: _nearestMemberInfo),', content)

old_badge = r'''class _MapDistanceBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppAssets.worldMap,
            width: 13,
            height: 13,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.public, size: 13, color: AppColors.primary),
          ),
          const SizedBox(width: 6),
          const Text(
            '20.2 km • 22 mins',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}'''

new_badge = '''class _MapDistanceBadge extends StatelessWidget {
  final Map<String, dynamic>? nearestMember;

  const _MapDistanceBadge({this.nearestMember});

  @override
  Widget build(BuildContext context) {
    String text = 'Finding nearby...';
    if (nearestMember != null) {
      final dist = nearestMember!['distance_km'] as double? ?? 0.0;
      final time = nearestMember!['duration_mins'] as int? ?? 0;
      final name = nearestMember!['name'] as String? ?? 'Member';
      text = '${name} is ${dist.toStringAsFixed(1)} km away • ${time} mins';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppAssets.worldMap,
            width: 13,
            height: 13,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.public, size: 13, color: AppColors.primary),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}'''

content = content.replace(old_badge, new_badge)

with open('lib/features/location/presentation/screens/live_map_screen.dart', 'w') as f:
    f.write(content)
