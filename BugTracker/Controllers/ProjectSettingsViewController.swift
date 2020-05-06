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
    @IBOutlet weak var usersTableView: UITableView!
    
    //@IBOutlet weak var userRoleTextField: UITextField!
    
    @IBOutlet weak var pickerContainerView: UIView!

    @IBOutlet weak var okButton: UIButton!
    
    @IBOutlet weak var userRolePickerView: UIPickerView!
    
    let userRolePickerData: [String] = K.getUserRoles()
    var cameFromIssues: Bool = false
    let dbManager = DbManager.instance
    
    private var users: [String] = []
    private var userRoles: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        //register the custom table view cell
        usersTableView.register(UINib(nibName: "CreateIssueTableViewCell", bundle: nil), forCellReuseIdentifier: "createIssueCustomCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pickerContainerView.isHidden = true
        if cameFromIssues //came from issues (master) view
        {
            okButton.isHidden = true
        }
        else //came from create project
        {
            navigationItem.hidesBackButton = true
        }
        
        //errorLabel.text = ""
        //to get notified if added user email is valid
        dbManager.delegate = self
        
        //get the project's current users
        if let project = dbManager.CurrentProject
        {
            onEnterUpdateUI(project: project)
        }
        else
        {
            projectIdLabel.text = "Error: current project not set"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //save the project description on navigating away
        updateProjectDescription()
    }
    
    @IBAction func pickerDoneButtonPress(_ sender: Any)
    {
        pickerContainerView.isHidden = true
    }
    private func onEnterUpdateUI(project: Project)
    {
        projectIdLabel.text = "Project: \(project.name)"
        descriptionTextView.text = project.description
        showUsersInUI()
    }
    
    private func showUsersInUI()
    {
        if let currProject = dbManager.CurrentProject
        {
            users = currProject.users
            userRoles = currProject.roles
            usersTableView.reloadData()
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
                //errorLabel.text = "Error: Please add a user email."
            }
            else
            {
                let roleIndex = userRolePickerView.selectedRow(inComponent: 0)
                let role = userRolePickerData[roleIndex]
                dbManager.tryAddEmailUserToProject(to: project.id, with: email, roleStr: role)
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

//MARK: - DbManagerDelegate
extension ProjectSettingsViewController: DbManagerDelegate
{
    func onAddEmailUserToProjectSuccess(email: String) {
        //errorLabel.text = "\(email) added to project."
        addUserTextField.text = ""
        showUsersInUI()
    }
    
    func onAddEmailUserToProjectError(email: String, errorStr: String) {
        //errorLabel.text = "Error with \(email): \(errorStr)"
        print("Error with \(email): \(errorStr)")
    }
}

//MARK: - picker delegates
extension ProjectSettingsViewController: UIPickerViewDelegate
{
    
}

extension ProjectSettingsViewController: UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return userRolePickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return userRolePickerData.count
    }
}

//MARK: - table view extensions
extension ProjectSettingsViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "createIssueCustomCell", for: indexPath) as! CreateIssueTableViewCell
        cell.titleLabel?.text = users[indexPath.row]
        cell.detailLabel?.text = userRoles[indexPath.row]
        return cell
    }
}

extension ProjectSettingsViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pickerContainerView.isHidden = false
        let selectedRow = indexPath.row
        //showPicker(tag: selectedRow)
    }
}
