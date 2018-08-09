//
//  Member.swift
//  Cab42
//
//  Created by Andres Margendie on 06/08/2018.
//  Copyright © 2018 Margendie Consulting LDT. All rights reserved.
//

import Foundation

import UIKit
import CoreLocation

class Member: NSObject {
    var memberName: String
    var userId: String
    var passengers: Int = 1
    var suitcases: Int = 0
    
    init(userId: String, memberName: String) {
        self.userId = userId
        self.memberName = memberName
    }
    
    init(userId: String, memberName: String, passengers: Int, suitcases: Int ) {
        self.userId = userId
        self.memberName = memberName
        self.passengers = passengers
        self.suitcases = suitcases
    }

    override var description: String { return "Name: \(memberName). Passengers: \(passengers). Suitcases: \(suitcases)." }
}

extension Member{
    convenience init?(dictionary: [String : Any]) {
        guard
            let userId = dictionary["userId"] as? String,
            let memberName = dictionary["memberName"] as? String,
            let passengers = dictionary["passengers"] as? Int,
            let suitcases = dictionary["suitcases"] as? Int
            else {
                return nil
                
        }
        self.init(userId: userId, memberName: memberName, passengers: passengers, suitcases: suitcases)
    }
}
