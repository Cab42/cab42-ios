//
//  GroupViewController.swift
//  Cab42
//
//  Created by Andres Margendie on 22/07/2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passengersNumber: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.passengersNumber.delegate = self
        self.passengersNumber.becomeFirstResponder()
  }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }

}

