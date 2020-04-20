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
    let db = Firestore.firestore()
    private var projects: [Project] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        loadProjects()
    }
    
    private func loadProjects()
    {
        let collection = db.collection("Projects")//.order(by: "title")
        //add a listener to the collection in case it gets updated elsewhere
        collection.addSnapshotListener
        { (querySnapshot, error) in
            self.projects = []
            if let e = error
            {
                print("Error getting docs! \(e)")
            }
            else
            {
                if let snapshotDocs = querySnapshot?.documents
                {
                    for doc in snapshotDocs
                    {
                        let data = doc.data() //dictionary
                        let project = Project(id: data["id"] as! String, users: ["todo"], modules: ["todo"])
                        self.projects.append(project)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            let indexPath = IndexPath(row: self.projects.count - 1, section: 0)
                            //self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                    }
                }
            }
        }
    }
}

extension ChooseProjectViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("todo: go to issues for project \(projects[indexPath.row].id)")
        performSegue(withIdentifier: "ProjectsToMaster", sender: self)
    }
}

extension ChooseProjectViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let project = projects[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath)
        
        cell.textLabel?.text = project.id
        return cell
    }
    
    
}
