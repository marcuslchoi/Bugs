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
    
    @IBOutlet weak var currentUsersLabel: UILabel!
    var currentProjectId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
