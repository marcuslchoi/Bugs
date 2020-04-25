//
//  DetailViewController.swift
//  BugTracker
//
//  Created by Marcus Choi on 4/15/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var statusPickerView: UIPickerView!
    
    @IBOutlet weak var assigneePickerView: UIPickerView!
    
    
    @IBOutlet weak var reporterLabel: UILabel!
    
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    
    let statusPickerData: [String] = K.getIssueStatuses()
    
    //the issue is set when the user selects it from the master view controller
    var issue: Issue?
    {
        didSet
        {
            refreshUI()
        }
    }

    private func refreshUI()
    {
        if let safeIssue = issue
        {
            loadViewIfNeeded()
            title = safeIssue.id
            titleLabel.text = safeIssue.title
            reporterLabel.text = "Reporter: \(safeIssue.reporter)"
            descriptionTextView.text = safeIssue.description
            setStatusPickerInitialSelection(issue: safeIssue)
            setDueDatePickerInitialSelection(issue: safeIssue)
        }
    }
    
    //the due date picker selection on entering the view
    //equals the due date of the issue in the db
    private func setDueDatePickerInitialSelection(issue: Issue)
    {
        dueDatePicker.setDate(issue.dueDate, animated: true)
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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func saveButtonPress(_ sender: Any)
    {
        if let issueId = issue?.id
        {
            let statusSelectedRow = statusPickerView.selectedRow(inComponent: 0)
            let status = statusPickerData[statusSelectedRow]
            
            let dateSelected = K.convertDateToString(date: dueDatePicker.date)
            
            DbManager.instance.updateIssue(issueId: issueId, title: titleLabel.text ?? "default title", description: descriptionTextView.text, statusString: status, dueDate: dateSelected)
        }
        else
        {
            print("saveButtonPress error: issue id is nil!")
        }
    }
}

//MARK: - Extensions
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
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statusPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        statusPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
}
