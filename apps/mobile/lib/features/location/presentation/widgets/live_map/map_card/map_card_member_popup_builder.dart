part of '../map_card.dart';

extension MapCardMemberPopupBuilder on MapCardState {
  Widget buildMemberMapPopup({
    required BuildContext dialogContext,
    required Map<String, dynamic> member,
    required String name,
    required String address,
    required String updatedLabel,
    required String avatarUrl,
    required String fallbackAsset,
    required String batteryLabel,
    required String connectivity,
    required Map<dynamic, dynamic>? activeSos,
    required String phone,
    required double latitude,
    required double longitude,
  }) {
    final isSharing = member.isNotEmpty && connectivity != 'Offline';
    return MemberMapPopup(
      name: name,
      address: address,
      updatedLabel: updatedLabel,
      avatarUrl: avatarUrl,
      fallbackAsset: fallbackAsset,
      batteryLabel: batteryLabel,
      connectivityLabel: connectivity,
      statusLabel: isSharing ? 'Active' : 'Paused',
      showSosBanner: activeSos != null,
      sosBannerText: remainingSosText(activeSos),
      onBack: () => Navigator.of(dialogContext).pop(),
      onClose: () => Navigator.of(dialogContext).pop(),
      onCall: () => handleMemberCall(dialogContext, phone, name),
      onViewOnMap: () => focusMemberLocation(
        dialogContext: dialogContext,
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  Future<void> handleMemberCall(
    BuildContext dialogContext,
    String phone,
    String name,
  ) async {
    if (phone.isEmpty) {
      toastification.show(
        context: dialogContext,
        title: const Text('Call unavailable'),
        description: Text('No phone number found for $name.'),
        type: ToastificationType.info,
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    final opened = await _tryLaunchPhone(uri);
    if (!opened && dialogContext.mounted) {
      toastification.show(
        context: dialogContext,
        title: const Text('Call unavailable'),
        description: const Text('Could not open the phone app.'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
    if (!dialogContext.mounted) return;
    Navigator.of(dialogContext).pop();
  }

  Future<bool> _tryLaunchPhone(Uri uri) async {
    try {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
