//
//  HelpersUITests.swift
//  NuLink
//
//  Created by Natália Arantes on 08/10/25.
//

import XCTest

extension XCUIApplication {
    func launch(scenario: String) {
        launchEnvironment["UI_TESTING"] = "1"
        launchEnvironment["UI_TEST_SCENARIO"] = scenario
        launch()
    }
}

extension XCUIElement {
    @discardableResult
    func waitHittable(_ timeout: TimeInterval = 2) -> Bool {
        waitForExistence(timeout: timeout) && isHittable
    }
}
