part of '../map_card.dart';

extension MapCardAvatarImage on MapCardState {
  Future<void> _paintAvatarImage(
    Canvas canvas,
    Offset center,
    double radius,
    String? assetPath,
    ui.Image? avatarImage,
  ) async {
    try {
      canvas.save();
      canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: center, radius: radius - 1.5)),
      );
      final image =
          avatarImage ??
          (assetPath != null ? await _loadUiImage(assetPath) : null);
      if (image != null) {
        paintImage(
          canvas: canvas,
          rect: Rect.fromCircle(center: center, radius: radius - 1.5),
          image: image,
          fit: BoxFit.cover,
        );
      }
      canvas.restore();
    } catch (_) {
      canvas.restore();
    }
  }
}
