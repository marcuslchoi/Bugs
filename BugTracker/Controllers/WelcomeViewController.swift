//
//  WelcomeViewController.swift
//  BugTracker
//
//  Created by Marcus Choi on 5/7/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    private var isLoginPressed = true
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func registerButtonPress(_ sender: Any) {
        isLoginPressed = false
        performSegue(withIdentifier: "WelcomeToLoginRegister", sender: self)
    }
    
    @IBAction func loginButtonPress(_ sender: Any) {
        isLoginPressed = true
        performSegue(withIdentifier: "WelcomeToLoginRegister", sender: self)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let loginVC = segue.destination as! LoginViewController
        loginVC.isLogin = isLoginPressed
    }
    

}
