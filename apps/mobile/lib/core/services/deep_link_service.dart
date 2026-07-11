import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_event.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  AuthBloc? _authBloc;

  void initialize(AuthBloc authBloc) {
    _authBloc = authBloc;
    _appLinks = AppLinks();

    _checkInitialLink();

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      log('DeepLink received: $uri');
      _handleLink(uri);
    }, onError: (err) {
      log('Failed to listen to AppLinks: $err');
    });
  }

  Future<void> _checkInitialLink() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        log('Initial DeepLink received: $initialUri');
        _handleLink(initialUri);
      }
    } catch (e) {
      log('Failed to get initial AppLink: $e');
    }
  }

  void _handleLink(Uri uri) {
    if (_authBloc == null) return;

    // Check if this is an invite link.
    // Format could be: guardian://invite/XYZ
    // Or: https://guardian.shadowchat.xyz/invite/XYZ
    // Or: https://guardian.shadowchat.xyz/join?code=XYZ

    String? inviteCode;

    if (uri.path.contains('/invite/')) {
      // Extract from path
      final segments = uri.pathSegments;
      final inviteIndex = segments.indexOf('invite');
      if (inviteIndex != -1 && inviteIndex + 1 < segments.length) {
        inviteCode = segments[inviteIndex + 1];
      }
    } else if (uri.path.contains('/join') && uri.queryParameters.containsKey('code')) {
      // Extract from query parameter
      inviteCode = uri.queryParameters['code'];
    }

    if (inviteCode != null && inviteCode.isNotEmpty) {
      log('Captured invite code from deep link: $inviteCode');
      _authBloc!.add(HandleDeepLinkInvite(inviteCode));
    } else {
      log('Deep link received but no invite code found.');
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
