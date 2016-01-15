//
//  ZoomImageViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 12/5/15.
//  Copyright © 2015 Zhe Wang. All rights reserved.
//

import UIKit

class ZoomImageViewController: UIViewController {
    
    @IBOutlet weak var imgMain: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("zoom view did load")
        
        imgMain.image = AppData.ImageData.selectedImage
        imgMain.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("tapView:"))
        let panGesture = UIPanGestureRecognizer(target: self, action: Selector("moveView:"))
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: Selector("rotateView:"))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: Selector("pinchView:"))
        imgMain.gestureRecognizers = [tapGesture, panGesture, rotateGesture, pinchGesture]
        
        if AppData.ImageData.userPropicMode {//need to download user's full propic
            if let u = AppData.ImageData.selectedUser {
                if let fullPropicFile = u[PFKey.USER.PROPIC_ORIGINAL] as? PFFile {
                    self.view.makeToastActivity(position: HRToastPositionCenterAbove)
                    fullPropicFile.getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) -> Void in
                        self.view.hideToastActivity()
                        if let d = data {
                            if self.imgMain != nil {//cell in table is visible
                                dispatch_async(dispatch_get_main_queue(), { _ in
                                    self.imgMain.image = UIImage(data: d)
                                })
                            }
                        }else{
                            print("Can't retrieve propic: \(error)")
                        }
                    })
                }
            }
        }
        
    }
    
    func tapView(gesture: UITapGestureRecognizer) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func moveView(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        recognizer.view!.center = CGPoint(x:view.center.x + translation.x, y:view.center.y + translation.y)
    }
    
    func rotateView(recognizer: UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = CGAffineTransformRotate(view.transform, recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    func pinchView(recognizer : UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = CGAffineTransformScale(view.transform, recognizer.scale, recognizer.scale)
            recognizer.scale = 1
        }
    }
    
    deinit{
        imgMain = nil
        AppData.ImageData.wipeSelectedImageData()
        print("zoom view deinit")
    }

}
