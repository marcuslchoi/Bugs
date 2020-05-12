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
    @IBOutlet weak var selectedUserLabel: UILabel!
    
    @IBOutlet weak var okButton: UIButton!
    
    @IBOutlet weak var userRolePickerView: UIPickerView!
    
    @IBOutlet weak var descriptionTextViewHeight: NSLayoutConstraint!
    let userRolePickerData: [String] = K.getUserRoles()
    var cameFromIssues: Bool = false
    let dbManager = DbManager.instance
    
    private var currSelectedUserIndex = 0
    
    //users on current project
    private var users: [String] = []
    //the roles associated with the users
    private var userAssignedRoles: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Project Settings"
        //register the custom table view cell
        usersTableView.register(UINib(nibName: "CreateIssueTableViewCell", bundle: nil), forCellReuseIdentifier: "createIssueCustomCell")
        //dbManager.projectUsersDelegate = self
        stylizeTextBoxes()
        setDescHeightOnLoad()
        tapToDismiss()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dbManager.projectUsersDelegate = self
        pickerContainerView.isHidden = true
        if cameFromIssues //came from issues (master) view
        {
            okButton.setTitle("Save", for: .normal)
        }
        else //came from create project
        {
            okButton.setTitle("Finish", for: .normal)
            navigationItem.hidesBackButton = true
        }

        //get the project's current users
        if let project = dbManager.CurrentProject
        {
            onEnterUpdateUI(project: project)
        }
        else
        {
            projectIdLabel.text = "Error: Current project not set."
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //save the project description on navigating away
        updateProjectDescriptionToDb()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        let orientBeforeTransition = UIApplication.shared.statusBarOrientation
        orientBeforeTransition == .landscapeLeft || orientBeforeTransition == .landscapeRight
        setDescriptionHeight(orientBeforeTransition == .landscapeLeft || orientBeforeTransition == .landscapeRight)
    }
    
    private func tapToDismiss()
    {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setDescHeightOnLoad()
    {
        let orientation = UIApplication.shared.statusBarOrientation
        setDescriptionHeight(orientation == .portrait || orientation == .portraitUpsideDown)
    }
    
    private func setDescriptionHeight(_ isPortrait: Bool)
    {
        let h: CGFloat
        if isPortrait
        {
            h = CGFloat(K.portraitDescHeight)
        }
        else
        {
            h = CGFloat(K.landscapeDescHeight)
        }
        descriptionTextViewHeight.constant = h
    }
    
    private func stylizeTextBoxes()
    {
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.delegate = self
        
        addUserTextField.layer.borderWidth = 1
        addUserTextField.layer.borderColor = UIColor.black.cgColor
        addUserTextField.layer.cornerRadius = 5
        addUserTextField.delegate = self
    }
    
    @IBAction func pickerDoneButtonPress(_ sender: Any)
    {
        pickerContainerView.isHidden = true
        if let project = dbManager.CurrentProject
        {
            let roleIndex = userRolePickerView.selectedRow(inComponent: 0)
            let newRole = userRolePickerData[roleIndex]
            let userSelected = users[currSelectedUserIndex]
            dbManager.updateUserRoleOnProject(projectId: project.id, email: userSelected, roleStr: newRole)
        }
    }
    private func onEnterUpdateUI(project: Project)
    {
        projectIdLabel.text = project.name
        descriptionTextView.text = project.description
        showUsersInUI()
    }
    
    private func showUsersInUI()
    {
        if let currProject = dbManager.CurrentProject
        {
            users = currProject.users
            userAssignedRoles = currProject.roles
            usersTableView.reloadData()
        }
    }
    
    //segues to projects vc
    @IBAction func okButtonPress(_ sender: Any)
    {
        if let addUserText = addUserTextField.text, addUserText != ""
        {
            showOkAlert(title: "Did you want to add the user?", msg: "Please press the + button, or clear the 'Add User' field to continue.")
        }
        else
        {
            updateProjectDescriptionToDb()
            if cameFromIssues
            {
                //todo move this stuff to delegate
                //ProjectUsersDelegate on description update success
                //todo show UI save success
            }
            else
            {
                performSegue(withIdentifier: "ProjectSettingsToChooseProject", sender: self)
            }
        }
    }
    
    private func updateProjectDescriptionToDb()
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
                showOkAlert(title: "Error", msg: "Please add a user email.")
            }
            else
            {
                let role = UserRole.Developer.rawValue
                dbManager.tryAddEmailUserToProject(to: project.id, with: email, roleStr: role)
            }
        }
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

//MARK: - ProjectUsersDelegate
extension ProjectSettingsViewController: ProjectUsersDelegate
{
    func onAddEmailUserToProjectSuccess(email: String) {
        addUserTextField.text = ""
        showUsersInUI()
    }
    
    func onAddEmailUserToProjectError(email: String, errorStr: String) {
        showOkAlert(title: "Error adding \(email)", msg: errorStr)
    }
    
    func onUpdateUserRoleOnProjectSuccess(email: String) {
        showUsersInUI()
    }
    
    func onUpdateUserRoleOnProjectError(email: String, errorStr: String) {
        showOkAlert(title: "Error updating \(email)", msg: errorStr)
    }
}

//MARK: - picker extensions
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
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "createIssueCustomCell", for: indexPath) as! CreateIssueTableViewCell
        cell.titleLabel?.text = userAssignedRoles[indexPath.row]
        cell.detailLabel?.text = users[indexPath.row]
        return cell
    }
}

extension ProjectSettingsViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pickerContainerView.isHidden = false
        let selectedRow = indexPath.row
        let selectedUser = users[selectedRow]
        selectedUserLabel.text = "Select \(selectedUser)'s Role"
        currSelectedUserIndex = selectedRow
        
        //select initial picker role
        let currRole = userAssignedRoles[selectedRow]
        if let indexOfRole = userRolePickerData.firstIndex(of: currRole)
        {
            userRolePickerView.selectRow(indexOfRole, inComponent: 0, animated: false)
        }
    }
}

extension ProjectSettingsViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ProjectSettingsViewController: UITextViewDelegate
{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
