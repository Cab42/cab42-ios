//
//  UserProfile.swift
//  Cab42
//
//  Created by Andres Margendie on 23/07/2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit

class UserProfile: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var profilePicture: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicture.roundedImage()
    }
    
}
