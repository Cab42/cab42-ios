//
//  GroupsTableViewDataSource.swift
//  Cab42
//
//  Created by Andres Margendie on 16/08/2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit
import FirebaseFirestore

/// A class that populates a table view using RestaurantTableViewCell cells
/// with restaurant data from a Firestore query. Consumers should update the
/// table view with new data from Firestore in the updateHandler closure.
@objc class RestaurantTableViewDataSource: NSObject, UITableViewDataSource {
    
    private let groups: LocalCollection<Group>

    /// Returns an instance of RestaurantTableViewDataSource. Consumers should update the
    /// table view with new data from Firestore in the updateHandler closure.
    public init(groups: LocalCollection<Group>) {
        self.groups = groups
    }
    
    /// Returns an instance of RestaurantTableViewDataSource. Consumers should update the
    /// table view with new data from Firestore in the updateHandler closure.
    public convenience init(query: Query, updateHandler: @escaping ([DocumentChange]) -> ()) {
        let collection = LocalCollection<Group>(query: query, updateHandler: updateHandler)
        self.init(groups: collection)
    }
    
    /// Starts listening to the Firestore query and invoking the updateHandler.
    public func startUpdates() {
        groups.listen()
    }
    
    /// Stops listening to the Firestore query. updateHandler will not be called unless startListening
    /// is called again.
    public func stopUpdates() {
        groups.stopListening()
    }
    
    /// Returns the restaurant at the given index.
    subscript(index: Int) -> Group {
        return groups[index]
    }
    
    /// The number of items in the data source.
    public var count: Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantTableViewCell",
                                                 for: indexPath) as! CustomHeader
        let group = groups[indexPath.row]
        //cell.populate(group: group)
        print(group)
        return cell
    }
    
    
}
