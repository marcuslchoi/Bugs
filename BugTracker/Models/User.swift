//
//  User.swift
//  BugTracker
//
//  Created by Marcus Choi on 4/27/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import Foundation

enum UserRole: CaseIterable
{
    case ProjectLead
    case Developer
    case DBA
    case Tester
}

extension UserRole: RawRepresentable
{
    typealias RawValue = String
    init?(rawValue: RawValue)
    {
        switch rawValue
        {
            case "Project Lead": self = .ProjectLead
            case "Developer": self = .Developer
            case "DBA": self = .DBA
            case "Tester": self = .Tester
            default: return nil
        }
    }
    
    var rawValue: RawValue
    {
        switch self
        {
            case .ProjectLead: return "Project Lead"
            case .Developer: return "Developer"
            case .DBA: return "DBA"
            case .Tester: return "Tester"
        }
    }
}

struct User
{
    let email: String
    //var projects: [Project] = []
}
