//
//  RealityView.swift
//  EffectSampler
//
//  Created by Alex Linkov on 11/26/19.
//  Copyright © 2019 SDWR. All rights reserved.
//

import UIKit
import MetalKit

protocol RealityViewDelegate: class {
    func realityViewDidBeginReceiving(touches: Set<UITouch>, withEvent: UIEvent?)
}

class RealityView: MTKView {
    
    weak var realityViewDelegate: RealityViewDelegate?
    
    
    init(realityViewDelegate: RealityViewDelegate, frame: CGRect, device: MTLDevice) {
        super.init(frame: frame, device: device)
        self.realityViewDelegate = realityViewDelegate

    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     // MARK: - Handle touch events
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.realityViewDelegate?.realityViewDidBeginReceiving(touches: touches, withEvent: event)
    }
    

}
