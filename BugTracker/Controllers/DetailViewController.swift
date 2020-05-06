//
//  DetailViewController.swift
//  BugTracker
//
//  Created by Marcus Choi on 4/15/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var statusPickerView: UIPickerView!
    
    @IBOutlet weak var assigneePickerView: UIPickerView!
    
    
    @IBOutlet weak var reporterLabel: UILabel!
    
    @IBOutlet weak var dueDatePicker: UIDatePicker!
        
    private let dbManager = DbManager.instance
    private let tableCellTitles = ["Status", "Assignee", "Due Date"]
    private var tableCellChosenVals = ["","",""]
    private let statusTag = K.IssueDetail.statusPickerTag
    private let assigneeTag = K.IssueDetail.assigneePickerTag
    
    let statusPickerData: [String] = K.getIssueStatuses()
    var assigneePickerData: [String] = []
    //these are the roles of the users assigned to this project
    var assigneeRoles: [String] = []
    
    //the issue is set when the user selects it from the master view controller
    var issue: Issue?
    {
        didSet
        {
            refreshUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //register the custom table view cell
        tableView.register(UINib(nibName: "CreateIssueTableViewCell", bundle: nil), forCellReuseIdentifier: "createIssueCustomCell")

        setAssigneePickerData()
        setAssigneeRoles()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        save()
    }

    @IBAction func pickerDoneButtonPress(_ sender: Any)
    {
        pickerContainerView.isHidden = true
    }
    private func refreshUI()
    {
        if let safeIssue = issue
        {
            loadViewIfNeeded()
            title = safeIssue.id
            titleTextField.text = safeIssue.title
            reporterLabel.text = "Reporter: \(safeIssue.reporter)"
            descriptionTextView.text = safeIssue.description
            setStatusPickerInitialSelection(issue: safeIssue)
            setAssigneePickerInitialSelection(issue: safeIssue)
            setDueDatePickerInitialSelection(issue: safeIssue)
        }
    }
    
    //the status picker selection on entering the view
    //equals the status of the issue in the db
    private func setStatusPickerInitialSelection(issue: Issue)
    {
        let status = issue.status
        let statusIndex = statusPickerData.firstIndex(of: status.rawValue)
        if let safeIndex = statusIndex
        {
            statusPickerView.selectRow(safeIndex, inComponent: 0, animated: true)
        }
    }
    
    //the assignee picker selection on entering the view
    //equals the assignedTo of the issue in the db
    private func setAssigneePickerInitialSelection(issue: Issue)
    {
        let assignee = issue.assignedTo
        let index = assigneePickerData.firstIndex(of: assignee)
        if let safeIndex = index
        {
            assigneePickerView.selectRow(safeIndex, inComponent: 0, animated: true)
            assigneePickerView.selectRow(safeIndex, inComponent: 1, animated: true)
        }
    }
    
    //the due date picker selection on entering the view
    //equals the due date of the issue in the db
    private func setDueDatePickerInitialSelection(issue: Issue)
    {
        dueDatePicker.setDate(issue.dueDate, animated: true)
    }

    private func setAssigneePickerData()
    {
        if let users = dbManager.CurrentProject?.users
        {
            assigneePickerData = users
        }
    }
    
    private func setAssigneeRoles()
    {
        if let roles = dbManager.CurrentProject?.roles
        {
            assigneeRoles = roles
        }
    }
    
    private func save()
    {
        if let issueId = issue?.id
        {
            let statusSelectedRow = statusPickerView.selectedRow(inComponent: 0)
            let status = statusPickerData[statusSelectedRow]
            
            let assigneeSelectedRow = assigneePickerView.selectedRow(inComponent: 0)
            let assignee = assigneePickerData[assigneeSelectedRow]
            
            let dateSelected = K.convertDateToString(date: dueDatePicker.date)

            if let title = titleTextField.text
            {
                DbManager.instance.updateIssue(issueId: issueId, title: title, description: descriptionTextView.text, statusString: status, assignee: assignee, dueDate: dateSelected)
            }
        }
        else
        {
            print("save error: issue id is nil!")
        }
    }
}

//MARK: - Extensions
//IssueSelectionDelegate is a delegate of MasterViewController
extension DetailViewController: IssueSelectionDelegate
{
    func onIssueSelected(selectedIssue: Issue) {
        self.issue = selectedIssue
        print("DetailViewController onIssueSelected \(issue?.title)")
    }
}

extension DetailViewController: UIPickerViewDelegate
{
    
}

extension DetailViewController: UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == assigneeTag
        {
            return 2
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == statusTag
        {
            return statusPickerData.count
        }
        else if pickerView.tag == assigneeTag
        {
            return assigneePickerData.count
        }
        else
        {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if pickerView.tag == statusTag
        {
            return statusPickerData[row]
        }
        else if pickerView.tag == assigneeTag
        {
            if component == 0 //users
            {
                return assigneePickerData[row]
            }
            else //roles
            {
                return assigneeRoles[row]
            }
        }
        else
        {
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == assigneeTag
        {
            if component == 0
            {
                pickerView.selectRow(row, inComponent: 1, animated: true)
            }
            else
            {
                pickerView.selectRow(row, inComponent: 0, animated: true)
            }
        }
    }
}

//MARK: - Table View extensions
extension DetailViewController: UITableViewDataSource
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

extension DetailViewController: UITableViewDelegate
{
    
}
