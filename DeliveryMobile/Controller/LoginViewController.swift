//
//  LoginViewController.swift
//  DeliveryMobile
//
//  Created by Cuong Pham on 2/27/19.
//  Copyright © 2019 Cuong Pham. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    var fbLoginSuccess = false
    var userType:String = USERTYPE_CUSTOMER
    
    
    @IBOutlet weak var bLogin: UIButton!
    @IBOutlet weak var bLogout: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (FBSDKAccessToken.current() != nil){
            
            bLogout.isHidden = false
            FBManager.getFBUserData {
                
                self.bLogin.setTitle("Continue as \(User.currentUser.email!)", for: .normal)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (FBSDKAccessToken.current() != nil && fbLoginSuccess == true){
            performSegue(withIdentifier: "CustomerView", sender: self)
        }
        else{
            self.bLogout.isHidden = true
        }
    }
    @IBAction func facebookLogout(_ sender: Any) {
        
        APIManager.shared.logout { (error) in
            
            if error == nil{
                FBManager.shared.logOut()
                User.currentUser.resetInfo()
                
                self.bLogout.isHidden = true
                self.bLogin.setTitle("Login with Facebook", for: .normal)
            }
        }
    }
    
    @IBAction func facebookLogin(_ sender: Any) {
        
        if (FBSDKAccessToken.current() != nil){

            APIManager.shared.login(userType: userType,completionHandler: { (error) in
                if error == nil {
                    self.fbLoginSuccess = true
                    self.viewDidAppear(true)
                }
            })
        }
        else{
            
            FBManager.shared.logIn(
                withReadPermissions: ["public_profile", "email"],
                from: self) { (result, error) in
                    if (error == nil) {
                        
                        FBManager.getFBUserData(completionHandler: {
                            APIManager.shared.login(userType: self.userType,completionHandler: { (error) in
                                if error == nil {
                                    self.fbLoginSuccess = true
                                    self.viewDidAppear(true)
                                }
                            })
                        })
                    }
            }
        }
    }
}
