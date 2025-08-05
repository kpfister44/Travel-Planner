import SwiftUI

/// Step 20: Reviews all itinerary preferences and initiates activity suggestions API call
struct ItinerarySummaryStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("Ready to plan your itinerary?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Review your preferences below. We'll use these to suggest the perfect activities for your trip.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            ScrollView {
                VStack(spacing: 16) {
                    // Destination info
                    if let destination = coordinator.selectedDestination {
                        DestinationSummaryCard(destination: destination)
                    }
                    
                    // Travel pace and schedule
                    PreferenceSummaryCard(
                        title: "Travel Pace",
                        icon: "clock",
                        content: [
                            "Pace: \(coordinator.itineraryPreferences.pace.displayName)",
                            "Daily hours: \(coordinator.itineraryPreferences.formattedTimeRange)",
                            "Max activities: \(coordinator.itineraryPreferences.maxActivitiesPerDay) per day"
                        ]
                    ) {
                        coordinator.jumpToStep(.travelPace)
                    }
                    
                    // Activity interests
                    PreferenceSummaryCard(
                        title: "Activity Interests",
                        icon: "star",
                        content: [coordinator.itineraryPreferences.activitySummary]
                    ) {
                        coordinator.jumpToStep(.activityTypes)
                    }
                    
                    // Selected activities
                    if !coordinator.selectedActivities.isEmpty {
                        PreferenceSummaryCard(
                            title: "Selected Activities (\(coordinator.selectedActivities.count))",
                            icon: "checkmark.circle",
                            content: coordinator.selectedActivities.map { activity in
                                "\(activity.name) - \(activity.category.replacingOccurrences(of: "_", with: " ").capitalized) (\(activity.durationHours)h)"
                            }
                        ) {
                            coordinator.jumpToStep(.activitySelection)
                        }
                    }
                    
                    // Must-see attractions
                    if !coordinator.itineraryPreferences.mustSeeAttractions.isEmpty {
                        PreferenceSummaryCard(
                            title: "Must-See Attractions",
                            icon: "mappin",
                            content: coordinator.itineraryPreferences.mustSeeAttractions
                        ) {
                            coordinator.jumpToStep(.mustSeeAttractions)
                        }
                    }
                    
                    
                    // Dining preferences
                    PreferenceSummaryCard(
                        title: "Dining Preferences",
                        icon: "fork.knife",
                        content: [
                            "Breakfast: \(coordinator.itineraryPreferences.mealPreferences.breakfast.displayName)",
                            "Lunch: \(coordinator.itineraryPreferences.mealPreferences.lunch.displayName)",
                            "Dinner: \(coordinator.itineraryPreferences.mealPreferences.dinner.displayName)"
                        ] + (coordinator.itineraryPreferences.mealPreferences.dietaryRestrictions.isEmpty ? [] : [
                            "Dietary: \(coordinator.itineraryPreferences.mealPreferences.dietaryRestrictions.joined(separator: ", "))"
                        ])
                    ) {
                        coordinator.jumpToStep(.mealPreferences)
                    }
                    
                    // Transportation
                    PreferenceSummaryCard(
                        title: "Transportation",
                        icon: coordinator.itineraryPreferences.transportation.iconName,
                        content: [
                            coordinator.itineraryPreferences.transportation.displayName,
                            coordinator.itineraryPreferences.accommodationArea.isEmpty ? "No area preference" : "Accommodation: \(formatAccommodationArea(coordinator.itineraryPreferences.accommodationArea))"
                        ]
                    ) {
                        coordinator.jumpToStep(.transportation)
                    }
                    
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Loading overlay when generating itinerary
            if coordinator.isGeneratingItinerary {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    
                    VStack(spacing: 8) {
                        Text("Generating your perfect itinerary...")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Text("This may take a few seconds while we optimize your activities and schedule.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground).opacity(0.95))
                .transition(.opacity)
            }
        }
        .padding()
    }
    
    private func formatInterestName(_ interest: String) -> String {
        return interest.replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
    
    private func formatAccommodationArea(_ area: String) -> String {
        return area.replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}

/// Summary card for destination information
struct DestinationSummaryCard: View {
    let destination: Destination
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.blue)
                    .font(.title3)
                
                Text("Your Destination")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(destination.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Match Score: \(destination.matchScore)%")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                Text(destination.whyRecommended)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

/// Reusable summary card for preference sections
struct PreferenceSummaryCard: View {
    let title: String
    let icon: String
    let content: [String]
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title3)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button("Edit", action: onEdit)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(content, id: \.self) { item in
                    Text("• \(item)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ItinerarySummaryStepView_Previews: PreviewProvider {
    static var previews: some View {
        let coordinator = QuestionnaireCoordinator()
        coordinator.selectedDestination = Destination(
            id: "1",
            name: "Barcelona, Spain",
            country: "Spain",
            matchScore: 95,
            estimatedCost: 150,
            highlights: ["Culture", "Food", "Art"],
            whyRecommended: "Perfect for cultural experiences",
            imageURL: nil
        )
        coordinator.itineraryPreferences.priorityInterests = ["cultural_experiences", "food_and_dining"]
        coordinator.itineraryPreferences.mustSeeAttractions = ["Sagrada Familia", "Park Güell"]
        return ItinerarySummaryStepView(coordinator: coordinator)
    }
}