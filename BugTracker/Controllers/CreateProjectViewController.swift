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

    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var userRolePickerView: UIPickerView!
    let userRolePickerDataSource: [String] = K.getUserRoles()

    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.text = ""
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //todo make sure this happens when nav back to this view
        DbManager.instance.delegate = self
    }
    
    @IBAction func createButtonPress(_ sender: Any)
    {
        if let projName = projectNameTextField.text
        {
            let roleIndex = userRolePickerView.selectedRow(inComponent: 0)
            let myRole = userRolePickerDataSource[roleIndex]
            errorLabel.text = DbManager.instance.tryCreateProject(projName: projName, myRoleStr: myRole)
        }
        else
        {
            print("error: projectNameTextField.text is nil")
        }
    }

    @IBAction func skipButtonPress(_ sender: Any)
    {
        performSegue(withIdentifier: "CreateProjectToProjects", sender: self)
    }
    
    private func showProjectAddedGoToSettingsAlert(for projectName: String)
    {
        let alert = UIAlertController(title: "\(projectName) Created", message: "Please add some project settings.", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Go to Settings", style: .default) { (action) in
            
            self.performSegue(withIdentifier: "CreateToProjectSettings", sender: self)
        }
        alert.addAction(addAction)
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - Extensions
extension CreateProjectViewController: DbManagerDelegate
{
    func onCreateProjectError(description: String) {
        errorLabel.text = description
    }
    
    func onCreateProjectSuccess(projectName: String) {
        //set the dbmanager current project so that we can add some properties to it in next view
        DbManager.instance.setCurrentProjectIdWithName(projectName: projectName)
        showProjectAddedGoToSettingsAlert(for: projectName)
    }
}

extension CreateProjectViewController: UIPickerViewDelegate
{
    
}

extension CreateProjectViewController: UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return userRolePickerDataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return userRolePickerDataSource.count
    }
}
