import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private func readMapsKey(from path: String, names: [String]) -> String? {
    guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
      return nil
    }

    for line in content.components(separatedBy: .newlines) {
      let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
      if trimmed.isEmpty || trimmed.hasPrefix("#") {
        continue
      }

      for name in names {
        let prefix = "\(name)="
        if trimmed.hasPrefix(prefix) {
          return String(trimmed.dropFirst(prefix.count))
            .trimmingCharacters(in: CharacterSet(charactersIn: "\"' "))
        }
      }
    }

    return nil
  }

  private func resolveMapsApiKey() -> String? {
    let keyNames = ["MAPS_API_KEY_IOS", "MAPS_API_KEY"]

    // 1. Try local source-tree files for development builds.
    let filePath = #filePath
    if let range = filePath.range(of: "/apps/mobile/ios/Runner/AppDelegate.swift") {
      let rootPath = String(filePath[..<range.lowerBound])
      let candidatePaths = [
        "\(rootPath)/apps/mobile/ios/Flutter/Maps.xcconfig",
        "\(rootPath)/apps/mobile/.env",
        "\(rootPath)/apps/mobile/android/local.properties",
        "\(rootPath)/apps/backend/.env",
      ]

      for path in candidatePaths {
        if let key = readMapsKey(from: path, names: keyNames), !key.isEmpty {
          return key
        }
      }
    }

    // 2. Fall back to Info.plist build setting injection for CI/release builds.
    if let plistKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !plistKey.isEmpty,
       !plistKey.contains("$(") {
      return plistKey
    }

    // 3. Fall back to GoogleService-Info.plist if a dedicated maps key is not available.
    if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
       let dict = NSDictionary(contentsOfFile: path),
       let plistKey = dict["API_KEY"] as? String,
       !plistKey.isEmpty {
      return plistKey
    }

    return nil
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let key = resolveMapsApiKey(), !key.isEmpty {
      GMSServices.provideAPIKey(key)
    } else {
      NSLog("Guardian: missing Google Maps iOS API key. Map tiles will not load.")
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
