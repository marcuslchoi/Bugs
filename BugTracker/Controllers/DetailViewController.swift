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
    
    var statusPickerData: [String] = []
    var issue: Issue?
    {
        didSet
        {
            refreshUI()
        }
    }
    
    private func refreshUI()
    {
        loadViewIfNeeded()
        title = issue?.id
        titleLabel.text = issue?.title
        descriptionTextView.text = issue?.description
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        statusPickerData = K.getIssueStatuses()
    }
    @IBAction func saveButtonPress(_ sender: Any)
    {
        if let issueId = issue?.id
        {
            let statusSelectedRow = statusPickerView.selectedRow(inComponent: 0)
            let status = statusPickerData[statusSelectedRow]
            DbManager.instance.updateIssue(issueId: issueId, title: titleLabel.text ?? "default title", description: descriptionTextView.text, statusString: status)
        }
    }
}

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
