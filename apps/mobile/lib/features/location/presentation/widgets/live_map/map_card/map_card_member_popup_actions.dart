part of '../map_card.dart';

extension MapCardMemberPopupActions on MapCardState {
  void preloadMemberMarker(dynamic member) {
    final uid = member['user_id'] ?? '';
    final url = member['avatar_url'] ?? '';
    final name = member['name'] ?? 'Member';
    if (uid.isEmpty || _loadingAvatars.containsKey(uid)) return;
    _loadingAvatars[uid] = true;
    (() async {
      try {
        final image = url.isNotEmpty ? await _loadNetworkImage(url) : null;
        final fallbackAsset = _fallbackAvatarAsset(uid);
        final googleMarker = await _createAvatarPinMarker(
          name,
          assetPath: image == null ? fallbackAsset : null,
          avatarImage: image,
        );
        if (mounted) {
          refresh(() => _googleMarkersCache[uid] = googleMarker);
        }
      } catch (e) {
        log('Error creating member marker for $name: $e');
      }
    })();
  }

  Future<void> showMemberPopup({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    final member = memberPopupData(userId);
    final name = member['name']?.toString().trim().isNotEmpty == true
        ? member['name'].toString().trim()
        : 'Circle member';
    final avatarUrl = member['avatar_url']?.toString() ?? '';
    final phone = member['phone']?.toString() ?? '';
    final battery = member['battery_level'];
    final batteryLabel = battery is num ? '${battery.toInt()}%' : '--';
    final connectivity = member['connectivity_type']?.toString() ?? 'Offline';
    final updatedLabel = relativeUpdatedLabel(member['updated_at']?.toString());
    final navigator = Navigator.of(context);
    final address = await resolveMemberAddress(latitude, longitude);
    final activeSos = activeSosBroadcastForUser(userId);
    final fallbackAsset = _fallbackAvatarAsset(userId);
    if (!mounted) return;
    await navigator.push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (dialogContext, animation, secondaryAnimation) =>
            buildMemberMapPopup(
              dialogContext: dialogContext,
              member: member,
              name: name,
              address: address,
              updatedLabel: updatedLabel,
              avatarUrl: avatarUrl,
              fallbackAsset: fallbackAsset,
              batteryLabel: batteryLabel,
              connectivity: connectivity,
              activeSos: activeSos,
              phone: phone,
              latitude: latitude,
              longitude: longitude,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
