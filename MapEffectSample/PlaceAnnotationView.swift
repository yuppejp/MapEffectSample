//
//  PlaceAnnotationView.swift
//  MapEffectSample
//

import Foundation
import UIKit
import MapKit

class PlaceAnnotation: MKPointAnnotation {
    let index: String
    var name: String
    var image: UIImage
    var latitude: Double
    var longitude: Double

    init(index: Int, name: String, image: UIImage, latitude: Double, longitude: Double) {
        self.index = index.description
        self.name = name
        self.image = image
        self.latitude = latitude
        self.longitude = longitude
    }
}


final class PlaceAnnotationView: MKAnnotationView {
    //@IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        //centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
        loadFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        loadFromNib()
    }

    private func loadFromNib() {
//        let nib = R.nib.placeAnnotationView
//        guard let view = nib.instantiate(withOwner: self).first as? UIView else { return }
//        view.frame = bounds
//        addSubview(view)

        // Since File's Owner is set to XibView, owner becomes self
        guard let view = UINib(nibName: "PlaceAnnotationView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        
        // Adjust the size of the view read from XIB to the view of the custom view class
        view.frame = bounds

        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
    }
}

