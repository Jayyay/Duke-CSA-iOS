//
//  EventSignUpViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/11/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class EventSignUpViewController: UIViewController, UIWebViewDelegate, ENSideMenuDelegate {
    
    /*@IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblWhen: UILabel!
    @IBOutlet weak var lblWhere: UILabel!*/
    
    @IBOutlet weak var openView: UIView!
    @IBOutlet weak var closeView: UIView!
    
    @IBOutlet weak var webviewSignUp: UIWebView!
    
    var selectedEvent:Event!
    
    var refreshConnectSuccess = false
    
    let GOOGLE_URL = "https://www.google.com/?gws_rd=ssl"
    let TIME_OUT_IN_SEC:NSTimeInterval = 5.0
    
    @IBAction func onRefresh(sender: AnyObject) {
        refreshEventSignUpInfo()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedEvent = AppData.EventData.selectedEvent
        AppData.EventData.signupVC = self
        
        /*lblTitle.text = selectedEvent.title
        let formatter = NSDateFormatter()
        formatter.dateFormat = "E, MM-dd 'at' HH:mm"
        lblWhen.text = "When: " + formatter.stringFromDate(selectedEvent.date)
        lblWhere.text = "Where: \(selectedEvent.location)"*/
        
        /*
        closeView.layer.cornerRadius = 20.0
        closeView.layer.masksToBounds = true*/
        webviewSignUp.delegate = self
        webviewSignUp.layer.borderColor = UIColor.blackColor().CGColor
        webviewSignUp.layer.borderWidth = 1.0
        webviewSignUp.layer.masksToBounds = true
        clearContentAndDisplayLoading()
        reloadContent()

    
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.sideMenuController()?.sideMenu?.delegate = self
        AppStatus.EventStatus.currentlyDisplayedView = AppStatus.EventStatus.ViewName.SignUp
        self.sideMenuController()?.sideMenu?.resetMenuSelectionForRow(AppStatus.EventStatus.ViewName.SignUp.rawValue)
        

    }
    
    func refreshEventSignUpInfo() {
        clearContentAndDisplayLoading()
        self.view.makeToastActivity(position: HRToastPositionCenterAbove, message: "")
        refreshConnectSuccess = false
        AppFunc.pauseApp()
        //set time out
        NSTimer.scheduledTimerWithTimeInterval(TIME_OUT_IN_SEC, target: self, selector: Selector("refreshTimeOut"), userInfo: nil, repeats: false)
        selectedEvent.PFInstance.fetchInBackgroundWithBlock { (result:PFObject?, error:NSError?) -> Void in
            self.refreshConnectSuccess = true
            self.view.hideToastActivity()
            AppFunc.resumeApp()
            if let re = result {
                if let o = re[PFKey.EVENT.OPEN_FOR_SIGN_UP] as? Bool {
                    self.selectedEvent.openForSignUp = o
                }else {
                    self.selectedEvent.openForSignUp = false
                }
                if let n = re[PFKey.EVENT.NEED_SIGN_UP] as? Bool {
                    self.selectedEvent.needToSignUp = n
                }else {
                    self.selectedEvent.needToSignUp = false
                }
                if self.selectedEvent.openForSignUp && self.selectedEvent.needToSignUp {
                    if let u = re[PFKey.EVENT.URL_FOR_SIGN_UP] as? String {
                        self.selectedEvent.urlForSignUp = u
                    }
                    else {
                        self.selectedEvent.urlForSignUp = self.GOOGLE_URL
                    }
                }
                self.reloadContent()
            } else {
                self.view.makeToast(message: AppConstants.Prompt.REFRESH_FAILED, duration: 1.5, position: HRToastPositionCenterAbove)
            }
        }
    }
    
    func refreshTimeOut() {
        if !refreshConnectSuccess{
            print("refresh time out")
            AppFunc.resumeApp()
            self.view.hideToastActivity()
            self.view.makeToast(message: AppConstants.Prompt.REFRESH_FAILED, duration: 1.5, position: HRToastPositionCenterAbove)
        }
    }
    
    func clearContentAndDisplayLoading() {
        // from html
        let html = "<html><head></header><body><h1 style=\"color:lightgrey\">Loading...</h1></body></html>"
        webviewSignUp.loadHTMLString(html, baseURL: nil)
    }
    
    func reloadContent() {
        if selectedEvent.needToSignUp && selectedEvent.openForSignUp { //open for signup
            openView.hidden = false
            closeView.hidden = true
            if let url = NSURL(string: selectedEvent.urlForSignUp) {
                let request = NSURLRequest(URL: url)
                webviewSignUp.loadRequest(request)
            }
        }else{
            openView.hidden = true
            closeView.hidden = false
        }
    }
    
    deinit{
        print("Release - EventSignUpViewController")
    }
}
