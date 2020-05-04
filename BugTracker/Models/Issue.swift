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
    case Improvement
    case Epic
}

enum IssueStatus: CaseIterable
{
    case Open 
    case InProgress
    case InReview
    case Closed
}

extension IssueStatus: RawRepresentable
{
    typealias RawValue = String
    init?(rawValue: RawValue)
    {
        switch rawValue
        {
            case "Open": self = .Open
            case "In Progress": self = .InProgress
            case "In Review": self = .InReview
            case "Closed": self = .Closed
            default: return nil
        }
    }
    
    var rawValue: RawValue
    {
        switch self
        {
            case .Open: return "Open"
            case .InProgress: return "In Progress"
            case .InReview: return "In Review"
            case .Closed: return "Closed"
        }
    }
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
