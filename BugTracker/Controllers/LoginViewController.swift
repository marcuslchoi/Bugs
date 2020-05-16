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
    @IBOutlet weak var savePasswordSwitch: UISwitch!
    
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
        if isLogin
        {
            possiblySetSavedCredentials()
        }
        tapToDismiss()
    }
    
    private func possiblySetSavedCredentials()
    {
        if let loginDict = authManager.getDefaultsLoginDictionary()
        {
            emailTextField.text = loginDict[K.Defaults.emailKey]
            pwTextField.text = loginDict[K.Defaults.pwKey]
        }
    }
    
    private func tapToDismiss()
    {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func stylizeTextBoxes()
    {
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.black.cgColor
        emailTextField.layer.cornerRadius = 5
        emailTextField.addDismissButton(target: self, selector: #selector(UIView.endEditing))
        
        pwTextField.layer.borderWidth = 1
        pwTextField.layer.borderColor = UIColor.black.cgColor
        pwTextField.layer.cornerRadius = 5
        pwTextField.addDismissButton(target: self, selector: #selector(UIView.endEditing))
        
        emailTextField.delegate = self
        pwTextField.delegate = self
    }
    
    @IBAction func loginPressed(_ sender: Any)
    {
        if let email = emailTextField.text, let password = pwTextField.text
        {
            authManager.login(email: email, pw: password, shouldSaveCredentials: savePasswordSwitch.isOn)
        }
    }
    
    @IBAction func registerPressed(_ sender: Any)
    {
        if let email = emailTextField.text, let password = pwTextField.text
        {
            authManager.register(email: email, pw: password, shouldSaveCredentials: savePasswordSwitch.isOn)
        }
    }
    
    private func showRegistrationSuccessAlert(title: String, msg: String)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.performSegue(withIdentifier: "LoginToCreateProject", sender: self)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
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
    
    func onRegisterSuccess(email: String) {
        showRegistrationSuccessAlert(title: "Registration success!", msg: "\(email) is now registered.")
    }
    
    func onRegisterFail(error: String) {
        self.errorLabel.text = error
    }
}

extension LoginViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
