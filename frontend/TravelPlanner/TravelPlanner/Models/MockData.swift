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
    
    /// Returns mock activity suggestions for testing itinerary flow
    static func mockActivitySuggestionsResponse() -> ActivitySuggestionsResponse {
        return ActivitySuggestionsResponse(
            suggestedActivities: [
                SuggestedActivity(
                    id: "activity_001",
                    name: "Sagrada Familia Tour",
                    description: "Explore Gaudí's masterpiece with skip-the-line access and expert guide",
                    category: "cultural_experiences",
                    estimatedDuration: "2-3 hours",
                    location: "Sagrada Familia, Barcelona",
                    cost: "€25-35",
                    rating: 4.8,
                    whyRecommended: "Must-see architectural wonder that matches your high interest in cultural experiences"
                ),
                SuggestedActivity(
                    id: "activity_002",
                    name: "Park Güell",
                    description: "Colorful park designed by Antoni Gaudí with stunning city views",
                    category: "outdoor_activities",
                    estimatedDuration: "2 hours",
                    location: "Park Güell, Barcelona",
                    cost: "€10-15",
                    rating: 4.6,
                    whyRecommended: "Combines outdoor exploration with unique architecture you'll love"
                ),
                SuggestedActivity(
                    id: "activity_003",
                    name: "Gothic Quarter Walking Tour",
                    description: "Discover medieval Barcelona's narrow streets and hidden squares",
                    category: "historical_sites",
                    estimatedDuration: "3 hours",
                    location: "Gothic Quarter, Barcelona",
                    cost: "€15-20",
                    rating: 4.7,
                    whyRecommended: "Perfect for your interest in historical sites and cultural exploration"
                ),
                SuggestedActivity(
                    id: "activity_004",
                    name: "La Boqueria Market Food Tour",
                    description: "Taste local specialties and learn about Catalan cuisine",
                    category: "food_and_dining",
                    estimatedDuration: "2.5 hours",
                    location: "La Boqueria Market, Barcelona",
                    cost: "€35-45",
                    rating: 4.9,
                    whyRecommended: "Matches your high interest in food experiences with authentic local flavors"
                ),
                SuggestedActivity(
                    id: "activity_005",
                    name: "Casa Batlló",
                    description: "Visit Gaudí's modernist masterpiece with immersive audio guide",
                    category: "cultural_experiences",
                    estimatedDuration: "1.5 hours",
                    location: "Passeig de Gràcia, Barcelona",
                    cost: "€25-30",
                    rating: 4.5,
                    whyRecommended: "Another Gaudí masterpiece for architecture enthusiasts"
                ),
                SuggestedActivity(
                    id: "activity_006",
                    name: "Barceloneta Beach",
                    description: "Relax at Barcelona's most popular urban beach",
                    category: "outdoor_activities",
                    estimatedDuration: "3-4 hours",
                    location: "Barceloneta Beach, Barcelona",
                    cost: "Free",
                    rating: 4.3,
                    whyRecommended: "Perfect for relaxation between cultural activities"
                )
            ]
        )
    }
}