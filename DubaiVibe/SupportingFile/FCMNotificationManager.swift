//
//  FCMNotificationManager.swift
//  MyGuardianLink
//

import Foundation
import UIKit
import UserNotifications
import FirebaseMessaging

extension Notification.Name {
    static let fcmTokenDidUpdate = Notification.Name("FCMTokenDidUpdate")
    static let didReceivePushNotification = Notification.Name("DidReceivePushNotification")
}

enum FCMNotificationManager {
    static let tokenKey = "FCMToken"
    private static let deviceIdKey = "STORED_DEVICE_ID"

    static var fcmToken: String {
        UserDefaults.standard.string(forKey: tokenKey) ?? ""
    }

    static func saveToken(_ token: String) {
        guard !token.isEmpty else { return }
        UserDefaults.standard.set(token, forKey: tokenKey)
        NotificationCenter.default.post(name: .fcmTokenDidUpdate, object: token)
    }

    /// Persisted device id — nil after logout.
    static var storedDeviceId: String? {
        UserDefaults.standard.string(forKey: deviceIdKey)
    }

    /// Device id for login APIs. Creates and stores if missing.
    static var deviceId: String {
        if let stored = storedDeviceId, !stored.isEmpty {
            return stored
        }
        return storeDeviceId()
    }

    @discardableResult
    static func storeDeviceId() -> String {
        let id = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        UserDefaults.standard.set(id, forKey: deviceIdKey)
        return id
    }

    static func clearDeviceId() {
        UserDefaults.standard.removeObject(forKey: deviceIdKey)
    }

    static func devicePayload() -> [String: Any] {
        let id = storeDeviceId()
        return [
            "deviceId": id,
            "deviceType": "ios",
            "fcmToken": fcmToken,
            "deviceModel": UIDevice.current.model,
            "osVersion": UIDevice.current.systemVersion,
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        ]
    }

    static func requestAuthorizationIfNeeded(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
                completion?(granted)
            }
        }
    }

    static func refreshToken() {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM token: \(error.localizedDescription)")
            } else if let token = token {
                saveToken(token)
            }
        }
    }

    static func pushEnabledStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let enabled = settings.authorizationStatus == .authorized
                || settings.authorizationStatus == .provisional
            DispatchQueue.main.async {
                completion(enabled)
            }
        }
    }
}
