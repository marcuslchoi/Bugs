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

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Projects"
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DbManager.instance.delegate = self
        loadProjectsInTable()
    }
    
    //show the projects in the table
    private func loadProjectsInTable()
    {
        let projects = DbManager.instance.Projects
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
        let dbManager = DbManager.instance
        let project = dbManager.Projects[indexPath.row]
        //let projectName = project.namo
        //print("going to issues for project \(projectName)")
        
        dbManager.setCurrentProjectId(id: project.id)
        dbManager.getIssues(for: project.id)
        
        performSegue(withIdentifier: "ProjectsToMaster", sender: self)
    }
}

extension ChooseProjectViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DbManager.instance.Projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let project = DbManager.instance.Projects[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath)
        
        //populate the cell's text
        cell.textLabel?.text = project.name
        return cell
    }
}
