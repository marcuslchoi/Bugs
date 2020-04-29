//
//  Project.swift
//  BugTracker
//
//  Created by Marcus Choi on 4/17/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import Foundation
struct Project
{
    let id: String
    let name: String
    var description: String
    var users: [String]
    var issues: [Issue]?
}
