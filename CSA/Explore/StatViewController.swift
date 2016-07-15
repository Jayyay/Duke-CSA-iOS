//
//  StatViewController.swift
//  Duke CSA
//
//  Created by Bill Yu on 7/14/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UIKit

class StatViewController: UIViewController {
    
    @IBOutlet weak var mostCuriousUser: UserLabel!
    @IBOutlet weak var mostWiseUser: UserLabel!
    @IBOutlet weak var mostQLabel: UILabel!
    @IBOutlet weak var mostALabel: UILabel!
    @IBOutlet weak var mostUpvotedQUser: UserLabel!
    @IBOutlet weak var mostUpvotedAUser: UserLabel!
    @IBOutlet weak var mostUpQLabel: UILabel!
    @IBOutlet weak var mostUpALabel: UILabel!
    
    var query: PFQuery!
    let USER_ID = "userID"
    let MAX = "max"
    let fontSize = CGFloat(15.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        query = PFQuery(className: PFKey.USER.CLASSKEY)
    }
    
    override func viewDidAppear(animated: Bool) {
        loadStat()
    }
    
    func loadStat() {
        PFCloud.callFunctionInBackground("mostPosts", withParameters: ["type": "Question"]) { (result, error) in
            if let re = result as? [NSObject: AnyObject] {
                let id = re[self.USER_ID] as! String
                let max = re[self.MAX] as! Int
                self.query.getObjectInBackgroundWithId(id, block: { (result, error) in
                    if let user = result as? PFUser {
                        //dispatch_async(dispatch_get_main_queue(), { _ in
                            self.mostCuriousUser.text = (user[PFKey.USER.DISPLAY_NAME] as! String)
                            print(user[PFKey.USER.DISPLAY_NAME])
                            self.mostQLabel.text = String(max) + " Questions"
                        //})
                    } else if let error = error {
                        print("Error getting user", error)
                    }
                })
            }
        }
        PFCloud.callFunctionInBackground("mostPosts", withParameters: ["type": "Answer"]) { (result, error) in
            if let re = result as? [NSObject: AnyObject] {
                let id = re[self.USER_ID] as! String
                let max = re[self.MAX] as! Int
                self.query.getObjectInBackgroundWithId(id, block: { (result, error) in
                    if let user = result as? PFUser {
                        //dispatch_async(dispatch_get_main_queue(), { _ in
                            self.mostWiseUser.text = (user[PFKey.USER.DISPLAY_NAME] as! String)
                            print(user[PFKey.USER.DISPLAY_NAME])
                            self.mostALabel.text = String(max) + " Answers"
                        //})
                    } else if let error = error {
                        print("Error getting user", error)
                    }
                })
            }
        }
        PFCloud.callFunctionInBackground("mostVote", withParameters: ["type": "Question"]) { (result, error) in
            if let re = result as? [NSObject: AnyObject] {
                let id = re[self.USER_ID] as! String
                let max = re[self.MAX] as! Int
                self.query.getObjectInBackgroundWithId(id, block: { (result, error) in
                    if let user = result as? PFUser {
                        //dispatch_async(dispatch_get_main_queue(), { _ in
                            print("most vote")
                            self.mostUpvotedQUser.text = (user[PFKey.USER.DISPLAY_NAME] as! String)
                            print(user[PFKey.USER.DISPLAY_NAME])
                            self.mostUpQLabel.text = String(max) + " votes"
                        //})
                    } else if let error = error {
                        print("Error getting user", error)
                    }
                })
            }
        }
        PFCloud.callFunctionInBackground("mostVote", withParameters: ["type": "Answer"]) { (result, error) in
            if let re = result as? [NSObject: AnyObject] {
                let id = re[self.USER_ID] as! String
                let max = re[self.MAX] as! Int
                self.query.getObjectInBackgroundWithId(id, block: { (result, error) in
                    if let user = result as? PFUser {
                        //dispatch_async(dispatch_get_main_queue(), { _ in
                            self.mostUpvotedAUser.text = (user[PFKey.USER.DISPLAY_NAME] as! String)
                            print(user[PFKey.USER.DISPLAY_NAME])
                            self.mostUpALabel.text = String(max) + " votes"
                        //})
                    } else if let error = error {
                        print("Error getting user", error)
                    }
                })
            }
        }
    }

}
