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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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