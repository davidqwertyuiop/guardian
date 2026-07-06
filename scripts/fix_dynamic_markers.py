import re

with open('lib/features/location/presentation/screens/live_map_screen.dart', 'r') as f:
    content = f.read()

# Replace _loadUiImage (which loads from rootBundle) with a network downloader version, or just pass bytes.
# Actually, we can use http.get to load the image into a Uint8List, then use instantiateImageCodec.
# Let's add a helper _loadNetworkImage(String url).
network_image_helper = '''  Future<ui.Image?> _loadNetworkImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final ui.Codec codec = await ui.instantiateImageCodec(response.bodyBytes);
        final ui.FrameInfo fi = await codec.getNextFrame();
        return fi.image;
      }
    } catch (e) {
      log('Error downloading avatar $url: $e');
    }
    return null;
  }

  Future<ui.Image> _loadUiImage(String assetPath) async {'''

if '_loadNetworkImage' not in content:
    content = content.replace('  Future<ui.Image> _loadUiImage(String assetPath) async {', network_image_helper)

# Update _createAvatarPinMarker signature
content = content.replace(
    'Future<BitmapDescriptor> _createAvatarPinMarker(\n    String assetPath,\n    String label,\n  ) async {',
    'Future<BitmapDescriptor> _createAvatarPinMarker(String label, {String? assetPath, ui.Image? avatarImage}) async {'
)
# Update its body
content = content.replace(
    'final ui.Image avatarImage = await _loadUiImage(assetPath);',
    'final ui.Image? img = avatarImage ?? (assetPath != null ? await _loadUiImage(assetPath) : null);\n      if (img != null) paintImage(canvas: canvas, rect: Rect.fromCircle(center: avatarCenter, radius: avatarRadius - 1.5), image: img, fit: BoxFit.cover);'
)
# Remove the old paintImage block because it was replaced above
content = re.sub(r'      paintImage\(\n        canvas: canvas,\n        rect: Rect\.fromCircle\(center: avatarCenter, radius: avatarRadius - 1\.5\),\n        image: avatarImage,\n        fit: BoxFit\.cover,\n      \);', '', content)


# Do the same for _createAmAvatarPinMarker
content = content.replace(
    'Future<am.BitmapDescriptor> _createAmAvatarPinMarker(\n    String assetPath,\n    String label,\n  ) async {',
    'Future<am.BitmapDescriptor> _createAmAvatarPinMarker(String label, {String? assetPath, ui.Image? avatarImage}) async {'
)
content = content.replace(
    'final ui.Image avatarImage = await _loadUiImage(assetPath);',
    'final ui.Image? img = avatarImage ?? (assetPath != null ? await _loadUiImage(assetPath) : null);\n      if (img != null) paintImage(canvas: canvas, rect: Rect.fromCircle(center: avatarCenter, radius: avatarRadius - 1.5), image: img, fit: BoxFit.cover);'
)
content = re.sub(r'      paintImage\(\n        canvas: canvas,\n        rect: Rect\.fromCircle\(center: avatarCenter, radius: avatarRadius - 1\.5\),\n        image: avatarImage,\n        fit: BoxFit\.cover,\n      \);', '', content)


# In _syncLocationAndLoadData, after loading _serverLocations, we should preload avatars into cache if they aren't there yet.
sync_location_patch = '''      if (mounted) {
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
        
        if (uid.isNotEmpty && url.isNotEmpty && !_loadingAvatars.containsKey(uid)) {
          _loadingAvatars[uid] = true;
          _loadNetworkImage(url).then((img) async {
            if (img != null) {
              final gMarker = await _createAvatarPinMarker(name, avatarImage: img);
              final aMarker = await _createAmAvatarPinMarker(name, avatarImage: img);
              if (mounted) {
                setState(() {
                  _googleMarkersCache[uid] = gMarker;
                  _appleMarkersCache[uid] = aMarker;
                });
              }
            }
          });
        }
      }'''

content = content.replace('''      if (mounted) {
        setState(() {
          _sessions = sessionsList;
          _serverLocations = serverLocs;
          _nearestMemberInfo = nearest;
        });
      }''', sync_location_patch)


