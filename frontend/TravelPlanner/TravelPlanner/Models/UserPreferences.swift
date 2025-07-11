import Foundation

// MARK: - UserPreferences
struct UserPreferences: Codable {
    var budget: Budget
    var travelDates: TravelDates
    var groupSize: Int
    var interests: [String]
    var travelStyle: String
    var mustHaves: [String]
    var dealBreakers: [String]
    
    enum CodingKeys: String, CodingKey {
        case budget
        case travelDates = "travel_dates"
        case groupSize = "group_size"
        case interests
        case travelStyle = "travel_style"
        case mustHaves = "must_haves"
        case dealBreakers = "deal_breakers"
    }
    
    init() {
        self.budget = Budget()
        self.travelDates = TravelDates()
        self.groupSize = 2
        self.interests = []
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

// MARK: - Questionnaire Step Enum
enum QuestionnaireStep: Int, CaseIterable {
    case welcome = 0
    case travelDates = 1
    case groupSize = 2
    case budget = 3
    case travelStyle = 4
    case interests = 5
    case mustHaves = 6
    case dealBreakers = 7
    case summary = 8
    
    var title: String {
        switch self {
        case .welcome: return "Welcome"
        case .travelDates: return "Travel Dates"
        case .groupSize: return "Group Size"
        case .budget: return "Budget"
        case .travelStyle: return "Travel Style"
        case .interests: return "Interests"
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
    static let availableInterests = [
        "cultural_experiences",
        "food_and_drink",
        "outdoor_activities",
        "historical_sites",
        "nightlife",
        "shopping",
        "beaches",
        "museums",
        "architecture",
        "nature"
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