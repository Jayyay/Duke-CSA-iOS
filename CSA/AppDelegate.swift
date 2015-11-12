//
//  AppDelegate.swift
//  CSA
//
//  Created by Zhe Wang on 4/4/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Parse.setApplicationId("Gfb36k13JiVKIcDDZAwjOAYUT1m6p1Nl0CddTq03", clientKey: "nPSLgS4du3j0Zumn2e1dM3viPGTInELP9feF9yrq")
        PFFacebookUtils.initializeFacebook()
        let userNotificationTypes: UIUserNotificationType = ([UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]);
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        //navigation bar style
        UINavigationBar.appearance().barStyle = UIBarStyle.BlackTranslucent
        UINavigationBar.appearance().barTintColor = AppConstants.Color.cuteRed
        UINavigationBar.appearance().translucent = true
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        //tab bar style
        UITabBar.appearance().barTintColor = UIColor(red: 232/255, green: 248/255, blue: 247/255, alpha: 1)
        UITabBar.appearance().translucent = true
        
        /*notification handled
        if let notif = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            if let notifHandleType = notif["type"] as? String {
                AppFunc.handleNotification(notifHandleType)
            }
        }*/
        
        return true
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.addUniqueObject(AppNotif.Channels.ALL, forKey: AppNotif.Channels.KEY)
        if let user = PFUser.currentUser() {
            installation[PFKey.INSTALL.BINDED_USER] = user
        }else{
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
            return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication,
                withSession:PFFacebookUtils.session())
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
        let installation = PFInstallation.currentInstallation()
        if installation.badge != 0{
            installation.badge = 0
            installation.saveEventually()
        }
        AppFunc.refreshCheck()
    }
    
    func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        if let message = userInfo[AppNotif.KEY] as? String {
            print(message)
            let vc = UIApplication.sharedApplication().keyWindow!.rootViewController!
            AppFunc.displayAlertViewFromViewController(vc, message: message)
        }else {
            print("no alert")
        }
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

