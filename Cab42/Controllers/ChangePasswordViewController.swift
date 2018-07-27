//
//  ChangePasswordViewController.swift
//  Cab42
//
//  Created by Andres Margendie on 25/07/2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ChangePasswordViewController: UIViewController {

    
    @IBOutlet weak var currentPasswordlTextField: UITextField!
    @IBOutlet weak var newPasswordlTextField: UITextField!
    @IBOutlet weak var repeatPasswordlTextField: UITextField!
    
    @IBOutlet weak var changePasswordButton: UIButton!

    @IBAction func passwordChanging(_ sender: Any) {
        if ( !(self.currentPasswordlTextField.text?.isEmpty)!
            && !(self.newPasswordlTextField.text?.isEmpty)!
            && !(self.repeatPasswordlTextField.text?.isEmpty)!
            && (newPasswordlTextField.text?.elementsEqual(repeatPasswordlTextField.text!))! ){
            changePasswordButton.isEnabled = true
        }
      else{
            changePasswordButton.isEnabled = false
        }
    }
    
    
      @IBAction func changePasswordPressed(_ sender: Any) {
        
        
        let credential = EmailAuthProvider.credential(withEmail: (Auth.auth().currentUser?.email)!, password: currentPasswordlTextField.text!)

        Auth.auth().currentUser?.reauthenticateAndRetrieveData(with: credential) { authData, error in
            if error != nil{
                let alertController = UIAlertController(title: "Authentication fails", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }else{
                Auth.auth().currentUser?.updatePassword(to: self.newPasswordlTextField.text!) { (error) in
                    if error == nil{
                        let alertController = UIAlertController(title: "Password updated successfully", message: error?.localizedDescription, preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                            print("aguanta o que?")
                            self.goBack()
                        }
                        
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true, completion: nil)
                    }else{
                        let alertController = UIAlertController(title: "Password updating fails", message: error?.localizedDescription, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)

                    }
                }
            }
         }
     }
    
    private func goBack() {
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
        //self.navigationController?.popToRootViewController(animated: true)
        //self.performSegue(withIdentifier: "segueBackToUserProfile", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentPasswordlTextField.becomeFirstResponder()
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  
}
