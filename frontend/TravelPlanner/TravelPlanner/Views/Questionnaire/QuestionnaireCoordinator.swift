import SwiftUI

/// Manages the questionnaire flow, user preferences, and validation logic
class QuestionnaireCoordinator: ObservableObject {
    @Published var currentStep: QuestionnaireStep = .welcome
    @Published var userPreferences = UserPreferences()
    @Published var isCompleted = false
    @Published var validationErrors: [String] = []
    
    var canGoForward: Bool {
        validateCurrentStep().isEmpty
    }
    
    var canGoBack: Bool {
        currentStep.rawValue > 0
    }
    
    func nextStep() {
        guard canGoForward else { return }
        
        let nextStepValue = currentStep.rawValue + 1
        if nextStepValue < QuestionnaireStep.allCases.count {
            currentStep = QuestionnaireStep(rawValue: nextStepValue) ?? .welcome
        }
    }
    
    func previousStep() {
        guard canGoBack else { return }
        
        let previousStepValue = currentStep.rawValue - 1
        if previousStepValue >= 0 {
            currentStep = QuestionnaireStep(rawValue: previousStepValue) ?? .welcome
        }
    }
    
    /// Allows direct navigation to any step (used by Summary view edit buttons)
    func jumpToStep(_ step: QuestionnaireStep) {
        currentStep = step
    }
    
    /// Validates current step and returns array of error messages
    func validateCurrentStep() -> [String] {
        var errors: [String] = []
        
        switch currentStep {
        case .welcome:
            break
        case .travelDates:
            if userPreferences.travelDates.startDate.isEmpty {
                errors.append("Please select a start date")
            }
            if userPreferences.travelDates.endDate.isEmpty {
                errors.append("Please select an end date")
            }
            if let startDate = dateFromString(userPreferences.travelDates.startDate),
               let endDate = dateFromString(userPreferences.travelDates.endDate) {
                if startDate >= endDate {
                    errors.append("End date must be after start date")
                }
                if startDate < Date() {
                    errors.append("Start date must be in the future")
                }
            }
        case .groupSize:
            if userPreferences.groupSize < 1 || userPreferences.groupSize > 20 {
                errors.append("Group size must be between 1 and 20")
            }
        case .budget:
            if userPreferences.budget.min >= userPreferences.budget.max {
                errors.append("Maximum budget must be greater than minimum")
            }
            if userPreferences.budget.min < 0 {
                errors.append("Budget cannot be negative")
            }
        case .travelStyle:
            if userPreferences.travelStyle.isEmpty {
                errors.append("Please select a travel style")
            }
        case .interests:
            if userPreferences.interests.isEmpty {
                errors.append("Please select at least one interest")
            }
            if userPreferences.interests.count > 5 {
                errors.append("Please select no more than 5 interests")
            }
        case .mustHaves:
            break
        case .dealBreakers:
            break
        case .summary:
            break
        }
        
        // Update published errors on main thread
        DispatchQueue.main.async {
            self.validationErrors = errors
        }
        
        return errors
    }
    
    func completeQuestionnaire() {
        isCompleted = true
    }
    
    /// Resets all questionnaire data and returns to welcome step
    func resetQuestionnaire() {
        currentStep = .welcome
        userPreferences = UserPreferences()
        isCompleted = false
        validationErrors = []
    }
    
    /// Helper to convert date strings to Date objects for validation
    private func dateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}