import Foundation

// MARK: - ItineraryPreferences
struct ItineraryPreferences: Codable {
    var pace: TravelPace
    var dailyStartTime: String
    var dailyEndTime: String
    var maxActivitiesPerDay: Int
    var priorityInterests: [String]
    var mustSeeAttractions: [String]
    var activityTypes: ActivityTypeRatings
    var mealPreferences: MealPreferences
    var transportation: TransportationType
    var accommodationArea: String
    
    enum CodingKeys: String, CodingKey {
        case pace
        case dailyStartTime = "daily_start_time"
        case dailyEndTime = "daily_end_time"
        case maxActivitiesPerDay = "max_activities_per_day"
        case priorityInterests = "priority_interests"
        case mustSeeAttractions = "must_see_attractions"
        case activityTypes = "activity_types"
        case mealPreferences = "meal_preferences"
        case transportation
        case accommodationArea = "accommodation_area"
    }
    
    init() {
        self.pace = .moderate
        self.dailyStartTime = "09:00"
        self.dailyEndTime = "22:00"
        self.maxActivitiesPerDay = 4
        self.priorityInterests = []
        self.mustSeeAttractions = []
        self.activityTypes = ActivityTypeRatings()
        self.mealPreferences = MealPreferences()
        self.transportation = .walkingAndPublic
        self.accommodationArea = ""
    }
}

// MARK: - TravelPace
enum TravelPace: String, Codable, CaseIterable {
    case relaxed = "relaxed"
    case moderate = "moderate"
    case fast = "fast"
    
    var displayName: String {
        switch self {
        case .relaxed: return "Relaxed"
        case .moderate: return "Moderate"
        case .fast: return "Fast"
        }
    }
    
    var description: String {
        switch self {
        case .relaxed: return "Take it easy with plenty of downtime"
        case .moderate: return "Balanced mix of activities and rest"
        case .fast: return "See as much as possible, stay busy"
        }
    }
}

// MARK: - ActivityTypeRatings
struct ActivityTypeRatings: Codable {
    var culturalExperiences: InterestLevel
    var outdoorActivities: InterestLevel
    var foodAndDining: InterestLevel
    var nightlife: InterestLevel
    var shopping: InterestLevel
    var entertainment: InterestLevel
    var historicalSites: InterestLevel
    var naturalAttractions: InterestLevel
    
    enum CodingKeys: String, CodingKey {
        case culturalExperiences = "cultural_experiences"
        case outdoorActivities = "outdoor_activities"
        case foodAndDining = "food_and_dining"
        case nightlife
        case shopping
        case entertainment
        case historicalSites = "historical_sites"
        case naturalAttractions = "natural_attractions"
    }
    
    init() {
        self.culturalExperiences = .medium
        self.outdoorActivities = .medium
        self.foodAndDining = .medium
        self.nightlife = .medium
        self.shopping = .medium
        self.entertainment = .medium
        self.historicalSites = .medium
        self.naturalAttractions = .medium
    }
}

// MARK: - InterestLevel
enum InterestLevel: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

// MARK: - MealPreferences
struct MealPreferences: Codable {
    var breakfast: MealVenueType
    var lunch: MealVenueType
    var dinner: MealVenueType
    var dietaryRestrictions: [String]
    
    enum CodingKeys: String, CodingKey {
        case breakfast
        case lunch
        case dinner
        case dietaryRestrictions = "dietary_restrictions"
    }
    
    init() {
        self.breakfast = .hotel
        self.lunch = .localRestaurant
        self.dinner = .localRestaurant
        self.dietaryRestrictions = []
    }
}

// MARK: - MealVenueType
enum MealVenueType: String, Codable, CaseIterable {
    case hotel = "hotel"
    case cafe = "cafe"
    case localRestaurant = "local_restaurant"
    case fineDining = "fine_dining"
    case quickBite = "quick_bite"
    case skip = "skip"
    
    var displayName: String {
        switch self {
        case .hotel: return "Hotel"
        case .cafe: return "Café"
        case .localRestaurant: return "Local Restaurant"
        case .fineDining: return "Fine Dining"
        case .quickBite: return "Quick Bite"
        case .skip: return "Skip"
        }
    }
}

// MARK: - TransportationType
enum TransportationType: String, Codable, CaseIterable {
    case walking = "walking"
    case publicTransit = "public_transit"
    case walkingAndPublic = "walking_and_public"
    case rideshare = "rideshare"
    case rentalCar = "rental_car"
    
    var displayName: String {
        switch self {
        case .walking: return "Walking Only"
        case .publicTransit: return "Public Transit"
        case .walkingAndPublic: return "Walking + Public Transit"
        case .rideshare: return "Rideshare/Taxi"
        case .rentalCar: return "Rental Car"
        }
    }
    
    var description: String {
        switch self {
        case .walking: return "Explore on foot, stay within walking distance"
        case .publicTransit: return "Use buses, trains, and metro systems"
        case .walkingAndPublic: return "Mix of walking and public transportation"
        case .rideshare: return "Use Uber, Lyft, or local taxis"
        case .rentalCar: return "Drive yourself with rental car"
        }
    }
}

