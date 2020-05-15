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
        filteredIssues = dbManager.getFilteredIssues(isSearchBarEmpty: isSearchBarEmpty, text: searchText, user: user)
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
            title = currentProject.name
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
            scopeButtonTitles.insert(K.MasterIssues.firstSearchScope, at: 0)
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
    
    private func showOkAlert(title: String, msg: String)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
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
            if issues.count > indexPath.row
            {
                selectedIssue = issues[indexPath.row]
            }
            else
            {
                //todo show alert
                print("Error! selected an issue that doesn't exist??")
                return;
            }
        }
        //the delegate is detail view controller
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
        
        let cellTitle = "\(issue.id): \(issue.title)"
        //strike through text if issue is closed
        if issue.status == IssueStatus.Closed
        {
            let attributedString: NSMutableAttributedString =  NSMutableAttributedString(string: cellTitle)
            attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributedString.length))
            cell.textLabel?.attributedText = attributedString
        }
        else
        {
            cell.textLabel?.attributedText = nil
            cell.textLabel?.text = cellTitle
        }
        
        cell.detailTextLabel?.text = "\(issue.status.rawValue): \(issue.assignedTo)"
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
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

