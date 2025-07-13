import Foundation

// MARK: - UserPreferences
struct UserPreferences: Codable {
    var travelerInfo: TravelerInfo
    var budget: Budget
    var travelDates: TravelDates
    var groupSize: Int
    var groupRelationship: String
    var preferredLocation: String
    var likes: [String]
    var dislikes: [String]
    var travelStyle: String
    var mustHaves: [String]
    var dealBreakers: [String]
    
    enum CodingKeys: String, CodingKey {
        case travelerInfo = "traveler_info"
        case budget
        case travelDates = "travel_dates"
        case groupSize = "group_size"
        case groupRelationship = "group_relationship"
        case preferredLocation = "preferred_location"
        case likes
        case dislikes
        case travelStyle = "travel_style"
        case mustHaves = "must_haves"
        case dealBreakers = "deal_breakers"
    }
    
    init() {
        self.travelerInfo = TravelerInfo()
        self.budget = Budget()
        self.travelDates = TravelDates()
        self.groupSize = 2
        self.groupRelationship = ""
        self.preferredLocation = ""
        self.likes = []
        self.dislikes = []
        self.travelStyle = ""
        self.mustHaves = []
        self.dealBreakers = []
    }
}

// MARK: - Budget
struct Budget: Codable {
    var min: Int
    var max: Int
    var currency: String
    
    init() {
        self.min = 500
        self.max = 2000
        self.currency = "USD"
    }
}

// MARK: - TravelDates
struct TravelDates: Codable {
    var startDate: String
    var endDate: String
    
    enum CodingKeys: String, CodingKey {
        case startDate = "start_date"
        case endDate = "end_date"
    }
    
    init() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = Date()
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: today) ?? today
        let weekLater = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: nextMonth) ?? nextMonth
        
        self.startDate = formatter.string(from: nextMonth)
        self.endDate = formatter.string(from: weekLater)
    }
}

// MARK: - TravelerInfo
struct TravelerInfo: Codable {
    var ageGroup: String
    
    enum CodingKeys: String, CodingKey {
        case ageGroup = "age_group"
    }
    
    init() {
        self.ageGroup = ""
    }
}

// MARK: - Questionnaire Step Enum
enum QuestionnaireStep: Int, CaseIterable {
    case welcome = 0
    case travelerInfo = 1
    case travelDates = 2
    case groupSize = 3
    case preferredLocation = 4
    case budget = 5
    case travelStyle = 6
    case likes = 7
    case dislikes = 8
    case mustHaves = 9
    case dealBreakers = 10
    case summary = 11
    
    var title: String {
        switch self {
        case .welcome: return "Welcome"
        case .travelerInfo: return "About You"
        case .travelDates: return "Travel Dates"
        case .groupSize: return "Group Details"
        case .preferredLocation: return "Destination Preference"
        case .budget: return "Budget"
        case .travelStyle: return "Travel Style"
        case .likes: return "What You Like"
        case .dislikes: return "What You Dislike"
        case .mustHaves: return "Must-Haves"
        case .dealBreakers: return "Deal-Breakers"
        case .summary: return "Summary"
        }
    }
    
    var progress: Double {
        return Double(self.rawValue) / Double(QuestionnaireStep.allCases.count - 1)
    }
}

// MARK: - Constants
struct QuestionnaireConstants {
    static let ageGroups = [
        "18-24",
        "25-34", 
        "35-44",
        "45-54",
        "55-64",
        "65+"
    ]
    
    static let groupRelationships = [
        "solo",
        "couple",
        "friends",
        "family_with_kids",
        "family_adults_only",
        "work_colleagues",
        "mixed_group"
    ]
    
    static let popularCountries = [
        "None (Open to suggestions)",
        "United States",
        "Canada", 
        "United Kingdom",
        "France",
        "Germany",
        "Italy",
        "Spain",
        "Netherlands",
        "Japan",
        "South Korea",
        "Australia",
        "New Zealand",
        "Mexico",
        "Brazil",
        "Argentina",
        "Thailand",
        "Indonesia",
        "India",
        "Egypt",
        "Morocco",
        "South Africa"
    ]
    
    static let availableLikes = [
        "cultural_experiences",
        "food_and_drink",
        "outdoor_activities",
        "historical_sites",
        "nightlife",
        "shopping",
        "beaches",
        "museums",
        "architecture",
        "nature",
        "adventure_sports",
        "photography",
        "local_festivals",
        "art_galleries",
        "live_music"
    ]
    
    static let availableDislikes = [
        "crowded_places",
        "extreme_weather",
        "long_flights",
        "language_barriers",
        "expensive_food",
        "poor_infrastructure",
        "limited_vegetarian_options",
        "unsafe_areas",
        "tourist_traps",
        "early_mornings",
        "late_nights",
        "physical_challenges",
        "lack_of_wifi",
        "noisy_environments",
        "unfamiliar_cuisines"
    ]
    
    static let travelStyles = [
        "adventure",
        "relaxed",
        "balanced",
        "luxury"
    ]
    
    static let commonMustHaves = [
        "walkable city",
        "good food scene",
        "beach access",
        "reliable wifi",
        "english spoken",
        "safe for solo travel",
        "good public transport",
        "close to airport",
        "nightlife options",
        "cultural attractions",
        "budget-friendly"
    ]
    
    static let commonDealBreakers = [
        "extreme weather",
        "language barrier",
        "expensive food",
        "crowded tourist spots",
        "long flights",
        "visa requirements",
        "poor infrastructure",
        "high crime rate",
        "limited vegetarian options",
        "no air conditioning",
        "smoking everywhere"
    ]
}