// MARK: - Activity Selection Models
struct SuggestedActivity: Codable, Identifiable {
    let id: String
    let name: String
    let category: String
    let durationHours: Int
    let cost: Double
    let priority: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case durationHours = "duration_hours"
        case cost
        case priority
        case description
    }
}

struct ActivityQuestionnaire: Codable {
    let selectedDestination: Destination
    let travelDates: TravelDates
    let activityPreferences: ItineraryPreferences
    
    enum CodingKeys: String, CodingKey {
        case selectedDestination = "selected_destination"
        case travelDates = "travel_dates"
        case activityPreferences = "activity_preferences"
    }
}

struct ActivitySuggestionsResponse: Codable {
    let errors: [BackendError]?
    let suggestedActivities: [SuggestedActivity]?
    let questionnaireId: String?
    let destination: SimpleDestination?
    let readyForOptimization: Bool?
    
    enum CodingKeys: String, CodingKey {
        case errors
        case suggestedActivities = "suggested_activities"
        case questionnaireId = "questionnaire_id"
        case destination
        case readyForOptimization = "ready_for_optimization"
    }
}

/// Simplified destination model for activity suggestions response
struct SimpleDestination: Codable {
    let id: String
    let name: String
}

/// Selected activity with priority for itinerary generation
struct SelectedActivity: Codable, Identifiable {
    let id: String
    let priority: ActivityPriority
    
    enum CodingKeys: String, CodingKey {
        case id, priority
    }
}

/// Activity priority levels
enum ActivityPriority: String, Codable, CaseIterable {
    case high = "high"
    case medium = "medium"
    case low = "low"
    
    var displayName: String {
        switch self {
        case .high: return "Must Do"
        case .medium: return "Would Like"
        case .low: return "If Time Allows"
        }
    }
}

// MARK: - Constants
struct ItineraryConstants {
    static let availableTimeSlots = [
        "06:00", "07:00", "08:00", "09:00", "10:00", "11:00", "12:00",
        "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00",
        "20:00", "21:00", "22:00", "23:00", "00:00"
    ]
    
    static let maxActivitiesOptions = [2, 3, 4, 5, 6]
    
    static let activityCategories = [
        (key: "cultural_experiences", name: "Cultural Experiences", icon: "theatermasks"),
        (key: "outdoor_activities", name: "Outdoor Activities", icon: "mountain.2"),
        (key: "food_and_dining", name: "Food & Dining", icon: "fork.knife"),
        (key: "nightlife", name: "Nightlife", icon: "moon.stars"),
        (key: "shopping", name: "Shopping", icon: "bag"),
        (key: "entertainment", name: "Entertainment", icon: "tv"),
        (key: "historical_sites", name: "Historical Sites", icon: "building.columns"),
        (key: "natural_attractions", name: "Natural Attractions", icon: "leaf")
    ]
    
    static let commonDietaryRestrictions = [
        "vegetarian",
        "vegan", 
        "gluten_free",
        "dairy_free",
        "halal",
        "kosher",
        "keto",
        "paleo",
        "nut_allergies",
        "shellfish_allergies"
    ]
    
    static let accommodationAreas = [
        "city_center",
        "historic_district", 
        "business_district",
        "waterfront",
        "near_airport",
        "shopping_area",
        "nightlife_district",
        "quiet_residential",
        "tourist_area"
    ]
}

// MARK: - UI Helper Extensions
extension ItineraryPreferences {
    /// Formatted time range for display
    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let startTime = formatter.date(from: dailyStartTime),
              let endTime = formatter.date(from: dailyEndTime) else {
            return "Time not set"
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "h:mm a"
        
        return "\(displayFormatter.string(from: startTime)) - \(displayFormatter.string(from: endTime))"
    }
    
    /// Summary of activity preferences for display
    var activitySummary: String {
        let highInterests = activityTypes.highInterestActivities
        if highInterests.isEmpty {
            return "No high-priority activities selected"
        }
        return "High interest: \(highInterests.joined(separator: ", "))"
    }
}

extension ActivityTypeRatings {
    /// Returns activities with high interest level
    var highInterestActivities: [String] {
        var activities: [String] = []
        
        if culturalExperiences == .high { activities.append("Cultural") }
        if outdoorActivities == .high { activities.append("Outdoor") }
        if foodAndDining == .high { activities.append("Food") }
        if nightlife == .high { activities.append("Nightlife") }
        if shopping == .high { activities.append("Shopping") }
        if entertainment == .high { activities.append("Entertainment") }
        if historicalSites == .high { activities.append("Historical") }
        if naturalAttractions == .high { activities.append("Nature") }
        
        return activities
    }
}

extension TransportationType {
    /// Icon name for UI display
    var iconName: String {
        switch self {
        case .walking: return "figure.walk"
        case .publicTransit: return "bus"
        case .walkingAndPublic: return "figure.walk.circle"
        case .rideshare: return "car"
        case .rentalCar: return "car.fill"
        }
    }
}