//
//  AuthManager.swift
//  BugTracker
//
//  Created by Marcus Choi on 4/27/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import Foundation
import Firebase

class AuthManager
{
    var delegate: AuthManagerDelegate?
    private let auth = Auth.auth()
    static var instance = AuthManager()
    private init()
    {
        
    }
    
    func login(email: String, pw: String)
    {
        auth.signIn(withEmail: email, password: pw)
        { authResult, error in
            if let e = error
            {
                //self.errorLabel.text = e.localizedDescription
                self.delegate?.onLoginFail(error: e.localizedDescription)
            }
            else
            {
                //self.performSegue(withIdentifier: "LoginToCreateProject", sender: self)
                self.delegate?.onLoginSuccess()
            }
        }
    }
    
    func register(email: String, pw: String)
    {
        auth.createUser(withEmail: email, password: pw)
        {
            authResult, error in
            if let e = error
            {
                self.delegate?.onRegisterFail(error: e.localizedDescription)
            }
            else
            {
                print("registered! \(email)")
                self.delegate?.onRegisterSuccess()
                DbManager.instance.addUserToMyDb(email: email)
            }
        }
    }
}

protocol AuthManagerDelegate
{
    func onLoginSuccess()
    func onLoginFail(error: String)
    func onRegisterSuccess()
    func onRegisterFail(error: String)
}