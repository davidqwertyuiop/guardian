import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    var apiKey: String? = nil
    
    // 1. Try to read from backend .env file at compile-time path (local development)
    let filePath = #filePath
    if let range = filePath.range(of: "/apps/mobile/ios/Runner/AppDelegate.swift") {
        let rootPath = String(filePath[..<range.lowerBound])
        let envPath = rootPath + "/apps/backend/.env"
        if let envContent = try? String(contentsOfFile: envPath, encoding: .utf8) {
            let lines = envContent.components(separatedBy: .newlines)
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.hasPrefix("MAPS_API_KEY_IOS=") {
                    apiKey = trimmed.replacingOccurrences(of: "MAPS_API_KEY_IOS=", with: "")
                    break
                }
            }
        }
    }
    
    // 2. Fall back to GoogleService-Info.plist if .env is not available
    if apiKey == nil {
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let plistKey = dict["API_KEY"] as? String {
            apiKey = plistKey
        }
    }
    
    if let key = apiKey, !key.isEmpty {
        GMSServices.provideAPIKey(key)
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
