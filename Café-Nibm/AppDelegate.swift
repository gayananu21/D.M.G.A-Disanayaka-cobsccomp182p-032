//
//  AppDelegate.swift
//  Café-Nibm
//
//  Created by Gayan Disanayaka on 2/22/21.
//  Copyright © 2021 Gayan Disanayaka. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import UserNotifications
import FBSDKCoreKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var hasAlreadyLaunched :Bool!
    var window: UIWindow?
    let notificationCenter = UNUserNotificationCenter.current()

    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        NetworkMonitor.shared.startMonitoring()
        FirebaseApp.configure()
        
        
         //retrieve value from local store, if value doesn't exist then false is returned
                hasAlreadyLaunched = UserDefaults.standard.bool(forKey: "hasAlreadyLaunched")
                
                //check first launched
                if (hasAlreadyLaunched)
                {
                   hasAlreadyLaunched = true
                }else{
                    UserDefaults.standard.set(true, forKey: "hasAlreadyLaunched")
                }
                
        notificationCenter.delegate = self
               
               let options: UNAuthorizationOptions = [.alert, .sound, .badge]
               
               notificationCenter.requestAuthorization(options: options) {
                   (didAllow, error) in
                   if !didAllow {
                       print("User has declined notifications")
                   }
               }
        ApplicationDelegate.shared.application(
                   application,
                   didFinishLaunchingWithOptions: launchOptions
               )

        
                return true
            }
    
    func applicationWillResignActive(_ application: UIApplication) {
           // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
           // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
       }

       func applicationDidEnterBackground(_ application: UIApplication) {
           // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
           // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
       }

       func applicationWillEnterForeground(_ application: UIApplication) {
           // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
       }

       func applicationDidBecomeActive(_ application: UIApplication) {
           
           UIApplication.shared.applicationIconBadgeNumber = 0
       }

       func applicationWillTerminate(_ application: UIApplication) {
           // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
       }
    
    func application(
           _ app: UIApplication,
           open url: URL,
           options: [UIApplication.OpenURLOptionsKey : Any] = [:]
       ) -> Bool {

           ApplicationDelegate.shared.application(
               app,
               open: url,
               sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
               annotation: options[UIApplication.OpenURLOptionsKey.annotation]
           )
    }
            
            func sethasAlreadyLaunched(){
                hasAlreadyLaunched = true
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

            // MARK: - Core Data stack
            lazy var persistentContainer: NSPersistentContainer = {
                /*
                 The persistent container for the application. This implementation
                 creates and returns a container, having loaded the store for the
                 application to it. This property is optional since there are legitimate
                 error conditions that could cause the creation of the store to fail.
                */
                let container = NSPersistentContainer(name: "Café-Nibm")
                container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                    if let error = error as NSError? {
                        // Replace this implementation with code to handle the error appropriately.
                        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                         
                        /*
                         Typical reasons for an error here include:
                         * The parent directory does not exist, cannot be created, or disallows writing.
                         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                         * The device is out of space.
                         * The store could not be migrated to the current model version.
                         Check the error message to determine what the actual problem was.
                         */
                        fatalError("Unresolved error \(error), \(error.userInfo)")
                    }
                })
                return container
            }()

            // MARK: - Core Data Saving support
            func saveContext () {
                let context = persistentContainer.viewContext
                if context.hasChanges {
                    do {
                        try context.save()
                    } catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                }
            }

        }


extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.identifier == "Local Notification" {
            print("Handling notifications with the Local Notification Identifier")
        }
        
        completionHandler()
    }
    
    func scheduleNotification(notificationType: String, alertTitle: String) {
        
        let content = UNMutableNotificationContent() // Содержимое уведомления
        let categoryIdentifire = "Delete Notification Type"
        
        content.title = alertTitle
        content.body = notificationType
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = categoryIdentifire
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "DeleteAction", title: "Delete", options: [.destructive])
        let category = UNNotificationCategory(identifier: categoryIdentifire,
                                              actions: [snoozeAction, deleteAction],
                                              intentIdentifiers: [],
                                              options: [])
        
        notificationCenter.setNotificationCategories([category])
    }
    
    
    func promoNotifications(notificationType: String, alertTitle: String) {
        
        let content = UNMutableNotificationContent() // Содержимое уведомления
        let categoryIdentifire = "Delete Notification Type"
        
        content.title = alertTitle
        content.body = notificationType
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = categoryIdentifire
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60*60*24, repeats: false)
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "DeleteAction", title: "Delete", options: [.destructive])
        let category = UNNotificationCategory(identifier: categoryIdentifire,
                                              actions: [snoozeAction, deleteAction],
                                              intentIdentifiers: [],
                                              options: [])
        
        notificationCenter.setNotificationCategories([category])
    }
}

