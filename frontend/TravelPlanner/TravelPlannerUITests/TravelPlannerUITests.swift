
import XCTest

final class TravelPlannerUITests: XCTestCase {

    func testWelcomePageShowsNextButton() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Welcome"].exists)
        let nextButton = app.buttons["Next"]
        XCTAssertTrue(nextButton.exists)
        XCTAssertTrue(nextButton.isEnabled)
    }

    func testCancelButtonReturnsToWelcome() throws {
        let app = XCUIApplication()
        app.launch()
        let nextButton = app.buttons["Next"]
        if nextButton.exists && nextButton.isEnabled {
            nextButton.tap() // Move from Welcome to next step
        }
        let cancelButton = app.navigationBars.buttons["Cancel"]
        XCTAssertTrue(cancelButton.exists)
        cancelButton.tap()
        XCTAssertTrue(app.staticTexts["Welcome"].exists)
    }

    func testNextButtonNavigatesThroughRequiredSelections() throws {
        let app = XCUIApplication()
        app.launch()

        let nextButton = app.buttons["Next"]
        XCTAssertTrue(nextButton.exists)
        XCTAssertTrue(nextButton.isEnabled)
        nextButton.tap()

        XCTAssertTrue(app.staticTexts["About you"].exists)
        XCTAssertFalse(nextButton.isEnabled)
        let firstOption = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstOption.exists)
        firstOption.tap()
        XCTAssertTrue(nextButton.isEnabled)
        nextButton.tap()

        XCTAssertTrue(app.staticTexts["Travel Dates"].exists)
        XCTAssertTrue(nextButton.isEnabled)
        nextButton.tap()

        XCTAssertTrue(app.staticTexts["Group Details"].exists)
        XCTAssertFalse(nextButton.isEnabled)
        let groupSizeOption = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(groupSizeOption.exists)
        groupSizeOption.tap()
        XCTAssertFalse(nextButton.isEnabled)
        let groupRelationshipOption = app.tables.cells.element(boundBy: 1)
        XCTAssertTrue(groupRelationshipOption.exists)
        groupRelationshipOption.tap()
        XCTAssertTrue(nextButton.isEnabled)
        nextButton.tap()

        XCTAssertTrue(app.staticTexts["Destination Preference"].exists)
        XCTAssertFalse(nextButton.isEnabled)
        let destinationOption = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(destinationOption.exists)
        destinationOption.tap()
        XCTAssertTrue(nextButton.isEnabled)
        nextButton.tap()

        XCTAssertTrue(app.staticTexts["Budget"].exists)
        XCTAssertTrue(nextButton.isEnabled)
        nextButton.tap()

        XCTAssertTrue(app.staticTexts["Travel Style"].exists)
        XCTAssertFalse(nextButton.isEnabled)
        let travelStyleOption = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(travelStyleOption.exists)
        travelStyleOption.tap()
        XCTAssertTrue(nextButton.isEnabled)
        nextButton.tap()

        XCTAssertTrue(app.staticTexts["What you like"].exists)
        XCTAssertFalse(nextButton.isEnabled)
        let likeOption = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(likeOption.exists)
        likeOption.tap()
        XCTAssertTrue(nextButton.isEnabled)
        nextButton.tap()
    }
}
