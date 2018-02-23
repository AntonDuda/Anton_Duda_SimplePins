//
//  LoginViewController.swift
//  Anton_Duda_SimplePins
//
//  Created by Anton on 2/23/18.
//  Copyright © 2018 Anton Duda. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = FBSDKLoginButton()
        loginButton.center = view.center
        
        view.addSubview(loginButton)
    }

}

