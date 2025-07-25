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