//
//  ViewController.swift
//  MapEffectSample
//

import UIKit
import MapKit

class ViewController: UIViewController {
    var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var tapAreaView: TapAreaView!
    var isLoadingMap = false
    var isRenderingMap = false
    var lastTapPoint = CGPoint(x: 0, y: 0)
    var lastEventTimestamp: TimeInterval = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapKit()
        setupZoomArea(rect: view.bounds)
    }
    
    private func setupMapKit() {
        // Generating mapView
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        mapView.delegate = self
        mapView.showsBuildings = true
        mapView.showsScale = true
        mapView.showsCompass = true
        //mapView.showsUserLocation = true
        self.view.addSubview(mapView)
        
        // Location manager setup
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // Adjust location to Tokyo station
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let coordinate = CLLocationCoordinate2DMake(35.681236, 139.767125)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.region = region
        
        // Image to display on pin (cut out with speech bubble image)
        let sourceImage = UIImage(named: "profile1")
        let maskImage = UIImage(named: "balloon_mask")
        let image = sourceImage?.masking(maskImage: maskImage)
        
        // generate pin
        let pin = PlaceAnnotation(index: 1, name: "name1", image: image!, latitude: 35.681236, longitude: 139.767125)
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
        
        // Callback for detecting drag
        let tapInterceptor = GlobalGestureRecognizer(target: nil, action: nil)
        tapInterceptor.touchesBeganCallback = { touches, event in
            let touchPoint = touches.first?.location(in: self.view) ?? CGPoint()
            self.lastTapPoint = touchPoint

            var x = self.view.bounds.width * 0.2
            let hitLeftRect = CGRect(x: 0, y: 0, width: x, height: self.view.bounds.height)

            x = self.view.bounds.width * 0.8
            let hitRightRect = CGRect(x: x, y: 0, width: self.view.bounds.width - x, height: self.view.bounds.height)
            
            if hitLeftRect.contains(touchPoint) || hitRightRect.contains(touchPoint){
                self.mapView.isScrollEnabled = false
                self.tapAreaView.showArea(touchPoint: touchPoint)
            }
        }
        tapInterceptor.touchesMovedCallback = { touches, event in
            if !self.tapAreaView.isHidden {
                self.tapAreaView.moveAreaWithCallback(touches: touches, event: event)
            }
        }
        tapInterceptor.touchesEndedCallback = { touches, event in
            if !self.tapAreaView.isHidden {
                self.mapView.isScrollEnabled = true
                self.tapAreaView.hideArea()
            }
        }
        mapView.addGestureRecognizer(tapInterceptor)
    }

    private func setupZoomArea(rect: CGRect) {
        let drawView = TapAreaView(frame: rect)
        drawView.hideArea()
        self.view.addSubview(drawView)
        self.tapAreaView = drawView

        drawView.touchesBeganCallback = { touches, event in
            //print("*** touchesBegan latitudeDelta: \(self.mapView.region.span.latitudeDelta), longitudeDelta: \(self.mapView.region.span.longitudeDelta)")
            self.mapView.isScrollEnabled = false
            self.lastTapPoint = touches.first?.location(in: self.mapView) ?? CGPoint()
        }
        drawView.touchesEndedCallback = { touches, event in
            self.mapView.isScrollEnabled = true
        }
        drawView.touchesMovedCallback = { touches, event in
            //print("*** touchesMovedCallback: timestamp: \(event.timestamp)")
            if self.isLoadingMap || self.isRenderingMap {
                return
            }
            if self.mapView.isScrollEnabled {
                return
            }
            if event.timestamp - self.lastEventTimestamp < 0.1 {
                return
            }
            self.lastEventTimestamp = event.timestamp
            
            let tapPoint = touches.first?.location(in: self.mapView) ?? CGPoint()
            let deltaX = self.lastTapPoint.x - tapPoint.x
            let deltaY = self.lastTapPoint.y - tapPoint.y
            self.lastTapPoint = tapPoint
            
            var zoomValue = 2.0
            if abs(deltaX) > abs(deltaY) {
                if abs(deltaX) < 3 {
                    return
                }
                if deltaX < 0 {
                    zoomValue *= -1
                }
            } else {
                if abs(deltaY) < 3 {
                    return
                }
                if deltaY < 0 {
                    zoomValue *= -1
                }
            }
            
            self.zoomMap(zoomValue: zoomValue)
        }
    }
    
    private func zoomMap(zoomValue: Double) {
        print("*** zoomValue: \(zoomValue)")
        var region: MKCoordinateRegion = self.mapView.region
        if zoomValue < 0 {
            region.span.latitudeDelta /= abs(zoomValue)
            region.span.longitudeDelta /= abs(zoomValue)
        } else {
            region.span.latitudeDelta *= zoomValue
            region.span.longitudeDelta *= zoomValue
        }
        
        if region.span.latitudeDelta < 0 || region.span.latitudeDelta > 30 {
            //region.span.latitudeDelta = self.mapView.region.span.latitudeDelta
            return
        }
        if region.span.longitudeDelta < 0 || region.span.longitudeDelta > 30 {
            //region.span.longitudeDelta = self.mapView.region.span.longitudeDelta
            return
        }
        
        //print("*** zoomMap \(region.span.latitudeDelta) -> \(region.span.latitudeDelta)")
        
        self.isRenderingMap = true
        self.mapView.setRegion(region, animated: true)
        
        // RenderingMap event may not occur, so clear it automatically
        // DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { // 3 seconds later
        //     self.isRenderingMap = false
        // }
    }
}

