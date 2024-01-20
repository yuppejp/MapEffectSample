//
//  DrawView.swift
//  MapEffectSample
//

import UIKit

class TapAreaView: UIView {
    var touchesBeganCallback: ((Set<UITouch>, UIEvent) -> Void)?
    var touchesEndedCallback: ((Set<UITouch>, UIEvent) -> Void)?
    var touchesMovedCallback: ((Set<UITouch>, UIEvent) -> Void)?
    var isLeftArea = true
    
    private var parentRect: CGRect!
    private var drawRect: CGRect!
    private var touchPoint: CGPoint = CGPoint()
    
    override init(frame: CGRect) {
        parentRect = frame
        drawRect = frame
        
        super.init(frame: frame);
        self.backgroundColor = UIColor.clear;
        
        print("frame: \(frame.origin.x) \(frame.origin.y) \(frame.size.width) \(frame.size.height)")
        print("drawRect: \(drawRect.origin.x) \(drawRect.origin.y) \(drawRect.size.width) \(drawRect.size.height)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        var startPoint = CGPoint()
        var endPoint = CGPoint()
        var controlPoint = CGPoint()

        if isLeftArea {
            startPoint = CGPoint(x: 0, y: 0)
            endPoint = CGPoint(x: 0, y: parentRect.height)
            
            let deltaX = touchPoint.x
            controlPoint = touchPoint
            controlPoint.x += deltaX
        } else {
            startPoint = CGPoint(x: parentRect.width, y: 0)
            endPoint = CGPoint(x: parentRect.width, y: parentRect.height)
            
            let deltaX = parentRect.width - touchPoint.x
            controlPoint = touchPoint
            controlPoint.x -= deltaX
        }
        
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addQuadCurve(to: endPoint,
                          controlPoint: CGPoint(x: controlPoint.x, y: controlPoint.y))

        UIColor.black.withAlphaComponent(0.3).setFill()
        path.fill()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print("**** TapAreaView touchesBegan")
        let touch = touches.first!
        let location = touch.location(in: self)
        showArea(touchPoint: location)
        
        if let touchesBeganCallback {
            touchesBeganCallback(touches, event!)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print("**** TapAreaView touchesMoved")
        hideArea()
        
        if let touchesEndedCallback {
            touchesEndedCallback(touches, event!)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print("**** TapAreaView touchesMoved")
        let touch = touches.first!
        let location = touch.location(in: self)
        moveArea(touchPoint: location)
        
        if let touchesMovedCallback {
            touchesMovedCallback(touches, event!)
        }
    }
    
    func showArea(touchPoint: CGPoint) {
        let x = touchPoint.x
        self.drawRect = CGRect(x: x, y: parentRect.origin.y, width: parentRect.width - x, height: parentRect.height)
        self.touchPoint = touchPoint
        
        if x < (parentRect.width / 2) {
            isLeftArea = true
        } else {
            isLeftArea = false
        }
        
        setNeedsDisplay()
        layer.opacity = 0.9
    }
    
    func hideArea() {
        layer.opacity = 0.0
    }
    
    func moveArea(touchPoint: CGPoint) {
        let x = touchPoint.x
        self.drawRect = CGRect(x: x, y: parentRect.origin.y, width: parentRect.width - x, height: parentRect.height)
        self.touchPoint = touchPoint
        setNeedsDisplay()
    }
    
    func moveAreaWithCallback(touches: Set<UITouch>, event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        let x = location.x
        self.drawRect = CGRect(x: x, y: parentRect.origin.y, width: parentRect.width - x, height: parentRect.height)
        self.touchPoint = location
        setNeedsDisplay()
        
        if let touchesMovedCallback {
            touchesMovedCallback(touches, event!)
        }
    }
    
}