# Rewrite the markers generation in build()
# Find the start of `final Set<Marker> markers = {`
markers_start = content.find('        final Set<Marker> markers = {')
markers_end_pattern = r'        if \(_selectedPlace != null\) \{'
markers_end_match = re.search(markers_end_pattern, content)
markers_end = markers_end_match.start()

dynamic_markers_code = '''        final Set<Marker> markers = {};
        
        // Add User Location
        markers.add(
          Marker(
            markerId: const MarkerId('user_loc'),
            position: userLoc,
            icon: _userLocationMarker ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
            infoWindow: const InfoWindow(title: 'You'),
          ),
        );
        
        // Add Device Sessions
        for (var session in _sessions) {
          final isCurrentDevice = session['hash'] == 'CURRENT_SESSION_HASH_IF_AVAILABLE'; // We might not have a reliable way to skip current besides relying on name match?
          // Actually if there's only 1 session we don't draw it since it's just 'This Phone'.
          // Wait, ApiService.getSessions() returns all valid devices.
          if (_sessions.length == 1) continue;
          
          final String deviceName = session['device_name'] ?? 'Device';
          final String os = session['os']?.toString().toLowerCase() ?? '';
          if (deviceName == _currentDeviceModel) continue; // skip current device
          
          final isMobile = os.contains('ios') || os.contains('android');
          final icon = isMobile ? _devicePhoneMarker : _deviceLaptopMarker;
          if (icon != null) {
            markers.add(
              Marker(
                markerId: MarkerId('device_${session['hash']}'),
                // Offset slightly based on hash length or similar to not overlap perfectly
                position: LatLng(widget.userLatitude + 0.0012, widget.userLongitude - 0.0012),
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
          
          BitmapDescriptor? icon = _googleMarkersCache[uid];
          if (icon == null) {
             // Fallback to top marker temporarily if not cached
             icon = _avatarTopMarker;
          }
          
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
        
'''

content = content[:markers_start] + dynamic_markers_code + content[markers_end:]

# Now do the same for Apple Maps amAnnotations
am_annotations_pattern = r'          final amAnnotations = markers\.map\(\(m\) \{.*?          \}\)\.toSet\(\);'

new_am_annotations = '''          final amAnnotations = <am.Annotation>{};
          
          amAnnotations.add(
            am.Annotation(
              annotationId: const am.AnnotationId('user_loc'),
              position: am.LatLng(userLoc.latitude, userLoc.longitude),
              icon: _amUserLocationMarker ?? am.BitmapDescriptor.defaultAnnotation,
              infoWindow: const am.InfoWindow(title: 'You'),
            ),
          );
          
          for (var session in _sessions) {
            if (_sessions.length == 1) continue;
            final String deviceName = session['device_name'] ?? 'Device';
            final String os = session['os']?.toString().toLowerCase() ?? '';
            if (deviceName == _currentDeviceModel) continue;
            final isMobile = os.contains('ios') || os.contains('android');
            final icon = isMobile ? _amDevicePhoneMarker : _amDeviceLaptopMarker;
            if (icon != null) {
              amAnnotations.add(
                am.Annotation(
                  annotationId: am.AnnotationId('device_${session['hash']}'),
                  position: am.LatLng(widget.userLatitude + 0.0012, widget.userLongitude - 0.0012),
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
            
            am.BitmapDescriptor? icon = _appleMarkersCache[uid];
            if (icon == null) icon = _amAvatarTopMarker;
            
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
          
          if (_selectedPlace != null) {
            amAnnotations.add(
              am.Annotation(
                annotationId: const am.AnnotationId('destination'),
                position: am.LatLng(_selectedPlace!.coordinates.latitude, _selectedPlace!.coordinates.longitude),
                icon: am.BitmapDescriptor.defaultAnnotation,
                infoWindow: am.InfoWindow(title: _selectedPlace!.name),
              ),
            );
          }'''

content = re.sub(am_annotations_pattern, new_am_annotations, content, flags=re.DOTALL)

with open('lib/features/location/presentation/screens/live_map_screen.dart', 'w') as f:
    f.write(content)

