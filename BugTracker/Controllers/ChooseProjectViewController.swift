//
//  ChooseProjectViewController.swift
//  BugTracker
//
//  Created by Marcus Choi on 4/18/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import UIKit
import Firebase

class ChooseProjectViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let dbManager = DbManager.instance
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredProjects: [Project] = []
    
    private var isSearchBarEmpty: Bool
    {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private var isFiltering: Bool
    {
        return searchController.isActive && !isSearchBarEmpty
    }

    private func filterContentForSearchText(_ searchText: String)
    {
        filteredProjects = dbManager.Projects.filter
        { (project: Project) -> Bool in

            let txt = searchText.lowercased()
            return
                project.name.lowercased().contains(txt) ||
                project.description.lowercased().contains(txt)
        }
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Projects"
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dbManager.delegate = self
        loadProjectsInTable()
        setSearchControllerProps()
    }
    
    private func setSearchControllerProps()
    {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Projects"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    //show the projects in the table
    private func loadProjectsInTable()
    {
        let projects = dbManager.Projects
        if !projects.isEmpty
        {
            for i in 0...projects.count - 1
            {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    let indexPath = IndexPath(row: i, section: 0)
                    //self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }
            }
        }
        else
        {
            print("loadProjectsInTable: no projects to load!")
        }
    }
}

//MARK: - DbManagerDelegate extension
extension ChooseProjectViewController: DbManagerDelegate
{
    func onProjectsLoaded() {
        loadProjectsInTable()
        print("ChooseProjectViewController: projects loaded in table!")
    }
}

extension ChooseProjectViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let project: Project
        if isFiltering
        {
            project = filteredProjects[indexPath.row]
        }
        else
        {
            project = dbManager.Projects[indexPath.row]
        }

        dbManager.setCurrentProjectId(id: project.id)
        dbManager.getIssues(for: project.id)
        
        performSegue(withIdentifier: "ProjectsToMaster", sender: self)
    }
}

extension ChooseProjectViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering
        {
            return filteredProjects.count
        }
        return dbManager.Projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let project: Project
        if isFiltering
        {
            project = filteredProjects[indexPath.row]
        }
        else
        {
            project = dbManager.Projects[indexPath.row]
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath)
        
        //populate the cell's text
        cell.textLabel?.text = project.name
        cell.detailTextLabel?.text = project.description
        return cell
    }
}

extension ChooseProjectViewController: UISearchResultsUpdating
{
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
