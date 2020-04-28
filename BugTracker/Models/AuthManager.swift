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
    private init() { }
    
    func login(email: String, pw: String)
    {
        auth.signIn(withEmail: email, password: pw)
        { authResult, error in
            if let e = error
            {
                self.delegate?.onLoginFail(error: e.localizedDescription)
            }
            else
            {
                print("logged in! \(email)")
                self.delegate?.onLoginSuccess()
                self.onUserAuthenticated(justRegistered: false, email: email)
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
                self.onUserAuthenticated(justRegistered: true, email: email)
            }
        }
    }
    
    //load user's projects. If just registered, add user to AllUsers collection
    private func onUserAuthenticated(justRegistered: Bool, email: String)
    {
        let dbManager = DbManager.instance
        if(justRegistered)
        {
            dbManager.addUserToMyDb(email: email)
        }
        dbManager.loadProjects()
    }
}

protocol AuthManagerDelegate
{
    func onLoginSuccess()
    func onLoginFail(error: String)
    func onRegisterSuccess()
    func onRegisterFail(error: String)
}
