//
//  SignUpViewController.swift
//  CSA
//
//  Created by Zhe Wang on 4/4/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import ParseFacebookUtilsV4

class LoginViewController: UIViewController {
    
    
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    //@IBOutlet weak var viewStatus: UIImageView!
    @IBOutlet weak var viewButtonView: UIView!
    @IBOutlet weak var viewStatus: UIView!
    
    
    let lblStatus = UILabel()
    let statusMsg = ["Connecting ...", "Authorizing ...", "Retrieving profile ...", "Setting Up...", "Failed, try again", "Failed to retrieve", "Not authorized"]
    //var statusOriginalPosition = CGPointZero
    
    @IBOutlet weak var btnLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewButtonView.layer.cornerRadius = viewButtonView.frame.height * 0.5
        viewButtonView.layer.masksToBounds = true
        //set up the UI
        
        viewStatus.layer.cornerRadius = 10
        viewStatus.layer.masksToBounds = true
        
        spinner.frame = CGRect(x: 12.5, y: 12.5, width: 25.0, height: 25.0)
        spinner.startAnimating()
        spinner.alpha = 0.0
        btnLogin.addSubview(spinner)
        
        //imgStatus.hidden = true
        viewStatus.alpha = 0.0
        //statusOriginalPosition = viewStatus.center
        
        lblStatus.frame = CGRect(x: 0.0, y: 0.0, width: viewStatus.frame.size.width, height: viewStatus.frame.size.height)
        lblStatus.font = UIFont(name: "HelveticaNeue", size: 18.0)
        lblStatus.textColor = UIColor.whiteColor()
        lblStatus.textAlignment = .Center
        viewStatus.addSubview(lblStatus)
        
