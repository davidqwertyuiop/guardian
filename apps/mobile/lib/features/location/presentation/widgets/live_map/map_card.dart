import 'package:http/http.dart' as http;
import 'package:guardian/features/location/services/gps_service.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart' as am;
import 'package:guardian/export.dart';

import 'map_styles.dart';
import 'map_distance_badge.dart';
import '../../../domain/models/live_map_models.dart';

class MapCard extends StatefulWidget {
  final MapDisplayState mapState;
  final Animation<double> mapAnim;
  final Animation<double> fullAnim;
  final VoidCallback onTap;
  final VoidCallback onOpenMap;
  final VoidCallback onSosTap;
  final List<dynamic> members;
  final double userLatitude;
  final double userLongitude;
  final String circleId;
  final SelectedLivePlace? selectedPlace;
  final VoidCallback onClearSearch;

  const MapCard({
    super.key,
    required this.mapState,
    required this.mapAnim,
    required this.fullAnim,
    required this.onTap,
    required this.onOpenMap,
    required this.onSosTap,
    required this.members,
    required this.userLatitude,
    required this.userLongitude,
    required this.circleId,
    required this.selectedPlace,
    required this.onClearSearch,
  });

  @override
  State<MapCard> createState() => MapCardState();
}

class MapCardState extends State<MapCard> {
  GoogleMapController? _controller;
  am.AppleMapController? _amController;

  BitmapDescriptor? _avatarTopMarker;
  BitmapDescriptor? _userLocationMarker;
  BitmapDescriptor? _devicePhoneMarker;
  BitmapDescriptor? _deviceLaptopMarker;

  am.BitmapDescriptor? _amAvatarTopMarker;
  am.BitmapDescriptor? _amUserLocationMarker;
  am.BitmapDescriptor? _amDevicePhoneMarker;
  am.BitmapDescriptor? _amDeviceLaptopMarker;

  Timer? _gpsTimer;
  List<dynamic> _serverLocations = [];
  Map<String, dynamic>? _nearestMemberInfo;
  List<dynamic> _sessions = [];
  String _currentDeviceModel = '';
  String _currentUserId = '';

  final Map<String, BitmapDescriptor> _googleMarkersCache = {};
  final Map<String, am.BitmapDescriptor> _appleMarkersCache = {};
  final Map<String, bool> _loadingAvatars = {};

  @override
  void initState() {
    super.initState();
    _loadMarkerIcons();
    _loadCurrentUserId();
    _fetchCurrentDeviceModel();
    _syncLocationAndLoadData();
    _startGpsTimer();
  }

  @override
  void dispose() {
    _gpsTimer?.cancel();
    super.dispose();
  }

