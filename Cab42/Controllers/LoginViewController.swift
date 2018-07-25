//
//  LoginViewController.swift
//  Cab42
//
//  Created by Andres Margendie on 22/07/2018.
//  Copyright © 2018 AppCoda. All rights reserved.
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
    
    //Login Action using Gmail
    @IBAction func btnGoogleSignInPressed(_ sender: Any) {
         GIDSignIn.sharedInstance().signIn()
    }
    
    //Login Action using Facebook
    @IBAction func btnFacebookSignInPressed(_ sender: Any) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
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
                    
                    return
                }
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainView")
                self.present(vc!, animated: true, completion: nil)
                
            })
            
        }
        
        fbLoginManager.logOut()
 
        
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
                        //Go to the MainViewViewController if the login is sucessful
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainView")
                        self.present(vc!, animated: true, completion: nil)
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
    }
        
}


