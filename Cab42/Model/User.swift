//
//  User.swift
//  Cab42
//
//  Created by Andres Margendie on 04/08/2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import Firebase

class User: NSObject {
    
    var userId: String = ""
    var isNewUser: Bool = false
    
    var userInfo: Firebase.User?
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    init(userInfo: Firebase.User, isNewUser: Bool ) {
        self.userInfo = userInfo
        self.isNewUser = isNewUser
        self.name = userInfo.displayName!
    }

    func getEmail () -> String{
        if let email = userInfo?.email {
            return email
        } else {
            return ""
        }
    }
    
    func getUserId () -> String{
        if let uid = userInfo?.uid {
            return uid
        } else {
            return ""
        }
    }
    
    func getPhotoURL () -> URL{
        return (userInfo?.photoURL)!
    }
    
    func getName () -> String{
        return name
    }
    
    func getPhoneNumber () -> String{
        return (userInfo?.phoneNumber)!
    }

    func getProviderID () -> String{
        if let providerID = userInfo?.providerID {
            return providerID
        } else {
            return ""
        }
    }
    
}

