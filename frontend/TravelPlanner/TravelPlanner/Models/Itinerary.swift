import Foundation

// MARK: - Itinerary Generation Response Models

/// Response from the `/itinerary/generate` endpoint
struct ItineraryResponse: Codable {
    let errors: [BackendError]?
    let itinerary: GeneratedItinerary?
    let summary: ItinerarySummary?
}

/// Main itinerary object containing all trip details
struct GeneratedItinerary: Codable {
    let destination: String
    let totalDays: Int
    let dailySchedules: [DailySchedule]
    
    enum CodingKeys: String, CodingKey {
        case destination
        case totalDays = "total_days"
        case dailySchedules = "daily_schedules"
    }
}

/// Individual day schedule with activities and metrics
struct DailySchedule: Codable {
    let date: String
    let dayNumber: Int
    let theme: String
    let activities: [ScheduledActivity]
    let dailyCost: Double
    let walkingDistance: String
    
    enum CodingKeys: String, CodingKey {
        case date
        case dayNumber = "day_number"
        case theme
        case activities
        case dailyCost = "daily_cost"
        case walkingDistance = "walking_distance"
    }
}

/// Time-based activity within a daily schedule
struct ScheduledActivity: Codable {
    let startTime: String
    let endTime: String
    let activity: ActivityDetail
    
    enum CodingKeys: String, CodingKey {
        case startTime = "start_time"
        case endTime = "end_time"
        case activity
    }
}

/// Detailed activity information
struct ActivityDetail: Codable {
    let name: String
    let type: String
    let notes: String?
}

/// Summary metrics for the entire itinerary
struct ItinerarySummary: Codable {
    let totalCost: Double
    let totalActivities: Int
    let optimizationScore: Double
    
    enum CodingKeys: String, CodingKey {
        case totalCost = "total_cost"
        case totalActivities = "total_activities"
        case optimizationScore = "optimization_score"
    }
}