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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.text = ""
    }
    
    @IBAction func loginPressed(_ sender: Any)
    {
        if let email = emailTextField.text, let pw = pwTextField.text
        {
            Auth.auth().signIn(withEmail: email, password: pw)
            { authResult, error in
                if let e = error
                {
                    self.errorLabel.text = e.localizedDescription
                }
                else
                {
                    self.performSegue(withIdentifier: "LoginToCreateProject", sender: self)
                }
                
            }
        }
    }
    
    @IBAction func registerPressed(_ sender: Any)
    {
        if let email = emailTextField.text, let pw = pwTextField.text
        {
            Auth.auth().createUser(withEmail: email, password: pw)
            {
                authResult, error in
                if let e = error
                {
                    self.errorLabel.text = e.localizedDescription
                }
                else
                {
                    self.performSegue(withIdentifier: "LoginToCreateProject", sender: self)
                    print("registered! \(email)")
                }
            }
        }
    }
}
