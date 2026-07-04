import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/responsive_scale.dart';
import 'package:guardian/core/services/api_service.dart';
import 'package:guardian/core/services/api/sos_api_service.dart';
import 'package:toastification/toastification.dart';

class SosBroadcastsScreen extends StatefulWidget {
  final String circleId;
  const SosBroadcastsScreen({super.key, required this.circleId});

  @override
  State<SosBroadcastsScreen> createState() => _SosBroadcastsScreenState();
}

class _SosBroadcastsScreenState extends State<SosBroadcastsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<dynamic> _broadcasts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBroadcasts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBroadcasts() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getSosBroadcasts(widget.circleId);
      if (mounted) {
        setState(() {
          _broadcasts = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resolveBroadcast(String broadcastId) async {
    try {
      final success = await SosApiService.resolveSos(broadcastId);
      if (success) {
        toastification.show(
          title: const Text('SOS Resolved'),
          description: const Text('The SOS broadcast has been successfully resolved.'),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 3),
        );
        _loadBroadcasts();
      } else {
        throw Exception('Failed to resolve');
      }
    } catch (_) {
      toastification.show(
        title: const Text('Error'),
        description: const Text('Could not resolve the SOS broadcast. Please try again.'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeBroadcasts = _broadcasts.where((b) => b['status'] == 'active').toList();
    final pastBroadcasts = _broadcasts.where((b) => b['status'] != 'active').toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0E17) : const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: Text(
          'SOS Broadcasts',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: context.sp(20),
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.white38 : Colors.black38,
          labelStyle: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: 'Active (${activeBroadcasts.length})'),
            Tab(text: 'Past (${pastBroadcasts.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBroadcastList(activeBroadcasts, isActive: true, isDark: isDark),
                _buildBroadcastList(pastBroadcasts, isActive: false, isDark: isDark),
              ],
            ),
    );
  }

  Widget _buildBroadcastList(List<dynamic> list, {required bool isActive, required bool isDark}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.shield_outlined : Icons.history_rounded,
              size: context.w(64),
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'No active SOS broadcasts' : 'No past SOS broadcasts',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: context.sp(16),
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadBroadcasts,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final b = list[index];
          final name = b['name'] as String? ?? 'Unknown Member';
          final address = b['address'] as String? ?? 'Unknown Location';
          final status = b['status'] as String? ?? 'resolved';
          final String broadcastId = b['id'] as String? ?? '';

          String dateStr = 'Unknown';
          String timeStr = 'Unknown';
          final createdAt = b['created_at'] as String?;
          if (createdAt != null) {
            try {
              final dt = DateTime.parse(createdAt).toLocal();
              dateStr = DateFormat('MM/dd/yyyy').format(dt);
              timeStr = DateFormat('h:mma').format(dt);
            } catch (_) {}
          }

          final List<String> avatars = [
            AppAssets.avatarTop,
            AppAssets.avatarLeft,
            AppAssets.avatarRight,
          ];
          final avatar = avatars[index % avatars.length];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E24) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar image
                    Container(
                      width: context.w(44),
                      height: context.w(44),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(avatar),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: context.sp(15),
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isActive)
                                Container(
                                  width: context.w(8),
                                  height: context.w(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: context.sp(11),
                              fontWeight: FontWeight.w800,
                              color: isActive ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: context.sp(11),
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: context.sp(11),
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: context.w(16),
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: context.sp(13),
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isActive && broadcastId.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: context.w(40),
                    child: OutlinedButton(
                      onPressed: () => _resolveBroadcast(broadcastId),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: isDark ? Colors.redAccent.withValues(alpha: 0.5) : Colors.redAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Mark as Resolved',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: context.sp(13),
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
