//
//  MasterViewController.swift
//  BugTracker
//
//  Created by Marcus Choi on 4/15/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var delegate: IssueSelectionDelegate?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = editButtonItem

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    @IBAction func addButtonPress(_ sender: UIBarButtonItem)
    {
        showAddIssueAlert()
    }
    
    private func showAddIssueAlert()
    {
        let alert = UIAlertController(title: "Add Issue", message: "", preferredStyle: .alert)
        
        var titleTextfield = UITextField()
        var descTextfield = UITextField()
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            
            if let title = titleTextfield.text
            {
                let description = descTextfield.text ?? ""
                DbManager.instance.addIssue(title, description, IssueType.Bug)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            print("cancel")
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { (textField) in
            titleTextfield = textField
            titleTextfield.placeholder = "Title"
        }
        
        alert.addTextField { (textField) in
            descTextfield = textField
            descTextfield.placeholder = "Description"
        }
        
        //todo add a picker for issue type:
        //austinvanalfen.wixsite.com/iosdeveloper/single-post/2016/11/22/UIPicker-inside-an-UIAlertController
//        alert.addTextField { (textField) in
//            textField.inputView = UIPickerView()
//        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        DbManager.instance.delegate = self
        loadIssuesInTable()
        title = DbManager.instance.getCurrentProjectId()
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                //let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                //controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
                
                delegate = detailViewController
            }
        }
    }
    
    //show the issues in the table
    private func loadIssuesInTable()
    {
        let issues = DbManager.instance.Issues
        if issues.count > 0
        {
            for i in 0...issues.count - 1
            {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    let indexPath = IndexPath(row: i, section: 0)
                }
            }
        }
        else
        {
            print("no issues for current project")
        }
    }

    // MARK: - Table View
    
    //on issue selected, call the delegate method for detail view to refresh
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let issues = DbManager.instance.Issues
        let selectedIssue = issues[indexPath.row]
        delegate?.onIssueSelected(selectedIssue: selectedIssue)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DbManager.instance.Issues.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "issueCell", for: indexPath)
        
        let issues = DbManager.instance.Issues
        let issue = issues[indexPath.row]
        cell.textLabel!.text = "\(issue.id): \(issue.title)"
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}

extension MasterViewController: DbManagerDelegate
{
    func onIssuesLoaded() {
        print("MasterViewController reloaded issues since they were updated")
        loadIssuesInTable()
    }
}

protocol IssueSelectionDelegate
{
    func onIssueSelected(selectedIssue: Issue)
}

