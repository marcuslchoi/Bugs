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
    
    @IBOutlet weak var pickersContainerView: UIView!
    @IBOutlet weak var issueTypePicker: UIPickerView!
    @IBOutlet weak var assigneePicker: UIPickerView!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    private let issueTypesDataSource = K.getIssueTypes()
    private var assigneesDataSource:[String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //register the custom table view cell
        tableView.register(UINib(nibName: "CreateIssueTableViewCell", bundle: nil), forCellReuseIdentifier: "createIssueCustomCell")
        
//        if let myEmail = AuthManager.instance.currentUserEmail
//        {
//            cellDetails[1] = myEmail
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pickersContainerView.isHidden = true
        
        if let users = dbManager.CurrentProject?.users
        {
            assigneesDataSource = users
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
    
    private func showPicker(tag: Int)
    {
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
