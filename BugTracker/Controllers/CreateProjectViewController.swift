//
//  CreateProjectViewController.swift
//  BugTracker
//
//  Created by Marcus Choi on 4/17/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import UIKit
import Firebase
class CreateProjectViewController: UIViewController {

    @IBOutlet weak var projectNameTextField: UITextField!
    
    @IBOutlet weak var usersTextField: UITextField!
    
    @IBOutlet weak var modulesTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    let db = Firestore.firestore()
    var projects:[Project] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        loadProjects()
    }
    
    func loadProjects()
    {
        projects = []
        
        db.collection("Projects").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    @IBAction func createButtonPress(_ sender: Any)
    {
        var status = "please enter a project name"
        if let projName = projectNameTextField.text
        {
            if projName != ""
            {
                let currentUser = Auth.auth().currentUser
                if currentUser == nil
                {
                    status = "current user is nil! todo login"
                }
                else
                {
                    let myEmail = currentUser!.email
                    let project = Project(id: "test-Id", title: projName, users: [myEmail!], modules: ["test module"])
                    
                    let projectsColl = db.collection("Projects")
                    //add the data to database collection
                    //projectsColl.addDocument(data: ["id": project.id, "title": project.title, "users": project.users, "modules": project.modules])
                    projectsColl.document(project.id).setData(["title": project.title, "users": project.users, "modules": project.modules])
                    {
                        (error) in
                        if let e = error
                        {
                            self.statusLabel.text = e.localizedDescription
                        }
                        else
                        {
                            self.statusLabel.text = "Created project \(projName)"
                        }
                    }
                }
            }
        }
        statusLabel.text = status
    }
    
    
    @IBAction func skipButtonPress(_ sender: Any)
    {
        performSegue(withIdentifier: "createProjectToProjects", sender: self)
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
