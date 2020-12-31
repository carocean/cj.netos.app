import Flutter
import UserNotifications
import UIKit

func getFlutterError(_ error: Error) -> FlutterError {
    let e = error as NSError
    return FlutterError(code: "Error: \(e.code)", message: e.domain, details: error.localizedDescription)
}
//参考：flutter-apns plugin的实现
@objc public class SwiftBuddyPushPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate {
    internal init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "buddy_push", binaryMessenger: registrar.messenger())
        let instance = SwiftBuddyPushPlugin(channel: channel)
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    let channel: FlutterMethodChannel
    var launchNotification: [String: Any]?
    var resumingFromBackground = false

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
                case "supportsDriver":
                result(["driver":"ios","isSupports":true])
                default:
//                     result(FlutterMethodNotImplemented)
                    result(nil)
                }
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        launchNotification = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any]
        UIApplication.shared.registerForRemoteNotifications()
        registerForPushNotifications()
        return true
    }

    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        channel.invokeMethod("onToken", arguments: ["driver":"ios","regId":token])
    }

    public  func application(_ application: UIApplication,
                    didFailToRegisterForRemoteNotificationsWithError
                        error: Error) {
          channel.invokeMethod("onError", arguments: ["driver":"ios","error":error.localizedDescription])
        }
   func registerForPushNotifications() {
       UNUserNotificationCenter.current()
         .requestAuthorization(options: [.alert, .sound, .badge]) {
           [weak self] granted, error in

           print("Permission granted: \(granted)")
           guard granted else { return }
           self?.getNotificationSettings()
       }
   }
   func getNotificationSettings() {
     UNUserNotificationCenter.current().getNotificationSettings { settings in
       print("Notification settings: \(settings)")
     }
   }

}

extension UNNotificationCategoryOptions {
    static let stringToValue: [String: UNNotificationCategoryOptions] = {
        var r: [String: UNNotificationCategoryOptions] = [:]
        r["UNNotificationCategoryOptions.customDismissAction"] = .customDismissAction
        r["UNNotificationCategoryOptions.allowInCarPlay"] = .allowInCarPlay
        if #available(iOS 11.0, *) {
            r["UNNotificationCategoryOptions.hiddenPreviewsShowTitle"] = .hiddenPreviewsShowTitle
        }
        if #available(iOS 11.0, *) {
            r["UNNotificationCategoryOptions.hiddenPreviewsShowSubtitle"] = .hiddenPreviewsShowSubtitle
        }
        if #available(iOS 13.0, *) {
            r["UNNotificationCategoryOptions.allowAnnouncement"] = .allowAnnouncement
        }
        return r
    }()
}

extension UNNotificationActionOptions {
    static let stringToValue: [String: UNNotificationActionOptions] = {
        var r: [String: UNNotificationActionOptions] = [:]
        r["UNNotificationActionOptions.authenticationRequired"] = .authenticationRequired
        r["UNNotificationActionOptions.destructive"] = .destructive
        r["UNNotificationActionOptions.foreground"] = .foreground
        return r
    }()
}

