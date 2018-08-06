//
//  CreateGroupAnnotation.swift
//  SearchDestination
//
//  Created by Andres Margendie on 31/07/2018.
//  Copyright © 2018 mc. All rights reserved.
//

import UIKit
import MapKit

class CreateGroupAnnotation: NSObject, MKAnnotation {

    var group: Group
    var coordinate: CLLocationCoordinate2D { return group.location }
    
    init(group: Group) {
        self.group = group
        super.init()
    }
    
    var title: String? {
        return group.destination
    }
    
    var subtitle: String? {
        return group.locality
    }
}
