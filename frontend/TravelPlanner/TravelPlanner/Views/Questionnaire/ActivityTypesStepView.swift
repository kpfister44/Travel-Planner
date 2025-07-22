import SwiftUI

/// Step 15: Allows users to rate their interest level in different activity categories
struct ActivityTypesStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("What activities interest you most?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Rate your interest level for each type of activity. This helps us prioritize your itinerary.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(ItineraryConstants.activityCategories, id: \.key) { category in
                        ActivityTypeCard(
                            name: category.name,
                            icon: category.icon,
                            currentLevel: getInterestLevel(for: category.key),
                            onLevelChanged: { level in
                                setInterestLevel(for: category.key, level: level)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func getInterestLevel(for category: String) -> InterestLevel {
        switch category {
        case "cultural_experiences":
            return coordinator.itineraryPreferences.activityTypes.culturalExperiences
        case "outdoor_activities":
            return coordinator.itineraryPreferences.activityTypes.outdoorActivities
        case "food_and_dining":
            return coordinator.itineraryPreferences.activityTypes.foodAndDining
        case "nightlife":
            return coordinator.itineraryPreferences.activityTypes.nightlife
        case "shopping":
            return coordinator.itineraryPreferences.activityTypes.shopping
        case "entertainment":
            return coordinator.itineraryPreferences.activityTypes.entertainment
        case "historical_sites":
            return coordinator.itineraryPreferences.activityTypes.historicalSites
        case "natural_attractions":
            return coordinator.itineraryPreferences.activityTypes.naturalAttractions
        default:
            return .medium
        }
    }
    
    private func setInterestLevel(for category: String, level: InterestLevel) {
        switch category {
        case "cultural_experiences":
            coordinator.itineraryPreferences.activityTypes.culturalExperiences = level
        case "outdoor_activities":
            coordinator.itineraryPreferences.activityTypes.outdoorActivities = level
        case "food_and_dining":
            coordinator.itineraryPreferences.activityTypes.foodAndDining = level
        case "nightlife":
            coordinator.itineraryPreferences.activityTypes.nightlife = level
        case "shopping":
            coordinator.itineraryPreferences.activityTypes.shopping = level
        case "entertainment":
            coordinator.itineraryPreferences.activityTypes.entertainment = level
        case "historical_sites":
            coordinator.itineraryPreferences.activityTypes.historicalSites = level
        case "natural_attractions":
            coordinator.itineraryPreferences.activityTypes.naturalAttractions = level
        default:
            break
        }
    }
}

/// Individual activity type card with interest level selection
struct ActivityTypeCard: View {
    let name: String
    let icon: String
    let currentLevel: InterestLevel
    let onLevelChanged: (InterestLevel) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 30, height: 30)
                
                Text(name)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                ForEach(InterestLevel.allCases, id: \.self) { level in
                    Button(action: {
                        onLevelChanged(level)
                    }) {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(currentLevel == level ? levelColor(level) : Color(.systemGray5))
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .stroke(levelColor(level), lineWidth: currentLevel == level ? 0 : 2)
                                )
                            
                            Text(level.displayName)
                                .font(.caption)
                                .fontWeight(currentLevel == level ? .semibold : .regular)
                                .foregroundColor(currentLevel == level ? levelColor(level) : .secondary)
                        }
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func levelColor(_ level: InterestLevel) -> Color {
        switch level {
        case .low:
            return .gray
        case .medium:
            return .orange
        case .high:
            return .green
        }
    }
}

struct ActivityTypesStepView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityTypesStepView(coordinator: QuestionnaireCoordinator())
    }
}