        addParticleEmitter()
    }
    
    deinit{
        print("release - LoginViewController")
    }
    
    func addParticleEmitter() {
        let rect = CGRect(x: 0.0, y: -70.0, width: view.bounds.width, height: 50.0)
        let emitter = CAEmitterLayer()
        emitter.frame = rect
        view.layer.addSublayer(emitter)
        
        emitter.emitterShape = kCAEmitterLayerRectangle
        emitter.emitterPosition = CGPoint(x: rect.width/2, y: rect.height/2)
        emitter.emitterSize = rect.size
        
        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage(named: "flake1.png")!.CGImage
        
        emitterCell.birthRate = 150
        emitterCell.lifetime = 3.5
        emitter.emitterCells = [emitterCell]
        
        emitterCell.yAcceleration = 70.0
        emitterCell.xAcceleration = 10.0
        emitterCell.velocity = 10.0
        emitterCell.emissionLongitude = CGFloat(-M_PI)
        emitterCell.velocityRange = 200.0
        emitterCell.emissionRange = CGFloat(M_PI_2)
        emitterCell.color = UIColor(red: 0.9, green: 1.0, blue: 1.0, alpha: 1.0).CGColor
        emitterCell.redRange   = 0.1
        emitterCell.greenRange = 0.1
        emitterCell.blueRange  = 0.1
        emitterCell.scale = 0.8
        emitterCell.scaleRange = 0.8
        emitterCell.scaleSpeed = -0.15
        emitterCell.alphaRange = 0.75
        emitterCell.alphaSpeed = -0.15
        emitterCell.lifetimeRange = 1.0
    }
    
    func showMessage(index index:Int, completion: (Bool)->(Void)){
        lblStatus.text = statusMsg[index]
        UIView.transitionWithView(viewStatus, duration: 0.5, options: [UIViewAnimationOptions.CurveEaseOut, UIViewAnimationOptions.TransitionCurlDown], animations: { () -> Void in
            self.viewStatus.alpha = 1.0
            }, completion: completion)
    }
    func removeMessage(completion: (Bool)->(Void)){
        UIView.animateWithDuration(0.5, delay: 0.0, options: [], animations: { () -> Void in
            self.viewStatus.alpha = 0.0
            }, completion: completion)
    }
    func resetStatus(){
        viewStatus.alpha = 0.0
        //viewStatus.center = statusOriginalPosition
    }
    func endAnimation(){
        spinner.alpha = 0.0
    }
    
    @IBAction func onLoginButton(sender: AnyObject) {
        self.spinner.alpha = 1.0
        AppFunc.pauseApp()
        showMessage(index: 0){ _ in
            let permissions = ["email", "public_profile"]//, "user_friends"]
            print("try to login")
            PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
                (user: PFUser?, error: NSError?) -> Void in
                if user == nil {
                    print("Uh oh. The user cancelled the Facebook login.")
                    self.removeMessage(){_ in
                        self.resetStatus()
                        AppFunc.resumeApp()
                        self.showMessage(index: 4){_ in
                            //failure message shown. Ends here.
                            self.endAnimation()
                        }
                    }
                } else if user!.isNew {
                    print("User signed up and logged in through Facebook!")
                    self.removeMessage(){_ in
                        self.resetStatus()
                        self.showMessage(index: 2){_ in
                            self.retrieveFacebookProfile()
                        }
                    }
                } else {
                    print("User logged in through Facebook!")
                    self.checkProfile()
                }
            }
        }
    }
    
    func checkProfile() {
        let u = PFUser.currentUser()!
        if let _ = u[PFKey.IS_VALID] as? Bool {
            AppFunc.resumeApp()
            self.readyForLogin()
        }else {
            self.removeMessage(){_ in
                self.resetStatus()
                self.showMessage(index: 2){_ in
                    self.retrieveFacebookProfile()
                }
            }
        }
    }
    
    func buildProfile(result: PFObject, completion: (Bool, NSError?) -> (Void)) {
        let u = PFUser.currentUser()!
        u[PFKey.IS_VALID] = true
        u[PFKey.USER.IS_ADMIN] = false
        //gender string can only be "male", "female", "other"
        if let gender = result["gender"] as? String {
            if gender == UserConstants.Gender.MALE || gender == UserConstants.Gender.FEMALE {
                u[PFKey.USER.GENDER] = gender
            }else {
                u[PFKey.USER.GENDER] = UserConstants.Gender.OTHER
            }
        }else {
            u[PFKey.USER.GENDER] = UserConstants.Gender.OTHER
        }
        //name 
        if let n = result["name"] as? String {
            u[PFKey.USER.REAL_NAME] = n
            u[PFKey.USER.DISPLAY_NAME] = n
        }else {
            u[PFKey.USER.REAL_NAME] = "Developer"
            u[PFKey.USER.DISPLAY_NAME] = "Developer"
        }
        //email
        if let e = result["email"] as? String {
            u[PFKey.USER.EMAIL] = e
        }else {
            u[PFKey.USER.EMAIL] = "developer@duke.edu"
        }
        u[PFKey.USER.ABOUT_ME] = UserConstants.AboutMe.DEFAULT
        u[PFKey.USER.BIRTHDAY] = UserConstants.Birthday.ENIAC
        u[PFKey.USER.WHICH_YEAR] = UserConstants.WhichYear.FRESHMAN
        u[PFKey.USER.RELATIONSHIP] = UserConstants.Relationship.UNKNOWN
        u[PFKey.USER.NET_ID] = UserConstants.EMPTY
        u[PFKey.USER.CELL_PHONE] = UserConstants.EMPTY
        u[PFKey.USER.MAJOR] = UserConstants.EMPTY
        u[PFKey.USER.MINOR] = UserConstants.EMPTY
        u[PFKey.USER.MYEVENTS_ARR] = []
        
        //Spotlight User
        let newSpUser = PFObject(className: PFKey.SPOTLIGHT.CLASSKEY)
        newSpUser[PFKey.IS_VALID] = true
        newSpUser[PFKey.SPOTLIGHT.USER] = PFUser.currentUser()!
        newSpUser[PFKey.SPOTLIGHT.IS_ON] = true
        newSpUser[PFKey.SPOTLIGHT.POINTS] = 30
        newSpUser[PFKey.SPOTLIGHT.BONUS] = 0
        newSpUser[PFKey.SPOTLIGHT.LIKES] = []
        newSpUser[PFKey.SPOTLIGHT.VOTE0] = []
        newSpUser[PFKey.SPOTLIGHT.VOTE1] = []
        newSpUser[PFKey.SPOTLIGHT.VOTE2] = []
        newSpUser.saveInBackgroundWithBlock(completion)
    }

    func retrieveFacebookProfile() {/*
        FBRequestConnection.startForMeWithCompletionHandler { (connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
            if let result = result as? PFObject{
                self.removeMessage(){_ in
                    self.resetStatus()
                    self.showMessage(index: 3){_ in
                        self.buildProfile(result) {(success:Bool, error:NSError?) in
                            if success { //important data is uploaded successfully
                                let userFBID = result["id"] as! String
                                let facebookProfileUrl = NSURL(string:"http://graph.facebook.com/\(userFBID)/picture?width=320&height=320")!
                                let urlRequest = NSURLRequest(URL: facebookProfileUrl)
                                NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response:NSURLResponse?, data:NSData?, error:NSError?) -> Void in
                                    if error == nil {
                                        let u = PFUser.currentUser()!
                                        if let compressedImg = AppTools.compressImage(UIImage(data: data!)){
                                            u[PFKey.USER.PROPIC_COMPRESSED] = PFFile(name: "compPropic.png",data: UIImagePNGRepresentation(compressedImg)!)
                                        }
                                        //Think: do we need to save original picture?
                                        //u[PFKey.USER.PROPIC_ORIGINAL] = PFFile(name: "propic.png", data: data)
                                        u.saveInBackground()
                                    }
                                    AppFunc.resumeApp()
                                    self.readyForLogin()
                                }
                            } else {
                                AppFunc.resumeApp()
                                self.showMessage(index: 4){_ in
                                    //failure message shown. Ends here.
                                    self.endAnimation()
                                }
                            }
                        }
                    }
                }
            }else{
                self.removeMessage(){_ in
                    self.resetStatus()
                    AppFunc.resumeApp()
                    self.showMessage(index: 6){_ in
                        self.endAnimation()
                    }
                }
            }
        }*/
    }
    
    func resetAppStatus(){
        let install = PFInstallation.currentInstallation()
        install[PFKey.INSTALL.BINDED_USER] = PFUser.currentUser()!
        install.saveInBackground()
        AppStatus.EventStatus.tableShouldRefresh = true
        AppStatus.BulletinStatus.tableShouldRefresh = true
        AppStatus.RendezvousStatus.tableShouldRefresh = true
        AppStatus.MeTableStatus.tableShouldRefreshLocally = true
    }
    
    func readyForLogin(){
        endAnimation()
        resetStatus()
        resetAppStatus()
        if let tabVC = self.presentingViewController as? TabBarController{
            //coming to login view from main app
            print("************reset tab view state*****")
            for vc in tabVC.viewControllers! {
                if vc is UINavigationController{
                    print("pop to root: ", terminator: "")
                    print(vc)
                    (vc as! UINavigationController).popToRootViewControllerAnimated(false)
                }
            }
            print("*************************************")
            tabVC.selectedIndex = 0
            self.dismissViewControllerAnimated(true, completion: nil)
        }else {
            //shouldn't be here
            print("ERROR: coming to login view from unknown view!")
            print("ERROR: coming to login view from unknown view!!")
            print("ERROR: coming to login view from unknown view!!!")
        }
    }
}
