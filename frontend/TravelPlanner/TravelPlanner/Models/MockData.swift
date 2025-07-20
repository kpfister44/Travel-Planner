import Foundation

/// Simple mock data for testing destination selection UI without backend
struct MockData {
    
    /// Returns 3 mock destinations matching the backend API structure
    static func mockDestinationResponse() -> DestinationResponse {
        return DestinationResponse(
            errors: nil,
            recommendations: [
                Destination(
                    id: "dest_001",
                    name: "Barcelona, Spain",
                    country: "Spain",
                    matchScore: 92,
                    estimatedCost: 1650,
                    highlights: [
                        "Stunning Gaudí architecture",
                        "World-class food scene",
                        "Beautiful beaches within city"
                    ],
                    whyRecommended: "Perfect for cultural interests with great walkability and amazing food scene. The city offers a perfect blend of historic architecture and modern culture.",
                    imageURL: nil
                ),
                Destination(
                    id: "dest_002",
                    name: "Prague, Czech Republic",
                    country: "Czech Republic",
                    matchScore: 88,
                    estimatedCost: 1200,
                    highlights: [
                        "Medieval Old Town",
                        "Affordable prices",
                        "Rich history"
                    ],
                    whyRecommended: "Great value destination with amazing architecture and affordable prices. The historic city center is perfect for cultural exploration.",
                    imageURL: nil
                ),
                Destination(
                    id: "dest_003",
                    name: "Lisbon, Portugal",
                    country: "Portugal",
                    matchScore: 85,
                    estimatedCost: 1400,
                    highlights: [
                        "Colorful neighborhoods",
                        "Excellent seafood",
                        "Mild climate"
                    ],
                    whyRecommended: "Charming coastal city with great food culture and pleasant weather. The hilly neighborhoods offer stunning views and authentic experiences.",
                    imageURL: nil
                )
            ]
        )
    }
    
    /// Returns mock error response for testing error states
    static func mockErrorResponse() -> DestinationResponse {
        return DestinationResponse(
            errors: [
                BackendError(code: "invalid_request", message: "Unable to process your preferences. Please try again.")
            ],
            recommendations: nil
        )
    }
}