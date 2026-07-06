part of '../map_card.dart';

extension MapCardAvatarMarkers on MapCardState {
  Future<BitmapDescriptor> _createAvatarPinMarker(
    String label, {
    String? assetPath,
    ui.Image? avatarImage,
  }) async {
    return BitmapDescriptor.bytes(
      await _createAvatarPinBytes(
        label,
        assetPath: assetPath,
        avatarImage: avatarImage,
      ),
    );
  }

  Future<Uint8List> _createAvatarPinBytes(
    String label, {
    String? assetPath,
    ui.Image? avatarImage,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const width = 88.0;
    const height = 104.0;
    const avatarCenter = Offset(44, 38);
    const avatarRadius = 24.0;

    _paintMemberPinBase(canvas);
    canvas.drawCircle(
      avatarCenter,
      avatarRadius + 5,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      avatarCenter,
      avatarRadius + 2,
      Paint()..color = const Color(0xFF7C4DFF),
    );
    await _paintAvatarImage(
      canvas,
      avatarCenter,
      avatarRadius,
      assetPath,
      avatarImage,
    );

    final image = await recorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _paintMemberPinBase(Canvas canvas) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final pinPath = Path()
      ..addOval(const Rect.fromLTWH(13, 5, 62, 62))
      ..moveTo(30, 59)
      ..quadraticBezierTo(44, 96, 58, 59)
      ..close();
    canvas
      ..drawPath(pinPath.shift(const Offset(0, 2)), shadowPaint)
      ..drawPath(pinPath, Paint()..color = Colors.black);
  }
}
