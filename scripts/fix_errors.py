with open('lib/features/location/presentation/screens/live_map_screen.dart', 'r') as f:
    content = f.read()

content = content.replace('_createAvatarPinMarker(\n        AppAssets.avatarTop,\n        "Dave",\n      )', '_createAvatarPinMarker("Dave", assetPath: AppAssets.avatarTop)')
content = content.replace('_createAmAvatarPinMarker(\n        AppAssets.avatarTop,\n        "Dave",\n      )', '_createAmAvatarPinMarker("Dave", assetPath: AppAssets.avatarTop)')
content = content.replace('_createAvatarPinMarker(\n        AppAssets.avatarLeft,\n        "Sarah",\n      )', '_createAvatarPinMarker("Sarah", assetPath: AppAssets.avatarLeft)')
content = content.replace('_createAmAvatarPinMarker(\n        AppAssets.avatarLeft,\n        "Sarah",\n      )', '_createAmAvatarPinMarker("Sarah", assetPath: AppAssets.avatarLeft)')
content = content.replace('_createAvatarPinMarker(\n        AppAssets.avatarRight,\n        "John",\n      )', '_createAvatarPinMarker("John", assetPath: AppAssets.avatarRight)')
content = content.replace('_createAmAvatarPinMarker(\n        AppAssets.avatarRight,\n        "John",\n      )', '_createAmAvatarPinMarker("John", assetPath: AppAssets.avatarRight)')

# Fix const issue at 1809. Let's see what is there.
# It is probably MarkerId(...) inside a Marker. Wait, what if the Marker has a const? No.
# I will just remove the 'const' from 'const MarkerId' if there is any, but I didn't add const to MarkerId.
# Let's see the context of line 1809.
