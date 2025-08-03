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
    
    /// Returns comprehensive mock itinerary response matching the backend API exactly
    static func mockItineraryResponse() -> ItineraryResponse {
        return ItineraryResponse(
            errors: nil,
            itinerary: GeneratedItinerary(
                destination: "Barcelona, Spain",
                totalDays: 7,
                dailySchedules: [
                    // Day 1: Arrival & Gothic Quarter
                    DailySchedule(
                        date: "2024-07-15",
                        dayNumber: 1,
                        theme: "Arrival & Gothic Quarter",
                        activities: [
                            ScheduledActivity(
                                startTime: "14:00",
                                endTime: "15:00",
                                activity: ActivityDetail(
                                    name: "Hotel Check-in",
                                    type: "logistics",
                                    notes: "Relax after arrival"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "15:30",
                                endTime: "17:30",
                                activity: ActivityDetail(
                                    name: "Las Ramblas Walk",
                                    type: "cultural",
                                    notes: "Introduction to the city"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "18:00",
                                endTime: "19:30",
                                activity: ActivityDetail(
                                    name: "Dinner at El Xampanyet",
                                    type: "dining",
                                    notes: "Traditional tapas experience"
                                )
                            )
                        ],
                        dailyCost: 85,
                        walkingDistance: "3.2 km"
                    ),
                    
                    // Day 2: Gaudí Architecture
                    DailySchedule(
                        date: "2024-07-16",
                        dayNumber: 2,
                        theme: "Gaudí Architecture Day",
                        activities: [
                            ScheduledActivity(
                                startTime: "09:00",
                                endTime: "09:30",
                                activity: ActivityDetail(
                                    name: "Hotel Breakfast",
                                    type: "dining",
                                    notes: "Start your day with energy"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "10:00",
                                endTime: "12:30",
                                activity: ActivityDetail(
                                    name: "Sagrada Familia Tour",
                                    type: "cultural",
                                    notes: "Skip-the-line tickets included"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "13:00",
                                endTime: "14:00",
                                activity: ActivityDetail(
                                    name: "Lunch at Cerveseria Catalana",
                                    type: "dining",
                                    notes: "Famous for their tapas"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "15:00",
                                endTime: "17:00",
                                activity: ActivityDetail(
                                    name: "Park Güell",
                                    type: "outdoor",
                                    notes: "Colorful park with city views"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "19:00",
                                endTime: "20:30",
                                activity: ActivityDetail(
                                    name: "Dinner at Cal Pep",
                                    type: "dining",
                                    notes: "Iconic seafood tapas bar"
                                )
                            )
                        ],
                        dailyCost: 120,
                        walkingDistance: "4.8 km"
                    ),
                    
                    // Day 3: Art & Culture
                    DailySchedule(
                        date: "2024-07-17",
                        dayNumber: 3,
                        theme: "Art & Culture Immersion",
                        activities: [
                            ScheduledActivity(
                                startTime: "09:30",
                                endTime: "10:00",
                                activity: ActivityDetail(
                                    name: "Coffee at Els Quatre Gats",
                                    type: "dining",
                                    notes: "Historic café where Picasso used to meet"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "10:30",
                                endTime: "12:30",
                                activity: ActivityDetail(
                                    name: "Picasso Museum",
                                    type: "cultural",
                                    notes: "Extensive collection of early works"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "13:00",
                                endTime: "14:00",
                                activity: ActivityDetail(
                                    name: "Lunch at Bar del Pla",
                                    type: "dining",
                                    notes: "Modern tapas in Gothic Quarter"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "15:00",
                                endTime: "16:30",
                                activity: ActivityDetail(
                                    name: "Casa Batlló",
                                    type: "cultural",
                                    notes: "Modernist masterpiece with audio guide"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "17:00",
                                endTime: "18:30",
                                activity: ActivityDetail(
                                    name: "La Boqueria Market",
                                    type: "food",
                                    notes: "Famous food market experience"
                                )
                            )
                        ],
                        dailyCost: 95,
                        walkingDistance: "5.1 km"
                    ),
                    
                    // Day 4: Beach & Neighborhoods
                    DailySchedule(
                        date: "2024-07-18",
                        dayNumber: 4,
                        theme: "Beach & Local Neighborhoods",
                        activities: [
                            ScheduledActivity(
                                startTime: "10:00",
                                endTime: "13:00",
                                activity: ActivityDetail(
                                    name: "Barceloneta Beach",
                                    type: "outdoor",
                                    notes: "Relax and swim at the city beach"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "13:30",
                                endTime: "14:30",
                                activity: ActivityDetail(
                                    name: "Seafood Lunch at Barceloneta",
                                    type: "dining",
                                    notes: "Fresh seafood by the beach"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "16:00",
                                endTime: "18:00",
                                activity: ActivityDetail(
                                    name: "El Born District Walk",
                                    type: "cultural",
                                    notes: "Trendy neighborhood with boutiques"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "18:30",
                                endTime: "19:30",
                                activity: ActivityDetail(
                                    name: "Santa Maria del Mar",
                                    type: "cultural",
                                    notes: "Beautiful Gothic church"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "20:00",
                                endTime: "21:30",
                                activity: ActivityDetail(
                                    name: "Dinner at Euskal Etxea",
                                    type: "dining",
                                    notes: "Basque pintxos bar"
                                )
                            )
                        ],
                        dailyCost: 75,
                        walkingDistance: "6.2 km"
                    ),
                    
                    // Day 5: Montjuïc Hill
                    DailySchedule(
                        date: "2024-07-19",
                        dayNumber: 5,
                        theme: "Montjuïc Hill Exploration",
                        activities: [
                            ScheduledActivity(
                                startTime: "09:30",
                                endTime: "10:00",
                                activity: ActivityDetail(
                                    name: "Cable Car to Montjuïc",
                                    type: "logistics",
                                    notes: "Scenic ride up the hill"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "10:30",
                                endTime: "12:00",
                                activity: ActivityDetail(
                                    name: "Fundació Joan Miró",
                                    type: "cultural",
                                    notes: "Modern art museum dedicated to Miró"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "12:30",
                                endTime: "13:30",
                                activity: ActivityDetail(
                                    name: "Lunch at Martínez Restaurant",
                                    type: "dining",
                                    notes: "Panoramic views of the city"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "14:30",
                                endTime: "16:00",
                                activity: ActivityDetail(
                                    name: "Montjuïc Castle",
                                    type: "historical",
                                    notes: "Historic fortress with harbor views"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "17:00",
                                endTime: "18:00",
                                activity: ActivityDetail(
                                    name: "Magic Fountain Show",
                                    type: "entertainment",
                                    notes: "Evening light and music show"
                                )
                            )
                        ],
                        dailyCost: 90,
                        walkingDistance: "3.5 km"
                    ),
                    
                    // Day 6: Day Trip to Girona
                    DailySchedule(
                        date: "2024-07-20",
                        dayNumber: 6,
                        theme: "Day Trip to Girona",
                        activities: [
                            ScheduledActivity(
                                startTime: "08:00",
                                endTime: "09:30",
                                activity: ActivityDetail(
                                    name: "Train to Girona",
                                    type: "logistics",
                                    notes: "1.5 hour scenic train ride"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "10:00",
                                endTime: "12:00",
                                activity: ActivityDetail(
                                    name: "Girona Cathedral & Old Town",
                                    type: "cultural",
                                    notes: "Medieval architecture and Game of Thrones filming locations"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "12:30",
                                endTime: "13:30",
                                activity: ActivityDetail(
                                    name: "Lunch at Casa Marieta",
                                    type: "dining",
                                    notes: "Traditional Catalan cuisine"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "14:00",
                                endTime: "16:00",
                                activity: ActivityDetail(
                                    name: "Jewish Quarter Walk",
                                    type: "historical",
                                    notes: "One of Europe's best-preserved Jewish quarters"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "18:00",
                                endTime: "19:30",
                                activity: ActivityDetail(
                                    name: "Return Train to Barcelona",
                                    type: "logistics",
                                    notes: "Back to Barcelona for evening"
                                )
                            )
                        ],
                        dailyCost: 110,
                        walkingDistance: "8.0 km"
                    ),
                    
                    // Day 7: Farewell Barcelona
                    DailySchedule(
                        date: "2024-07-21",
                        dayNumber: 7,
                        theme: "Farewell Barcelona",
                        activities: [
                            ScheduledActivity(
                                startTime: "10:00",
                                endTime: "11:30",
                                activity: ActivityDetail(
                                    name: "Casa Milà (La Pedrera)",
                                    type: "cultural",
                                    notes: "Final Gaudí masterpiece visit"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "12:00",
                                endTime: "13:00",
                                activity: ActivityDetail(
                                    name: "Souvenir Shopping on Passeig de Gràcia",
                                    type: "shopping",
                                    notes: "Last-minute gifts and memories"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "13:30",
                                endTime: "15:00",
                                activity: ActivityDetail(
                                    name: "Farewell Lunch at 7 Portes",
                                    type: "dining",
                                    notes: "Historic restaurant serving paella since 1836"
                                )
                            ),
                            ScheduledActivity(
                                startTime: "16:00",
                                endTime: "17:00",
                                activity: ActivityDetail(
                                    name: "Hotel Check-out & Departure",
                                    type: "logistics",
                                    notes: "End of your Barcelona adventure"
                                )
                            )
                        ],
                        dailyCost: 80,
                        walkingDistance: "2.8 km"
                    )
                ]
            ),
            summary: ItinerarySummary(
                totalCost: 655,
                totalActivities: 28,
                optimizationScore: 0.91
            )
        )
    }
}