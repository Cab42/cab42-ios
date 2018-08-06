//
//  AppDelegate.swift
//  Cab42
//
//  Created by Andres Margendie on 22/07/2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if error != nil {
            print ("Error signing out: %@", error!.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
            if  error != nil {
                print ("Error signing out: %@", error!.localizedDescription)
                return
            }else{
                //Print into the console if successfully logged in
                print("You have successfully logged in using google account")
                
                let isNewUser = user?.additionalUserInfo?.isNewUser
                let userInfo = user?.user
                let userLoged = self.getUserLoged(user: userInfo!,isNewUser: isNewUser!)

                print(userLoged.getName())
                //Go to the MianViewController if the login is sucessful
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nav = storyboard.instantiateViewController(withIdentifier: "Home") as! UINavigationController
                let vc = nav.topViewController as! HomeViewController
                vc.user = userLoged
                self.window!.rootViewController = nav
            }
        }
    }
    
    private func getUserLoged(user: Firebase.User, isNewUser: Bool ) -> User{
        let userLoged = User(userInfo: user, isNewUser: isNewUser)
        return userLoged
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        GIDSignIn.sharedInstance().signOut()
        try! Auth.auth().signOut()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.window!.rootViewController = storyboard.instantiateViewController(withIdentifier: "Login")
    }
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
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

