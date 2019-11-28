RealityTap
==================

Let's learn [Metal](https://developer.apple.com/metal/) shaders in the context of a typical UIKit interaction. The repo will be updated with new shaders, feel free to contribute.🤘

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
