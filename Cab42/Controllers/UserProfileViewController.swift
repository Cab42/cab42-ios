//
//  UserProfileViewController.swift
//  Cab42
//
//  Created by Andres Margendie on 23/07/2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var keys: [String] = []
    var values: [String] = []

    @IBOutlet weak var tableView: UITableView!
    let cellIdentifier = "cellIdentifier"
    
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        // Fetch Fruit
        let key = keys[indexPath.row]
        let value = values[indexPath.row]

        // Configure Cell
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = value

        return cell
    }
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicture.roundedImage()

        keys = ["First Name", "Last Name", "Email", "Change Password"]
        values = ["Andres", "Margendie", "amargendie@gmail.com", ""]

    }
    
}
