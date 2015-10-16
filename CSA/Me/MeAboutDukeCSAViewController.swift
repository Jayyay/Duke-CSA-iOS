//
//  MeAboutDukeCSAViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 7/30/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class MeAboutDukeCSAViewController: UIViewController {

    @IBOutlet weak var tvAbout: UITextView!
    @IBOutlet weak var viewDynamic: UIView!
    
    let NO_RESULT = "'About Duke CSA' is being updated. Please check back later."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addParticleEmitter()
        tvAbout.layer.cornerRadius = 10
        tvAbout.layer.masksToBounds = true
        let query = PFQuery(className: PFKey.ABOUT_DUKE_CSA.CLASSKEY)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.cachePolicy = PFCachePolicy.CacheThenNetwork
        query.getFirstObjectInBackgroundWithBlock { (result:PFObject?, error:NSError?) -> Void in
            self.tvAbout.text = self.NO_RESULT
            if let re = result {
                if let mainPost = re[PFKey.ABOUT_DUKE_CSA.MAIN_POST] as? String {
                    self.tvAbout.text = mainPost
                }
            }
        }
        
    }
    
    func addParticleEmitter() {
        let rect = CGRect(x: 0.0, y: -70.0, width: view.bounds.width, height: 50.0)
        let emitter = CAEmitterLayer()
        emitter.frame = rect
        viewDynamic.layer.addSublayer(emitter)
        
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

}
