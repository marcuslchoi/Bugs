//
//  User.swift
//  BugTracker
//
//  Created by Marcus Choi on 4/27/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import Foundation

enum UserRole: String, CaseIterable
{
    case ProjectLead
    case DBA
    case Developer
    case Tester
}

struct User
{
    let email: String
    //var projects: [Project] = []
}
