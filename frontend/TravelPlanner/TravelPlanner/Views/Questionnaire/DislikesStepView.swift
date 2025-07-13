import SwiftUI

/// Multi-select interface for things users dislike about travel with 5-item limit
struct DislikesStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    
    private let dislikeOptions = [
        (id: "crowded_places", title: "Crowded Places", icon: "person.3.fill"),
        (id: "extreme_weather", title: "Extreme Weather", icon: "thermometer.sun.fill"),
        (id: "long_flights", title: "Long Flights", icon: "airplane"),
        (id: "language_barriers", title: "Language Barriers", icon: "bubble.left.and.bubble.right.fill"),
        (id: "expensive_food", title: "Expensive Food", icon: "dollarsign.circle.fill"),
        (id: "poor_infrastructure", title: "Poor Infrastructure", icon: "road.lanes"),
        (id: "limited_vegetarian_options", title: "Limited Vegetarian", icon: "leaf.circle.fill"),
        (id: "unsafe_areas", title: "Unsafe Areas", icon: "exclamationmark.triangle.fill"),
        (id: "tourist_traps", title: "Tourist Traps", icon: "photo.fill"),
        (id: "early_mornings", title: "Early Mornings", icon: "sunrise.fill"),
        (id: "late_nights", title: "Late Nights", icon: "moon.fill"),
        (id: "physical_challenges", title: "Physical Challenges", icon: "figure.walk"),
        (id: "lack_of_wifi", title: "No WiFi", icon: "wifi.slash"),
        (id: "noisy_environments", title: "Noisy Places", icon: "speaker.wave.3.fill"),
        (id: "unfamiliar_cuisines", title: "Unfamiliar Food", icon: "questionmark.circle.fill")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("What do you want to avoid?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text("Select up to 5 things you'd prefer to avoid when traveling. This helps us filter out destinations that might not suit you.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(dislikeOptions, id: \.id) { dislike in
                        Button(action: {
                            toggleDislike(dislike.id)
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: dislike.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(coordinator.userPreferences.dislikes.contains(dislike.id) ? .white : .red)
                                
                                Text(dislike.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(coordinator.userPreferences.dislikes.contains(dislike.id) ? .white : .primary)
                            }
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .background(coordinator.userPreferences.dislikes.contains(dislike.id) ? Color.red : Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        coordinator.userPreferences.dislikes.contains(dislike.id) ? Color.red : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                        }
                        .disabled(
                            !coordinator.userPreferences.dislikes.contains(dislike.id) &&
                            coordinator.userPreferences.dislikes.count >= 5
                        )
                        .opacity(
                            !coordinator.userPreferences.dislikes.contains(dislike.id) &&
                            coordinator.userPreferences.dislikes.count >= 5 ? 0.5 : 1.0
                        )
                    }
                }
                
                if coordinator.userPreferences.dislikes.count >= 5 {
                    Text("Maximum 5 dislikes selected")
                        .font(.caption)
                        .foregroundColor(.orange)
                } else {
                    Text("Optional - select things you want to avoid")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
    
    /// Handles dislike selection with maximum limit enforcement
    private func toggleDislike(_ dislikeId: String) {
        if coordinator.userPreferences.dislikes.contains(dislikeId) {
            coordinator.userPreferences.dislikes.removeAll { $0 == dislikeId }
        } else if coordinator.userPreferences.dislikes.count < 5 {
            coordinator.userPreferences.dislikes.append(dislikeId)
        }
    }
}

struct DislikesStepView_Previews: PreviewProvider {
    static var previews: some View {
        DislikesStepView(coordinator: QuestionnaireCoordinator())
    }
}