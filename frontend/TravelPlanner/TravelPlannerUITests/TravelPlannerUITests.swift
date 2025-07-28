import XCTest

final class TravelPlannerUITests: XCTestCase {

    func testWelcome() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Welcome"].exists)
        let nextButton = app.buttons["Next"]
        XCTAssertTrue(nextButton.exists)
        XCTAssertTrue(nextButton.isEnabled)
    }

    func testCancel() throws {
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

    func testStartEnd() throws {
        let app = XCUIApplication()
        app.launch()

        let nextButton = app.buttons["Next"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 5))
        XCTAssertTrue(nextButton.isEnabled)
        nextButton.tap()

        // Traveler Info (Age Group)
        XCTAssertTrue(app.staticTexts["Tell us about yourself"].waitForExistence(timeout: 5))
        let ageGroup = app.buttons["ageGroup_25-34"]
        XCTAssertTrue(ageGroup.waitForExistence(timeout: 5))
        ageGroup.tap()
        XCTAssertTrue(nextButton.isEnabled)
        nextButton.tap()

        // Travel Dates
        XCTAssertTrue(app.staticTexts["When are you planning to travel?"].waitForExistence(timeout: 5))
        XCTAssertTrue(nextButton.isEnabled)
        nextButton.tap()

        // Group Info
        XCTAssertTrue(app.staticTexts["Tell us about your group"].waitForExistence(timeout: 5))
        let groupSize = app.buttons["groupSize_2"]
        XCTAssertTrue(groupSize.waitForExistence(timeout: 5))
        groupSize.tap()
        let relationship = app.buttons["groupRelationship_couple"]
        XCTAssertTrue(relationship.waitForExistence(timeout: 5))
        relationship.tap()
        XCTAssertTrue(nextButton.isEnabled)
        nextButton.tap()

        // Preferred Location
        XCTAssertTrue(app.staticTexts["Where would you like to go?"].waitForExistence(timeout: 5))
        let location = app.buttons["United States"]
        XCTAssertTrue(location.waitForExistence(timeout: 5))
        location.tap()
        XCTAssertTrue(nextButton.isEnabled)
        nextButton.tap()

        // Budget
        XCTAssertTrue(app.staticTexts["What's your budget range?"].waitForExistence(timeout: 5))
        XCTAssertTrue(nextButton.isEnabled)
        nextButton.tap()

        // Style
        XCTAssertTrue(app.staticTexts["What's your travel style?"].waitForExistence(timeout: 5))
        let style = app.buttons["style_balanced"]
        XCTAssertTrue(style.waitForExistence(timeout: 5))
        style.tap()
        XCTAssertTrue(nextButton.isEnabled)
        nextButton.tap()

        // Likes
        XCTAssertTrue(app.staticTexts["What do you like about travel?"].waitForExistence(timeout: 5))
        let like = app.buttons["Cultural Experiences"]
        XCTAssertTrue(like.waitForExistence(timeout: 5))
        like.tap()
        XCTAssertTrue(nextButton.isEnabled)
        nextButton.tap()

        // Dislikes
        XCTAssertTrue(app.staticTexts["What do you want to avoid?"].waitForExistence(timeout: 5))
        let dislike = app.buttons["Crowded Places"]
        XCTAssertTrue(dislike.waitForExistence(timeout: 5))
        dislike.tap()
        XCTAssertTrue(nextButton.isEnabled)
        nextButton.tap()

        // Must-Haves
        XCTAssertTrue(app.staticTexts["What are your must-haves?"].waitForExistence(timeout: 5))
        XCTAssertTrue(nextButton.isEnabled)
        nextButton.tap()

        // Deal-Breakers
        XCTAssertTrue(app.staticTexts["What should we avoid?"].waitForExistence(timeout: 5))
        XCTAssertTrue(nextButton.isEnabled)
        nextButton.tap()

        // Summary
        XCTAssertTrue(app.staticTexts["Ready to find your perfect trip?"].waitForExistence(timeout: 5))
        let getRecommendations = app.buttons["Get Recommendations"]
        XCTAssertTrue(getRecommendations.isEnabled)
        getRecommendations.tap()
    }
}