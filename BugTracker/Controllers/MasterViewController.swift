//
//  MasterViewController.swift
//  BugTracker
//
//  Created by Marcus Choi on 4/15/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import UIKit

//this view shows the issues for the currently selected project
class MasterViewController: UITableViewController {

    let dbManager = DbManager.instance
    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var delegate: IssueSelectionDelegate?
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredIssues: [Issue] = []
    
    private var isSearchBarEmpty: Bool
    {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private var isFiltering: Bool
    {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }

    private func filterContentForSearchText(_ searchText: String, user: String? = nil)
    {
        filteredIssues = dbManager.Issues.filter
        { (issue: Issue) -> Bool in
            let isUserMatch = issue.assignedTo == user || user == "All"
            if isSearchBarEmpty
            {
                return isUserMatch
            }
            else
            {
                let txt = searchText.lowercased()
                return
                    isUserMatch &&
                    (issue.title.lowercased().contains(txt) ||
                    issue.description.lowercased().contains(txt) ||
                    issue.status.rawValue.lowercased().contains(txt) ||
                    issue.type.rawValue.lowercased().contains(txt))
            }

        }
        tableView.reloadData()
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        navigationItem.leftBarButtonItem = editButtonItem

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        dbManager.delegate = self
        loadIssuesInTable()
        if let currentProject = dbManager.CurrentProject
        {
            title = "Issues for \(currentProject.name)"
        }
        else
        {
            title = ""
            print("Error: current project is nil!")
        }
        setSearchControllerProps()
    }
    
    private func setSearchControllerProps()
    {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Issues"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        //scope buttons
        if let users = dbManager.CurrentProject?.users
        {
            var scopeButtonTitles = users
            scopeButtonTitles.insert("All", at: 0)
            searchController.searchBar.scopeButtonTitles = scopeButtonTitles
            searchController.searchBar.delegate = self
        }
    }

    @IBAction func addButtonPress(_ sender: UIBarButtonItem)
    {
        //showAddIssueAlert()
    }

    @IBAction func settingsButtonPress(_ sender: Any) {
        performSegue(withIdentifier: "IssuesToSettings", sender: self)
    }
    
    /*
    private func showAddIssueAlert()
    {
        let alert = UIAlertController(title: "Add Issue", message: "", preferredStyle: .alert)
        
        var titleTextfield = UITextField()
        var descTextfield = UITextField()
        var issueTypeTextField = UITextField()
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            
            if let title = titleTextfield.text
            {
                let description = descTextfield.text ?? ""
                
                //temp code: a way to test different issue types
                let issueTypeStr = issueTypeTextField.text ?? ""
                let issueType = self.tempGetIssueType(issueTypeStr)
                
                //self.dbManager.addIssue(title, description, issueType)
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
        
        alert.addTextField { (textField) in
            issueTypeTextField = textField
            issueTypeTextField.placeholder = "Issue type"
        }
        
        //todo add a picker for issue type:
        //austinvanalfen.wixsite.com/iosdeveloper/single-post/2016/11/22/UIPicker-inside-an-UIAlertController
//        alert.addTextField { (textField) in
//            textField.inputView = UIPickerView()
//        }
        
        present(alert, animated: true, completion: nil)
    }
    
    //temp code: a way to test different issue types
    private func tempGetIssueType(_ issueTypeStr: String) -> IssueType
    {
        var issueType: IssueType
        if issueTypeStr == "t"
        {
            issueType = IssueType.Task
        }
        else if issueTypeStr == "f"
        {
            issueType = IssueType.Feature
        }
        else if issueTypeStr == "i"
        {
            issueType = IssueType.Improvement
        }
        else if issueTypeStr == "e"
        {
            issueType = IssueType.Epic
        }
        else
        {
            issueType = IssueType.Bug
        }
        return issueType
    }
    */

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail"
        {
            if let indexPath = tableView.indexPathForSelectedRow
            {
                //let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                //controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
                
                delegate = detailViewController
            }
        }
        else if segue.identifier == "IssuesToSettings"
        {
            if let settingsVC = segue.destination as? ProjectSettingsViewController
            {
                settingsVC.cameFromIssues = true
            }
        }
    }
    
    //show the issues in the table
    private func loadIssuesInTable()
    {
        let issues = dbManager.Issues
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let selectedIssue: Issue
        if isFiltering
        {
            selectedIssue = filteredIssues[indexPath.row]
        }
        else
        {
            let issues = dbManager.Issues
            selectedIssue = issues[indexPath.row]
        }
        delegate?.onIssueSelected(selectedIssue: selectedIssue)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering
        {
            return filteredIssues.count
        }
        
        return dbManager.Issues.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "issueCell", for: indexPath)

        let issue: Issue
        if isFiltering
        {
            issue = filteredIssues[indexPath.row]
        }
        else
        {
            let issues = dbManager.Issues
            issue = issues[indexPath.row]
        }
        cell.textLabel?.text = "\(issue.id): \(issue.title)"
        cell.detailTextLabel?.text = "Assignee: \(issue.assignedTo)"
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

//MARK: - DbManagerDelegate
extension MasterViewController: DbManagerDelegate
{
    func onIssuesLoaded() {
        print("MasterViewController reloaded issues since they were updated")
        loadIssuesInTable()
    }
}

//MARK: - search bar
extension MasterViewController: UISearchResultsUpdating
{
    func updateSearchResults(for searchController: UISearchController)
    {
        let searchBar = searchController.searchBar
        let assignee = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchBar.text!, user: assignee)
    }
}

extension MasterViewController: UISearchBarDelegate
{
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
    {
        let selectedUser = searchBar.scopeButtonTitles?[selectedScope]
        filterContentForSearchText(searchBar.text!, user: selectedUser ?? nil)
    }
}

protocol IssueSelectionDelegate
{
    func onIssueSelected(selectedIssue: Issue)
}

