import Foundation

/// API configuration and service for backend communication
class APIService {
    static let shared = APIService()
    
    // MARK: - Configuration
    private let baseURL = Config.apiBaseURL
    private let apiKey = Config.apiKey
    
    private init() {}
    
    // MARK: - Health Check
    
    /// Tests backend connectivity
    func healthCheck() async throws -> Bool {
        let url = URL(string: "\(baseURL)/destinations/health")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            return httpResponse.statusCode == 200
        }
        
        return false
    }
    
    // MARK: - Destination API
    
    /// Fetches destination recommendations from backend
    /// - Parameter preferences: User travel preferences from questionnaire
    /// - Returns: DestinationResponse with recommendations or errors
    func getDestinationRecommendations(preferences: UserPreferences) async throws -> DestinationResponse {
        let url = URL(string: "\(baseURL)/destinations/recommendations")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        // Convert UserPreferences to backend expected format
        let requestBody = createDestinationRequest(from: preferences)
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Handle HTTP status codes
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    // Success - decode the response
                    return try JSONDecoder().decode(DestinationResponse.self, from: data)
                    
                case 401, 403:
                    // Authentication/Authorization errors
                    throw NetworkError.authenticationFailed("Invalid API key")
                    
                case 400:
                    // Bad request - try to decode error response
                    if let errorResponse = try? JSONDecoder().decode(DestinationResponse.self, from: data),
                       let errors = errorResponse.errors, !errors.isEmpty {
                        throw NetworkError.serverError(errors.first?.message ?? "Bad request")
                    }
                    throw NetworkError.invalidRequest("Invalid request data")
                    
                case 500...599:
                    // Server errors
                    throw NetworkError.serverError("Backend server error")
                    
                default:
                    throw NetworkError.unknown("Unexpected response: \(httpResponse.statusCode)")
                }
            }
            
            throw NetworkError.unknown("Invalid response")
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Converts UserPreferences to backend DestinationRequest format
    private func createDestinationRequest(from preferences: UserPreferences) -> DestinationRequest {
        return DestinationRequest(
            preferences: BackendUserPreferences(
                travelerInfo: BackendTravelerInfo(
                    ageGroup: preferences.travelerInfo.ageGroup
                ),
                budget: BackendBudget(
                    min: preferences.budget.min,
                    max: preferences.budget.max,
                    currency: "USD"
                ),
                travelDates: BackendTravelDates(
                    startDate: preferences.travelDates.startDate,
                    endDate: preferences.travelDates.endDate
                ),
                groupSize: preferences.groupSize,
                groupRelationship: preferences.groupRelationship,
                preferredLocation: preferences.preferredLocation,
                interests: preferences.likes,
                travelStyle: preferences.travelStyle,
                mustHaves: preferences.mustHaves,
                dealBreakers: preferences.dislikes + preferences.dealBreakers
            )
        )
    }
    
    // MARK: - Itinerary API
    
    /// Fetches activity suggestions from backend based on destination and preferences
    /// - Parameters:
    ///   - destination: Selected destination from previous step
    ///   - preferences: User travel preferences
    ///   - itineraryPreferences: Activity and itinerary preferences
    /// - Returns: ActivitySuggestionsResponse with suggested activities
    func getActivitySuggestions(
        destination: Destination,
        preferences: UserPreferences,
        itineraryPreferences: ItineraryPreferences
    ) async throws -> ActivitySuggestionsResponse {
        let url = URL(string: "\(baseURL)/itinerary/questionnaire")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        let requestBody = createActivitySuggestionsRequest(
            destination: destination,
            preferences: preferences,
            itineraryPreferences: itineraryPreferences
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Handle HTTP errors
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    throw NetworkError.authenticationFailed("Invalid API key")
                } else if httpResponse.statusCode == 422 {
                    throw NetworkError.invalidRequest("Invalid request data")
                } else if httpResponse.statusCode >= 500 {
                    throw NetworkError.serverError("Server error occurred")
                } else if httpResponse.statusCode != 200 {
                    throw NetworkError.unknown("HTTP \(httpResponse.statusCode)")
                }
            }
            
            // Parse response
            let activityResponse = try JSONDecoder().decode(ActivitySuggestionsResponse.self, from: data)
            
            // Check for backend errors
            if let errors = activityResponse.errors, !errors.isEmpty {
                let errorMessage = errors.map { $0.message }.joined(separator: ", ")
                throw NetworkError.serverError(errorMessage)
            }
            
            return activityResponse
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error.localizedDescription)
        }
    }
    
    /// Generates optimized itinerary from selected activities
    /// - Parameters:
    ///   - questionnaireId: ID from activity suggestions response
    ///   - selectedActivities: Activities chosen by user with priorities
    ///   - itineraryPreferences: User's itinerary preferences
    /// - Returns: ItineraryResponse with optimized daily schedules
    func generateItinerary(
        questionnaireId: String,
        selectedActivities: [SelectedActivity],
        itineraryPreferences: ItineraryPreferences
    ) async throws -> ItineraryResponse {
        let url = URL(string: "\(baseURL)/itinerary/generate")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        let requestBody = createItineraryGenerateRequest(
            questionnaireId: questionnaireId,
            selectedActivities: selectedActivities,
            itineraryPreferences: itineraryPreferences
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Handle HTTP errors
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    throw NetworkError.authenticationFailed("Invalid API key")
                } else if httpResponse.statusCode == 422 {
                    throw NetworkError.invalidRequest("Invalid request data")
                } else if httpResponse.statusCode >= 500 {
                    throw NetworkError.serverError("Server error occurred")
                } else if httpResponse.statusCode != 200 {
                    throw NetworkError.unknown("HTTP \(httpResponse.statusCode)")
                }
            }
            
            // Parse response
            let itineraryResponse = try JSONDecoder().decode(ItineraryResponse.self, from: data)
            
            // Check for backend errors
            if let errors = itineraryResponse.errors, !errors.isEmpty {
                let errorMessage = errors.map { $0.message }.joined(separator: ", ")
                throw NetworkError.serverError(errorMessage)
            }
            
            return itineraryResponse
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Helper Methods for Itinerary Requests
    
    /// Creates activity suggestions request from frontend models
    private func createActivitySuggestionsRequest(
        destination: Destination,
        preferences: UserPreferences,
        itineraryPreferences: ItineraryPreferences
    ) -> ItineraryQuestionnaireRequest {
        return ItineraryQuestionnaireRequest(
            questionnaireId: UUID().uuidString,
            selectedActivities: [], // Empty for initial request
            selectedDestination: BackendDestination(
                id: destination.id,
                name: destination.name,
                city: destination.name.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) ?? destination.name,
                country: destination.country
            ),
            travelDates: BackendTravelDates(
                startDate: preferences.travelDates.startDate,
                endDate: preferences.travelDates.endDate
            ),
            activityPreferences: BackendActivityPreferences(
                priorityInterests: itineraryPreferences.priorityInterests,
                mustSeeAttractions: itineraryPreferences.mustSeeAttractions,
                activityTypes: BackendActivityTypes(
                    cultural: itineraryPreferences.activityTypes.culturalExperiences.rawValue,
                    outdoor: itineraryPreferences.activityTypes.outdoorActivities.rawValue,
                    food: itineraryPreferences.activityTypes.foodAndDining.rawValue,
                    nightlife: itineraryPreferences.activityTypes.nightlife.rawValue,
                    shopping: itineraryPreferences.activityTypes.shopping.rawValue
                ),
                mealPreferences: BackendMealPreferences(
                    breakfast: itineraryPreferences.mealPreferences.breakfast.rawValue,
                    lunch: itineraryPreferences.mealPreferences.lunch.rawValue,
                    dinner: itineraryPreferences.mealPreferences.dinner.rawValue
                ),
                transportation: itineraryPreferences.transportation.rawValue,
                accommodationArea: itineraryPreferences.accommodationArea,
                ageGroup: preferences.travelerInfo.ageGroup,
                groupSize: preferences.groupSize,
                groupRelationship: preferences.groupRelationship,
                preferredLocation: preferences.preferredLocation,
                budget: BackendBudget(
                    min: preferences.budget.min,
                    max: preferences.budget.max,
                    currency: preferences.budget.currency
                ),
                travelStyle: preferences.travelStyle,
                likes: preferences.likes,
                dislikes: preferences.dislikes,
                mustHaves: preferences.mustHaves,
                dealBreakers: preferences.dealBreakers,
                pace: itineraryPreferences.pace.rawValue,
                dailyStartTime: itineraryPreferences.dailyStartTime,
                dailyEndTime: itineraryPreferences.dailyEndTime,
                maxActivitiesPerDay: itineraryPreferences.maxActivitiesPerDay
            )
        )
    }
    
    /// Creates itinerary generation request from selected activities
    private func createItineraryGenerateRequest(
        questionnaireId: String,
        selectedActivities: [SelectedActivity],
        itineraryPreferences: ItineraryPreferences
    ) -> ItineraryGenerateRequest {
        return ItineraryGenerateRequest(
            questionnaireId: questionnaireId,
            selectedActivities: selectedActivities.map { activity in
                BackendSelectedActivity(
                    id: activity.id,
                    priority: activity.priority.rawValue
                )
            },
            preferences: BackendItineraryPreferences(
                pace: itineraryPreferences.pace.rawValue,
                dailyStartTime: itineraryPreferences.dailyStartTime,
                dailyEndTime: itineraryPreferences.dailyEndTime,
                maxActivitiesPerDay: itineraryPreferences.maxActivitiesPerDay
            )
        )
    }
}

