//
//  FirstTestCase.swift
//  BugTrackerTests
//
//  Created by Marcus Choi on 5/15/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import XCTest
@testable import BugTracker

class FirstTestCase: XCTestCase {

    let dbManager = DbManager.instance
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_createNextIssueId()
    {
        let testIssues = generateTestIssues()
        let id = dbManager.test_CreateNextIssueId(for: .Bug, testIssues)
        XCTAssertEqual(id, "B-3")
    }
    
    private func generateTestIssues() -> [Issue]
    {
        let issue0 = Issue(id: "B-1", reporter: "reporter", assignedTo: "assignee", status: .InProgress, type: .Bug, title: "title", description: "", dueDate: nil)
        let issue1 = Issue(id: "T-1", reporter: "reporter", assignedTo: "assignee", status: .InProgress, type: .Task, title: "title", description: "", dueDate: nil)
        let issue2 = Issue(id: "T-2", reporter: "reporter", assignedTo: "assignee", status: .InProgress, type: .Task, title: "title", description: "", dueDate: nil)
        let issue3 = Issue(id: "T-3", reporter: "reporter", assignedTo: "assignee", status: .InProgress, type: .Task, title: "title", description: "", dueDate: nil)
        let issue4 = Issue(id: "E-1", reporter: "reporter", assignedTo: "assignee", status: .InProgress, type: .Epic, title: "title", description: "", dueDate: nil)
        let issue5 = Issue(id: "B-2", reporter: "reporter", assignedTo: "assignee", status: .InProgress, type: .Bug, title: "title", description: "", dueDate: nil)
        
        return [issue0, issue1, issue2, issue3, issue4, issue5]
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
