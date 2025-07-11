import SwiftUI

/// Multi-select interface for travel interests with 5-item limit and visual feedback
struct InterestsStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    
    private let interestOptions = [
        (id: "cultural_experiences", title: "Cultural Experiences", icon: "theatermasks.fill"),
        (id: "food_and_drink", title: "Food & Drink", icon: "fork.knife"),
        (id: "outdoor_activities", title: "Outdoor Activities", icon: "figure.hiking"),
        (id: "historical_sites", title: "Historical Sites", icon: "building.columns.fill"),
        (id: "nightlife", title: "Nightlife", icon: "music.note.house.fill"),
        (id: "shopping", title: "Shopping", icon: "bag.fill"),
        (id: "beaches", title: "Beaches", icon: "beach.umbrella.fill"),
        (id: "museums", title: "Museums", icon: "building.fill"),
        (id: "architecture", title: "Architecture", icon: "building.2.fill"),
        (id: "nature", title: "Nature", icon: "tree.fill")
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("What interests you most?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Select 1-5 interests that best describe what you love about traveling.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(interestOptions, id: \.id) { interest in
                    Button(action: {
                        toggleInterest(interest.id)
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: interest.icon)
                                .font(.system(size: 24))
                                .foregroundColor(coordinator.userPreferences.interests.contains(interest.id) ? .white : .blue)
                            
                            Text(interest.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .foregroundColor(coordinator.userPreferences.interests.contains(interest.id) ? .white : .primary)
                        }
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .background(coordinator.userPreferences.interests.contains(interest.id) ? Color.blue : Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    coordinator.userPreferences.interests.contains(interest.id) ? Color.blue : Color.clear,
                                    lineWidth: 2
                                )
                        )
                    }
                    .disabled(
                        !coordinator.userPreferences.interests.contains(interest.id) &&
                        coordinator.userPreferences.interests.count >= 5
                    )
                    .opacity(
                        !coordinator.userPreferences.interests.contains(interest.id) &&
                        coordinator.userPreferences.interests.count >= 5 ? 0.5 : 1.0
                    )
                }
            }
            
            if coordinator.userPreferences.interests.count >= 5 {
                Text("Maximum 5 interests selected")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            Spacer()
        }
        .padding()
    }
    
    /// Handles interest selection with maximum limit enforcement
    private func toggleInterest(_ interestId: String) {
        if coordinator.userPreferences.interests.contains(interestId) {
            coordinator.userPreferences.interests.removeAll { $0 == interestId }
        } else if coordinator.userPreferences.interests.count < 5 {
            coordinator.userPreferences.interests.append(interestId)
        }
    }
}

struct InterestsStepView_Previews: PreviewProvider {
    static var previews: some View {
        InterestsStepView(coordinator: QuestionnaireCoordinator())
    }
}