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
    private let db = Firestore.firestore()
    
    private var projects:[Project] = []
    
    static var instance = DbManager()
    private init()
    {
        loadProjects()
    }
    
    func loadProjects()
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
}
