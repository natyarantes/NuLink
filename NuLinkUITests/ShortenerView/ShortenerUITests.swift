//
//  ShortenerUITests.swift
//  NuLink
//
//  Created by Natália Arantes on 08/10/25.
//

import XCTest
@testable import NuLink

final class ShortenerUITests: XCTestCase {

    func test_happyPath_shortenAndCopy() {
        let app = XCUIApplication()
        app.launch(scenario: "success")

        let input = app.textFields["urlInputField"]
        XCTAssertTrue(input.waitHittable())
        input.tap()
        input.typeText("https://long.example.com/path")

        let button = app.buttons["shortenerButton"]
        XCTAssertTrue(button.waitHittable())
        button.tap()

        let shortText = app.staticTexts["https://sho.rt/a1"]
        XCTAssertTrue(shortText.waitForExistence(timeout: 3))

        let copy = app.buttons["Copiar"]
        XCTAssertTrue(copy.exists)
        copy.tap()
        XCTAssertTrue(app.staticTexts["Link copiado!"].waitForExistence(timeout: 2))
    }

    func test_invalidURL_showsValidationMessage() {
        let app = XCUIApplication()
        app.launch(scenario: "success")

        let input = app.textFields["urlInputField"]
        XCTAssertTrue(input.waitHittable())
        input.tap()
        input.typeText("not a url")

        app.buttons["shortenerButton"].tap()

        XCTAssertTrue(app.staticTexts["URL inválida. Inclua https://"].waitForExistence(timeout: 1.5))
    }

    func test_requestFailed_showsErrorMessage() {
        let app = XCUIApplication()
        app.launch(scenario: "requestFailed")

        let input = app.textFields["urlInputField"]
        input.tap()
        input.typeText("https://long.example.com")

        app.buttons["shortenerButton"].tap()

        XCTAssertTrue(app.staticTexts["Falha 500. oops"].waitForExistence(timeout: 2))
    }

    func test_loading_showsProgress_thenCard() {
        let app = XCUIApplication()
        app.launch(scenario: "delayedSuccess")

        let input = app.textFields["urlInputField"]
        XCTAssertTrue(input.waitForExistence(timeout: 2))
        input.tap()
        input.typeText("https://delayed.com")

        let button = app.buttons["shortenerButton"]
        XCTAssertTrue(button.waitForExistence(timeout: 2))
        button.tap()

        XCTAssertTrue(app.staticTexts["https://sho.rt/d1"].waitForExistence(timeout: 4.0))
    }

    func test_clearAll_removesCards_andShowsEmptyState() {
        let app = XCUIApplication()
        app.launch(scenario: "success")

        let input = app.textFields["urlInputField"]
        input.tap()
        input.typeText("https://x.com")
        app.buttons["shortenerButton"].tap()
        XCTAssertTrue(app.staticTexts["https://sho.rt/a1"].waitForExistence(timeout: 2))

        if app.buttons["toolbar.more"].exists {
            app.buttons["toolbar.more"].tap()
        } else {
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
        app.buttons["Limpar tudo"].tap()

        XCTAssertTrue(app.staticTexts["Não há link"].waitForExistence(timeout: 1.5))
    }
}
