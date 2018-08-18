//
//  Group.swift
//  Cab42
//
//  Created by Andres Margendie on 30/07/2018.
//  Copyright © 2018 Margendie Consulting LDT. All rights reserved.
//

import FirebaseFirestore
import UIKit
import CoreLocation
import Firebase

/// A restaurant, created by a user.
struct Group {
    
    /// The ID of the restaurant, generated from Firestore.
    var documentID: String = ""
    
    var destination: String
    var active: Bool = true
    var locality: String = ""
    var maxPassengers: Int = 10
    var originGeoPoint: GeoPoint?
    var destinationGeoPoint: GeoPoint?
    var members = [Member]()
    
    var location: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    
    var geocoder = CLGeocoder()

}

// MARK: - Firestore interoperability

extension Group: DocumentSerializable {
    
    init(destination: String) {
        self.destination = destination
    }

    init(destination: String,
         active: Bool,
         locality: String,
         maxPassengers: Int,
         originGeoPoint: GeoPoint,
         destinationGeoPoint: GeoPoint,
         members: [Member]) {
        let document = Firestore.firestore().groups.document()
        
        self.init(documentID: document.documentID,
                  destination: destination,
                  active: active,
                  locality: locality,
                  maxPassengers: maxPassengers,
                  originGeoPoint: originGeoPoint,
                  destinationGeoPoint: destinationGeoPoint,
                  members: members,
                  location: kCLLocationCoordinate2DInvalid,
                  geocoder: CLGeocoder())

    }
    
    /// Initializes a restaurant from a documentID and some data, ostensibly from Firestore.
    private init?(documentID: String, dictionary: [String: Any]) {
        guard
            let destination = dictionary["destination"] as? String,
            let active = dictionary["active"] as? Bool,
            let locality = dictionary["locality"] as? String,
            let maxPassengers = dictionary["maxPassengers"] as? Int,
            let originGeoPoint = dictionary["originGeoPoint"] as? GeoPoint,
            let destinationGeoPoint = dictionary["destinationGeoPoint"] as? GeoPoint,
            let members  = dictionary["members"] as? [[String:AnyObject]]
            else { return nil }
        
        let membersList = members.map { Member(userId: $0["userId"] as? String ?? "",
                                               memberName : $0["memberName"] as? String ?? "",
                                               passengers : $0["passengers"] as? Int ?? 1,
                                               suitcases : $0["suitcases"] as? Int ?? 0) }
        
        self.init(documentID: documentID,
                  destination: destination,
                  active: active,
                  locality: locality,
                  maxPassengers: maxPassengers,
                  originGeoPoint: originGeoPoint,
                  destinationGeoPoint: destinationGeoPoint,
                  members: membersList,
                  location: kCLLocationCoordinate2DInvalid,
                  geocoder: CLGeocoder())
    }
    
    init?(document: QueryDocumentSnapshot) {
        self.init(documentID: document.documentID, dictionary: document.data())
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        self.init(documentID: document.documentID, dictionary: data)
    }
    
    /// The dictionary representation of the restaurant for uploading to Firestore.
    var documentData: [String: Any] {
        return [
            "destination": destination,
            "active": active,
            "locality": locality,
            "maxPassengers": maxPassengers,
            "members": membersDictionary(),
            "originGeoPoint": originGeoPoint!,
            "destinationGeoPoint": destinationGeoPoint!
        ]
    }

    var dictionary: [String: Any] {
        return [
            "destination": destination,
            "active": active,
            "locality": locality,
            "maxPassengers": maxPassengers,
            "members": membersDictionary(),
            "originGeoPoint": originGeoPoint!,
            "destinationGeoPoint": destinationGeoPoint!
        ]
    }

    
    private func membersDescripcion() -> String{
        var description = ""
        self.members.forEach { member in
            description = description + ". " + member.description
        }
        return description
    }
    
    private func membersDictionary() -> [[String: Any]]{
        var membersDictionary = [[String: Any]]()
        self.members.forEach { member in
            membersDictionary.append(member.dictionary)
        }
        return membersDictionary
    }
    
    var description: String { return "Destination: \(destination). maxPassengers: \(maxPassengers). Members: [\(membersDescripcion())]" }
    
    func originAddress() ->  [String: Any]{
        return frendlyAddress(latitude: (originGeoPoint?.latitude)!, longitude: (originGeoPoint?.longitude)!)
    }
    
    func destinationAddress() ->  [String: Any]{
        return frendlyAddress(latitude: (destinationGeoPoint?.latitude)!, longitude: (destinationGeoPoint?.longitude)!)
    }
    
    private func frendlyAddress(latitude: Double, longitude: Double) ->  [String: Any]{
        
        var frendlyAddress = [String: Any]()
        
        let l = CLLocation(latitude: latitude, longitude: longitude)
        geocoder.reverseGeocodeLocation(l) { (placemarks, error) in
            if let error = error {
                print("Unable to Reverse Geocode Location (\(error))")
                
            } else {
                if let placemarks = placemarks, let placemark = placemarks.first {
                    frendlyAddress["name"] =  placemark.name
                    frendlyAddress["subThoroughfare"] =  placemark.subThoroughfare
                    frendlyAddress["thoroughfare"] =  placemark.thoroughfare
                    frendlyAddress["postalCode"] =  placemark.postalCode
                    frendlyAddress["subLocality"] =  placemark.subLocality
                    frendlyAddress["locality"] =  placemark.locality
                    frendlyAddress["subAdministrativeArea"] =  placemark.subAdministrativeArea
                    frendlyAddress["administrativeArea"] =  placemark.administrativeArea
                    frendlyAddress["country"] =  placemark.country
                    print(frendlyAddress)
                } else {
                    print("No Matching Addresses Found")
                }
            }
        }
        return frendlyAddress
    }
}




