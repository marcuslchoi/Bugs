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
    
    var currentProjectId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let projectId = currentProjectId
        {
            let dbManager = DbManager.instance
            if let users = dbManager.getProject(with: projectId)?.users
            {
                for user in users
                {
                    currentUsersTextView.text += "\(user), "
                }
            }
        }
    }
    
    @IBAction func okButtonPress(_ sender: Any)
    {
        if let projectId = currentProjectId
        {
            let dbManager = DbManager.instance
            dbManager.updateProject(projectId: projectId, description: descriptionTextView.text)
        }
    }
    
    @IBAction func addUserButtonPress(_ sender: Any)
    {
    
    }
}
