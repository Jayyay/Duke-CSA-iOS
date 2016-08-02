//
//  NotificationService.swift
//  ServiceExtension
//
//  Created by Bill Yu on 7/22/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceiveNotificationRequest(request: UNNotificationRequest, withContentHandler contentHandler: (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        print("function is called")
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            print(bestAttemptContent.title)
            bestAttemptContent.title = "\(bestAttemptContent.title)"
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
