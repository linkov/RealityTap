RealityTap
==================

The goal was to start learning Metal shaders in the context of a usual UIKit interaction. The repo will be updated with new shaders and more robust code, feel free to contribute.

![Effect 1](demo1.gif) ![Effect 2](demo2.gif)

#Usage

```
var metalRenderer: RealityTap!

...

@objc func handleTap(_ gesture: UITapGestureRecognizer) {


   metalRenderer = RealityTap(view: self.mapView, effect: .shockwave)
   metalRenderer.realityTap(presentingView: self.mapView, gestureRecognizer: gesture)

}


```
