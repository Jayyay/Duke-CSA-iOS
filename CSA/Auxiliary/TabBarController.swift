//
//  TabBarController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/10/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var previousVC:AnyObject!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
    }
    //tabbarcontroller
    
    /*
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        /*print("TabBarController: did select: ")
        println(viewController)*/
        if previousVC == nil {
            previousVC = (self.viewControllers!)[0]
        }
        if viewController === previousVC && viewController is EventNavigationController {
            let visibleVC =  (viewController as EventNavigationController).visibleViewController
            if visibleVC is EventTableViewController {
                print("could refresh")
                if AppStatus.Event.lastRefreshTime != nil && NSDate().timeIntervalSinceDate(AppStatus.Event.lastRefreshTime!) > 10{
                    println(" and... go")
                    (visibleVC as EventTableViewController).autoRefresh()
                }else{
                    println(" but too soon")
                }
            }
        }
        
        previousVC = viewController
    }*/
    
}
