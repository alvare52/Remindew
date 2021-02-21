//
//  AppDelegate.swift
//  WaterMyPlantsBackup
//
//  Created by Jorge Alvarez on 2/4/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit
import UserNotifications
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        
        /// Asks user for permission to send notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("App launched for first time, note permission granted")
            } else {
                // local alert saying it needs permission??
                print("App launced for first time, note permission NOT granted")
            }
            
            if let error = error {
                print("error first time asking for permission in app delegate \(error)")
            }
        }
    
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    /// Lets app show Push Notifications when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // .alert deprecated in ios14
        //completionHandler([.alert, .sound, .badge])
        // .list is to show in lock screen, .banner is to show like normal banners.
        completionHandler([.banner, .sound, .badge])
        
        // ignore if we get a chime notification
        if notification.request.identifier == "chime" { return }
        
        // check watering status of all plants by sending notification to observer (PlantTableViewController)
        NotificationCenter.default.post(name: .checkWateringStatus, object: self)
    }
    
//    /// Called when you tap on notification banner
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        print("userNotificationCenter didReceive response called")
//        let content = response.notification.request.content
//        let badge = content.badge as! Int
//        print("badge = \(badge)")
//        UIApplication.shared.applicationIconBadgeNumber = 69
//    }
    
//    /// Checks if app is in the foreground and if it's foreground then show Local PushNotification
//    func application(_ application: UIApplication,didReceiveRemoteNotification userInfo: [AnyHashable: Any],fetchCompletionHandler completionHandler:@escaping (UIBackgroundFetchResult) -> Void) {
//
//        let state : UIApplication.State = application.applicationState
//        if (state == .inactive || state == .background) {
//            // go to screen relevant to Notification content
//            print("background")
//        } else {
//            // App is in UIApplicationStateActive (running in foreground)
//            print("foreground")
////            showLocalNotification()
//        }
//    }
    
//    fileprivate func showLocalNotification() {
//
//        //creating the notification content
//        let content = UNMutableNotificationContent()
//
//        //adding title, subtitle, body and badge
//        content.title = "App Update"
//        //content.subtitle = "local notification"
//        content.body = "New version of app update is available."
//        //content.badge = 1
//        content.sound = UNNotificationSound.default
//
//        //getting the notification trigger
//        //it will be called after 5 seconds
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//
//        //getting the notification request
//        let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification", content: content, trigger: trigger)
//
//        //adding the notification to notification center
//        notificationCenter.add(request, withCompletionHandler: nil)
//    }
}

