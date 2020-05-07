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
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    var isLogin = true
    let authManager = AuthManager.instance
    override func viewDidLoad() {
        super.viewDidLoad()
        authManager.delegate = self
        errorLabel.text = ""
        stylizeTextBoxes()
        registerButton.isHidden = isLogin
        loginButton.isHidden = !isLogin
    }
    
    private func stylizeTextBoxes()
    {
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.black.cgColor
        emailTextField.layer.cornerRadius = 5
        
        pwTextField.layer.borderWidth = 1
        pwTextField.layer.borderColor = UIColor.black.cgColor
        pwTextField.layer.cornerRadius = 5
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
