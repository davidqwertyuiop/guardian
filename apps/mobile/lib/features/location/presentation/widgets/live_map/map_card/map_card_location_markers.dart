part of '../map_card.dart';

extension MapCardLocationMarkers on MapCardState {
  Future<BitmapDescriptor> _createLocationPinMarker(String label) async {
    return BitmapDescriptor.bytes(await _createLocationPinBytes(label));
  }

  Future<BitmapDescriptor> _createSosPinMarker() async {
    return BitmapDescriptor.bytes(await _createSosPinBytes());
  }

  Future<Uint8List> _createLocationPinBytes(String label) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const width = 120.0;
    const height = 100.0;
    final paint = Paint()..color = Colors.black;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 5, 100, 35),
        const Radius.circular(8),
      ),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(50, 40)
        ..lineTo(70, 40)
        ..lineTo(60, 48)
        ..close(),
      paint,
    );
    _paintMarkerLabel(canvas, label, Colors.white, 11, 35);
    _paintMarkerIcon(
      canvas,
      Icons.location_on,
      Colors.black,
      32,
      const Offset(45, 55),
    );

    final image = await recorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<Uint8List> _createSosPinBytes() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const width = 124.0;
    const height = 104.0;
    final redPaint = Paint()..color = const Color(0xFFFF2F7D);
    final blackPaint = Paint()..color = Colors.black;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final label = RRect.fromRectAndRadius(
      const Rect.fromLTWH(12, 4, 100, 36),
      const Radius.circular(18),
    );
    canvas
      ..drawRRect(label.shift(const Offset(0, 3)), shadowPaint)
      ..drawRRect(label, blackPaint);
    _paintMarkerLabel(canvas, 'SOS', const Color(0xFFFF2F7D), 18, 36);

    final pin = Path()
      ..addOval(const Rect.fromLTWH(42, 48, 40, 40))
      ..moveTo(52, 82)
      ..quadraticBezierTo(62, 104, 72, 82)
      ..close();
    canvas
      ..drawPath(pin.shift(const Offset(0, 2)), shadowPaint)
      ..drawPath(pin, redPaint)
      ..drawCircle(const Offset(62, 68), 8, Paint()..color = Colors.white);

    final image = await recorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _paintMarkerLabel(
    Canvas canvas,
    String label,
    Color color,
    double fontSize,
    double bubbleHeight,
  ) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      )
      ..layout(minWidth: 0, maxWidth: 100);
    textPainter.paint(
      canvas,
      Offset(
        10 + (100 - textPainter.width) / 2,
        5 + (bubbleHeight - textPainter.height) / 2,
      ),
    );
  }

  void _paintMarkerIcon(
    Canvas canvas,
    IconData icon,
    Color color,
    double size,
    Offset offset,
  ) {
    final iconPainter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: icon.fontFamily,
          color: color,
        ),
      )
      ..layout();
    iconPainter.paint(canvas, offset);
  }
}
