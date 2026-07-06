# settings_screen.dart

* **File Path:** `apps/mobile/lib/features/settings/presentation/screens/settings_screen.dart`
* **Type:** `DART`

---

```dart
import 'package:flutter/material.dart';

import 'package:guardian/export.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsBloc _settingsBloc;

  @override
  void initState() {
    super.initState();
    _settingsBloc = context.read<SettingsBloc>();
    _settingsBloc.add(const LoadSessions());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0E0E12)
          : const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        bloc: context.read<HomeBloc>(),
        builder: (context, homeState) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // 1. Profile Card Info
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                          image: homeState.avatarUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(homeState.avatarUrl),
                                  fit: BoxFit.cover,
                                )
                              : const DecorationImage(
                                  image: AssetImage(AppAssets.avatarTop),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        homeState.userName.isNotEmpty
                            ? homeState.userName
                            : 'User',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: AdaptiveLayout.sp(context, 22),
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Guardian Safe ID Active',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: AdaptiveLayout.sp(context, 13),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // 2. Active Devices / Logged-in Sessions
                Text(
                  'Logged-in Devices',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: AdaptiveLayout.sp(context, 18),
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                BlocBuilder<SettingsBloc, SettingsState>(
                  bloc: _settingsBloc,
                  builder: (context, state) {
                    if (state.status == SettingsStatus.loading &&
                        state.sessions.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }

                    if (state.sessions.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text(
                          'No active device sessions found.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.sessions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final session =
                            state.sessions[index] as Map<String, dynamic>;
                        final deviceName =
                            session['device_name'] as String? ?? 'Device';
                        final deviceModel =
                            session['device_model'] as String? ??
                            'Generic Model';
                        final platform =
                            session['platform'] as String? ?? 'ios';
                        final tokenHash =
                            session['refresh_token_hash'] as String? ?? '';

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E24)
                                : const Color(0xFFF7F7FA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                platform.toLowerCase() == 'ios'
                                    ? Icons.phone_iphone_rounded
                                    : Icons.phone_android_rounded,
                                color: AppColors.primary,
                                size: 28,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      deviceName,
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      deviceModel,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.logout_rounded,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                onPressed: () {
                                  if (tokenHash.isNotEmpty) {
                                    _settingsBloc.add(RevokeSession(tokenHash));
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 36),

                // 3. Settings List Options
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_none),
                  title: const Text(
                    'Notifications',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text(
                    'Security & Privacy',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () async {
                    await TokenManager().clearTokens();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        FadeRoute(page: const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

```
