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
    private let auth = Auth.auth()

    private var projects:[Project] = []
    var Projects: [Project]
    { get { return projects } }
    
    //this is the project that the user has chosen
    private var currentProjectId: String?
    //return the project with id == currentProjectId
    var CurrentProject: Project?
    {
        get
        {
            if let id = currentProjectId
            {
                if var currProject = getProject(with: id)
                {
                    currProject.issues = issues
                    return currProject
                }
            }
            return nil
        }
    }
    
    var issues: [Issue] = []
    
    //singleton
    static var instance = DbManager()
    private init() { }

    //MARK: - projects
    //get current user's projects from db, listen for any projects changes that user is assigned to
    func getProjects()
    {
        if let myEmail = auth.currentUser?.email
        {
            print("getProjects for \(myEmail)")
            let collection = db.collection("Projects")
            
            //note: this required a composite index with fields indexed: users Arrays name Ascending
            collection.whereField("users", arrayContains: myEmail).order(by: "name", descending: false).addSnapshotListener { (querySnapshot, err) in
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
                        let name = data["name"] as? String
                        let users = data["users"] as? [String]
                        let desc = data["description"] as? String
                        
                        if let safeUsers = users, let safeName = name
                        {
                            let project = Project(id: id, name: safeName, description: desc ?? "", users: safeUsers)
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
        else
        {
            print("getProjects error: currentUser is nil!")
        }
    }
    
    //check if user is already assigned to a project with the same name
    private func checkIfUniqueProjectName(_ name: String) -> Bool
    {
        for project in projects
        {
            if project.name == name
            {
                return false
            }
        }
        return true
    }
    
    //try to create a project in the db, return status
    func tryCreateProject(projName: String, myRoleStr: String) -> String
    {
        var status = ""
        if projName == ""
        {
            status = "Please enter a project name"
        }
        else
        {
            if !checkIfUniqueProjectName(projName)
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
                    let myEmail = currentUser!.email!
                    let users = [myEmail]
                    let roles = [myRoleStr]
                    
                    let projectsRef = db.collection("Projects")
                    //add the data to database collection
                    projectsRef.document().setData(["name": projName, "users": users, "roles": roles])
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
    
    func setCurrentProjectId(id: String)
    {
        currentProjectId = id
    }
    
    //note: use this method only after creating a new project,
    //since we don't yet have access to its id,
    //and user can't create another project with same name
    func setCurrentProjectIdWithName(projectName: String)
    {
        let index = projects.firstIndex(where: {$0.name == projectName})
        if let i = index
        {
            currentProjectId = projects[i].id
        }
    }

    //get the project with id from the projects array
    func getProject(with projectId: String) -> Project?
    {
        if let index = projects.firstIndex(where: { $0.id == projectId })
        {
            return projects[index]
        }
        return nil
    }

    //update project's data in db
    func updateProject(project: Project, description: String)
    {
        let projectRef = db.collection("Projects").document(project.id)
        //todo error UI
        projectRef.updateData(["description": description]) { (error) in
            if let e = error
            {
                print("updateProject error for \(project.name): \(e.localizedDescription)")
            }
            else
            {
                print("updateProject success: \(project.name) updated")
            }
        }
    }
}

//MARK: - issues
extension DbManager
{
    //get the issues from db for the projectId, and add listener for any project-specific issue updates
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
                    
                    if let safeType = type, let safeStatus = status, let d = description, let t = title, let a = assignedTo, let r = reporter
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
            case IssueType.Improvement:
                searchString = "I-"
                break;
            case IssueType.Epic:
                searchString = "E-"
                break;
            default:
                print("error: issue type doesn't exist!")
                break;
        }

        var count = 0
        for issue in issues
        {
            let id = issue.id
            if id.contains(searchString)
            {
                count += 1
            }
        }
        return searchString + String(count + 1)
    }
    
    //add a new issue to the db
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
    
    //on save in detail view, update issue on db
    func updateIssue(issueId: String, title: String,
                     description: String, statusString: String,
                     assignee: String, dueDate: String)
    {
        if let projectId = currentProjectId
        {
            let projectRef = db.collection("Projects").document(projectId)
            let issuesRef = projectRef.collection("Issues")
            //todo error UI
            issuesRef.document(issueId).updateData(["title": title, "description": description, "status": statusString, "assignedTo": assignee, "dueDate": dueDate]) { (error) in
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
}

//MARK: - users
extension DbManager
{
    //add a user to a self-managed Firestore db
    func addUserToMyDb(email: String)
    {
        let user = User(email: email)
        let allUsers = db.collection("AllUsers")
        let userRef = allUsers.document(email)
        userRef.setData(["email": user.email]) { (error) in
            if let e = error
            {
                print("error adding user to my db: \(email), \(e.localizedDescription)")
            }
            else
            {
                print("user added to my db: \(email)")
            }
        }
    }

    //check if user is already on the project
    private func checkIfUserOnProject(_ projectId: String, _ email: String) -> Bool
    {
        let project = getProject(with: projectId)
        if let p = project
        {
            let users = p.users
            if let index = users.firstIndex(where: { $0 == email })
            {
                return true
            }
        }
        return false
    }
    
    //check AllUsers db collection for the user, if it exists, add it to project
    func tryAddEmailUserToProject(to projectId: String, with email: String, roleStr: String)
    {
        if checkIfUserOnProject(projectId, email)
        {
            self.delegate?.onAddEmailUserToProjectError(email: email, errorStr: "\(email) is already on this project.")
            return;
        }
        
        let allUsers = db.collection("AllUsers")
        let userRef = allUsers.document(email)
        userRef.getDocument { (doc, error) in
            if let e = error
            {
                self.delegate?.onAddEmailUserToProjectError(email: email, errorStr: e.localizedDescription)
            }
            else if let safeDoc = doc, safeDoc.exists
            {
                let dataDescription = safeDoc.data().map(String.init(describing:)) ?? "nil"
                print("tryAddEmailUserToProject: \(dataDescription) user exists in my db")
                self.updateProjectAddUser(projectId: projectId, email: email, roleStr: roleStr)
            }
            else
            {
                self.delegate?.onAddEmailUserToProjectError(email: email, errorStr: "\(email) not found")
            }
        }
    }
    
    //add the user to the project in db
    private func updateProjectAddUser(projectId: String, email: String, roleStr: String)
    {
        let projectRef = db.collection("Projects").document(projectId)
        //todo error UI
        projectRef.updateData(["users": FieldValue.arrayUnion([email]), "roles": FieldValue.arrayUnion([roleStr])]) { (error) in
            if let e = error
            {
                self.delegate?.onAddEmailUserToProjectError(email: email, errorStr: e.localizedDescription)
            }
            else
            {
                self.delegate?.onAddEmailUserToProjectSuccess(email: email)
            }
        }
    }
}

//MARK: - DbManager delegate
protocol DbManagerDelegate
{
    func onCreateProjectError(description: String)
    func onCreateProjectSuccess(projectName: String)
    func onProjectsLoaded()
    func onIssuesLoaded()
    func onAddEmailUserToProjectSuccess(email: String)
    func onAddEmailUserToProjectError(email: String, errorStr: String)
}

//delegate default methods
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
    
    func onAddEmailUserToProjectSuccess(email: String)
    {
        print("default: onEmailUserExists")
    }
    
    func onAddEmailUserToProjectError(email: String, errorStr: String)
    {
        print("default: onEmailUserDoesNotExist")
    }
}
