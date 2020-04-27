//
//  ProjectSettingsViewController.swift
//  BugTracker
//
//  Created by Marcus Choi on 4/26/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import UIKit

class ProjectSettingsViewController: UIViewController {

    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var addUserTextField: UITextField!
    
    @IBOutlet weak var currentUsersTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let dbManager = DbManager.instance
        
        //to get notified if added user email is valid
        dbManager.delegate = self
        
        //get the project's current users
        if let project = dbManager.getCurrentProject()
        {
            let users = project.users
            for user in users
            {
                currentUsersTextView.text += "\(user), "
            }
        }
    }
    
    @IBAction func okButtonPress(_ sender: Any)
    {
        let dbManager = DbManager.instance
        if let projectId = dbManager.getCurrentProject()?.id
        {
            dbManager.updateProject(projectId: projectId, description: descriptionTextView.text)
        }
    }
    
    @IBAction func addUserButtonPress(_ sender: Any)
    {
        let dbManager = DbManager.instance
        if let email = addUserTextField.text, let project = dbManager.getCurrentProject()
        {
            if email == ""
            {
                //todo errorLabel
            }
            else
            {
                dbManager.tryAddEmailUser(to: project.id, with: email)
            }
        }
        
    }
}

extension ProjectSettingsViewController: DbManagerDelegate
{
    func onAddEmailUserToProjectSuccess(email: String) {
        print("\(email) added!!")
    }
    
    func onAddEmailUserToProjectError(email: String, errorStr: String) {
        print("Error with \(email): \(errorStr)")
    }
}
