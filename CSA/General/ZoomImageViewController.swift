//
//  ZoomImageViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 12/5/15.
//  Copyright © 2015 Zhe Wang. All rights reserved.
//

import UIKit

class ZoomImageViewController: UIViewController {
    
    var imageView: UIImageView!
    var image: UIImage!
    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        image = AppData.ImageData.selectedImage
        let hideGesture = UITapGestureRecognizer(target: self, action: Selector("hideImage"))
        view.addGestureRecognizer(hideGesture)
        
        imageView = UIImageView(image: image)
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        scrollView.backgroundColor = UIColor.blackColor()
        scrollView.contentSize = imageView.bounds.size
        
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        
        scrollView.delegate = self
        setZoomParametersForSize(scrollView.bounds.size)
        
        recenterImage()
        
        if AppData.ImageData.userPropicMode {//need to download user's full propic
            if let u = AppData.ImageData.selectedUser {
                if let fullPropicFile = u[PFKey.USER.PROPIC_ORIGINAL] as? PFFile {
                    self.view.makeToastActivity(position: HRToastPositionCenterAbove)
                    fullPropicFile.getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) -> Void in
                        self.view.hideToastActivity()
                        if let d = data {
                            if self.imageView != nil {
                                dispatch_async(dispatch_get_main_queue(), { _ in
                                    self.imageView.image = UIImage(data: d)
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
    
    func setZoomParametersForSize(scrollViewSize: CGSize) {
        let imageSize = imageView.bounds.size
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 3.0
        scrollView.zoomScale = minScale
    }
    
    func recenterImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageSize = imageView.frame.size
        
        let horizontalSpace = imageSize.width < scrollViewSize.width ?
            (scrollViewSize.width - imageSize.width) / 2 : 0
        let verticalSpace = imageSize.height < scrollViewSize.height ?
            (scrollViewSize.height - imageSize.height) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(top: verticalSpace, left: horizontalSpace, bottom: verticalSpace, right: horizontalSpace)
    }
    
    override func viewWillLayoutSubviews() {
        setZoomParametersForSize(scrollView.bounds.size)
        recenterImage()
    }
    
    func hideImage() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    deinit {
        print("deinit - ZoomImage")
        AppData.ImageData.wipeSelectedImageData()
    }
    
}

extension ZoomImageViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        recenterImage()
    }
}