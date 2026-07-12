import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  private let radioChannelName = "guardian/radio_type"

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    guard let controller = window?.rootViewController as? FlutterViewController else {
      NSLog("Guardian: failed to register radio type channel because FlutterViewController is unavailable.")
      return
    }

    let channel = FlutterMethodChannel(
      name: radioChannelName,
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      if call.method == "mobileRadioType",
         let appDelegate = UIApplication.shared.delegate as? AppDelegate {
        result(appDelegate.mobileRadioType())
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
