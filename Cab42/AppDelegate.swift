//
//  AppDelegate.swift
//  Cab42
//
//  Created by Andres Margendie on 22/07/2018.
//  Copyright © 2018 Margendie Consulting LDT. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FirebaseFirestore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
        
    private func getProviderId(user: Firebase.User) -> String {
        for p in user.providerData {
            switch p.providerID {
            case "facebook.com":
                print("user is signed in with facebook")
                return "facebook.com"
            case "google.com":
                print("user is signed in with google")
                return "google.com"
            default:
                print("user is signed in with \(p.providerID)")
                return "password"
            }
        }
        return ""
    }
    
    private func getUserLoged(user: Firebase.User, isNewUser: Bool ) -> User{
        let providerID = getProviderId(user: user)
        let userLoged = User(userId: user.uid, name: user.displayName ?? "", email: user.email!, photoURL: user.photoURL ?? URL(string: "default")!, providerID: providerID)
        return userLoged
    }
    

    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if Auth.auth().currentUser == nil {
            print("NO USER") // this does print out in the console before the app crashes
            let vc = storyboard.instantiateViewController(withIdentifier: "Login")
            self.window!.rootViewController = vc
            
        } else {
            print("USER ALREADY LOGED") // this does print out in the console before the app crashes
            let userInfo = Auth.auth().currentUser
            let userLoged = self.getUserLoged(user: userInfo!, isNewUser: false)
            
            let nav = storyboard.instantiateViewController(withIdentifier: "Home") as! UINavigationController
            let vc = nav.topViewController as! HomeViewController
            if (userLoged.providerID == "password"){
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
            }
            vc.user = userLoged
            self.window!.rootViewController = nav

        }
        
        
        return true
    }
    
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url as URL?, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

