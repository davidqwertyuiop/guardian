import 'package:firebase_auth/firebase_auth.dart';
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
  terms,
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
  final List<SettingsPage> _history = [SettingsPage.profile];

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
    final Widget child = switch (_page) {
      SettingsPage.profile => SettingsProfileView(
        key: const ValueKey(SettingsPage.profile),
        homeState: homeState,
        onOpen: _open,
        onLogout: _logout,
      ),
      SettingsPage.details => SettingsDetailsPage(
        key: const ValueKey(SettingsPage.details),
        userName: homeState.userName,
        avatarUrl: homeState.avatarUrl,
        onBack: _back,
      ),
      SettingsPage.location => SettingsLocationPage(
        key: const ValueKey(SettingsPage.location),
        state: settingsState,
        onBack: _back,
        onChanged: _updatePreferences,
      ),
      SettingsPage.notifications => SettingsNotificationsPage(
        key: const ValueKey(SettingsPage.notifications),
        state: settingsState,
        onBack: _back,
        onChanged: _updatePreferences,
      ),
      SettingsPage.devices => SettingsDevicesPage(
        key: const ValueKey(SettingsPage.devices),
        state: settingsState,
        onBack: _back,
        onRevoke: (hash) => _settingsBloc.add(RevokeSession(hash)),
      ),
      SettingsPage.privacy => SettingsPrivacyPage(
        key: const ValueKey(SettingsPage.privacy),
        onBack: _back,
        isTerms: false,
      ),
      SettingsPage.terms => SettingsPrivacyPage(
        key: const ValueKey(SettingsPage.terms),
        onBack: _back,
        isTerms: true,
      ),
      SettingsPage.help => SettingsHelpPage(
        key: const ValueKey(SettingsPage.help),
        onBack: _back,
      ),
      SettingsPage.account => SettingsAccountPage(
        key: const ValueKey(SettingsPage.account),
        onBack: _back,
        onOpen: _open,
        onDeleteAccount: () => showDeleteAccountDialog(
          context,
          onDelete: () => _settingsBloc.add(const DeleteAccountRequested()),
        ),
      ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: child,
    );
  }

  void _open(SettingsPage page) {
    setState(() {
      _history.add(page);
      _page = page;
    });
  }

  void _back() {
    if (_history.length > 1) {
      setState(() {
        _history.removeLast();
        _page = _history.last;
      });
    } else {
      setState(() {
        _page = SettingsPage.profile;
      });
    }
  }

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
    
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    if (!mounted) return;

    try {
      context.read<AuthBloc>().add(const ResetAuth());
    } catch (_) {}

    Navigator.of(context).pushAndRemoveUntil(
      FadeRoute(page: const LoginScreen()),
      (route) => false,
    );
  }
}
