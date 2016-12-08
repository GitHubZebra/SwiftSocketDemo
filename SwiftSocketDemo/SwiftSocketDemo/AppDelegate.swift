//
//  AppDelegate.swift
//  SwiftSocketDemo
//
//  Created by Zebra on 2016/11/3.
//  Copyright © 2016年 Zebra. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        registerAppNotificationSettings()
        
        return true
    }

    //MARK: - 注册通知
    private func registerAppNotificationSettings() {
        
        if #available(iOS 10.0, *) {
            
            let notifiCenter = UNUserNotificationCenter.current()
            
            notifiCenter.delegate = self
            
            let types = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
            
            notifiCenter.requestAuthorization(options: types) { (flag, error) in
                
                if flag {
                    
                    print("iOS request notification success")
                    
                } else {
                    
                    print("iOS 10 request notification fail")
                    
                }
                
            }
            
        } else { //iOS8,iOS9registration
            
            let setting = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            
            UIApplication.shared.registerUserNotificationSettings(setting)
            
        }
        
        DispatchQueue.main.async {
            
            UIApplication.shared.registerForRemoteNotifications()
            
            let userSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            
            UIApplication.shared.registerUserNotificationSettings(userSettings)
            
        }
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        var token = ""
        
        for i in 0..<deviceToken.count {
            
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
            
        }
        
        print("\n>>>[DeviceToken Success]:%@\n\n",token);
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
//        UserManager.sharedInstance.saveToken(pushToken: "")
        
        print("\n>>>[DeviceToken Error]:%@\n\n",error);
        
    }
    
    //iOS10 Feature: the front desk agent notified method processing
    @available(iOS 10.0, *)
    private func userNotificationCenter(center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        print("userInfo10:\(userInfo)")
        
        completionHandler([.sound, .alert])
        
    }
    
    //iOS10 Feature: proxy method of dealing with the backstage, click on the notification
    @available(iOS 10.0, *)
    private func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        print("userInfo10:\(userInfo)")
        
        completionHandler()
        
    }
    
    //iOS9
    private func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        print("收到新消息Active\(userInfo)")
        
        if application.applicationState == UIApplicationState.active {
            // The front desk to accept the message app
        }else{
            // The background after accepting the message into the app
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
        showNotificationAlert(userInfo: userInfo)
        
        completionHandler(.newData)
        
    }
    
    @nonobjc func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]){
        
        print(userInfo)
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("前台收到新消息Active\(notification.request.content.userInfo)")
        
        completionHandler([.sound,.alert,.badge])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        print("后台收到新消息Active\(userInfo)")
        
        completionHandler()
    }
    
    
    func showNotificationAlert(userInfo:[NSObject : AnyObject]){
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        UIApplication.shared.keyWindow?.endEditing(true)
        
        application.applicationIconBadgeNumber = 0
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

