//
//  RealityTap.swift
//  EffectSampler 🤘
//
//  Created by Alex Linkov on 11/25/19.
//  Copyright © 2019 SDWR. All rights reserved.
//

import UIKit
import MetalKit


class RealityTap: NSObject, MTKViewDelegate, RealityViewDelegate {

    
    enum effect: String {
        case shockwave = "shockwave"
        case ripple = "ripple"
    }
   
    
    // MARK: General
    
    private var view: RealityView!
    private let metalDevice = MTLCreateSystemDefaultDevice()!
    
    // MARK: Metal setup
    
    private let device = MTLCreateSystemDefaultDevice()!
    private var queue: MTLCommandQueue?
    private var computePipelineState: MTLComputePipelineState?
    private var renderPipelineState: MTLRenderPipelineState?
    private var texture: MTLTexture?
    private var timer: Float = 0
    private var timerBuffer: MTLBuffer?
    private var time = TimeInterval(0.0)
    
    // MARK: TapReality
    
    private var touchedPoint: float2?

    private var currentEffect: effect?
    private var speed: Float = 0.0
    private var speedBuffer: MTLBuffer?
    private var intense: Float = 700.0
        
    private var touchedPointBuffer: MTLBuffer?
    
    
    // MARK: Inputs
    
    weak var parentView: UIView!
    
    
    
    init?(view: UIView, effect: effect) {
        
        super.init()
        self.currentEffect = effect
        
        // UIKit
        self.parentView = view
        self.view = RealityView(realityViewDelegate: self, frame: .zero, device: device)
        self.view.delegate = self
        self.view.framebufferOnly = false
        self.view.isExclusiveTouch = false
        self.view.delegate = self
        self.view.device = device

        queue = device.makeCommandQueue()!

        
        // Buffers
        
        timerBuffer = device.makeBuffer(length: MemoryLayout<Float>.size, options: [])!
        speedBuffer = device.makeBuffer(length: MemoryLayout<Float>.size, options: [])!
        touchedPointBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * 2, options: [])!
        
        
        
        // Render pipeline
        let library = metalDevice.makeDefaultLibrary()!
        
        let kernalProgram = library.makeFunction(name: currentEffect!.rawValue)!
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.label = "Reality pipeline"
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = self.view.colorPixelFormat
        
        
        computePipelineState = try! device.makeComputePipelineState(function: kernalProgram)


        
        
    }
    
    
    public func realityTap(presentingView: UIView, gestureRecognizer: UIGestureRecognizer) {
       
//        cleanUp()
        
        let touchPoint = gestureRecognizer.location(in: presentingView)
        
        
        let rect = CGRect(center: touchPoint, size: presentingView.bounds.size)
        let x: Float = Float( abs(rect.centerX) )
        let y: Float = Float( abs(rect.centerY) )

    
        let screenScale = Float( UIScreen.main.nativeScale )
        
        touchedPoint = float2( x * screenScale, y * screenScale )
        
        
        let image = presentingView.snapshot(view: presentingView)
        
        self.parentView.addSubview(self.view)
        self.view.frame =  presentingView.bounds
        self.view.isOpaque = false
        
        do {
            
            self.texture = try RealityTap.buildTextureImage(image:image, self.device)
            
        }
        
        catch {
            
            print("Unable to load texture from main bundle")
            
        }
        
        
    }
    


        
    
    // MARK: - MTKViewDelegate
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    
    func draw(in metalView: MTKView) {
        
        if let drawable = view.currentDrawable {
            
            let commandBuffer = queue!.makeCommandBuffer()
            let commandEncoder = commandBuffer!.makeComputeCommandEncoder()
            commandEncoder!.setComputePipelineState(computePipelineState!)
        
            
            commandEncoder!.setTexture(drawable.texture, index: 0)
            commandEncoder!.setTexture(texture, index: 1)
            
           
            commandEncoder!.setBuffer(touchedPointBuffer, offset: 0, index: 1)
            commandEncoder?.setBytes(&touchedPoint, length: MemoryLayout<float2>.stride * 2, index: 1)
            
            commandEncoder!.setBuffer(timerBuffer, offset: 0, index: 0)
            commandEncoder?.setBytes(&timer, length: MemoryLayout<Float>.stride * 2, index: 0)
            
            let timestep = 1.0 / TimeInterval(view.preferredFramesPerSecond)
            updateWithTimeStep(timestep)
            
            let threadGroupCount = MTLSizeMake(8, 8, 1)
            let threadGroups = MTLSizeMake(drawable.texture.width / threadGroupCount.width, drawable.texture.height / threadGroupCount.height, 1)
            
            commandEncoder!.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
            commandEncoder!.endEncoding()
            commandBuffer?.present(drawable)
            
            commandBuffer!.commit()
                

                
            }
            
        }
        
        
    
    
    // MARK: - RealityViewDelegate
    // MARK: todo: handle touches so we don't have to require gesture recognizer in API
    func realityViewDidBeginReceiving(touches: Set<UITouch>, withEvent: UIEvent?) {

    }
    

    
    
    
    // MARK: - Utility
    
    class func buildTextureImage(image:UIImage, _ device: MTLDevice) throws -> MTLTexture {
        
        let texutreLoader = MTKTextureLoader(device: device)
        return try texutreLoader.newTexture(cgImage: image.cgImage!, options: [MTKTextureLoader.Option.SRGB: false])
    }
    
    
    func updateWithTimeStep(_ timestep: TimeInterval) {
        time = time + timestep
        timer = Float(time)
        let bufferPointer = timerBuffer!.contents()
        memcpy(bufferPointer, &timer, MemoryLayout<Float>.size)
        
        if time > 1 {
            cleanUp()
        }
    }


    // MARK: todo: clean up in Metal way
    func cleanUp() {
        if self.view.superview != nil {
            self.view.removeFromSuperview()
        }
        
        
        
        
    }

    

}



private var rendererKey: UInt8 = 0
extension UIView {
    
    func snapshot(view: UIView) -> UIImage {
         UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
         let snapshot = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()

        return snapshot!
    }
    
    // if we want a cutout from view
    var renderer: UIGraphicsImageRenderer! {
        get {
            guard let rendererInstance = objc_getAssociatedObject(self, &rendererKey) as? UIGraphicsImageRenderer else {
                self.renderer = UIGraphicsImageRenderer(bounds: bounds)
                return self.renderer
                
            }
            return rendererInstance}
        set(newValue) {
            objc_setAssociatedObject(self, &rendererKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
     // if we want a cutout from view
    func imageView() -> UIImageView {
           let img:UIImage = renderer.image { ctx in
            
              layer.render(in: ctx.cgContext)
           }
           let imageView:UIImageView = UIImageView(image: img)
           imageView.frame = renderer.format.bounds

           return imageView
       }
    
    
     // if we want a cutout from view
    func jpegData() -> Data {
        let jpegData:Data = renderer.jpegData(withCompressionQuality: 0.6, actions: { (ctx) in
            layer.render(in: ctx.cgContext)
            
        })
        return jpegData
        
    }
    
}

