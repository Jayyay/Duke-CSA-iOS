//
//  EventPicCell.swift
//  Duke CSA
//
//  Created by Zhe Wang on 1/13/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UIKit

class EventPicCell: UITableViewCell {

    @IBOutlet weak var imgPropic: UIImageView!
    weak var parentVC:UIViewController!
    
    func initWithEvent(evt:Event, fromVC:UIViewController, fromTableView tableView:UITableView, forIndexPath indexPath:NSIndexPath){
        
        self.parentVC = fromVC
        if let p = evt.propic {
            AppFunc.downloadPictureFile(file: p, saveToImgView: imgPropic, inTableView: tableView, forIndexPath: indexPath)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("tapView:"))
        imgPropic.gestureRecognizers = [tapGesture]

        layoutIfNeeded()
    }
    
    
    func tapView(gesture: UITapGestureRecognizer) {
        print("tap image")
        AppData.ImageData.userPropicMode = false
        AppData.ImageData.selectedImage = imgPropic.image
        let vc = parentVC.storyboard?.instantiateViewControllerWithIdentifier(StoryboardID.ZOOM_IMAGE) as! ZoomImageViewController
        parentVC.presentViewController(vc, animated: true, completion: nil)
    }
}
