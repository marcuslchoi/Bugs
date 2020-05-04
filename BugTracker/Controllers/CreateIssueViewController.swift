//
//  CreateIssueViewController.swift
//  BugTracker
//
//  Created by Marcus Choi on 5/4/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import UIKit

class CreateIssueViewController: UIViewController {

    let cellTitles:[String] = ["Issue Type", "Assignee","Due Date"]
    //issue type, assignee, due date
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension CreateIssueViewController: UITableViewDelegate
{
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "createIssueCell", for: indexPath)
        cell.textLabel?.text = cellTitles[indexPath.row]
        return cell
    }
    
    
}
