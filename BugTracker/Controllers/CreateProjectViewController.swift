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

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createButtonPress(_ sender: Any)
    {
        if let projName = projectNameTextField.text
        {
            if projName == ""
            {
                statusLabel.text = "please enter a project name"
            }
            else
            {
                statusLabel.text = "Created \(projName)!"
                let myEmail = Auth.auth().currentUser?.email
                let project = Project(id: "testId", title: projName, users: [myEmail!], modules: ["test module"])
            }
        }
        else
        {
            statusLabel.text = "please enter a project name"
        }
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
