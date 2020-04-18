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
    
    private var projects: [Project] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension ChooseProjectViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print(indexPath.row)
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
        
        cell.textLabel?.text = "\(project.id): \(project.title)"
        return cell
    }
    
    
}
