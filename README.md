RealityTap
==================

Add Metal powered effects to your taps.


#Usage

```
var metalRenderer: RealityTap!

...

@objc func handleTap(_ gesture: UITapGestureRecognizer) {


   metalRenderer = RealityTap(view: self.mapView, effect: .shockwave)
   metalRenderer.realityTap(presentingView: self.mapView, gestureRecognizer: gesture)

}


```
