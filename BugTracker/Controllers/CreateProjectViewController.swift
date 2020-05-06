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
    
    let userRolePicker = UIPickerView()

    let userRolePickerDataSource: [String] = K.getUserRoles()
    @IBOutlet weak var myRoleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.text = ""
        navigationItem.hidesBackButton = true
        setupPicker()
    }
    
    private func setupPicker()
    {
        //stackoverflow.com/questions/31728680/how-to-make-an-uipickerview-with-a-done-button
        userRolePicker.backgroundColor = .white
        userRolePicker.delegate = self
        userRolePicker.dataSource = self

        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.backgroundColor = .systemGreen
        toolBar.isTranslucent = true
        //toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))

        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        myRoleTextField.inputView = userRolePicker
        myRoleTextField.inputAccessoryView = toolBar
    }
    
    @objc func donePicker()
    {
        myRoleTextField.text = userRolePickerDataSource[userRolePicker.selectedRow(inComponent: 0)]
        myRoleTextField.resignFirstResponder()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //todo make sure this happens when nav back to this view
        DbManager.instance.delegate = self
        let pickerIndex = userRolePicker.selectedRow(inComponent: 0)
        myRoleTextField.text = userRolePickerDataSource[pickerIndex]
    }
    
    @IBAction func createButtonPress(_ sender: Any)
    {
        if let projName = projectNameTextField.text, projName != ""
        {
            let roleIndex = userRolePicker.selectedRow(inComponent: 0)
            let myRole = userRolePickerDataSource[roleIndex]
            errorLabel.text = DbManager.instance.tryCreateProject(projName: projName, myRoleStr: myRole)
        }
        else
        {
            errorLabel.text = "please enter a project name"
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