  void _startGpsTimer() {
    _gpsTimer?.cancel();
    _gpsTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _syncLocationAndLoadData();
    });
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final prefs = locator<SharedPreferences>();
      _currentUserId = prefs.getString('user_id') ?? '';
    } catch (_) {}
  }

  Future<void> _fetchCurrentDeviceModel() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _currentDeviceModel = androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _currentDeviceModel = iosInfo.utsname.machine;
      }
    } catch (_) {}
  }

  Future<void> _syncLocationAndLoadData() async {
    if (!mounted) return;
    try {
      final loc = await GpsService().getCurrentLocation();
      final lat = loc['latitude'] ?? widget.userLatitude;
      final lon = loc['longitude'] ?? widget.userLongitude;

      if (widget.circleId.isNotEmpty) {
        await ApiService.updateLocation(
          circleId: widget.circleId,
          latitude: lat,
          longitude: lon,
          accuracy: 10.0,
        );
      }

      final sessionsList = await ApiService.getSessions();

      List<dynamic> serverLocs = [];
      Map<String, dynamic>? nearest;
      if (widget.circleId.isNotEmpty) {
        serverLocs = await ApiService.getCircleMemberLocations(widget.circleId);
        nearest = await ApiService.getNearestMemberLocation(widget.circleId);
      }

      if (mounted) {
        setState(() {
          _sessions = sessionsList;
          _serverLocations = serverLocs;
          _nearestMemberInfo = nearest;
        });
      }

      // Background avatar preloading
      for (var member in serverLocs) {
        final String uid = member['user_id'] ?? '';
        final String url = member['avatar_url'] ?? '';
        final String name = member['name'] ?? 'Member';

        if (uid.isNotEmpty &&
            url.isNotEmpty &&
            !_loadingAvatars.containsKey(uid)) {
          _loadingAvatars[uid] = true;
          _loadNetworkImage(url).then((img) async {
            if (img != null) {
              final gMarker = await _createAvatarPinMarker(
                name,
                avatarImage: img,
              );
              final aMarker = await _createAmAvatarPinMarker(
                name,
                avatarImage: img,
              );
              if (mounted) {
                setState(() {
                  _googleMarkersCache[uid] = gMarker;
                  _appleMarkersCache[uid] = aMarker;
                });
              }
            }
          });
        }
      }
    } catch (e) {
      log('Error in location background sync: $e');
    }
  }

  Future<void> _loadMarkerIcons() async {
    try {
      // 1. User locator pin ("Me")
      _userLocationMarker = await _createLocationPinMarker("Me");
      _amUserLocationMarker = await _createAmLocationPinMarker("Me");

      // 2. Member avatar pins (Nigeria/brother's circle members with labels)
      _avatarTopMarker = await _createAvatarPinMarker(
        "Dave",
        assetPath: AppAssets.avatarTop,
      );
      _amAvatarTopMarker = await _createAmAvatarPinMarker(
        "Dave",
        assetPath: AppAssets.avatarTop,
      );

      // 3. Logged-in device pins (locator icon for other user devices)
      _devicePhoneMarker = await _createDevicePinMarker(
        "Samsung A14",
        Icons.phone_android,
      );
      _amDevicePhoneMarker = await _createAmDevicePinMarker(
        "Samsung A14",
        Icons.phone_android,
      );

      _deviceLaptopMarker = await _createDevicePinMarker(
        "MacBook Pro",
        Icons.laptop,
      );
      _amDeviceLaptopMarker = await _createAmDevicePinMarker(
        "MacBook Pro",
        Icons.laptop,
      );

      if (mounted) setState(() {});
    } catch (e) {
      log('Error loading custom marker bitmaps: $e');
    }
  }

  Future<ui.Image?> _loadNetworkImage(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final ui.Codec codec = await ui.instantiateImageCodec(
          response.bodyBytes,
        );
        final ui.FrameInfo fi = await codec.getNextFrame();
        return fi.image;
      }
    } catch (e) {
      log('Error downloading avatar $url: $e');
    }
    return null;
  }

  Future<ui.Image> _loadUiImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  Future<BitmapDescriptor> _createLocationPinMarker(String label) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double width = 120;
    const double height = 100;

    final Paint paint = Paint()..color = Colors.black;
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 5, 100, 35),
      const Radius.circular(8),
    );
    canvas.drawRRect(rrect, paint);

    final Path path = Path()
      ..moveTo(50, 40)
      ..lineTo(70, 40)
      ..lineTo(60, 48)
      ..close();
    canvas.drawPath(path, paint);

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout(minWidth: 0, maxWidth: 100);
    textPainter.paint(
      canvas,
      Offset(
        10 + (100 - textPainter.width) / 2,
        5 + (35 - textPainter.height) / 2,
      ),
    );

    final TextPainter iconPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    iconPainter.text = TextSpan(
      text: String.fromCharCode(Icons.location_on.codePoint),
      style: TextStyle(
        fontSize: 32,
        fontFamily: Icons.location_on.fontFamily,
        color: Colors.black,
      ),
    );
    iconPainter.layout();
    iconPainter.paint(canvas, const Offset(45, 55));

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  Future<am.BitmapDescriptor> _createAmLocationPinMarker(String label) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double width = 120;
    const double height = 100;

    final Paint paint = Paint()..color = Colors.black;
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 5, 100, 35),
      const Radius.circular(8),
    );
    canvas.drawRRect(rrect, paint);

    final Path path = Path()
      ..moveTo(50, 40)
      ..lineTo(70, 40)
      ..lineTo(60, 48)
      ..close();
    canvas.drawPath(path, paint);

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout(minWidth: 0, maxWidth: 100);
    textPainter.paint(
      canvas,
      Offset(
        10 + (100 - textPainter.width) / 2,
        5 + (35 - textPainter.height) / 2,
      ),
    );

    final TextPainter iconPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    iconPainter.text = TextSpan(
      text: String.fromCharCode(Icons.location_on.codePoint),
      style: TextStyle(
        fontSize: 32,
        fontFamily: Icons.location_on.fontFamily,
        color: Colors.black,
      ),
    );
    iconPainter.layout();
    iconPainter.paint(canvas, const Offset(45, 55));

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return am.BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<BitmapDescriptor> _createAvatarPinMarker(
    String label, {
    String? assetPath,
    ui.Image? avatarImage,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double width = 120;
    const double height = 120;

    final Paint bubblePaint = Paint()..color = Colors.white;
    final Paint borderPaint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 5, 100, 32),
      const Radius.circular(6),
    );
    canvas.drawRRect(rrect, bubblePaint);
    canvas.drawRRect(rrect, borderPaint);

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: label,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout(minWidth: 0, maxWidth: 100);
    textPainter.paint(
      canvas,
      Offset(
        10 + (100 - textPainter.width) / 2,
        5 + (32 - textPainter.height) / 2,
      ),
    );

    final Paint purplePaint = Paint()
      ..color = const Color(0xFF7C60FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    const double avatarRadius = 20;
    const Offset avatarCenter = Offset(60, 75);
    canvas.drawCircle(
      avatarCenter,
      avatarRadius,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(avatarCenter, avatarRadius, purplePaint);

    try {
      canvas.save();
      final Path clipPath = Path()
        ..addOval(
          Rect.fromCircle(center: avatarCenter, radius: avatarRadius - 1.5),
        );
      canvas.clipPath(clipPath);

      final ui.Image? img =
          avatarImage ??
          (assetPath != null ? await _loadUiImage(assetPath) : null);
      if (img != null) {
        paintImage(
          canvas: canvas,
          rect: Rect.fromCircle(
            center: avatarCenter,
            radius: avatarRadius - 1.5,
          ),
          image: img,
          fit: BoxFit.cover,
        );
      }

      canvas.restore();
    } catch (_) {
      canvas.restore();
    }

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  Future<am.BitmapDescriptor> _createAmAvatarPinMarker(
    String label, {
    String? assetPath,
    ui.Image? avatarImage,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double width = 120;
    const double height = 120;

    final Paint bubblePaint = Paint()..color = Colors.white;
    final Paint borderPaint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 5, 100, 32),
      const Radius.circular(6),
    );
    canvas.drawRRect(rrect, bubblePaint);
    canvas.drawRRect(rrect, borderPaint);

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: label,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout(minWidth: 0, maxWidth: 100);
    textPainter.paint(
      canvas,
      Offset(
        10 + (100 - textPainter.width) / 2,
        5 + (32 - textPainter.height) / 2,
      ),
    );

    final Paint purplePaint = Paint()
      ..color = const Color(0xFF7C60FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    const double avatarRadius = 20;
    const Offset avatarCenter = Offset(60, 75);
    canvas.drawCircle(
      avatarCenter,
      avatarRadius,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(avatarCenter, avatarRadius, purplePaint);

    try {
      canvas.save();
      final Path clipPath = Path()
        ..addOval(
          Rect.fromCircle(center: avatarCenter, radius: avatarRadius - 1.5),
        );
      canvas.clipPath(clipPath);

      final ui.Image? img =
          avatarImage ??
          (assetPath != null ? await _loadUiImage(assetPath) : null);
      if (img != null) {
        paintImage(
          canvas: canvas,
          rect: Rect.fromCircle(
            center: avatarCenter,
            radius: avatarRadius - 1.5,
          ),
          image: img,
          fit: BoxFit.cover,
        );
      }

      canvas.restore();
    } catch (_) {
      canvas.restore();
    }

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return am.BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<BitmapDescriptor> _createDevicePinMarker(
    String deviceName,
    IconData iconData,
  ) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double width = 120;
    const double height = 100;

    final Paint paint = Paint()..color = const Color(0xFF7C60FF);
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 5, 100, 35),
      const Radius.circular(8),
    );
    canvas.drawRRect(rrect, paint);

    final Path path = Path()
      ..moveTo(50, 40)
      ..lineTo(70, 40)
      ..lineTo(60, 48)
      ..close();
    canvas.drawPath(path, paint);

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: deviceName,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout(minWidth: 0, maxWidth: 100);
    textPainter.paint(
      canvas,
      Offset(
        10 + (100 - textPainter.width) / 2,
        5 + (35 - textPainter.height) / 2,
      ),
    );

    final TextPainter iconPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    iconPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: 28,
        fontFamily: iconData.fontFamily,
        color: const Color(0xFF7C60FF),
      ),
    );
    iconPainter.layout();
    iconPainter.paint(canvas, const Offset(46, 56));

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  Future<am.BitmapDescriptor> _createAmDevicePinMarker(
    String deviceName,
    IconData iconData,
  ) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double width = 120;
    const double height = 100;

    final Paint paint = Paint()..color = const Color(0xFF7C60FF);
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 5, 100, 35),
      const Radius.circular(8),
    );
    canvas.drawRRect(rrect, paint);

    final Path path = Path()
      ..moveTo(50, 40)
      ..lineTo(70, 40)
      ..lineTo(60, 48)
      ..close();
    canvas.drawPath(path, paint);

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: deviceName,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout(minWidth: 0, maxWidth: 100);
    textPainter.paint(
      canvas,
      Offset(
        10 + (100 - textPainter.width) / 2,
        5 + (35 - textPainter.height) / 2,
      ),
    );

    final TextPainter iconPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    iconPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: 28,
        fontFamily: iconData.fontFamily,
        color: const Color(0xFF7C60FF),
      ),
    );
    iconPainter.layout();
    iconPainter.paint(canvas, const Offset(46, 56));

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return am.BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  @override
  void didUpdateWidget(covariant MapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userLatitude != widget.userLatitude ||
        oldWidget.userLongitude != widget.userLongitude) {
      if (Platform.isIOS) {
        _amController?.animateCamera(
          am.CameraUpdate.newCameraPosition(
            am.CameraPosition(
              target: am.LatLng(widget.userLatitude, widget.userLongitude),
              zoom: widget.mapState == MapDisplayState.full ? 15.0 : 16.0,
              pitch: 45.0,
            ),
          ),
        );
      } else {
        _controller?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(widget.userLatitude, widget.userLongitude),
              zoom: widget.mapState == MapDisplayState.full ? 15.0 : 16.0,
              tilt: 45.0,
            ),
          ),
        );
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  List<LatLng> _generateRoutingCoordinates(LatLng start, LatLng end) {
    final List<LatLng> points = [];
    points.add(start);
    points.add(
      LatLng(
        start.latitude + (end.latitude - start.latitude) * 0.4,
        start.longitude,
      ),
    );
    points.add(
      LatLng(
        start.latitude + (end.latitude - start.latitude) * 0.4,
        end.longitude,
      ),
    );
    points.add(end);
    return points;
  }

  Future<void> _launchDirections() async {
    if (widget.selectedPlace == null) return;
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${widget.selectedPlace!.coordinates.latitude},${widget.selectedPlace!.coordinates.longitude}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      toastification.show(
        title: const Text('Navigation Error'),
        description: const Text('Could not open map navigation application.'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  Widget _buildMapControl(bool isDark, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: isDark ? Colors.white : Colors.black87),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildStatIcon(bool isDark, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userLoc = LatLng(widget.userLatitude, widget.userLongitude);

    final double screenHeight = MediaQuery.sizeOf(context).height;

    return AnimatedBuilder(
      animation: Listenable.merge([widget.mapAnim, widget.fullAnim]),
      builder: (context, _) {
        final mapVal = widget.mapAnim.value;
        final fullVal = widget.fullAnim.value;

        // Height: Compact: 168, Expanded: 320, Full: screenHeight
        final double compactHeight = context.w(168.0);
        final double expandedHeight = context.w(320.0);
        final double currentHeight =
            compactHeight +
            (expandedHeight - compactHeight) * mapVal +
            (screenHeight - expandedHeight) * fullVal;

        // Top margin moves the map up behind the TopBar when expanding
        final double currentTopMargin = 0.0;
        final double currentSideMargin = context.w(20.0) * (1.0 - mapVal);

        final double currentRadius = 24.0 * (1.0 - mapVal);

        final double compactOpacity = (1.0 - mapVal).clamp(0.0, 1.0);
        final double expandedOpacity = (mapVal * (1.0 - fullVal)).clamp(
          0.0,
          1.0,
        );
        final double fullOpacity = fullVal.clamp(0.0, 1.0);

        final bool isCompact = widget.mapState == MapDisplayState.compact;
        final bool isFull = widget.mapState == MapDisplayState.full;
        final bool ignoreGestures = isCompact;

        // Define markers list
        final Set<Marker> markers = {};

        // Add User Location
        markers.add(
          Marker(
            markerId: const MarkerId('user_loc'),
            position: userLoc,
            icon:
                _userLocationMarker ??
                BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueViolet,
                ),
            infoWindow: const InfoWindow(title: 'You'),
          ),
        );

        // Add Device Sessions
        for (var session in _sessions) {
          if (_sessions.length == 1) continue;

          final String deviceName = session['device_name'] ?? 'Device';
          final String os = session['os']?.toString().toLowerCase() ?? '';
          if (deviceName == _currentDeviceModel) continue;

          final isMobile = os.contains('ios') || os.contains('android');
          final icon = isMobile ? _devicePhoneMarker : _deviceLaptopMarker;
          if (icon != null) {
            markers.add(
              Marker(
                markerId: MarkerId('device_${session['hash']}'),
                position: LatLng(
                  widget.userLatitude + 0.0012,
                  widget.userLongitude - 0.0012,
                ),
                icon: icon,
                infoWindow: InfoWindow(title: deviceName),
              ),
            );
          }
        }

        // Add Dynamic Member Locations
        for (var member in _serverLocations) {
          final uid = member['user_id'] ?? '';
          if (uid == _currentUserId) continue;

          final lat = member['latitude'] as double? ?? 0.0;
          final lng = member['longitude'] as double? ?? 0.0;
          final name = member['name'] ?? 'Member';

          BitmapDescriptor? icon = _googleMarkersCache[uid] ?? _avatarTopMarker;

          if (icon != null) {
            markers.add(
              Marker(
                markerId: MarkerId('member_$uid'),
                position: LatLng(lat, lng),
                icon: icon,
                infoWindow: InfoWindow(title: name),
              ),
            );
          }
        }

        if (widget.selectedPlace != null) {
          markers.add(
            Marker(
              markerId: const MarkerId('destination'),
              position: widget.selectedPlace!.coordinates,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRose,
              ),
              infoWindow: InfoWindow(title: widget.selectedPlace!.name),
            ),
          );
        }

        // Routing polylines
        Set<Polyline> polylines = {};
        double distanceKm = 0.0;
        int durationMins = 0;

        if (widget.selectedPlace != null) {
          final routeCoords = _generateRoutingCoordinates(
            userLoc,
            widget.selectedPlace!.coordinates,
          );
          polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: routeCoords,
              color: AppColors.primary,
              width: 5,
              jointType: JointType.round,
            ),
          );

          final meters = Geolocator.distanceBetween(
            userLoc.latitude,
            userLoc.longitude,
            widget.selectedPlace!.coordinates.latitude,
            widget.selectedPlace!.coordinates.longitude,
          );
          distanceKm = meters / 1000.0;
          durationMins = (distanceKm / 40.0 * 60.0).round().clamp(1, 120);
        }

        final Widget mapWidget;

        if (Platform.isIOS) {
          final amAnnotations = <am.Annotation>{};

          amAnnotations.add(
            am.Annotation(
              annotationId: am.AnnotationId('user_loc'),
              position: am.LatLng(userLoc.latitude, userLoc.longitude),
              icon:
                  _amUserLocationMarker ??
                  am.BitmapDescriptor.defaultAnnotation,
              infoWindow: am.InfoWindow(title: 'You'),
            ),
          );

          for (var session in _sessions) {
            if (_sessions.length == 1) continue;
            final String deviceName = session['device_name'] ?? 'Device';
            final String os = session['os']?.toString().toLowerCase() ?? '';
            if (deviceName == _currentDeviceModel) continue;
            final isMobile = os.contains('ios') || os.contains('android');
            final icon = isMobile
                ? _amDevicePhoneMarker
                : _amDeviceLaptopMarker;
            if (icon != null) {
              amAnnotations.add(
                am.Annotation(
                  annotationId: am.AnnotationId('device_${session['hash']}'),
                  position: am.LatLng(
                    widget.userLatitude + 0.0012,
                    widget.userLongitude - 0.0012,
                  ),
                  icon: icon,
                  infoWindow: am.InfoWindow(title: deviceName),
                ),
              );
            }
          }

          for (var member in _serverLocations) {
            final uid = member['user_id'] ?? '';
            if (uid == _currentUserId) continue;
            final lat = member['latitude'] as double? ?? 0.0;
            final lng = member['longitude'] as double? ?? 0.0;
            final name = member['name'] ?? 'Member';

            am.BitmapDescriptor? icon =
                _appleMarkersCache[uid] ?? _amAvatarTopMarker;

            if (icon != null) {
              amAnnotations.add(
                am.Annotation(
                  annotationId: am.AnnotationId('member_$uid'),
                  position: am.LatLng(lat, lng),
                  icon: icon,
                  infoWindow: am.InfoWindow(title: name),
                ),
              );
            }
          }

          final amPolylines = polylines
              .map(
                (p) => am.Polyline(
                  polylineId: am.PolylineId(p.polylineId.value),
                  points: p.points
                      .map((pt) => am.LatLng(pt.latitude, pt.longitude))
                      .toList(),
                  color: p.color,
                  width: p.width,
                ),
              )
              .toSet();

          mapWidget = am.AppleMap(
            initialCameraPosition: am.CameraPosition(
              target: am.LatLng(userLoc.latitude, userLoc.longitude),
              zoom: isFull ? 15.0 : 16.0,
              pitch: 45.0,
            ),
            onMapCreated: (am.AppleMapController c) {
              _amController = c;
            },
            annotations: amAnnotations,
            polylines: amPolylines,
            compassEnabled: false,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            pitchGesturesEnabled: !ignoreGestures,
            scrollGesturesEnabled: !ignoreGestures,
            rotateGesturesEnabled: !ignoreGestures,
            zoomGesturesEnabled: !ignoreGestures,
            onTap: (latLng) {
              if (!isCompact && !isFull) {
                widget.onTap(); // Tapping collapses map
              }
            },
          );
        } else {
          mapWidget = GoogleMap(
            initialCameraPosition: CameraPosition(
              target: userLoc,
              zoom: isFull ? 15.0 : 16.0,
              tilt: 45.0,
            ),
            onMapCreated: _onMapCreated,
            style: isDark ? darkMapStyle : lightMapStyle,
            markers: markers,
            polylines: polylines,
            compassEnabled: false,
            mapToolbarEnabled: false,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: !ignoreGestures,
            scrollGesturesEnabled: !ignoreGestures,
            tiltGesturesEnabled: !ignoreGestures,
            rotateGesturesEnabled: !ignoreGestures,
            onTap: (latLng) {
              if (!isCompact && !isFull) {
                widget.onTap(); // Tapping collapses map
              }
            },
          );
        }

        return GestureDetector(
          onTap: isCompact ? widget.onTap : null,
          child: Container(
            height: currentHeight,
            width: double.infinity,
            margin: EdgeInsets.only(
              top: currentTopMargin,
              left: currentSideMargin,
              right: currentSideMargin,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF0F3),
              borderRadius: BorderRadius.circular(currentRadius),
              boxShadow: isFull
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(currentRadius),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ignoreGestures
                        ? IgnorePointer(child: mapWidget)
                        : mapWidget,
                  ),

                  // Compact overlays
                  if (compactOpacity > 0.0)
                    Positioned.fill(
                      child: Opacity(
                        opacity: compactOpacity,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 14,
                              left: 14,
                              child: MapDistanceBadge(
                                nearestMember: _nearestMemberInfo,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Expanded overlays
                  if (expandedOpacity > 0.0)
                    Positioned.fill(
                      child: Opacity(
                        opacity: expandedOpacity,
                        child: Stack(
                          children: [
                            // Removed _ExpandedTopRow as it is now handled by the persistent TopBar
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: GestureDetector(
                                  onTap: widget.onOpenMap,
                                  child: Container(
                                    width: context.w(140),
                                    height: context.w(40),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8E9BFF),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.15,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          AppAssets.openMapIcon,
                                          width: context.w(16),
                                          height: context.w(16),
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Open map',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w700,
                                            fontSize: context.sp(13),
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Full screen overlays (Search bar, suggestions list, custom zoom/recenter controls, directions card)
                  if (fullOpacity > 0.0)
                    Positioned.fill(
                      child: Opacity(
                        opacity: fullOpacity,
                        child: Stack(
                          children: [
                            // Right controls (Zoom In, Zoom Out, Recenter to user)
                            Positioned(
                              right: 16,
                              bottom: widget.selectedPlace != null ? 300 : 120,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildMapControl(
                                    isDark,
                                    Icons.add_rounded,
                                    () {
                                      if (Platform.isIOS) {
                                        _amController?.animateCamera(
                                          am.CameraUpdate.zoomIn(),
                                        );
                                      } else {
                                        _controller?.animateCamera(
                                          CameraUpdate.zoomIn(),
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  _buildMapControl(
                                    isDark,
                                    Icons.remove_rounded,
                                    () {
                                      if (Platform.isIOS) {
                                        _amController?.animateCamera(
                                          am.CameraUpdate.zoomOut(),
                                        );
                                      } else {
                                        _controller?.animateCamera(
                                          CameraUpdate.zoomOut(),
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  _buildMapControl(
                                    isDark,
                                    Icons.my_location_rounded,
                                    () {
                                      if (Platform.isIOS) {
                                        _amController?.animateCamera(
                                          am.CameraUpdate.newCameraPosition(
                                            am.CameraPosition(
                                              target: am.LatLng(
                                                userLoc.latitude,
                                                userLoc.longitude,
                                              ),
                                              zoom: 15.5,
                                              pitch: 45.0,
                                            ),
                                          ),
                                        );
                                      } else {
                                        _controller?.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                              target: userLoc,
                                              zoom: 15.5,
                                              tilt: 45.0,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // Bottom Directions Panel
                            if (widget.selectedPlace != null)
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 100,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(
                                            0xFF1C1C22,
                                          ).withValues(alpha: 0.95)
                                        : Colors.white.withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.15,
                                        ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.selectedPlace!.name,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.selectedPlace!.address,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          _buildStatIcon(
                                            isDark,
                                            Icons.directions_car_rounded,
                                            '${distanceKm.toStringAsFixed(1)} km',
                                          ),
                                          const SizedBox(width: 24),
                                          _buildStatIcon(
                                            isDark,
                                            Icons.access_time_filled_rounded,
                                            '$durationMins mins',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: ElevatedButton(
                                          onPressed: _launchDirections,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: const Text(
                                            'Start Navigation',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
