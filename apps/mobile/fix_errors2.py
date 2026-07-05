import re

with open('lib/features/location/presentation/screens/live_map_screen.dart', 'r') as f:
    content = f.read()

# Use regex to replace _createAvatarPinMarker(AppAssets.avatarTop, "Dave") with _createAvatarPinMarker("Dave", assetPath: AppAssets.avatarTop)
content = re.sub(r'_createAvatarPinMarker\(\s*AppAssets\.avatarTop,\s*"Dave",\s*\)', '_createAvatarPinMarker("Dave", assetPath: AppAssets.avatarTop)', content)
content = re.sub(r'_createAmAvatarPinMarker\(\s*AppAssets\.avatarTop,\s*"Dave",\s*\)', '_createAmAvatarPinMarker("Dave", assetPath: AppAssets.avatarTop)', content)
content = re.sub(r'_createAvatarPinMarker\(\s*AppAssets\.avatarLeft,\s*"Sarah",\s*\)', '_createAvatarPinMarker("Sarah", assetPath: AppAssets.avatarLeft)', content)
content = re.sub(r'_createAmAvatarPinMarker\(\s*AppAssets\.avatarLeft,\s*"Sarah",\s*\)', '_createAmAvatarPinMarker("Sarah", assetPath: AppAssets.avatarLeft)', content)
content = re.sub(r'_createAvatarPinMarker\(\s*AppAssets\.avatarRight,\s*"John",\s*\)', '_createAvatarPinMarker("John", assetPath: AppAssets.avatarRight)', content)
content = re.sub(r'_createAmAvatarPinMarker\(\s*AppAssets\.avatarRight,\s*"John",\s*\)', '_createAmAvatarPinMarker("John", assetPath: AppAssets.avatarRight)', content)

with open('lib/features/location/presentation/screens/live_map_screen.dart', 'w') as f:
    f.write(content)
