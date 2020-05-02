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
    
    @IBOutlet weak var okButton: UIButton!
    
    var cameFromIssues: Bool = false
    let dbManager = DbManager.instance

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if cameFromIssues //came from issues (master) view
        {
            okButton.isHidden = true
        }
        else //came from create project
        {
            navigationItem.hidesBackButton = true
        }
        
        errorLabel.text = ""
        //to get notified if added user email is valid
        dbManager.delegate = self
        
        //get the project's current users
        if let project = dbManager.CurrentProject
        {
            onEnterUpdateUI(project: project)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //save the project description on navigating away
        updateProjectDescription()
    }
    
    private func onEnterUpdateUI(project: Project)
    {
        projectIdLabel.text = "Project: \(project.name)"
        descriptionTextView.text = project.description
        showUsersInUI()
    }
    
    private func showUsersInUI()
    {
        if let users = dbManager.CurrentProject?.users
        {
            currentUsersTextView.text = ""
            for i in 0...users.count - 1
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
    
    //segues to projects vc
    @IBAction func okButtonPress(_ sender: Any)
    {
        if let addUserText = addUserTextField.text, addUserText != ""
        {
            showMustAddUserAlert()
        }
    }
    
    private func updateProjectDescription()
    {
        if let project = dbManager.CurrentProject
        {
            dbManager.updateProject(project: project, description: descriptionTextView.text)
        }
        else
        {
            print("updateProjectDescription error: current project is nil")
        }
    }
    
    @IBAction func addUserButtonPress(_ sender: Any)
    {
        if let email = addUserTextField.text, let project = dbManager.CurrentProject
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
    
    private func showMustAddUserAlert()
    {
        let alert = UIAlertController(title: "Did you want to add the user?", message: "Please press the 'Add User' button, or clear the field to continue.", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        alert.addAction(addAction)
        present(alert, animated: true, completion: nil)
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
