import Foundation

// MARK: - API Response Models

/// Backend error model matching backend error structure
struct BackendError: Codable {
    let code: String
    let message: String
}

/// Individual destination recommendation from LLM
struct Destination: Codable, Identifiable {
    let id: String
    let name: String
    let country: String
    let matchScore: Int
    let estimatedCost: Int
    let highlights: [String]
    let whyRecommended: String
    let imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, country, highlights
        case matchScore = "match_score"
        case estimatedCost = "estimated_cost"
        case whyRecommended = "why_recommended"
        case imageURL = "image_url"
    }
}

/// Backend response wrapper for destination recommendations
struct DestinationResponse: Codable {
    let errors: [BackendError]?
    let recommendations: [Destination]?
}

// MARK: - UI Helper Extensions

extension Destination {
    /// Formatted cost string for display
    var formattedCost: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: estimatedCost)) ?? "$\(estimatedCost)"
    }
    
    /// Match score as percentage for UI display
    var matchPercentage: Double {
        return Double(matchScore) / 100.0
    }
    
    /// Color based on match score
    var matchScoreColor: String {
        switch matchScore {
        case 90...100: return "green"
        case 75...89: return "blue"
        case 60...74: return "orange"
        default: return "red"
        }
    }
}