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
        stylizeTextBoxes()
        title = "Create a New Project"
        tapToDismiss()
    }
    
    private func tapToDismiss()
    {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func stylizeTextBoxes()
    {
        projectNameTextField.layer.borderWidth = 1
        projectNameTextField.layer.borderColor = UIColor.black.cgColor
        projectNameTextField.layer.cornerRadius = 5
        projectNameTextField.delegate = self
        projectNameTextField.addDismissButton(target: self, selector: #selector(UIView.endEditing))
        
        myRoleTextField.layer.borderWidth = 1
        myRoleTextField.layer.borderColor = UIColor.black.cgColor
        myRoleTextField.layer.cornerRadius = 5
        //note: don't add a dismiss button to myRoleTextField, causes conflict with picker
    }
    
    private func setupPicker()
    {
        //stackoverflow.com/questions/31728680/how-to-make-an-uipickerview-with-a-done-button
        //userRolePicker.backgroundColor = .white
        userRolePicker.delegate = self
        userRolePicker.dataSource = self

        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.backgroundColor = .white
        toolBar.isTranslucent = true
        //toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()

        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.donePicker))

        toolBar.setItems([flexButton, doneButton], animated: false)
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
            errorLabel.text = "Please enter a project name."
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
    
    private func showOkAlert(title: String, msg: String)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        alert.addAction(okAction)
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

extension CreateProjectViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
