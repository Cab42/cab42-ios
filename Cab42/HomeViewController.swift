//
//  HomeViewController.swift
//  Cab42
//
//  Created by James Dacombe on 16/11/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func logOutAction(sender: AnyObject) {
        print("logOutAction...")
        if Auth.auth().currentUser != nil {
            do {
                print("there is a current user...")
                FBSDKAccessToken.setCurrent(nil)
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
                
                GIDSignIn.sharedInstance().signOut()
                
                try Auth.auth().signOut()
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login")
                present(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                print ("Error signing out: %@", error.localizedDescription)
            }
        }
    }
}
