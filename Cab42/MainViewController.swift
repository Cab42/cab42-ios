//
//  MainViewController.swift
//  Cab42
//
//  Created by Andres Margendie on 23/07/2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//
import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var trailingC: NSLayoutConstraint!
    
    @IBOutlet weak var leadingC: NSLayoutConstraint!
    
    var hamburgerMenuIsVisible = false
    
    @IBOutlet weak var ubeView: UIView!
    
    @IBAction func mainMenuPressed(_ sender: Any) {
        //if the hamburger menu is NOT visible, then move the ubeView back to where it used to be
        if !hamburgerMenuIsVisible {
            leadingC.constant = 200
            //this constant is NEGATIVE because we are moving it 150 points OUTWARD and that means -150
            trailingC.constant = -200
            
            //1
            hamburgerMenuIsVisible = true
        } else {
            //if the hamburger menu IS visible, then move the ubeView back to its original position
            leadingC.constant = 0
            trailingC.constant = 0
            
            //2
            hamburgerMenuIsVisible = false
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }) { (animationComplete) in
            print("The animation is complete!")
        }
  }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //here
    }
    
    
}
