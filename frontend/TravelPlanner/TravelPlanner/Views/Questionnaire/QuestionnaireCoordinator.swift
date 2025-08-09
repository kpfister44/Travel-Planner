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
    
    // Itinerary preferences state
    @Published var itineraryPreferences = ItineraryPreferences()
    @Published var activitySuggestionsResponse: ActivitySuggestionsResponse?
    @Published var selectedActivities: [SuggestedActivity] = []
    @Published var isLoadingSuggestedActivities = false
    
    // Generated itinerary state
    @Published var generatedItinerary: ItineraryResponse?
    @Published var isGeneratingItinerary = false
    
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
                
                // Check if trip length exceeds 10 days
                let calendar = Calendar.current
                let daysDifference = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
                if daysDifference > 10 {
                    errors.append("Please select a trip of 10 days or less for the best recommendations")
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
        // Improved itinerary questionnaire validation
        case .activityTypes:
            break // Activity types have default values, no validation needed
        case .activitySelection:
            if selectedActivities.isEmpty {
                errors.append("Please select at least one activity to continue")
            }
        case .travelPace:
            break // Pace has default value, no validation needed
        case .mustSeeAttractions:
            break // Optional step, no validation needed
        case .mealPreferences:
            break // Meal preferences have default values, no validation needed
        case .transportation:
            if itineraryPreferences.accommodationArea.isEmpty {
                errors.append("Please select your accommodation area preference")
            }
        case .itinerarySummary:
            break // Summary step, no validation needed
        case .itineraryDisplay:
            break // Display step, no validation needed
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
    
    /// Selects a destination and prepares for activity questionnaire
    func selectDestination(_ destination: Destination) {
        selectedDestination = destination
        // Don't automatically advance - let user click Next button
    }
    
    /// Completes activity types step and loads activity suggestions
    func completeActivityTypes() {
        currentStep = .activitySelection
        loadActivitySuggestions()
    }
    
    /// Loads activity suggestions based on destination and activity preferences
    func loadActivitySuggestions() {
        guard let selectedDestination = selectedDestination else { return }
        
        isLoadingSuggestedActivities = true
        
        Task {
            do {
                let response = try await APIService.shared.getActivitySuggestions(
                    destination: selectedDestination,
                    preferences: userPreferences,
                    itineraryPreferences: itineraryPreferences
                )
                
                await MainActor.run {
                    self.activitySuggestionsResponse = response
                    self.isLoadingSuggestedActivities = false
                    // Simple persistence: store questionnaire ID and response
                    self.saveActivitySuggestionsToUserDefaults(response)
                }
            } catch let error as NetworkError {
                await MainActor.run {
                    self.validationErrors = [error.localizedDescription]
                    self.isLoadingSuggestedActivities = false
                    // Keep showing loading state so user can retry
                }
            } catch {
                await MainActor.run {
                    self.validationErrors = ["Failed to load activity suggestions. Please try again."]
                    self.isLoadingSuggestedActivities = false
                }
            }
        }
    }
    
    /// Selects activities and continues to travel planning
    func selectActivities(_ activities: [SuggestedActivity]) {
        selectedActivities = activities
        // Continue to travel pace step for detailed itinerary planning
        currentStep = .travelPace
    }
    
    /// Completes the itinerary summary and generates final itinerary
    func completeItinerarySummary() {
        generateItinerary()
    }
    
    /// Generates the final itinerary and navigates to display view
    func generateItinerary() {
        guard let questionnaireId = activitySuggestionsResponse?.questionnaireId else {
            validationErrors = ["Missing questionnaire ID. Please reload activity suggestions."]
            return
        }
        
        isGeneratingItinerary = true
        
        // Convert selected activities to the required format
        let selectedActivitiesWithPriority = selectedActivities.map { activity in
            SelectedActivity(
                id: activity.id,
                priority: .medium // Default priority, could be customized by user
            )
        }
        
        Task {
            do {
                let response = try await APIService.shared.generateItinerary(
                    questionnaireId: questionnaireId,
                    selectedActivities: selectedActivitiesWithPriority,
                    itineraryPreferences: itineraryPreferences
                )
                
                await MainActor.run {
                    self.generatedItinerary = response
                    self.isGeneratingItinerary = false
                    // Simple persistence: store final itinerary
                    self.saveItineraryToUserDefaults(response)
                    // Only navigate after loading completes
                    self.currentStep = .itineraryDisplay
                }
            } catch let error as NetworkError {
                await MainActor.run {
                    self.validationErrors = [error.localizedDescription]
                    self.isGeneratingItinerary = false
                }
            } catch {
                await MainActor.run {
                    self.validationErrors = ["Failed to generate itinerary. Please try again."]
                    self.isGeneratingItinerary = false
                }
            }
        }
    }
    
    /// Re-attempts to load activity suggestions after a failure
    func retryActivitySuggestions() {
        validationErrors = []
        loadActivitySuggestions()
    }
    
    /// Re-attempts to generate itinerary after a failure
    func retryItineraryGeneration() {
        validationErrors = []
        generateItinerary()
    }
    
    /// Completes the entire questionnaire flow
    func completeItineraryQuestionnaire() {
        isCompleted = true
    }
    
    /// Helper to convert date strings to Date objects for validation
    private func dateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
    
    // MARK: - Simple Data Persistence
    
    /// Saves activity suggestions response to UserDefaults for simple persistence
    private func saveActivitySuggestionsToUserDefaults(_ response: ActivitySuggestionsResponse) {
        do {
            let data = try JSONEncoder().encode(response)
            UserDefaults.standard.set(data, forKey: "activitySuggestionsResponse")
        } catch {
            // Ignore persistence errors - not critical for functionality
            print("Failed to save activity suggestions: \(error)")
        }
    }
    
    /// Saves itinerary response to UserDefaults for simple persistence
    private func saveItineraryToUserDefaults(_ response: ItineraryResponse) {
        do {
            let data = try JSONEncoder().encode(response)
            UserDefaults.standard.set(data, forKey: "generatedItinerary")
        } catch {
            // Ignore persistence errors - not critical for functionality
            print("Failed to save itinerary: \(error)")
        }
    }
    
    /// Loads activity suggestions from UserDefaults if available
    func loadActivitySuggestionsFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: "activitySuggestionsResponse") else { return }
        do {
            let response = try JSONDecoder().decode(ActivitySuggestionsResponse.self, from: data)
            self.activitySuggestionsResponse = response
        } catch {
            // Ignore decoding errors - data might be from old version
            print("Failed to load activity suggestions: \(error)")
        }
    }
    
    /// Loads itinerary from UserDefaults if available
    func loadItineraryFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: "generatedItinerary") else { return }
        do {
            let response = try JSONDecoder().decode(ItineraryResponse.self, from: data)
            self.generatedItinerary = response
        } catch {
            // Ignore decoding errors - data might be from old version
            print("Failed to load itinerary: \(error)")
        }
    }
    
    /// Clears all stored data when starting new questionnaire
    func clearStoredData() {
        UserDefaults.standard.removeObject(forKey: "activitySuggestionsResponse")
        UserDefaults.standard.removeObject(forKey: "generatedItinerary")
    }
    
    /// Resets questionnaire to start over
    func resetQuestionnaire() {
        currentStep = .welcome
        userPreferences = UserPreferences()
        itineraryPreferences = ItineraryPreferences()
        destinationResponse = nil
        selectedDestination = nil
        activitySuggestionsResponse = nil
        selectedActivities = []
        generatedItinerary = nil
        isLoadingDestinations = false
        isLoadingSuggestedActivities = false
        isGeneratingItinerary = false
        isCompleted = false
        validationErrors = []
    }
}