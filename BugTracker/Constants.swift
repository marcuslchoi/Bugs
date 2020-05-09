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
    static let portraitDescHeight = 200
    static let landscapeDescHeight = 80
    struct IssueDetail
    {
        static let statusPickerTag = 0
        static let assigneePickerTag = 1
        static let dueDatePickerTag = 2
        static let assigneeEmailComponent = 0
    }
    
    struct CreateIssue
    {
        static let issueTypePickerTag = 0
        static let assigneePickerTag = 1
        static let dueDatePickerTag = 2
    }
    
    static let dateFormat = "MM-dd-yyyy"
    static func getIssueStatuses() -> [String]
    {
        var statuses: [String] = []
        for status in IssueStatus.allCases
        {
            statuses.append(status.rawValue)
        }
        return statuses
    }
    
    static func getIssueTypes() -> [String]
    {
        var types: [String] = []
        for type in IssueType.allCases
        {
            types.append(type.rawValue)
        }
        return types
    }
    
    static func getUserRoles() -> [String]
    {
        var roles: [String] = []
        for role in UserRole.allCases
        {
            roles.append(role.rawValue)
        }
        return roles
    }
    
    static func convertDateToString(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
    
    static func convertStringToDate(dateStr: String) -> Date?
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: dateStr)
    }
}
