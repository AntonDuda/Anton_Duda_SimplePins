//
//  LoginViewController.swift
//  Anton_Duda_SimplePins
//
//  Created by Anton on 2/23/18.
//  Copyright © 2018 Anton Duda. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let manager: FBSDKLoginManager = {
        let mn = FBSDKLoginManager()
        mn.loginBehavior = .web
        return mn
    }()
    
    @IBAction func didTapLogin(_ sender: UIButton!) {
        manager.logIn(withReadPermissions: ["public_profile"],
                      from: self) { (result, error) in
            if error != nil {
                let myAlert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                myAlert.addAction(okAction)
                self.present(myAlert, animated: true, completion: nil)
            }
            else if result?.token != nil, let userId = result?.token.userID {
                if DBManager.shared.getUser(with: userId) != nil {
                    DBManager.shared.makeUserActive(with: userId)
                }
                else {
                    DBManager.shared.createUser(with: userId)
                }
                DispatchQueue.main.async {
                    (UIApplication.shared.delegate as? AppDelegate)?.goToMaps()
                }
            }
        }
    }

}

