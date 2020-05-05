//
//  CreateIssueViewController.swift
//  BugTracker
//
//  Created by Marcus Choi on 5/4/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import UIKit

class CreateIssueViewController: UIViewController {

    private var cellTitles:[String] = ["Issue Type", "Assignee","Due Date"]
    private var cellDetails:[String] = ["","",""]
    
    @IBOutlet weak var issueTypePicker: UIPickerView!
    
    private let issueTypesDataSource = K.getIssueTypes()
    private var tableViewRow: Int?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var pickerBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "CreateIssueTableViewCell", bundle: nil), forCellReuseIdentifier: "createIssueCustomCell")
    }
}

extension CreateIssueViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewRow = indexPath.row
        pickerBottomConstraint.constant = 0
    }
}

extension CreateIssueViewController: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "createIssueCustomCell", for: indexPath) as! CreateIssueTableViewCell
        cell.titleLabel?.text = cellTitles[indexPath.row]
        cell.detailLabel?.text = cellDetails[indexPath.row]
        return cell
    }
}

extension CreateIssueViewController: UIPickerViewDelegate
{
    
}

extension CreateIssueViewController: UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return issueTypesDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return issueTypesDataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //let indexPath = IndexPath(row: 0, section: 0)
        cellDetails[0] = issueTypesDataSource[row]
        tableView.reloadData()
    }
}
