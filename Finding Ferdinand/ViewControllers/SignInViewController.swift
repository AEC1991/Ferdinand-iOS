//
//  SignInViewController.swift
//  Ferdinand
//
//  Created by alex on 3/21/18.
//  Copyright © 2018 Hamal Labs. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import FBSDKLoginKit
import FacebookLogin
import Firebase
import GoogleSignIn
import FacebookCore
import SwiftyJSON


class SignInViewController: BaseViewController, GIDSignInUIDelegate, GIDSignInDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
#if DEBUG // KKK
//        txtEmail.text = "as259532@gmail.com"
//        txtPassword.text = "ff1234"
#endif
    }
    
    @IBAction func onFBSignInBtnClicked(_ sender: Any) {
        self.startIndicator()
        
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { (result) in
            switch result {
            case .failed(let error):
                self.stopIndicator()
                print(error)
            case .cancelled:
                self.stopIndicator()
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                self.getFBUserDataWithFirebase()
            }
        }
    }
    
    @IBAction func onGoogleSignInBtnClicked(_ sender: Any) {
        self.startIndicator()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func onSignInBtnClicked(_ sender: Any) {
        let email = txtEmail.text!
        let password = txtPassword.text!
        
        if (email.isEmpty) {
            Tools.showAlert(self, "Error", "Please input email")
            return
        }
        
        if (password.isEmpty) {
            Tools.showAlert(self, "Error", "Please input valid passwords")
            return
        }
        
        self.startIndicator()
        WebService.login(email, password, completion: { successed, json in
            self.stopIndicator()
            
            if successed == false {
                return
            }
            
            let dataJson = json["data"] as JSON
            let customerAccessTokenCreate = dataJson["customerAccessTokenCreate"] as JSON
            let customerAccessToken = customerAccessTokenCreate["customerAccessToken"] as JSON
            let accessToken = customerAccessToken["accessToken"].stringValue
            
            print("\(accessToken)")
            
            if (!accessToken.isEmpty) {
                PrefHelper.setUserEmail(email)
                self.setRootVCForMain()
            }
        })
    }
    
    @IBAction func onForgotBtnClicked(_ sender: Any) {
        self.setRootVCForMain()
        
//        let email = txtEmail.text!
//        if (email.isEmpty) {
//            Tools.showAlert(self, "Error", "Please input email")
//            return
//        }
//
//        self.startIndicator()
//        WebService.forgotPassword(email, completion: { successed, json in
//            self.stopIndicator()
//
//            if successed == false {
//                Tools.showAlert(self, "Error", "Invalid email")
//                return
//            }
//
//            Tools.showAlert(self, "", "forgot password email was sent.")
//        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (textField == txtEmail) {
            txtPassword.becomeFirstResponder()
        } else if (textField == txtPassword) {
            textField.resignFirstResponder()
        }
        
        return false
    }
    
    func setRootVCForMain () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.window?.rootViewController = vc
    }
        
    func getFBUserDataWithFirebase() {
        guard let authenticationToken = AccessToken.current?.authenticationToken else {return}
        //let authenticationToken1 = FBSDKAccessToken.current().tokenString
        
        let credential = FacebookAuthProvider.credential(withAccessToken: authenticationToken)
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            self.stopIndicator()
            if let error = error {
                print(error)
                return
            }
            
            // User is signed in
            let email = authResult?.user.email
            let firstname = authResult?.user.displayName
            let uid = authResult?.user.uid
            print(email)
            
            PrefHelper.setUserEmail(email!)
            self.setRootVCForMain()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        self.stopIndicator()
        if let error = error {
            print("\(error.localizedDescription)")
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        let userId = user.userID                  // For client-side use only!
        let idToken = user.authentication.idToken // Safe to send to the server
        let fullName = user.profile.name
        let givenName = user.profile.givenName
        let familyName = user.profile.familyName
        let email = user.profile.email
        
        PrefHelper.setUserEmail(email!)
        self.setRootVCForMain()
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
//    func signOut() {
//        let firebaseAuth = Auth.auth()
//        do {
//            try firebaseAuth.signOut()
//        } catch let signOutError as NSError {
//            print ("Error signing out: %@", signOutError)
//        }
//    }

}


