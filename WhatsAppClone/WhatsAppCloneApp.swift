//
//  WhatsAppCloneApp.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 16.05.24.
//

import SwiftUI
import FirebaseCore
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        setupPushNotifications(for: application)
        return true
    }
    
    private func setupPushNotifications(for application: UIApplication) {
        let notificationCenter = UNUserNotificationCenter.current()
        Messaging.messaging().delegate = self
        notificationCenter.delegate = self
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        notificationCenter.requestAuthorization(options: options) { granted, error in
            
            if let error {
                print("APNS failed to request authorization: \(error.localizedDescription)")
                return
            }
            if granted {
                print("APNS authorization granted")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                print("APNS authorization denied")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate && MessagingDelegate
extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("APNS device token is: \(String(describing: fcmToken))")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("APNS successfully registered for push notifications: \(deviceToken)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return[.sound, .badge, .badge]
    }
}

@main
struct WhatsAppCloneApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootScreen()
        }
    }
}
