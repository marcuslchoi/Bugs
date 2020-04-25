//
//  Issue.swift
//  BugTracker
//
//  Created by Marcus Choi on 4/15/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import Foundation
enum IssueType: String, CaseIterable
{
    case Bug
    case Task
    case Feature
}

enum IssueStatus: String, CaseIterable
{
    case Open 
    case InProgress
    case Closed
}

struct Issue
{
    let id: String
    let reporter: String
    var assignedTo: String
    var status: IssueStatus
    let type: IssueType
    var title:String
    var description:String
    var dueDate: Date

//    let module: String
//    var dueDate: Date
//    var comments: [String]
}
