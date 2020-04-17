//
//  Issue.swift
//  BugTracker
//
//  Created by Marcus Choi on 4/15/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import Foundation
enum IssueType
{
    case Bug
    case Task
    case Feature
}

enum IssueStatus
{
    case Open
    case InProgress
    case Closed
}

struct Issue
{
    let id: String
    let reporter: String
    let dateAdded: Date
    
    let type: IssueType
    var title:String
    var description:String
    let module: String
    var assignedTo: String
    var dueDate: Date
    var comments: [String]
    var status: IssueStatus
}
