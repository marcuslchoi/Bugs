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
    var testIssues: [Issue] = []
    
    private func generateTestIssues() -> [Issue]
    {
        let issue0 = Issue(id: "B-1", reporter: "Marcus", assignedTo: "assignee0", status: .Closed, type: .Bug, title: "title", description: "", dueDate: nil)
        let issue1 = Issue(id: "T-1", reporter: "Choi", assignedTo: "assignee1", status: .InProgress, type: .Task, title: "title", description: "", dueDate: nil)
        let issue2 = Issue(id: "T-2", reporter: "marcuschoi", assignedTo: "assignee2", status: .InReview, type: .Task, title: "title", description: "", dueDate: nil)
        let issue3 = Issue(id: "T-3", reporter: "reporter", assignedTo: "assignee3", status: .Open, type: .Task, title: "title", description: "", dueDate: nil)
        let issue4 = Issue(id: "E-1", reporter: "1@3.com", assignedTo: "assignee4", status: .Open, type: .Epic, title: "title", description: "", dueDate: nil)
        let issue5 = Issue(id: "B-2", reporter: "1@2.com", assignedTo: "assignee5", status: .InReview, type: .Bug, title: "title", description: "related to epic: E-1", dueDate: nil)
        
        return [issue0, issue1, issue2, issue3, issue4, issue5]
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        testIssues = generateTestIssues()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_createNextIssueId()
    {
        let id = dbManager.test_createNextIssueId(for: .Bug, testIssues)
        XCTAssertEqual(id, "B-3")
    }

    func test_getFilteredIssues()
    {
        let filtered = dbManager.test_getFilteredIssues(testIssues: testIssues, isSearchBarEmpty: false, text: "E-1", user: K.MasterIssues.firstSearchScope)
        XCTAssertEqual(filtered.count, 2)
        XCTAssertEqual(filtered[0].id, testIssues[4].id)
        XCTAssertEqual(filtered[1].id, testIssues[5].id)
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
