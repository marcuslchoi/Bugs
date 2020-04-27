//
//  LoginViewController.swift
//  BugTracker
//
//  Created by Marcus Choi on 4/17/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var pwTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    let authManager = AuthManager.instance
    override func viewDidLoad() {
        super.viewDidLoad()
        authManager.delegate = self
        errorLabel.text = ""
    }
    
    @IBAction func loginPressed(_ sender: Any)
    {
        if let email = emailTextField.text, let password = pwTextField.text
        {
            authManager.login(email: email, pw: password)
        }
    }
    
    @IBAction func registerPressed(_ sender: Any)
    {
        if let email = emailTextField.text, let password = pwTextField.text
        {
            authManager.register(email: email, pw: password)
        }
    }
}

extension LoginViewController: AuthManagerDelegate
{
    func onLoginSuccess() {
        self.performSegue(withIdentifier: "LoginToCreateProject", sender: self)
    }
    
    func onLoginFail(error: String) {
        self.errorLabel.text = error
    }
    
    func onRegisterSuccess() {
        self.performSegue(withIdentifier: "LoginToCreateProject", sender: self)
    }
    
    func onRegisterFail(error: String) {
        self.errorLabel.text = error
    }
}
