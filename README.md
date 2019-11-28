RealityTap
==================

Add Metal powered effects to your taps.

![Effect 1](demo1.gif)
![Effect 2](demo2.gif)

#Usage

```
var metalRenderer: RealityTap!

...

@objc func handleTap(_ gesture: UITapGestureRecognizer) {


   metalRenderer = RealityTap(view: self.mapView, effect: .shockwave)
   metalRenderer.realityTap(presentingView: self.mapView, gestureRecognizer: gesture)

}


```
