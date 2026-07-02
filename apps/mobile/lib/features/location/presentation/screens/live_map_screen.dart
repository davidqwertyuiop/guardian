import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/core/utils/fade_route.dart';
import 'package:guardian/features/emergency/presentation/screens/emergency_screen.dart';
import 'package:guardian/features/home/presentation/bloc/home_bloc.dart';
import 'package:guardian/features/home/presentation/bloc/home_event.dart';
import 'package:guardian/features/home/presentation/bloc/home_state.dart';
import 'package:guardian/features/location/presentation/screens/full_map_screen.dart';

enum _MapState { compact, expanded }

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen>
    with SingleTickerProviderStateMixin {
  late final HomeBloc _bloc;
  _MapState _mapState = _MapState.compact;
  late final AnimationController _mapAnim;
  late final Animation<double> _mapHeight;

  @override
  void initState() {
    super.initState();
    _bloc = locator<HomeBloc>()..add(const LoadHomeData());
    _mapAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _mapHeight = Tween<double>(
      begin: 160,
      end: 340,
    ).animate(CurvedAnimation(parent: _mapAnim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _mapAnim.dispose();
    super.dispose();
  }

  void _toggleMap() {
    setState(() {
      if (_mapState == _MapState.compact) {
        _mapState = _MapState.expanded;
        _mapAnim.forward();
      } else {
        _mapState = _MapState.compact;
        _mapAnim.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: _bloc,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => _bloc.add(const LoadHomeData()),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _TopBar(
                      onSosTap: () => Navigator.push(
                        context,
                        FadeRoute(page: const EmergencyScreen()),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _MapCard(
                      mapState: _mapState,
                      mapHeight: _mapHeight,
                      onTap: _toggleMap,
                      onOpenMap: () => Navigator.push(
                        context,
                        FadeRoute(page: const FullMapScreen()),
                      ),
                      members: state.members,
                    ),
                    const SizedBox(height: 16),
                    _CircleCard(
                      circleName: state.circleName,
                      members: state.members,
                    ),
                    const SizedBox(height: 16),
                    const _HeadingOutButton(),
                    const SizedBox(height: 28),
                    const _SosBroadcastsSection(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onSosTap;
  const _TopBar({required this.onSosTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bell icon — circular grey pill
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                AppAssets.phBell,
                width: 20,
                height: 20,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.notifications_none_rounded,
                  size: 20,
                  color: Color(0xFF555566),
                ),
              ),
            ),
          ),

          // Centre: Guardian home icon
          Image.asset(
            AppAssets.appHomeIcon,
            width: 42,
            height: 42,
            errorBuilder: (_, _, _) => Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: const Icon(Icons.shield, color: Colors.white, size: 22),
            ),
          ),

          // SOS pill + grid icon
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // SOS pill
              GestureDetector(
                onTap: onSosTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECF4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'SOS',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFF3380),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Image.asset(
                        AppAssets.sosIcon,
                        width: 20,
                        height: 20,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.warning_rounded,
                          size: 16,
                          color: Color(0xFFFF3380),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Grid / menu icon
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF3380),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Map Card ─────────────────────────────────────────────────────────────────

class _MapCard extends StatelessWidget {
  final _MapState mapState;
  final Animation<double> mapHeight;
  final VoidCallback onTap;
  final VoidCallback onOpenMap;
  final List<dynamic> members;

  const _MapCard({
    required this.mapState,
    required this.mapHeight,
    required this.onTap,
    required this.onOpenMap,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: mapHeight,
        builder: (context, _) {
          return GestureDetector(
            onTap: onTap,
            child: Container(
              height: mapHeight.value,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF0F3),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    // Map background
                    Positioned.fill(
                      child: Image.asset(
                        AppAssets.mapAddress,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: const Color(0xFFE8EAF0),
                          child: const Center(
                            child: Icon(
                              Icons.map_outlined,
                              size: 48,
                              color: Color(0xFFAAABBB),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Compact state overlays
                    if (mapState == _MapState.compact) ...[
                      // Distance badge — top left
                      Positioned(top: 14, left: 14, child: _MapDistanceBadge()),
                      // Location pin — center bottom area
                      const Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: Center(child: _LocationPin()),
                      ),
                      // Area name — bottom right
                      const Positioned(
                        right: 16,
                        bottom: 14,
                        child: Text(
                          'COUNTRY\nCLUB PARK',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7779A0),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],

                    // Expanded state overlays
                    if (mapState == _MapState.expanded) ...[
                      // Top overlay row
                      Positioned(
                        top: 14,
                        left: 14,
                        right: 14,
                        child: _ExpandedTopRow(onSosTap: onTap),
                      ),
                      // Avatar pins
                      const Positioned(
                        left: 80,
                        bottom: 120,
                        child: _AvatarPin(
                          asset: AppAssets.avatarTop,
                          label: 'Olympic Blvd',
                        ),
                      ),
                      const Positioned(
                        right: 60,
                        top: 120,
                        child: _AvatarPin(
                          asset: AppAssets.avatarLeft,
                          label: 'WILSHIRE PA',
                        ),
                      ),
                      // Open map button
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: onOpenMap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B97E8),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.map_outlined,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Open map',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MapDistanceBadge extends StatelessWidget {
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
}

class _LocationPin extends StatelessWidget {
  const _LocationPin();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Circular avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF3D1F80),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            image: const DecorationImage(
              image: AssetImage(AppAssets.avatarTop),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Pin tail
        Positioned(
          bottom: -8,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF3D1F80),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpandedTopRow extends StatelessWidget {
  final VoidCallback onSosTap;
  const _ExpandedTopRow({required this.onSosTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.notifications_none_rounded,
              size: 18,
              color: Color(0xFF444455),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.grey.shade700.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Mabushi, Abuja 900108',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onSosTap,
          child: Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'SOS',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  color: Color(0xFFFF3380),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarPin extends StatelessWidget {
  final String asset;
  final String label;
  const _AvatarPin({required this.asset, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
            image: DecorationImage(image: AssetImage(asset), fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }
}

// ─── Circle Card ──────────────────────────────────────────────────────────────

class _CircleCard extends StatelessWidget {
  final String circleName;
  final List<dynamic> members;
  const _CircleCard({required this.circleName, required this.members});

  @override
  Widget build(BuildContext context) {
    final count = members.isNotEmpty ? members.length : 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7FA),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left column: count label + circle name + circular member avatars
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count members',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF999AB0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    circleName.isNotEmpty ? circleName : "brother's\ncircle",
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Overlapping circular member avatars
                  _MemberAvatarRow(members: members),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right column: 2x2 square avatar grid
            _AvatarGrid(members: members),
          ],
        ),
      ),
    );
  }
}

/// 3 overlapping circles — flag/emoji style avatars matching the design.
class _MemberAvatarRow extends StatelessWidget {
  final List<dynamic> members;
  const _MemberAvatarRow({required this.members});

  // Fallback coloured backgrounds for when there are no real avatars
  static const _fallbackColors = [
    Color(0xFF2D7D32), // green (Nigerian flag)
    Color(0xFFF48FB1), // pink / floral
    Color(0xFF1565C0), // blue flag
  ];

  static const _fallbackAssets = [
    AppAssets.avatarTop,
    AppAssets.avatarLeft,
    AppAssets.avatarRight,
  ];

  @override
  Widget build(BuildContext context) {
    final displayCount = members.isEmpty ? 3 : members.length.clamp(1, 4);
    const avatarSize = 32.0;
    const overlap = 10.0;

    return SizedBox(
      height: avatarSize,
      width: avatarSize + (displayCount - 1) * (avatarSize - overlap),
      child: Stack(
        children: List.generate(displayCount, (i) {
          final String? url = members.isEmpty
              ? null
              : (members[i] as Map<String, dynamic>)['avatar_url'] as String?;

          final bool hasUrl = url != null && url.isNotEmpty;
          final String fallbackAsset = i < _fallbackAssets.length
              ? _fallbackAssets[i]
              : _fallbackAssets[0];
          final Color fallbackColor = i < _fallbackColors.length
              ? _fallbackColors[i]
              : _fallbackColors[0];

          return Positioned(
            left: i * (avatarSize - overlap),
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fallbackColor,
                border: Border.all(color: Colors.white, width: 2),
                image: DecorationImage(
                  image: hasUrl
                      ? NetworkImage(url) as ImageProvider
                      : AssetImage(fallbackAsset),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 2 × 2 grid of rounded-square avatar tiles (filled or empty placeholder).
class _AvatarGrid extends StatelessWidget {
  final List<dynamic> members;
  const _AvatarGrid({required this.members});

  static const _fallbackAssets = [
    AppAssets.avatarTop,
    AppAssets.avatarLeft,
    AppAssets.avatarRight,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 88,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_slot(0), const SizedBox(width: 6), _slot(1)],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_slot(2), const SizedBox(width: 6), _slot(3)],
          ),
        ],
      ),
    );
  }

  Widget _slot(int index) {
    final bool hasMember = index < members.length;
    if (!hasMember) {
      return Container(
        width: 40,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFE4E4EC),
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    final m = members[index] as Map<String, dynamic>;
    final url = m['avatar_url'] as String? ?? '';
    final fallback = index < _fallbackAssets.length
        ? _fallbackAssets[index]
        : _fallbackAssets[0];

    return Container(
      width: 40,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade300,
        image: DecorationImage(
          image: url.isNotEmpty
              ? NetworkImage(url) as ImageProvider
              : AssetImage(fallback),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// ─── I'm Heading Out Button ───────────────────────────────────────────────────

class _HeadingOutButton extends StatelessWidget {
  const _HeadingOutButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Journey request initiated!'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          child: const Text(
            "I'm heading out",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── SOS Broadcasts Section ───────────────────────────────────────────────────

class _SosBroadcastsSection extends StatelessWidget {
  const _SosBroadcastsSection();

  static const _broadcasts = [
    {
      'name': 'Mac',
      'location': 'LBS, Lekki',
      'date': '02/06/2024',
      'time': '2:20PM',
    },
    {
      'name': 'Olajire',
      'location': 'Alausa, Ikeja',
      'date': '02/06/2024',
      'time': '2:20PM',
    },
    {
      'name': 'Tunde',
      'location': 'Mabushi, Abuja',
      'date': '02/06/2024',
      'time': '3:50PM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Image.asset(
                AppAssets.sosBroadcastIcon,
                width: 20,
                height: 20,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.campaign_rounded,
                  color: Color(0xFF3355FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                'SOS Broadcasts',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3355FF),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Color(0xFF888899),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Date group label
        const Padding(
          padding: EdgeInsets.only(left: 20, bottom: 10),
          child: Text(
            'Today',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Color(0xFF888899),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Broadcast list
        ...List.generate(_broadcasts.length, (i) {
          final b = _broadcasts[i];
          return _BroadcastTile(
            name: b['name']!,
            location: b['location']!,
            date: b['date']!,
            time: b['time']!,
            avatarIndex: i,
          );
        }),
      ],
    );
  }
}

class _BroadcastTile extends StatelessWidget {
  final String name;
  final String location;
  final String date;
  final String time;
  final int avatarIndex;

  const _BroadcastTile({
    required this.name,
    required this.location,
    required this.date,
    required this.time,
    required this.avatarIndex,
  });

  static const _avatarAssets = [
    AppAssets.avatarTop,
    AppAssets.avatarLeft,
    AppAssets.avatarRight,
  ];

  @override
  Widget build(BuildContext context) {
    final asset = avatarIndex < _avatarAssets.length
        ? _avatarAssets[avatarIndex]
        : _avatarAssets[0];

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
      child: Row(
        children: [
          // Circular avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
              image: DecorationImage(
                image: AssetImage(asset),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  location,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF888899),
                  ),
                ),
              ],
            ),
          ),

          // Date + time (right-aligned)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Color(0xFF888899),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Color(0xFF888899),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
