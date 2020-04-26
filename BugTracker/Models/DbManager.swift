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
                    
                    if let safeUsers = users
                    {
                        let project = Project(id: id, users: safeUsers)
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
    func tryCreateProject(projName: String, additionalUsers: String?) -> String
    {
        var status = ""
        if projName == ""
        {
            status = "Please enter a project name"
        }
        else
        {
            if !checkIfUniqueProjectId(projName)
            {
                status = "\(projName) already exists"
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
                    var users = [myEmail!]
                    
                    //todo comma separated? or update UI
                    if let moreUsers = additionalUsers
                    {
                        users.append(moreUsers)
                    }
                    
                    let project = Project(id: projName, users: users) //, modules: ["test module"])
                    
                    let projectsRef = db.collection("Projects")
                    //add the data to database collection
                    projectsRef.document(project.id).setData(["users": project.users])
                    {
                        (error) in
                        if let e = error
                        {
                            self.delegate?.onCreateProjectError(description: e.localizedDescription)
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
    
    func getCurrentProject() -> Project?
    {
        if let index = projects.firstIndex(where: { $0.id == currentProjectId })
        {
            return projects[index]
        }
        return nil
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
                    
                    //get the due date
                    let dueDateStr = data["dueDate"] as? String
                    var date: Date? = nil
                    if let dateStr = dueDateStr
                    {
                        date = K.convertStringToDate(dateStr: dateStr)
                    }
                    
                    if let safeType = type, let safeStatus = status, let d = description, let t = title, let a = assignedTo, let r = reporter //, let safeDate = dueDateStr
                    {
                        let issue = Issue(id: id, reporter: r, assignedTo: a, status: IssueStatus(rawValue: safeStatus) ?? IssueStatus.Open, type: IssueType(rawValue: safeType) ?? IssueType.Bug, title: t, description: d, dueDate: date ?? Date())
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
    
    //create a new id for the issue being added
    private func createNextIssueId(for type: IssueType) -> String
    {
        var searchString = ""
        switch(type)
        {
            case IssueType.Bug:
                searchString = "B-"
                break;
            case IssueType.Task:
                searchString = "T-"
                break;
            case IssueType.Feature:
                searchString = "F-"
                break;
            default:
                print("error: issue type doesn't exist!")
                break;
        }
        
        var idNumbers: [Int] = []
        for issue in issues
        {
            let id = issue.id
            if id.contains(searchString)
            {
                let strings = id.components(separatedBy: "-")
                let num = Int(strings.last!)
                idNumbers.append(num!)
            }
        }
        
        var newNum = 1
        if(idNumbers.count > 0)
        {
            idNumbers.sort()
            newNum = idNumbers.last! + 1
        }
        
        return searchString + String(newNum)
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
                let id = createNextIssueId(for: type)
                //todo error UI
                issuesRef.document(id).setData(["reporter": safeEmail, "assignedTo": safeEmail, "title": title, "description": description,"status": IssueStatus.Open.rawValue, "type": type.rawValue ])
                { (error) in
                    if let e = error
                    {
                        print("addIssue error for \(title): \(e.localizedDescription)")
                    }
                    else
                    {
                        print("addIssue success: \(title) added")
                    }
                }
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
    
    //on save in detail view
    func updateIssue(issueId: String, title: String,
                     description: String, statusString: String, dueDate: String)
    {
        if let projectId = currentProjectId
        {
            let projectRef = db.collection("Projects").document(projectId)
            let issuesRef = projectRef.collection("Issues")
            //todo error UI
            issuesRef.document(issueId).updateData(["title": title, "description": description, "status": statusString, "dueDate": dueDate]) { (error) in
                if let e = error
                {
                    print("updateIssue error for \(title): \(e.localizedDescription)")
                }
                else
                {
                    print("updateIssue success: \(title) updated")
                }
            }
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
