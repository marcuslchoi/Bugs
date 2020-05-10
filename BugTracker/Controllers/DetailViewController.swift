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
    
    @IBOutlet weak var pickersContainerView: UIView!
    @IBOutlet weak var statusPickerView: UIPickerView!
    
    @IBOutlet weak var assigneePickerView: UIPickerView!
    
    @IBOutlet weak var reporterLabel: UILabel!
    
    @IBOutlet weak var dueDatePicker: UIDatePicker!
        
    @IBOutlet weak var descriptionTextViewHeight: NSLayoutConstraint!
    
    private let dbManager = DbManager.instance
    private let tableCellTitles = ["Status", "Assignee", "Due Date"]
    private var tableCellChosenVals = ["", "", "None"]
    private let statusTag = K.IssueDetail.statusPickerTag
    private let assigneeTag = K.IssueDetail.assigneePickerTag
    private let dueDateTag = K.IssueDetail.dueDatePickerTag
    
    let statusPickerData: [String] = K.getIssueStatuses()
    var assigneePickerData: [String] = []
    //these are the roles of the users assigned to this project
    //each index corresponds to same index of assigneePickerData
    var assigneeRolesData: [String] = []
    
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
        
        possiblySetIssueOnEnter()
        setAssigneePickerData()
        setAssigneeRolesData()
        stylizeTextBoxes()
        setDescHeightOnLoad()
    }
    
    //set to first issue if it is nil
    private func possiblySetIssueOnEnter()
    {
        if issue == nil && dbManager.Issues.count > 0
        {
            issue = dbManager.Issues[0]
        }
    }
    
    private func stylizeTextBoxes()
    {
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        descriptionTextView.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pickersContainerView.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        save()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        let orientBeforeTransition = UIApplication.shared.statusBarOrientation
        orientBeforeTransition == .landscapeLeft || orientBeforeTransition == .landscapeRight
        setDescriptionHeight(orientBeforeTransition == .landscapeLeft || orientBeforeTransition == .landscapeRight)
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
    
    private func showPicker(tag: Int)
    {
        //createIssueButton.isHidden = true
        switch (tag)
        {
            case statusTag:
                statusPickerView.isHidden = false
                assigneePickerView.isHidden = true
                dueDatePicker.isHidden = true
            break
            case assigneeTag:
                statusPickerView.isHidden = true
                assigneePickerView.isHidden = false
                dueDatePicker.isHidden = true
            break
            case dueDateTag:
                statusPickerView.isHidden = true
                assigneePickerView.isHidden = true
                dueDatePicker.isHidden = false
            break
        default:
            break
        }
    }

    @IBAction func pickerDoneButtonPress(_ sender: Any)
    {
        if !dueDatePicker.isHidden
        {
            let date = dueDatePicker.date
            tableCellChosenVals[dueDateTag] = K.convertDateToString(date: date)
            tableView.reloadData()
        }
        pickersContainerView.isHidden = true
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
            
            tableCellChosenVals[statusTag] = safeIssue.status.rawValue
            tableCellChosenVals[assigneeTag] = safeIssue.assignedTo
            tableCellChosenVals[dueDateTag] = K.convertDateToString(date: safeIssue.dueDate)
            tableView.reloadData()
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
    
    private func setAssigneeRolesData()
    {
        if let roles = dbManager.CurrentProject?.roles
        {
            assigneeRolesData = roles
        }
    }
    
    @IBAction func saveButtonPress(_ sender: Any)
    {
        save()
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

//MARK: - Issue Selection Delegate
//IssueSelectionDelegate is a delegate of MasterViewController
extension DetailViewController: IssueSelectionDelegate
{
    func onIssueSelected(selectedIssue: Issue) {
        self.issue = selectedIssue
        print("DetailViewController onIssueSelected \(issue?.title)")
    }
}

//MARK: - Picker delegates
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
                return assigneeRolesData[row]
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
            if component == K.IssueDetail.assigneeEmailComponent
            {
                pickerView.selectRow(row, inComponent: 1, animated: true)
            }
            else
            {
                pickerView.selectRow(row, inComponent: 0, animated: true)
            }
            tableCellChosenVals[assigneeTag] = assigneePickerData[row]
        }
        else //status
        {
            tableCellChosenVals[statusTag] = statusPickerData[row]
        }
        tableView.reloadData()
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pickersContainerView.isHidden = false
        let selectedRow = indexPath.row
        showPicker(tag: selectedRow)
    }
}
