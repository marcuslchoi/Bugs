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
    
    @IBOutlet weak var usersTextField: UITextField!
    
    @IBOutlet weak var modulesTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        DbManager.instance.delegate = self
    }
    
    @IBAction func createButtonPress(_ sender: Any)
    {
        var status: String
        if let projName = projectNameTextField.text
        {
            status = DbManager.instance.tryCreateProject(projName: projName)
        }
        else
        {
            status = "please enter a project name"
        }

        statusLabel.text = status
    }
    
    
    @IBAction func skipButtonPress(_ sender: Any)
    {
        performSegue(withIdentifier: "createProjectToProjects", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CreateProjectViewController: DbManagerDelegate
{
    func onCreateProjectError(description: String) {
        statusLabel.text = description
    }
    
    func onCreateProjectSuccess(projectName: String) {
        statusLabel.text = "Created project: \(projectName)"
    }
    
    
}
