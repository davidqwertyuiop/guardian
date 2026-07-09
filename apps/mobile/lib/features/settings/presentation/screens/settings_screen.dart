import 'package:flutter/material.dart';
import 'package:guardian/export.dart';
import '../widgets/settings_detail_pages.dart';
import '../widgets/settings_account_page.dart';
import '../widgets/settings_profile_view.dart';

enum SettingsPage {
  profile,
  details,
  location,
  notifications,
  devices,
  privacy,
  help,
  account,
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsBloc _settingsBloc;
  SettingsPage _page = SettingsPage.profile;

  @override
  void initState() {
    super.initState();
    _settingsBloc = context.read<SettingsBloc>()
      ..add(const LoadSessions())
      ..add(const LoadSettingsProfile());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, homeState) {
        return BlocBuilder<SettingsBloc, SettingsState>(
          bloc: _settingsBloc,
          builder: (context, settingsState) {
            return BlocListener<SettingsBloc, SettingsState>(
              bloc: _settingsBloc,
              listenWhen: (previous, current) =>
                  !previous.accountDeleted && current.accountDeleted,
              listener: (_, _) => _goToLogin(),
              child: Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: SafeArea(child: _body(homeState, settingsState)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _body(HomeState homeState, SettingsState settingsState) {
    return switch (_page) {
      SettingsPage.profile => SettingsProfileView(
        homeState: homeState,
        onOpen: _open,
        onLogout: _logout,
      ),
      SettingsPage.details => SettingsDetailsPage(
        userName: homeState.userName,
        avatarUrl: homeState.avatarUrl,
        onBack: _back,
      ),
      SettingsPage.location => SettingsLocationPage(
        state: settingsState,
        onBack: _back,
        onChanged: _updatePreferences,
      ),
      SettingsPage.notifications => SettingsNotificationsPage(
        state: settingsState,
        onBack: _back,
        onChanged: _updatePreferences,
      ),
      SettingsPage.devices => SettingsDevicesPage(
        state: settingsState,
        onBack: _back,
        onRevoke: (hash) => _settingsBloc.add(RevokeSession(hash)),
      ),
      SettingsPage.privacy => SettingsPrivacyPage(onBack: _back),
      SettingsPage.help => SettingsHelpPage(onBack: _back),
      SettingsPage.account => SettingsAccountPage(
        onBack: _back,
        onOpen: _open,
        onDeleteAccount: () => showDeleteAccountDialog(
          context,
          onDelete: () => _settingsBloc.add(const DeleteAccountRequested()),
        ),
      ),
    };
  }

  void _open(SettingsPage page) => setState(() => _page = page);

  void _back() => setState(() => _page = SettingsPage.profile);

  void _goToLogin() {
    TokenManager().clearTokens().then((_) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        FadeRoute(page: const LoginScreen()),
        (route) => false,
      );
    });
  }

  void _updatePreferences(
          bool location, bool sos, bool broadcast, bool newMember,
          [DateTime? locationPausedUntil]) =>
      _settingsBloc.add(
        UpdateSettingsPreferences(
          locationEnabled: location,
          notifySos: sos,
          notifyBroadcast: broadcast,
          notifyNewMember: newMember,
          locationPausedUntil: locationPausedUntil,
        ),
      );

  Future<void> _logout() async {
    await TokenManager().clearTokens();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      FadeRoute(page: const LoginScreen()),
      (route) => false,
    );
  }
}
