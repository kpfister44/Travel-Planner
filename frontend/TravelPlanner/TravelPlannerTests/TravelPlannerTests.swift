import XCTest
@testable import TravelPlanner

final class TravelPlannerTests: XCTestCase {

    func testDefaultUserPreferencesInitialization() {
        let prefs = UserPreferences()
        XCTAssertEqual(prefs.groupSize, 2)
        XCTAssertEqual(prefs.budget.currency, "USD")
        XCTAssertTrue(prefs.likes.isEmpty)
    }

    func testBudgetRangeIsValid() {
        let prefs = UserPreferences()
        XCTAssertGreaterThan(prefs.budget.max, prefs.budget.min, "Budget max should be greater than min")
        XCTAssertTrue(prefs.budget.min >= 0, "Budget min should not be negative")
    }

    func testTravelDatesValidity() {
        let prefs = UserPreferences()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let start = formatter.date(from: prefs.travelDates.startDate), let end = formatter.date(from: prefs.travelDates.endDate) {
            XCTAssertLessThan(start, end, "Start date should be before end date")
        } else {
            XCTFail("Could not parse travel dates")
        }
    }

    func testGroupSizeWithinExpectedRange() {
        let prefs = UserPreferences()
        XCTAssertTrue((1...10).contains(prefs.groupSize), "Group size should be within 1-10 (expected range)")
    }

    func testAgeGroupIsValid() {
        let prefs = UserPreferences()
        let validAgeGroups = QuestionnaireConstants.ageGroups
        XCTAssertTrue(validAgeGroups.contains(prefs.travelerInfo.ageGroup) || prefs.travelerInfo.ageGroup == "", "Age group should be valid or empty")
    }

    func testTravelStyleIsValidOrEmpty() {
        let prefs = UserPreferences()
        let validStyles = QuestionnaireConstants.travelStyles
        XCTAssertTrue(validStyles.contains(prefs.travelStyle) || prefs.travelStyle == "", "Travel style should be valid or empty")
    }
}
