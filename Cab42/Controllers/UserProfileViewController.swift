//
//  UserProfileViewController.swift
//  Cab42
//
//  Created by Andres Margendie on 23/07/2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePicture: UIImageView!

    var keys: [String] = []
    var values: [String] = []
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
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = keys[indexPath.row]
        if value == "Change Password" {
            print(keys[indexPath.row])
            performSegue(withIdentifier: "segueChangePassword", sender: self)
        } else {
             print("no me interesa")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicture.roundedImage()

        keys = ["","First Name", "Last Name", "Email", "Change Password"]
        values = ["","Andres", "Margendie", "amargendie", ">"]

    }
    
}
