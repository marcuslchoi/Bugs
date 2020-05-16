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
    @IBOutlet weak var saveButton: UIButton!
    
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
    
    //use this for auto-save on leaving the issue
    var hasBeenEdited = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hasBeenEdited = false
        dbManager.issueUpdateDelegate = self
        
        //register the custom table view cell
        tableView.register(UINib(nibName: "CreateIssueTableViewCell", bundle: nil), forCellReuseIdentifier: "createIssueCustomCell")
        
        possiblySetIssueOnEnter()
        setAssigneePickerData()
        setAssigneeRolesData()
        stylizeTextBoxes()
        setDescHeightOnLoad()
        tapToDismiss()
    }
    
    private func tapToDismiss()
    {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        //fix for auto dismiss on tapping table view
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
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
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.borderColor = UIColor.black.cgColor
        titleTextField.layer.cornerRadius = 5
        titleTextField.delegate = self
        titleTextField.addDismissButton(target: self, selector: #selector(UIView.endEditing))
        
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.delegate = self
        descriptionTextView.addDismissButton(target: self, selector: #selector(UIView.endEditing))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pickersContainerView.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if hasBeenEdited
        {
            save()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        let orientBeforeTransition = UIApplication.shared.statusBarOrientation
        let wasLandscape = orientBeforeTransition == .landscapeLeft || orientBeforeTransition == .landscapeRight
        setDescriptionHeight(wasLandscape)
    }
    
    private func setDescHeightOnLoad()
    {
        let orientation = UIApplication.shared.statusBarOrientation
        let isPortrait = orientation == .portrait || orientation == .portraitUpsideDown
        setDescriptionHeight(isPortrait)
    }
    
    private func setDescriptionHeight(_ isPortrait: Bool)
    {
        let h: CGFloat
        let model = UIDevice.current.model.lowercased()
        if model.contains("ipad")
        {
            h = CGFloat(K.portraitDescHeight)
        }
        else
        {
            if isPortrait
            {
                h = CGFloat(K.portraitDescHeight)
            }
            else
            {
                h = CGFloat(K.landscapeDescHeight)
            }
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
            if let dueDate = safeIssue.dueDate
            {
                tableCellChosenVals[dueDateTag] = K.convertDateToString(date: dueDate)
            }
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
        if let dueDate = issue.dueDate
        {
            dueDatePicker.setDate(dueDate, animated: true)
        }
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
            
            let dateSelected = tableCellChosenVals[dueDateTag]
            
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
    
    private func showOkAlert(title: String, msg: String)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
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

extension DetailViewController: IssueUpdateDelegate
{
    func onIssueUpdateSuccess() {
        saveButton.backgroundColor = .green
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.setTitle("Saved!", for: .normal)
        let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(resetSaveButtonUI), userInfo: nil, repeats: false)
        //reset this so it doesn't save again on leave view
        hasBeenEdited = false
    }
    
    @objc func resetSaveButtonUI()
    {
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = UIColor(named: "BrandPurple")
    }
    
    func onIssueUpdateError(error: String) {
        showOkAlert(title: "Error", msg: error)
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
        hasBeenEdited = true
    }
}

extension DetailViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hasBeenEdited = true
    }
}

extension DetailViewController: UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView) {
        hasBeenEdited = true
    }
}
