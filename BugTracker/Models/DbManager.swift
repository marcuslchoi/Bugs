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
    
    //this is the project that the user has chosen
    private var currentProjectId: String?
    
    private var issues: [Issue] = []
    var Issues: [Issue]
    {
        get
        {
            return issues
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
                    let users = data["users"] as? [String]
                    let modules = data["modules"] as? [String]
                    
                    if let safeUsers = users, let safeModules = modules
                    {
                        let project = Project(id: id, users: safeUsers, modules: safeModules)
                        self.projects.append(project)
                    }
                    else
                    {
                        print("load projects error: users or modules is not a [String]")
                    }
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
                    let project = Project(id: projName, users: [myEmail!, "another@eml.com"], modules: ["test module"])
                    
                    let projectsRef = db.collection("Projects")
                    //add the data to database collection
                    projectsRef.document(project.id).setData(["users": project.users, "modules": project.modules])
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
    
    func setCurrentProjectId(to projectId: String)
    {
        currentProjectId = projectId
    }
    
    func getIssues(for projectId: String)
    {
        let projectRef = db.collection("Projects").document(projectId)
        let issuesRef = projectRef.collection("Issues")
        issuesRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err
            {
                print("Error getting issues: \(err)")
            }
            else
            {
                self.issues = []
                for document in querySnapshot!.documents
                {
                    let id = document.documentID
                    let data = document.data()
                    
                    let type = data["type"] as? String
                    let description = data["description"] as? String
                    let title = data["title"] as? String
                    let status = data["status"] as? String
                    let assignedTo = data["assignedTo"] as? String
                    let reporter = data["reporter"] as? String
                    
                    if let safeType = type, let safeStatus = status, let d = description, let t = title, let a = assignedTo, let r = reporter
                    {
                        let issue = Issue(id: id, reporter: r, assignedTo: a, status: IssueStatus(rawValue: safeStatus) ?? IssueStatus.Open, type: IssueType(rawValue: safeType) ?? IssueType.Bug, title: t, description: d)
                        self.issues.append(issue)
                    }
                    else
                    {
                        print("error! issue \(id) has a nil value")
                    }
                }
                self.delegate?.onIssuesLoaded()
            }
        }
    }
    
    private func getNextIssueId(for type: IssueType) -> String
    {
        return "B-3"
    }
    
    func addIssue(_ title: String, _ description: String, _ type: IssueType)
    {
        if let projectId = currentProjectId
        {
            let projectRef = db.collection("Projects").document(projectId)
            let issuesRef = projectRef.collection("Issues")
            let myEmail = Auth.auth().currentUser?.email
            
            if let safeEmail = myEmail
            {
                //add the issue
                let id = getNextIssueId(for: type)
                issuesRef.document(id).setData(["reporter": safeEmail, "assignedTo": safeEmail, "title": title, "description": description,"status": IssueStatus.Open.rawValue, "type": type.rawValue ])
            }
            else
            {
                print("addIssue error: current user is nil")
            }
        }
        else
        {
            print("addIssue error: currentProjectId is nil")
        }
    }
    
    func createTestBugs(projectId: String)
    {
        let projectRef = db.collection("Projects").document(projectId)
        let issuesRef = projectRef.collection("Issues")
        let me = Auth.auth().currentUser!.email!
        
        //issuesRef.document("B-1").setData(["reporter": me]) //"status": IssueStatus.Open as String, "type": IssueType.Bug as String
        issuesRef.document("B-1").setData(["reporter": me, "assignedTo": "other", "title": "BugTitle!", "description": "hi test bug desc","status": IssueStatus.Open.rawValue, "type": IssueType.Bug.rawValue ])
        //issuesRef.document("B-2").setData(["reporter": me, "assignedTo": "2other", "status": IssueStatus.InProgress, "type": IssueType.Task, "title": "BugTitle2!", "description": "hi test bug desc2" ])
        print("created test bugs for \(projectId)")
    }
}

protocol DbManagerDelegate
{
    func onCreateProjectError(description: String)
    func onCreateProjectSuccess(projectName: String)
    func onProjectsLoaded()
    func onIssuesLoaded()
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
    
    func onIssuesLoaded()
    {
        print("default: onIssuesLoaded")
    }
}
