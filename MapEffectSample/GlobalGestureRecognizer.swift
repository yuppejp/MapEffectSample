//
//  GlobalGestureRecognizer.swift
//  MapEffectSample
//

import UIKit

// REF: How to intercept touches events on a MKMapView or UIWebView objects?
// https://stackoverflow.com/questions/1049889/how-to-intercept-touches-events-on-a-mkmapview-or-uiwebview-objects

class GlobalGestureRecognizer: UIGestureRecognizer {
    var touchesBeganCallback: ((Set<UITouch>, UIEvent) -> Void)?
    var touchesEndedCallback: ((Set<UITouch>, UIEvent) -> Void)?
    var touchesMovedCallback: ((Set<UITouch>, UIEvent) -> Void)?

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        self.cancelsTouchesInView = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        //print("*** GlobalGestureRecognizer touchesBegan")
        super.touchesBegan(touches, with: event)
        
        if let touchesBeganCallback {
            touchesBeganCallback(touches, event)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        //print("*** GlobalGestureRecognizer touchesEnded")
        super.touchesEnded(touches, with: event)

        if let touchesEndedCallback {
            touchesEndedCallback(touches, event)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        //print("*** GlobalGestureRecognizer touchesMoved")
        super.touchesMoved(touches, with: event)

        if let touchesMovedCallback {
            touchesMovedCallback(touches, event)
        }
    }

    override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    override func canBePrevented(by preventingGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

