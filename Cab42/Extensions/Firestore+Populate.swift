//
//  Firestore+Populate.swift
//  Cab42
//
//  Created by Andres Margendie on 17/08/2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import FirebaseFirestore

extension Firestore {
    
    /// Returns a reference to the top-level users collection.
    var users: CollectionReference {
        return self.collection("users")
    }
    
    /// Returns a reference to the top-level restaurants collection.
    var groups: CollectionReference {
        return self.collection("groups")
    }

    /// Returns a reference to the top-level restaurants collection.
    var groupsActive: Query {
        return self.collection("groups").whereField("active", isEqualTo: true)
            .limit(to: 5)
    }

}