extension ViewController: CLLocationManagerDelegate {
    // delegate method to ask for permission
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            // Start acquiring current location
            //manager.startUpdatingLocation()
            //manager.requestLocation()
            break
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("fail to get location")
    }
}

extension ViewController: MKMapViewDelegate {
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        isLoadingMap = true
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        isLoadingMap = false
    }
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        isRenderingMap = true
    }

    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        isRenderingMap = false
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            // ignore UserLocation
            return nil
        }
        
        let annotationView = PlaceAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        if let annotation = annotation as? PlaceAnnotation {
            annotationView.imageView.image = annotation.image
        }
        return annotationView
    }
}

extension UIImage {
    func masking(maskImage: UIImage?) -> UIImage? {
        guard let maskImage = maskImage?.cgImage else {
            return nil
        }
        let mask = CGImage(maskWidth: maskImage.width,
                           height: maskImage.height,
                           bitsPerComponent: maskImage.bitsPerComponent,
                           bitsPerPixel: maskImage.bitsPerPixel,
                           bytesPerRow: maskImage.bytesPerRow,
                           provider: maskImage.dataProvider!,
                           decode: nil, shouldInterpolate: false)!
        guard let maskedImage = self.cgImage?.masking(mask) else {
            return nil
        }
        return UIImage(cgImage: maskedImage)
    }
}


//extension ViewController {
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("ViewController touchesBegan")
//
//        let touchPoint = touches.first?.location(in: view) ?? CGPoint()
//        let x = view.bounds.width / 4 * 3
//        let hitRect = CGRect(x: x, y: 0, width: view.bounds.width - x, height: view.bounds.height)
//        if hitRect.contains(touchPoint) {
//            mapView.isScrollEnabled = false
//            tapAreaView.showArea(touchPoint: touchPoint)
//        }
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesMoved(touches, with: event)
//        print("ViewController touchesMoved")
//
//        if !tapAreaView.isHidden {
//            tapAreaView.moveAreaWithCallback(touches: touches, event: event)
//        }
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("ViewController touchesEnded")
//
//        if !tapAreaView.isHidden {
//            mapView.isScrollEnabled = true
//            tapAreaView.hideArea()
//        }
//    }
//
//    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
//        print("touchesEstimatedPropertiesUpdated")
//    }
//}

