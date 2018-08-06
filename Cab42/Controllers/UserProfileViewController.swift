//
//  UserProfileViewController.swift
//  Cab42
//
//  Created by Andres Margendie on 23/07/2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePicture: UIImageView!
    
    var keys: [String] = []
    var values: [String?] = []
    let cellIdentifier = "cellIdentifier"
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicture.roundedImage()
        
        keys = ["","Full Name", "Email","Change Password"]
        values = ["",user?.getName(), user?.getEmail(), ">"]
        
        if let url = user?.getPhotoURL() {
            profilePicture.contentMode = .scaleAspectFit
            downloadImage(url: url)
        }
        
    }
    
    private func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    private func downloadImage(url: URL) {
        print("Download Started")
        self.getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.profilePicture.image = UIImage(data: data)
            }
        }
    }
    
}

extension UserProfileViewController : UITableViewDataSource, UITableViewDelegate {
    
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

}




