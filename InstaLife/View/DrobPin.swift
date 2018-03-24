//
//  DrobPin.swift
//  InstaLife
//
//  Created by SherifShokry on 3/17/18.
//  Copyright © 2018 SherifShokry. All rights reserved.
//

import Foundation
import MapKit


class DrobPin: NSObject , MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var identifier : String
     init(coordinate: CLLocationCoordinate2D , identifier : String ) {
        self.coordinate = coordinate
        self.identifier = identifier
    }
    
}
