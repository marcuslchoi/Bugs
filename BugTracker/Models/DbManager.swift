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
    //this delegate used only for CreateIssueViewController
    var createIssueDelegate: CreateIssueDelegate?
    //this delegate used only for ProjectSettingsViewController
    var projectSettingsManagerDelegate: ProjectSettingsManagerDelegate?
    
    var issueUpdateDelegate: IssueUpdateDelegate?
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
                    //note: since issues is a property of DbManager, this does nothing
                    //but is here just to show the relationship
                    currProject.issues = issues
                    return currProject
                }
            }
            return nil
        }
    }
    
    private var issues: [Issue] = []
    var Issues: [Issue]
    {
        get
        {
            return issues
        }
    }
    
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
                    self.delegate?.onProjectsLoadError(error: err.localizedDescription)
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
                        let roles = data["roles"] as? [String]
                        let desc = data["description"] as? String
                        
                        if let safeUsers = users, let safeRoles = roles, let safeName = name
                        {
                            let project = Project(id: id, name: safeName, description: desc ?? "", users: safeUsers, roles: safeRoles)
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
            if project.name.lowercased() == name.lowercased()
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
        if !checkIfUniqueProjectName(projName)
        {
            status = "\(projName) already exists. Please choose a different name."
        }
        else //create the project
        {
            let currentUser = Auth.auth().currentUser
            if currentUser == nil
            {
                status = "Error: You are not logged in."
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
                self.projectSettingsManagerDelegate?.onUpdateProjectError(errorStr: e.localizedDescription)
            }
            else
            {
                print("updateProject success: \(project.name) updated")
                self.projectSettingsManagerDelegate?.onUpdateProjectSuccess()
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
                self.delegate?.onIssuesLoadError(error: err.localizedDescription)
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
                        let issue = Issue(id: id, reporter: r, assignedTo: a, status: IssueStatus(rawValue: safeStatus) ?? IssueStatus.Open, type: IssueType(rawValue: safeType) ?? IssueType.Bug, title: t, description: d, dueDate: date)
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
    
    func test_CreateNextIssueId(for type: IssueType) -> String
    {
        //issues = 
        return createNextIssueId(for: type)
    }
    
    //create a new id for the issue being added
    private func createNextIssueId(for type: IssueType) -> String
    {
        var searchString = ""
        switch(type)
        {
            case IssueType.Bug:
                searchString = K.Issues.bugPrefix
                break;
            case IssueType.Task:
                searchString = K.Issues.taskPrefix
                break;
            case IssueType.Feature:
                searchString = K.Issues.featurePrefix
                break;
            case IssueType.Improvement:
                searchString = K.Issues.improvementPrefix
                break;
            case IssueType.Epic:
                searchString = K.Issues.epicPrefix
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
    func addIssue(_ title: String, _ description: String, _ type: IssueType, _ assignee: String, _ dueDate: String)
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
                issuesRef.document(id).setData(["reporter": safeEmail, "assignedTo": assignee, "title": title, "description": description,"status": IssueStatus.Open.rawValue, "type": type.rawValue, "dueDate": dueDate ])
                { (error) in
                    if let e = error
                    {
                        print("addIssue error for \(title): \(e.localizedDescription)")
                        self.createIssueDelegate?.onAddIssueFail(name: title, error: e.localizedDescription)
                    }
                    else
                    {
                        print("addIssue success: \(title) added")
                        self.createIssueDelegate?.onAddIssueSuccess(name: title)
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
                    self.issueUpdateDelegate?.onIssueUpdateError(error: e.localizedDescription)
                }
                else
                {
                    print("updateIssue success: \(title) updated")
                    self.issueUpdateDelegate?.onIssueUpdateSuccess()
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
            self.projectSettingsManagerDelegate?.onAddEmailUserToProjectError(email: email, errorStr: "\(email) is already on this project.")
            return;
        }
        
        let allUsers = db.collection("AllUsers")
        let userRef = allUsers.document(email)
        userRef.getDocument { (doc, error) in
            if let e = error
            {
                self.projectSettingsManagerDelegate?.onAddEmailUserToProjectError(email: email, errorStr: e.localizedDescription)
            }
            else if let safeDoc = doc, safeDoc.exists
            {
                let dataDescription = safeDoc.data().map(String.init(describing:)) ?? "nil"
                print("tryAddEmailUserToProject: \(dataDescription) user exists in my db")
                self.updateProjectAddUser(projectId: projectId, email: email, roleStr: roleStr)
            }
            else
            {
                self.projectSettingsManagerDelegate?.onAddEmailUserToProjectError(email: email, errorStr: "\(email) is not registered. Please ask them to register in order to be added to the project.")
            }
        }
    }
    
    func updateUserRoleOnProject(projectId: String, email: String, roleStr: String)
    {
        //todo error UI
        if var project = getProject(with: projectId)
        {
            var roles = project.roles
            let users = project.users
            if let index = users.firstIndex(of: email)
            {
                if roles.count > index
                {
                    if roles[index] == roleStr
                    {
                        print("role already set to \(roleStr)")
                        return;
                    }
                    else
                    {
                        let projectRef = db.collection("Projects").document(projectId)
                        roles[index] = roleStr
                        
                        projectRef.updateData(["roles": roles]) { (error) in
                            if let e = error
                            {
                                self.projectSettingsManagerDelegate?.onUpdateUserRoleOnProjectError(email: email, errorStr: e.localizedDescription)
                            }
                            else
                            {
                                self.projectSettingsManagerDelegate?.onUpdateUserRoleOnProjectSuccess(email: email)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //add the user to the project in db
    private func updateProjectAddUser(projectId: String, email: String, roleStr: String)
    {
        let projectRef = db.collection("Projects").document(projectId)
        //todo error UI
        if var roles = getProject(with: projectId)?.roles
        {
            //note: can't use arrayUnion for roles because it only adds unique values
            roles.append(roleStr)
            projectRef.updateData(["users": FieldValue.arrayUnion([email]), "roles": roles]) { (error) in
                if let e = error
                {
                    self.projectSettingsManagerDelegate?.onAddEmailUserToProjectError(email: email, errorStr: e.localizedDescription)
                }
                else
                {
                    self.projectSettingsManagerDelegate?.onAddEmailUserToProjectSuccess(email: email)
                }
            }
        }
        else
        {
            print("updateProjectAddUser error: project with id \(projectId) does not exist")
        }
    }
}

//MARK: - DbManager delegate
protocol DbManagerDelegate
{
    func onCreateProjectError(description: String)
    func onCreateProjectSuccess(projectName: String)
    
    func onProjectsLoaded()
    func onProjectsLoadError(error: String)
    
    func onIssuesLoaded()
    func onIssuesLoadError(error: String)
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
    
    func onProjectsLoadError(error: String)
    {
        print("default: onProjectsLoadError")
    }
    
    func onIssuesLoaded()
    {
        print("default: onIssuesLoaded")
    }
    
    func onIssuesLoadError(error: String)
    {
        print("default: onIssuesLoadError")
    }
}

//MARK: - Create Issue Delegate
//todo this should be in a separate class, CreateIssueManager
protocol CreateIssueDelegate
{
    func onAddIssueSuccess(name: String)
    func onAddIssueFail(name: String, error: String)
}

protocol IssueUpdateDelegate
{
    func onIssueUpdateSuccess()
    func onIssueUpdateError(error: String)
}

protocol ProjectSettingsManagerDelegate
{
    func onAddEmailUserToProjectSuccess(email: String)
    func onAddEmailUserToProjectError(email: String, errorStr: String)
    func onUpdateUserRoleOnProjectSuccess(email: String)
    func onUpdateUserRoleOnProjectError(email: String, errorStr: String)
    func onUpdateProjectSuccess()
    func onUpdateProjectError(errorStr: String)
}
