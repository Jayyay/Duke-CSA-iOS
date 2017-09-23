//
//  AppDelegate.swift
//  CSA
//
//  Created by Zhe Wang on 4/4/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import ParseFacebookUtilsV4
import UserNotifications

let userNotificationReceivedNotificationName = "com.billyu.Duke-CSA.userNotificationReceived"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let configuration = ParseClientConfiguration {
            $0.applicationId = "Gfb36k13JiVKIcDDZAwjOAYUT1m6p1Nl0CddTq03"
            $0.clientKey = "nPSLgS4du3j0Zumn2e1dM3viPGTInELP9feF9yrq"
            $0.server = "https://parseapi.back4app.com"
        }
        Parse.initializeWithConfiguration(configuration)
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        let userNotificationTypes: UIUserNotificationType = ([UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]);
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        //navigation bar style
        UINavigationBar.appearance().barStyle = UIBarStyle.BlackOpaque
        UINavigationBar.appearance().barTintColor = AppConstants.ColorSet0.p1
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        //tab bar style
        UITabBar.appearance().barTintColor = UIColor.whiteColor()
        UITabBar.appearance().translucent = true
        UITabBar.appearance().tintColor = AppConstants.ColorSet0.p2
        
        // notification storage
        let notifInfo = NSKeyedUnarchiver.unarchiveObjectWithFile(NotifInfo.ArchiveURL!.path!) as? NotifInfo
        if let info = notifInfo {
            AppData.NotifData.notifInfo = info
        } else {
            let notif = NotifInfo(newEvents: [], events: [], rendezvous: [], questions: [], answers: [], ansQuestions: [])
            notif!.save()
            AppData.NotifData.notifInfo = notif
        }
        
        AppNotif.retrieveNotifications()
        if let notification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject:AnyObject] {
            AppData.NotifData.notification = notification
        }
        
        return true
    }
    
    func application(application: UIApplication,
                     openURL url: NSURL,
                             sourceApplication: String?,
                             annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                     openURL: url,
                                                                     sourceApplication: sourceApplication,
                                                                     annotation: annotation)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        if let notif = AppData.NotifData.notification {
            AppNotif.retrieveNotifications()
            print("did become active")
            AppNotif.goToVCWithNotification(notif)
        }
        AppFunc.refreshCheck()
    }
    
    func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        let state = application.applicationState
        AppNotif.retrieveNotifications()
        if state != UIApplicationState.Active {
            AppData.NotifData.notification = userInfo
        }
        completionHandler(.NoData)
    }
}

extension AppDelegate {
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.addUniqueObject(AppNotif.Channels.ALL, forKey: AppNotif.Channels.KEY)
        if let user = PFUser.currentUser() {
            installation[PFKey.INSTALL.BINDED_USER] = user
        } else {
            installation[PFKey.INSTALL.BINDED_USER] = NSNull()
        }
        installation.saveInBackground()
        print("succeedtoregisterRemoteNote")
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("failToRegisterNote")
    }
}

@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        NSNotificationCenter.defaultCenter().postNotificationName(userNotificationReceivedNotificationName, object: .None)
        completionHandler(.Alert)
    }
    
    func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        print("Response received for \(response.actionIdentifier)")
        completionHandler()
    }
}
