import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let instagramStoryChannel = "vibi/instagram_story"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: instagramStoryChannel,
        binaryMessenger: controller.binaryMessenger
      )

      channel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "shareStickerToStory" else {
          result(FlutterMethodNotImplemented)
          return
        }
        self?.shareStickerToStory(call: call, result: result)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func shareStickerToStory(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard
      let args = call.arguments as? [String: Any],
      let backgroundPath = args["backgroundImagePath"] as? String,
      let stickerPath = args["stickerImagePath"] as? String
    else {
      result(
        FlutterError(
          code: "INVALID_ARGS",
          message: "Missing required image path arguments.",
          details: nil
        )
      )
      return
    }

    guard let instagramUrl = URL(string: "instagram-stories://share") else {
      result(false)
      return
    }

    guard UIApplication.shared.canOpenURL(instagramUrl) else {
      result(false)
      return
    }

    let backgroundUrl = URL(fileURLWithPath: backgroundPath)
    let stickerUrl = URL(fileURLWithPath: stickerPath)

    guard
      let backgroundData = try? Data(contentsOf: backgroundUrl),
      let stickerData = try? Data(contentsOf: stickerUrl)
    else {
      result(
        FlutterError(
          code: "FILE_READ_FAILED",
          message: "Could not read story assets for Instagram share.",
          details: nil
        )
      )
      return
    }

    var pasteboardItem: [String: Any] = [
      "com.instagram.sharedSticker.backgroundImage": backgroundData,
      "com.instagram.sharedSticker.stickerImage": stickerData,
    ]

    if let topColor = args["topBackgroundColor"] as? String, !topColor.isEmpty {
      pasteboardItem["com.instagram.sharedSticker.backgroundTopColor"] = topColor
    }

    if let bottomColor = args["bottomBackgroundColor"] as? String, !bottomColor.isEmpty {
      pasteboardItem["com.instagram.sharedSticker.backgroundBottomColor"] = bottomColor
    }

    if let attributionUrl = args["attributionUrl"] as? String, !attributionUrl.isEmpty {
      pasteboardItem["com.instagram.sharedSticker.contentURL"] = attributionUrl
    }

    UIPasteboard.general.setItems(
      [pasteboardItem],
      options: [
        UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(5 * 60),
      ]
    )

    UIApplication.shared.open(instagramUrl, options: [:]) { success in
      result(success)
    }
  }
}
