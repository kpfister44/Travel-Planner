import SwiftUI

/// Manages the questionnaire flow, user preferences, and validation logic
class QuestionnaireCoordinator: ObservableObject {
    @Published var currentStep: QuestionnaireStep = .welcome
    @Published var userPreferences = UserPreferences()
    @Published var isCompleted = false
    @Published var validationErrors: [String] = []
    
    // Destination selection state
    @Published var destinationResponse: DestinationResponse?
    @Published var selectedDestination: Destination?
    @Published var isLoadingDestinations = false
    
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
        case .travelerInfo:
            if userPreferences.travelerInfo.ageGroup.isEmpty {
                errors.append("Please select your age group")
            }
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
            if userPreferences.groupRelationship.isEmpty {
                errors.append("Please select your group relationship")
            }
        case .preferredLocation:
            if userPreferences.preferredLocation.isEmpty {
                errors.append("Please select a destination preference")
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
        case .likes:
            if userPreferences.likes.isEmpty {
                errors.append("Please select at least one thing you like")
            }
            if userPreferences.likes.count > 5 {
                errors.append("Please select no more than 5 likes")
            }
        case .dislikes:
            if userPreferences.dislikes.count > 5 {
                errors.append("Please select no more than 5 dislikes")
            }
        case .mustHaves:
            break
        case .dealBreakers:
            break
        case .summary:
            break
        case .destinationSelection:
            if selectedDestination == nil {
                errors.append("Please select a destination to continue")
            }
        }
        
        // Update published errors on main thread
        DispatchQueue.main.async {
            self.validationErrors = errors
        }
        
        return errors
    }
    
    func completeQuestionnaire() {
        // Navigate to destination selection step
        currentStep = .destinationSelection
        loadDestinations()
    }
    
    /// Resets all questionnaire data and returns to welcome step
    func resetQuestionnaire() {
        currentStep = .welcome
        userPreferences = UserPreferences()
        isCompleted = false
        validationErrors = []
        // Reset destination selection state
        destinationResponse = nil
        selectedDestination = nil
        isLoadingDestinations = false
    }
    
    /// Loads destination recommendations based on user preferences
    func loadDestinations() {
        isLoadingDestinations = true
        
        Task {
            do {
                let response = try await APIService.shared.getDestinationRecommendations(preferences: userPreferences)
                
                await MainActor.run {
                    self.destinationResponse = response
                    self.isLoadingDestinations = false
                }
                
            } catch {
                await MainActor.run {
                    // Create error response for display
                    self.destinationResponse = DestinationResponse(
                        errors: [BackendError(code: "API_ERROR", message: error.localizedDescription)],
                        recommendations: []
                    )
                    self.isLoadingDestinations = false
                }
            }
        }
    }
    
    /// Selects a destination and prepares for next step
    func selectDestination(_ destination: Destination) {
        selectedDestination = destination
        // TODO: Navigate to itinerary questionnaire step
    }
    
    /// Helper to convert date strings to Date objects for validation
    private func dateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}