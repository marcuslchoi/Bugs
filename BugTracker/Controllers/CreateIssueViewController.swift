//
//  CreateIssueViewController.swift
//  BugTracker
//
//  Created by Marcus Choi on 5/4/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import UIKit
import Firebase

class CreateIssueViewController: UIViewController {

    let dbManager = DbManager.instance
    private var tableCellTitles:[String] = ["Issue Type", "Assignee","Due Date"]
    private var tableCellChosenVals:[String] = ["","","None"]
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var pickersContainerView: UIView!
    @IBOutlet weak var issueTypePicker: UIPickerView!
    @IBOutlet weak var assigneePicker: UIPickerView!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var createIssueButton: UIButton!
    
    private let issueTypesDataSource = K.getIssueTypes()
    private var assigneesDataSource:[String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        dbManager.createIssueDelegate = self
        //register the custom table view cell
        tableView.register(UINib(nibName: "CreateIssueTableViewCell", bundle: nil), forCellReuseIdentifier: "createIssueCustomCell")
        
//        if let myEmail = AuthManager.instance.currentUserEmail
//        {
//            cellDetails[1] = myEmail
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //to be informed of add issue success / fail
        pickersContainerView.isHidden = true
        
        let issuesSelectedRow = issueTypePicker.selectedRow(inComponent: 0)
        tableCellChosenVals[K.CreateIssue.issueTypePickerTag] = issueTypesDataSource[issuesSelectedRow]
        
        //set assignee picker data, initial selection
        if let users = dbManager.CurrentProject?.users, let myEmail = AuthManager.instance.currentUserEmail
        {
            assigneesDataSource = users
            if let index = assigneesDataSource.firstIndex(of: myEmail)
            {
                assigneePicker.selectRow(index, inComponent: 0, animated: true)
                tableCellChosenVals[K.CreateIssue.assigneePickerTag] = myEmail
            }
        }
        tableView.reloadData()
    }
    
    private func showPicker(tag: Int)
    {
        createIssueButton.isHidden = true
        switch (tag)
        {
            case K.CreateIssue.issueTypePickerTag:
                issueTypePicker.isHidden = false
                assigneePicker.isHidden = true
                dueDatePicker.isHidden = true
            break
            case K.CreateIssue.assigneePickerTag:
                issueTypePicker.isHidden = true
                assigneePicker.isHidden = false
                dueDatePicker.isHidden = true
            break
            case K.CreateIssue.dueDatePickerTag:
                issueTypePicker.isHidden = true
                assigneePicker.isHidden = true
                dueDatePicker.isHidden = false
            break
        default:
            break
        }
    }
    
    @IBAction func pickerDoneButtonPress(_ sender: Any) {
        if !dueDatePicker.isHidden
        {
            let date = dueDatePicker.date
            tableCellChosenVals[K.CreateIssue.dueDatePickerTag] = K.convertDateToString(date: date)
            tableView.reloadData()
        }
        pickersContainerView.isHidden = true
        createIssueButton.isHidden = false
    }
    
    @IBAction func createIssueButtonPress(_ sender: Any)
    {
        if let title = titleTextField?.text, title != ""
        {
            let issueType = IssueType(rawValue: tableCellChosenVals[K.CreateIssue.issueTypePickerTag])
            dbManager.addIssue(title, descriptionTextView?.text ?? "", issueType ?? IssueType.Bug, tableCellChosenVals[K.CreateIssue.assigneePickerTag], tableCellChosenVals[K.CreateIssue.dueDatePickerTag])
        }
        else
        {
            print("no title")
        }
    }
}

//MARK: - Table View Delegate
extension CreateIssueViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pickersContainerView.isHidden = false
        let selectedRow = indexPath.row
        showPicker(tag: selectedRow)
    }
}

extension CreateIssueViewController: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableCellTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "createIssueCustomCell", for: indexPath) as! CreateIssueTableViewCell
        cell.titleLabel?.text = tableCellTitles[indexPath.row]
        cell.detailLabel?.text = tableCellChosenVals[indexPath.row]
        return cell
    }
}

//MARK: - Picker View Delegate
extension CreateIssueViewController: UIPickerViewDelegate
{
    
}

extension CreateIssueViewController: UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == K.CreateIssue.issueTypePickerTag
        {
            return issueTypesDataSource.count
        }
        else if pickerView.tag == K.CreateIssue.assigneePickerTag
        {
            return assigneesDataSource.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == K.CreateIssue.issueTypePickerTag
        {
            return issueTypesDataSource[row]
        }
        else if pickerView.tag == K.CreateIssue.assigneePickerTag
        {
            return assigneesDataSource[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let chosenVal:String
        
        if pickerView.tag == K.CreateIssue.issueTypePickerTag
        {
            chosenVal = issueTypesDataSource[row]
        }
        else //if pickerView.tag == K.CreateIssue.assigneePickerTag
        {
            chosenVal = assigneesDataSource[row]
        }
        
        tableCellChosenVals[pickerView.tag] = chosenVal
        tableView.reloadData()
    }
}

extension CreateIssueViewController: CreateIssueDelegate
{
    func onAddIssueFail(name: String, error: String) {
        showAddIssueFailAlert(name: name, error: error)
    }
    
    func onAddIssueSuccess(name: String)
    {
        dismiss(animated: true, completion: nil)
    }
    
    private func showAddIssueFailAlert(name: String, error: String)
    {
        let alert = UIAlertController(title: "Add \(name) Failed", message: error, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
    }
}
