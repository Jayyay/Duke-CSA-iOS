//
//  MeNotifCell.swift
//  Duke CSA
//
//  Created by Zhe Wang on 9/4/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class MeNotifCell: UITableViewCell {

    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblCreatedAt: UILabel!
    var notification: [NSObject: AnyObject]! = [:]
    
    func initWithNotif(notif:Notification) {
        lblMessage.text = notif.message
        lblCreatedAt.text = AppTools.formatDateUserFriendly(notif.createdAt)
        
        notification[AppNotif.NotifType.KEY] = notif.type
        notification[AppNotif.INSTANCE_ID] = notif.instanceID
    }

    func getSelected() {
        AppNotif.goToVCWithNotification(notification)
    }
}
