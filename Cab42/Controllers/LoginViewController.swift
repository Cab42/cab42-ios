//
//  LoginViewController.swift
//  Cab42
//
//  Created by Andres Margendie on 22/07/2018.
//  Copyright © 2018 Margendie Consulting LDT. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    //Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var btnGoogleSignIn: UIButton!
    @IBOutlet weak var btnFacebookSignIn: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Login Action using Gmail
    @IBAction func btnGoogleSignInPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        GIDSignIn.sharedInstance().signIn()
    }
    
    //Login Action using Facebook
    @IBAction func btnFacebookSignInPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                self.activityIndicator.stopAnimating()
               return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                self.activityIndicator.stopAnimating()
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signInAndRetrieveData(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    self.activityIndicator.stopAnimating()

                    return
                }
                let isNewUser = user?.additionalUserInfo?.isNewUser
                let userInfo = user?.user
                let userLoged = self.getUserLoged(user: userInfo!,isNewUser: isNewUser!)
                
                let nav = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! UINavigationController
                let vc = nav.topViewController as! HomeViewController
                vc.user = userLoged

                self.activityIndicator.stopAnimating()
                self.present(nav, animated: true, completion: nil)
                
            })
            self.activityIndicator.stopAnimating()

        }
        //fbLoginManager.logOut()
    }
    private func getProviderId(user: Firebase.User) -> String {
        var id = ""
        for p in user.providerData {
            switch p.providerID {
            case "facebook.com":
                print("user is signed in with facebook")
                id = "facebook.com"
            case "google.com":
                print("user is signed in with google")
                id = "google.com"
            default:
                print("user is signed in with \(p.providerID)")
                id = "password"
            }
        }
        return id
    }

    private func getUserLoged(user: Firebase.User, isNewUser: Bool ) -> User{
        let providerID = getProviderId(user: user)
        let userLoged = User(userId: user.uid, name: user.displayName ?? "", email: user.email!, photoURL: user.photoURL ?? URL(string: "default")!, providerID: providerID)
        return userLoged
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        //Create the gmail login button look/feel
        GIDSignIn.sharedInstance().uiDelegate = self
        
        emailTextField.rightViewMode = UITextFieldViewMode.always
        let emailImageView = UIImageView(frame: CGRect(x: 0, y: -5, width: 20, height: 20))
        let emailImage = UIImage(named: "icon-email")
        emailImageView.image = emailImage
        emailTextField.rightView = emailImageView
        
        passwordTextField.rightViewMode = UITextFieldViewMode.always
        let passwordImageView = UIImageView(frame: CGRect(x: -5, y: 0, width: 40, height: 20))
        let passwordImage = UIImage(named: "lock-icon")
        passwordImageView.image = passwordImage
        passwordTextField.rightView = passwordImageView

        self.emailTextField.becomeFirstResponder()
        
    }
    
    
    //Login Action using email and password
    @IBAction func loginAction(_ sender: AnyObject) {
        activityIndicator.startAnimating()
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields because they didn't fill anything in
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                if error == nil {
                    if (Auth.auth().currentUser?.isEmailVerified)! {
                        //Print into the console if successfully logged in
                        print("You have successfully logged in")
                        //Go to the HomeViewController if the login is sucessful
                        
                        let isNewUser = user?.additionalUserInfo?.isNewUser
                        let userInfo = user?.user
                        let userLoged = self.getUserLoged(user: userInfo!,isNewUser: isNewUser!)
                        let db = Firestore.firestore()
                        let docRef = db.collection("users").document((userInfo?.uid)!)
                        
                        docRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                let userData = document.data()
                                
                                userLoged.name = (userData!["name"] as? String)!
                                userLoged.photoURL = URL (string: (userData!["photoURL"] as? String)!)!
                                
                                print("Document data1: \(String(describing: userData))")
                            } else {
                                print("Document does not exist")
                            }
                        }

                        let nav = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! UINavigationController
                        let vc = nav.topViewController as! HomeViewController
                        vc.user = userLoged
                        self.present(nav, animated: true, completion: nil)

                        
                    } else{
                        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                            var title = ""
                            var message = ""
                            if error != nil {
                                title = "Error!"
                                message = (error?.localizedDescription)!
                            } else {
                                title = "Oops!"
                                message = "Please, verify your email."
                                self.emailTextField.text = ""
                                self.passwordTextField.text = ""
                            }
                            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                            
                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertController.addAction(defaultAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                        })
                    }
                } else {
                     print("Email or Password wrong")
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        activityIndicator.stopAnimating()
    }
        
}


