//
//  Group.swift
//  Cab42
//
//  Created by Andres Margendie on 30/07/2018.
//  Copyright © 2018 Margendie Consulting LDT. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class Group: NSObject {
    var groupId: String = ""
    var destination: String
    var postalCode: String = ""
    var locality: String
    var maxPassengers: String = "10"
    var members = [Member]()
    var location: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    var originGeoPoint: GeoPoint?
    var destinationGeoPoint: GeoPoint?

    
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
    
    private func membersDescripcion() -> String{
        var description = ""
        self.members.forEach { member in
            description = description + ". " + member.description
        }
        return description
    }
    
    
     override var description: String { return "Destination: \(destination). maxPassengers: \(maxPassengers). Members: [\(membersDescripcion())]" }
    
    
}

extension Group{
    convenience init?(dictionary: [String : Any], groupId: String) {
        guard
            let destination = dictionary["destination"] as? String,
            let maxPassengers = dictionary["maxPassengers"] as? String,
            let members  = dictionary["members"] as? [[String:AnyObject]]
            else {
                return nil
            }
        
        let membersList = members.map { Member(userId: $0["userId"] as? String ?? "",
                                               memberName : $0["memberName"] as? String ?? "",
                                               passengers : $0["passengers"] as? Int ?? 1,
                                               suitcases : $0["suitcases"] as? Int ?? 0) }

        self.init(groupId: groupId, destination: destination, maxPassengers: maxPassengers,members: membersList)
    }
}

/*
extension Group: FirestoreModel {
    
    var documentID: String! {
        return groupId
    }
    
   
    convenience init?(modelData: FirestoreModelData) {
        try? self.init(
            groupId: modelData.documentID,
            destination: modelData.value(forKey: "destination"),
            maxPassengers: modelData.value(forKey: "maxPassengers"),
            members: modelData.value(forKey: "members")
        )
    }
}
 */
