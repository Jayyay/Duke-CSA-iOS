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
        //Parse.setApplicationId("Gfb36k13JiVKIcDDZAwjOAYUT1m6p1Nl0CddTq03", clientKey: "nPSLgS4du3j0Zumn2e1dM3viPGTInELP9feF9yrq")
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        let userNotificationTypes: UIUserNotificationType = ([UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]);
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        //navigation bar style
        UINavigationBar.appearance().barStyle = UIBarStyle.BlackOpaque
        UINavigationBar.appearance().barTintColor = AppConstants.ColorSet0.c2
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        //tab bar style
        UITabBar.appearance().barTintColor = AppConstants.ColorSet0.c4
        UITabBar.appearance().translucent = true
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        
        // notification storage
        let notifInfo = NSKeyedUnarchiver.unarchiveObjectWithFile(NotifInfo.ArchiveURL!.path!) as? NotifInfo
        if let info = notifInfo {
            AppData.NotifData.notifInfo = info
        } else {
            let notif = NotifInfo(newEvents: [], events: [], rendezvous: [], questions: [], answers: [], ansQuestions: [])
            notif!.save()
            AppData.NotifData.notifInfo = notif
        }
        
        if let notification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject:AnyObject] {
            AppData.NotifData.notification = notification
        }
        
        return true
    }
    
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
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        if let notif = AppData.NotifData.notification {
            AppNotif.handleBadgeNotif(notif)
            AppNotif.showBadgeOnTabbar()
            print("did become active")
            AppNotif.goToVCWithNotification(notif)
        }
        AppFunc.refreshCheck()
    }
    
    func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        let state = application.applicationState
        AppNotif.handleBadgeNotif(userInfo)
        AppNotif.showBadgeOnTabbar()
        if state != UIApplicationState.Active {
            AppData.NotifData.notification = userInfo
        }
        completionHandler(.NoData)
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

