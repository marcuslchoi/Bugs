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
    let defaults = UserDefaults.standard
    
    var currentUserEmail: String?
    {
        get
        {
            return auth.currentUser?.email
        }
    }
    
    private init() { }
    
    func login(email: String, pw: String, shouldSaveCredentials: Bool)
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
                if shouldSaveCredentials
                {
                    self.saveCredentials(email, pw)
                }
            }
        }
    }
    
    private func saveCredentials(_ email: String, _ pw:String)
    {
        let loginDict = [K.Defaults.emailKey: email, K.Defaults.pwKey: pw]
        defaults.set(loginDict, forKey: K.Defaults.loginDictKey)
    }
    
    func getDefaultsLoginDictionary() -> Dictionary<String, String>?
    {
        let dict = defaults.dictionary(forKey: K.Defaults.loginDictKey) as? Dictionary<String, String>
        return dict
    }
    
    func register(email: String, pw: String, shouldSaveCredentials: Bool)
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
                self.delegate?.onRegisterSuccess(email: email)
                self.onUserAuthenticated(justRegistered: true, email: email)
                if shouldSaveCredentials
                {
                    self.saveCredentials(email, pw)
                }
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
        dbManager.getProjects()
    }
}

protocol AuthManagerDelegate
{
    func onLoginSuccess()
    func onLoginFail(error: String)
    func onRegisterSuccess(email: String)
    func onRegisterFail(error: String)
}
