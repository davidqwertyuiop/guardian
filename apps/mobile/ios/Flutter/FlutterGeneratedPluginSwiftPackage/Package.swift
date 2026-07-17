// swift-tools-version: 5.9
//
// Project-owned Flutter plugin package.
//
// Flutter's generated package currently falls back to iOS 13 after a clean,
// while Firebase 12 requires iOS 15. Keep this wrapper outside Flutter's
// ephemeral directory so Debug, Profile, and Release resolve consistently.

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(
            name: "FlutterGeneratedPluginSwiftPackage",
            type: .static,
            targets: ["FlutterGeneratedPluginSwiftPackage"]
        )
    ],
    dependencies: [
        .package(name: "app_links", path: "../ephemeral/Packages/.packages/app_links-7.0.0"),
        .package(name: "battery_plus", path: "../ephemeral/Packages/.packages/battery_plus-7.1.0"),
        .package(name: "connectivity_plus", path: "../ephemeral/Packages/.packages/connectivity_plus-7.2.0"),
        .package(name: "device_info_plus", path: "../ephemeral/Packages/.packages/device_info_plus-13.2.0"),
        .package(name: "firebase_analytics", path: "../ephemeral/Packages/.packages/firebase_analytics-12.4.3"),
        .package(name: "firebase_core", path: "../ephemeral/Packages/.packages/firebase_core-4.11.0"),
        .package(name: "firebase_crashlytics", path: "../ephemeral/Packages/.packages/firebase_crashlytics-5.2.4"),
        .package(name: "firebase_messaging", path: "../ephemeral/Packages/.packages/firebase_messaging-16.4.1"),
        .package(name: "flutter_local_notifications", path: "../ephemeral/Packages/.packages/flutter_local_notifications-22.0.1"),
        .package(name: "flutter_secure_storage_darwin", path: "../ephemeral/Packages/.packages/flutter_secure_storage_darwin-0.3.2"),
        .package(name: "geocoding_darwin", path: "../ephemeral/Packages/.packages/geocoding_darwin-1.0.2"),
        .package(name: "geolocator_apple", path: "../ephemeral/Packages/.packages/geolocator_apple-2.3.14"),
        .package(name: "image_picker_ios", path: "../ephemeral/Packages/.packages/image_picker_ios-0.8.13+6"),
        .package(name: "package_info_plus", path: "../ephemeral/Packages/.packages/package_info_plus-10.2.0"),
        .package(name: "permission_handler_apple", path: "../ephemeral/Packages/.packages/permission_handler_apple-9.4.10"),
        .package(name: "sensors_plus", path: "../ephemeral/Packages/.packages/sensors_plus-7.1.0"),
        .package(name: "share_plus", path: "../ephemeral/Packages/.packages/share_plus-13.2.0"),
        .package(name: "shared_preferences_foundation", path: "../ephemeral/Packages/.packages/shared_preferences_foundation-2.5.6"),
        .package(name: "url_launcher_ios", path: "../ephemeral/Packages/.packages/url_launcher_ios-6.4.1"),
        .package(name: "vibration", path: "../ephemeral/Packages/.packages/vibration-3.2.0"),
        .package(name: "FlutterFramework", path: "../ephemeral/Packages/.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "app-links", package: "app_links"),
                .product(name: "battery-plus", package: "battery_plus"),
                .product(name: "connectivity-plus", package: "connectivity_plus"),
                .product(name: "device-info-plus", package: "device_info_plus"),
                .product(name: "firebase-analytics", package: "firebase_analytics"),
                .product(name: "firebase-core", package: "firebase_core"),
                .product(name: "firebase-crashlytics", package: "firebase_crashlytics"),
                .product(name: "firebase-messaging", package: "firebase_messaging"),
                .product(name: "flutter-local-notifications", package: "flutter_local_notifications"),
                .product(name: "flutter-secure-storage-darwin", package: "flutter_secure_storage_darwin"),
                .product(name: "geocoding-darwin", package: "geocoding_darwin"),
                .product(name: "geolocator-apple", package: "geolocator_apple"),
                .product(name: "image-picker-ios", package: "image_picker_ios"),
                .product(name: "package-info-plus", package: "package_info_plus"),
                .product(name: "permission-handler-apple", package: "permission_handler_apple"),
                .product(name: "sensors-plus", package: "sensors_plus"),
                .product(name: "share-plus", package: "share_plus"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "url-launcher-ios", package: "url_launcher_ios"),
                .product(name: "vibration", package: "vibration"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)

