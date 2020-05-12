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
    
    private let issueTag = K.CreateIssue.issueTypePickerTag
    private let assigneeTag = K.CreateIssue.assigneePickerTag
    private let dueDateTag = K.CreateIssue.dueDatePickerTag
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var descriptionTextViewHeight: NSLayoutConstraint!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        dbManager.createIssueDelegate = self
        
        //register the custom table view cell
        tableView.register(UINib(nibName: "CreateIssueTableViewCell", bundle: nil), forCellReuseIdentifier: "createIssueCustomCell")
        stylizeTextBoxes()
        setDescHeightOnLoad()
        tapToDismiss()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //to be informed of add issue success / fail
        pickersContainerView.isHidden = true
        
        let issuesSelectedRow = issueTypePicker.selectedRow(inComponent: 0)
        tableCellChosenVals[issueTag] = issueTypesDataSource[issuesSelectedRow]
        
        //set assignee picker data, initial selection
        if let users = dbManager.CurrentProject?.users, let myEmail = AuthManager.instance.currentUserEmail
        {
            assigneesDataSource = users
            if let index = assigneesDataSource.firstIndex(of: myEmail)
            {
                assigneePicker.selectRow(index, inComponent: 0, animated: true)
                tableCellChosenVals[assigneeTag] = myEmail
            }
        }
        tableView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        let orientBeforeTransition = UIApplication.shared.statusBarOrientation
        let wasLandscape = orientBeforeTransition == .landscapeLeft || orientBeforeTransition == .landscapeRight
        setDescriptionHeight(wasLandscape)
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
    
    private func stylizeTextBoxes()
    {
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        descriptionTextView.layer.cornerRadius = 5

        titleTextField.layer.borderWidth = 1
        titleTextField.layer.borderColor = UIColor.black.cgColor
        titleTextField.layer.cornerRadius = 5
        titleTextField.delegate = self
    }
    
    private func showPicker(tag: Int)
    {
        createIssueButton.isHidden = true
        switch (tag)
        {
            case issueTag:
                issueTypePicker.isHidden = false
                assigneePicker.isHidden = true
                dueDatePicker.isHidden = true
            break
            case assigneeTag:
                issueTypePicker.isHidden = true
                assigneePicker.isHidden = false
                dueDatePicker.isHidden = true
            break
            case dueDateTag:
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
            tableCellChosenVals[dueDateTag] = K.convertDateToString(date: date)
            tableView.reloadData()
        }
        pickersContainerView.isHidden = true
        createIssueButton.isHidden = false
    }
    
    @IBAction func createIssueButtonPress(_ sender: Any)
    {
        if let title = titleTextField?.text, title != ""
        {
            let issueType = IssueType(rawValue: tableCellChosenVals[issueTag])
            dbManager.addIssue(title, descriptionTextView?.text ?? "", issueType ?? IssueType.Bug, tableCellChosenVals[assigneeTag], tableCellChosenVals[dueDateTag])
        }
        else
        {
            showNoTitleAlert()
        }
    }
    
    private func showNoTitleAlert()
    {
        let alert = UIAlertController(title: "Please add a title.", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            print("OK")
        }
        alert.addAction(okAction)
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
        if pickerView.tag == issueTag
        {
            return issueTypesDataSource.count
        }
        else if pickerView.tag == assigneeTag
        {
            return assigneesDataSource.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == issueTag
        {
            return issueTypesDataSource[row]
        }
        else if pickerView.tag == assigneeTag
        {
            return assigneesDataSource[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let chosenVal:String
        
        if pickerView.tag == issueTag
        {
            chosenVal = issueTypesDataSource[row]
        }
        else //if pickerView.tag == assigneeTag
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
        //just added first issue
        if dbManager.Issues.count == 1
        {
            performSegue(withIdentifier: "CreateIssueToMaster", sender: self)
        }
        else
        {
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func showAddIssueFailAlert(name: String, error: String)
    {
        let alert = UIAlertController(title: "Add \(name) Failed", message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            print("OK")
        }
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

extension CreateIssueViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
