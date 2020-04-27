//
//  ProjectSettingsViewController.swift
//  BugTracker
//
//  Created by Marcus Choi on 4/26/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import UIKit

class ProjectSettingsViewController: UIViewController {
    @IBOutlet weak var projectIdLabel: UILabel!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var addUserTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var currentUsersTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        errorLabel.text = ""
        let dbManager = DbManager.instance
        //to get notified if added user email is valid
        dbManager.delegate = self
        
        //get the project's current users
        if let project = dbManager.getCurrentProject()
        {
            projectIdLabel.text = "Project Id: \(project.id)"
            showUsersInUI()
        }
    }
    
    private func showUsersInUI()
    {
        let dbManager = DbManager.instance
        if let users = dbManager.getCurrentProject()?.users
        {
            currentUsersTextView.text = ""
            for i in 0...users.count - 1//user in users
            {
                var userStr = "\(users[i]), "
                if i == users.count - 1
                {
                    userStr = users[i]
                }
                currentUsersTextView.text += userStr
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
                errorLabel.text = "Error: Please add a user email."
            }
            else
            {
                dbManager.tryAddEmailUserToProject(to: project.id, with: email)
            }
        }
    }
}

extension ProjectSettingsViewController: DbManagerDelegate
{
    func onAddEmailUserToProjectSuccess(email: String) {
        errorLabel.text = "\(email) added to project."
        addUserTextField.text = ""
        showUsersInUI()
    }
    
    func onAddEmailUserToProjectError(email: String, errorStr: String) {
        errorLabel.text = "Error with \(email): \(errorStr)"
        print("Error with \(email): \(errorStr)")
    }
}
