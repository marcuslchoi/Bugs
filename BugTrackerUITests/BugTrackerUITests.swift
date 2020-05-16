//
//  BugTrackerUITests.swift
//  BugTrackerUITests
//
//  Created by Marcus Choi on 4/15/20.
//  Copyright © 2020 Marcus Choi. All rights reserved.
//

import XCTest

class BugTrackerUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_Login() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        let errorLabel = app.staticTexts["loginErrorLabel"]
        let emailField = app.textFields["loginEmailTextField"]
        let passField = app.secureTextFields["loginPasswordTextField"]
        let loginButton = app.buttons["loginButton"]
        
        emailField.tap()
        emailField.typeText("1@2.com")
        passField.tap()
        passField.typeText("1234")
        loginButton.tap()
        XCTAssert(errorLabel.label != "")
        
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
