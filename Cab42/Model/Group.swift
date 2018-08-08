//
//  Group.swift
//  Cab42
//
//  Created by Andres Margendie on 30/07/2018.
//  Copyright © 2018 Margendie Consulting LDT. All rights reserved.
//

import UIKit
import CoreLocation

class Group: NSObject {
    var groupId: String = ""
    var destination: String
    var origin: String = ""
    var postalCode: String = ""
    var locality: String
    var maxPassengers: String = "10"
    var members = [Member]()
    var location: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    
    
    var dictionary: [String: Any] {
        return [
            "destination": destination,
            "locality": locality,
            "maxPassengers": maxPassengers,
            "members": members,
            "location": location
        ]
    }
    
    init(destination: String) {
        self.destination = destination
        self.locality = "Milton Keynes"
    }
    
    init(destination: String, locality: String) {
        self.destination = destination
        self.locality = locality
    }
    
    init(groupId: String, destination: String, maxPassengers: String) {
        self.groupId = groupId
        self.destination = destination
        self.locality = "Milton Keynes"
        self.maxPassengers = maxPassengers
    }
    
    
    init(groupId: String, destination: String, maxPassengers: String, members: [Member]) {
        self.groupId = groupId
        self.destination = destination
        self.locality = "Milton Keynes"
        self.maxPassengers = maxPassengers
        self.members = members
    }
    
    override var description: String { return "Destination: \(destination). maxPassengers: \(maxPassengers)." }
    
    /*
     override var description: String { return "Destination: \(destination). maxPassengers: \(maxPassengers). Members: [\(members.joined(separator: ", "))]" }
     */
    
}

extension Group{
    convenience init?(dictionary: [String : Any], groupId: String) {
        guard
            let destination = dictionary["destination"] as? String,
            let maxPassengers = dictionary["maxPassengers"] as? String,
            let members = dictionary["members"] as? [AnyObject]
            else {
                return nil
            }
        for m in members {
            print(m["userId"])
        }
        let membersList = members.map { Member(userId: $0["userId"] as? String ?? "",
                                               memberName : $0["memberName"] as? String ?? "",
                                               passengers : $0["passengers"] as? Int ?? 1,
                                               suitcases : $0["suitcases"] as? Int ?? 0) }

        self.init(groupId: groupId, destination: destination, maxPassengers: maxPassengers,members: membersList)
        //
    }
}
