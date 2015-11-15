//
//  ImageScrollerViewController.swift
//  Duke CSA
//
//  Created by Qiongjia Xu on 11/15/15.
//  Copyright © 2015 Zhe Wang. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController {
    var imageView: UIImageView!
    var scrollView: UIScrollView!
    var originLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView(image: UIImage(named: "IMG_2932.jpg"))
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = .FlexibleWidth
        scrollView.autoresizingMask = .FlexibleHeight
        scrollView.backgroundColor = UIColor.blackColor()
        scrollView.contentSize = imageView.bounds.size
        
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        
        originLabel = UILabel(frame: CGRect(x: 20, y: 30, width: 0, height: 0))
        originLabel.backgroundColor = UIColor.blackColor()
        originLabel.textColor = UIColor.whiteColor()
        view.addSubview(originLabel)
        
        scrollView.delegate = self
        
        setZoomParametersForSize(scrollView.bounds.size)
        scrollView.zoomScale = scrollView.minimumZoomScale
        recenterImage()
    }
    
    func setZoomParametersForSize(scrollViewSize: CGSize) {
        let imageSize = imageView.bounds.size
        
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 1.0 // how large can it zoom in
        //scrollView.zoomScale = minScale
    }
    
    func recenterImage(){
        let scrollViewSize = scrollView.bounds.size
        let imageSize = imageView.frame.size
        
        let horizontalSpace = imageSize.width < scrollViewSize.width ?
            (scrollViewSize.width - imageSize.width) / 2:0
        let verticalSpace = imageSize.height < scrollViewSize.height ?
            (scrollViewSize.height - imageSize.height) / 2:0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalSpace, left: horizontalSpace, bottom: verticalSpace, right: horizontalSpace)
        
        
    }
    
    // when rotation happens
    override func viewWillLayoutSubviews() {
        setZoomParametersForSize(scrollView.bounds.size)
        if scrollView.zoomScale < scrollView.minimumZoomScale{
            scrollView.zoomScale = scrollView.minimumZoomScale
        }
        recenterImage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UIScrollViewDelegate

extension ViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //originLabel.text = "\(scrollView.contentOffset)" //display the coordinates
        originLabel.sizeToFit()
    }
}