// MARK: - Error Handling

/// Network and API-specific error types
enum NetworkError: Error, LocalizedError {
    case networkError(String)
    case authenticationFailed(String)
    case invalidRequest(String)
    case serverError(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .invalidRequest(let message):
            return "Invalid request: \(message)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}

// MARK: - Backend Request Models for Itinerary API

/// Request structure for /itinerary/questionnaire endpoint
struct ItineraryQuestionnaireRequest: Codable {
    let questionnaireId: String
    let selectedActivities: [BackendSelectedActivity]
    let selectedDestination: BackendDestination
    let travelDates: BackendTravelDates
    let activityPreferences: BackendActivityPreferences
    
    enum CodingKeys: String, CodingKey {
        case questionnaireId = "questionnaire_id"
        case selectedActivities = "selected_activities"
        case selectedDestination = "selected_destination"
        case travelDates = "travel_dates"
        case activityPreferences = "activity_preferences"
    }
}

/// Request structure for /itinerary/generate endpoint
struct ItineraryGenerateRequest: Codable {
    let questionnaireId: String
    let selectedActivities: [BackendSelectedActivity]
    let preferences: BackendItineraryPreferences
    
    enum CodingKeys: String, CodingKey {
        case questionnaireId = "questionnaire_id"
        case selectedActivities = "selected_activities"
        case preferences
    }
}

/// Backend destination structure
struct BackendDestination: Codable {
    let id: String
    let name: String
    let city: String
    let country: String
}

/// Backend selected activity structure
struct BackendSelectedActivity: Codable {
    let id: String
    let priority: String
}

/// Backend activity preferences structure
struct BackendActivityPreferences: Codable {
    let priorityInterests: [String]
    let mustSeeAttractions: [String]
    let activityTypes: BackendActivityTypes
    let mealPreferences: BackendMealPreferences
    let transportation: String
    let accommodationArea: String
    let ageGroup: String
    let groupSize: Int
    let groupRelationship: String
    let preferredLocation: String
    let budget: BackendBudget
    let travelStyle: String
    let likes: [String]
    let dislikes: [String]
    let mustHaves: [String]
    let dealBreakers: [String]
    let pace: String
    let dailyStartTime: String
    let dailyEndTime: String
    let maxActivitiesPerDay: Int
    
    enum CodingKeys: String, CodingKey {
        case priorityInterests = "priority_interests"
        case mustSeeAttractions = "must_see_attractions"
        case activityTypes = "activity_types"
        case mealPreferences = "meal_preferences"
        case transportation
        case accommodationArea = "accommodation_area"
        case ageGroup = "age_group"
        case groupSize = "group_size"
        case groupRelationship = "group_relationship"
        case preferredLocation = "preferred_location"
        case budget
        case travelStyle = "travel_style"
        case likes
        case dislikes
        case mustHaves = "must_haves"
        case dealBreakers = "deal_breakers"
        case pace
        case dailyStartTime = "daily_start_time"
        case dailyEndTime = "daily_end_time"
        case maxActivitiesPerDay = "max_activities_per_day"
    }
}

/// Backend activity types structure
struct BackendActivityTypes: Codable {
    let cultural: String
    let outdoor: String
    let food: String
    let nightlife: String
    let shopping: String
}

/// Backend meal preferences structure
struct BackendMealPreferences: Codable {
    let breakfast: String
    let lunch: String
    let dinner: String
}

/// Backend itinerary preferences for generation
struct BackendItineraryPreferences: Codable {
    let pace: String
    let dailyStartTime: String
    let dailyEndTime: String
    let maxActivitiesPerDay: Int
    
    enum CodingKeys: String, CodingKey {
        case pace
        case dailyStartTime = "daily_start_time"
        case dailyEndTime = "daily_end_time"
        case maxActivitiesPerDay = "max_activities_per_day"
    }
}

// MARK: - Backend Request Models

/// Backend-compatible request structure for destinations
struct DestinationRequest: Codable {
    let preferences: BackendUserPreferences
}

/// Backend-compatible user preferences structure
struct BackendUserPreferences: Codable {
    let travelerInfo: BackendTravelerInfo
    let budget: BackendBudget
    let travelDates: BackendTravelDates
    let groupSize: Int
    let groupRelationship: String
    let preferredLocation: String
    let interests: [String]
    let travelStyle: String
    let mustHaves: [String]
    let dealBreakers: [String]
    
    enum CodingKeys: String, CodingKey {
        case travelerInfo = "traveler_info"
        case budget
        case travelDates = "travel_dates"
        case groupSize = "group_size"
        case groupRelationship = "group_relationship"
        case preferredLocation = "preferred_location"
        case interests
        case travelStyle = "travel_style"
        case mustHaves = "must_haves"
        case dealBreakers = "deal_breakers"
    }
}

struct BackendTravelerInfo: Codable {
    let ageGroup: String
    
    enum CodingKeys: String, CodingKey {
        case ageGroup = "age_group"
    }
}

struct BackendTravelDates: Codable {
    let startDate: String
    let endDate: String
    
    enum CodingKeys: String, CodingKey {
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

struct BackendBudget: Codable {
    let min: Int
    let max: Int
    let currency: String
}