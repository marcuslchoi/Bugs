//
//  CreateProjectViewController.swift
//  BugTracker
//
//  Created by Marcus Choi on 4/17/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import UIKit
import Firebase
class CreateProjectViewController: UIViewController {

    @IBOutlet weak var projectNameTextField: UITextField!

    @IBOutlet weak var statusLabel: UILabel!

    private var createdProjectId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //todo make sure this happens when nav back to this view
        DbManager.instance.delegate = self
    }
    
    @IBAction func createButtonPress(_ sender: Any)
    {
        if let projName = projectNameTextField.text
        {
            statusLabel.text = DbManager.instance.tryCreateProject(projName: projName, additionalUsers: nil)
        }
        else
        {
            print("error: projectNameTextField.text is nil")
        }
    }

    @IBAction func skipButtonPress(_ sender: Any)
    {
        performSegue(withIdentifier: "createProjectToProjects", sender: self)
    }
    
    private func showAddIssueAlert(for projectName: String)
    {
        let alert = UIAlertController(title: "\(projectName) Created", message: "Please add some project settings.", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Go to Settings", style: .default) { (action) in
            
            self.performSegue(withIdentifier: "CreateToProjectSettings", sender: self)
        }
        alert.addAction(addAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateToProjectSettings"
        {
            if let settingsVC = segue.destination as? ProjectSettingsViewController
            {
                settingsVC.currentProjectId = createdProjectId
            }
        }
    }
}

extension CreateProjectViewController: DbManagerDelegate
{
    func onCreateProjectError(description: String) {
        statusLabel.text = description
    }
    
    func onCreateProjectSuccess(projectName: String) {
        createdProjectId = projectName
        showAddIssueAlert(for: projectName)
    }
}
