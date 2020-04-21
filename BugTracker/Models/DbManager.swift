//
//  DbManager.swift
//  BugTracker
//
//  Created by Marcus Choi on 4/20/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import Foundation
import Firebase

class DbManager
{
    var delegate: DbManagerDelegate?
    private let db = Firestore.firestore()

    private var projects:[Project] = []
    var Projects: [Project]
    {
        get
        {
            return projects
        }
    }
    
    static var instance = DbManager()
    private init()
    {
        loadProjects()
    }
    
    private func loadProjects()
    {
        let collection = db.collection("Projects")
        collection.addSnapshotListener { (querySnapshot, err) in
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
                self.projects = []
                for document in querySnapshot!.documents
                {
                    let id = document.documentID
                    let data = document.data()
                    let users = data["users"]
                    let modules = data["modules"]
                    
                    let project = Project(id: id, users: ["todo"], modules: ["todo"])
                    self.projects.append(project)
                    //print("\(document.documentID) => \(document.data())")
                }
                self.delegate?.onProjectsLoaded()
            }
        }
    }
    
    func checkIfUniqueProjectId(_ projectId: String) -> Bool
    {
        for project in projects
        {
            if project.id == projectId
            {
                return false
            }
        }
        return true
    }
    
    ///return status
    func tryCreateProject(projName: String) -> String
    {
        var status = "please enter a project name"
        if projName != ""
        {
            if !checkIfUniqueProjectId(projName)
            {
                status = "please enter a unique project name"
            }
            else //create the project
            {
                let currentUser = Auth.auth().currentUser
                if currentUser == nil
                {
                    status = "current user is nil! todo login"
                }
                else
                {
                    let myEmail = currentUser!.email
                    let project = Project(id: projName, users: [myEmail!], modules: ["test module"])
                    
                    let projectsColl = db.collection("Projects")
                    //add the data to database collection
                    projectsColl.document(project.id).setData(["users": project.users, "modules": project.modules])
                    {
                        (error) in
                        if let e = error
                        {
                            self.delegate?.onCreateProjectError(description: e.localizedDescription)
                            //print(e.localizedDescription)
                        }
                        else
                        {
                            self.delegate?.onCreateProjectSuccess(projectName: projName)
                        }
                    }
                }
            }
        }
        return status
    }
}

protocol DbManagerDelegate
{
    func onCreateProjectError(description: String)
    func onCreateProjectSuccess(projectName: String)
    func onProjectsLoaded()
}

extension DbManagerDelegate
{
    func onCreateProjectError(description: String)
    {
        print("default: onCreateProjectError")
    }
    
    func onCreateProjectSuccess(projectName: String)
    {
        print("default: onCreateProjectSuccess")
    }
    
    func onProjectsLoaded()
    {
        print("default: onProjectsLoaded")
    }
}
