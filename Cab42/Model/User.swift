//
//  User.swift
//  Cab42
//
//  Created by Andres Margendie on 04/08/2018.
//  Copyright © 2018 Margendie Consulting LDT. All rights reserved.
//

import Firebase

class User: NSObject {
    
    var userId: String
    var isNewUser: Bool = false
    var name: String = ""
    
    var email: String = ""
    var photoURL: URL = URL(string: "default")!
    var providerID: String = ""
    var phoneNumber: String = ""
    var address: String = ""
    
    init(userId: String) {
        self.userId = userId
    }
    
    init(userId: String, name: String, email: String, photoURL: URL, providerID: String) {
        self.userId = userId
        self.name = name
        self.email = email
        self.photoURL = photoURL
        self.providerID = providerID
    }
    
    func getEmail () -> String{
        return email
    }
    
    func getUserId () -> String{
        return userId
    }
    
    func getPhotoURL () -> URL{
        return photoURL
    }
    
    func getName () -> String{
        return name
    }
    
    func getPhoneNumber () -> String{
        return phoneNumber
    }
    
    func getProviderID () -> String{
        return providerID
    }
    
}

