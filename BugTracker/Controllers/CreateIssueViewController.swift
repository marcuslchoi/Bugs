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

    private var cellTitles:[String] = ["Issue Type", "Assignee","Due Date"]
    private var cellDetails:[String] = ["","","None"]
    
    @IBOutlet weak var issuePickerView: UIView!
    @IBOutlet weak var issueTypePicker: UIPickerView!
    
    private let issueTypesDataSource = K.getIssueTypes()
    //private var tableViewRow: Int?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "CreateIssueTableViewCell", bundle: nil), forCellReuseIdentifier: "createIssueCustomCell")
        issuePickerView.isHidden = true
        if let myEmail = AuthManager.instance.currentUserEmail
        {
            cellDetails[1] = myEmail
        }
    }
    @IBAction func issuePickerDonePress(_ sender: Any) {
        issuePickerView.isHidden = true
    }
}

extension CreateIssueViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = indexPath.row
        if selectedRow == 0
        {
            issuePickerView.isHidden = false
        }
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
