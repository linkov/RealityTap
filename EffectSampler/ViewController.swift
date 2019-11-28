//
//  ViewController.swift
//  EffectSampler
//
//  Created by Alex Linkov on 11/25/19.
//  Copyright © 2019 SDWR. All rights reserved.
//

import UIKit
import MapKit
import MetalKit

class ViewController: UIViewController {

    var metalRenderer: RealityTap!
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.navigationController?.navigationBar.isHidden = true
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.view.addGestureRecognizer(tap)
        
        
    }
    
     @objc func handleTap(_ gesture: UITapGestureRecognizer) {
    
        
        metalRenderer = RealityTap(view: self.mapView, effect: .shockwave)
        metalRenderer.realityTap(presentingView: self.mapView, gestureRecognizer: gesture)
        
    }
    
    

    
    


}

