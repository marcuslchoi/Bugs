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
        // Do any additional setup after loading the view.
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
                    self.performSegue(withIdentifier: "LoginToMaster", sender: self)
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
                    self.performSegue(withIdentifier: "LoginToMaster", sender: self)
                    print("registered! \(email)")
                }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
