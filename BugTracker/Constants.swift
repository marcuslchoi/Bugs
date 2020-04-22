//
//  Constants.swift
//  BugTracker
//
//  Created by Marcus Choi on 4/22/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import Foundation

struct K
{
    static func getIssueStatuses() -> [String]
    {
        var statuses: [String] = []
        for status in IssueStatus.allCases
        {
            statuses.append(status.rawValue)
        }
        return statuses
    }
}
