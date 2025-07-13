import SwiftUI

/// Multi-select interface for things users like about travel with 5-item limit
struct LikesStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    
    private let likeOptions = [
        (id: "cultural_experiences", title: "Cultural Experiences", icon: "theatermasks.fill"),
        (id: "food_and_drink", title: "Food & Drink", icon: "fork.knife"),
        (id: "outdoor_activities", title: "Outdoor Activities", icon: "figure.hiking"),
        (id: "historical_sites", title: "Historical Sites", icon: "building.columns.fill"),
        (id: "nightlife", title: "Nightlife", icon: "music.note.house.fill"),
        (id: "shopping", title: "Shopping", icon: "bag.fill"),
        (id: "beaches", title: "Beaches", icon: "beach.umbrella.fill"),
        (id: "museums", title: "Museums", icon: "building.fill"),
        (id: "architecture", title: "Architecture", icon: "building.2.fill"),
        (id: "nature", title: "Nature", icon: "tree.fill"),
        (id: "adventure_sports", title: "Adventure Sports", icon: "figure.snowboarding"),
        (id: "photography", title: "Photography", icon: "camera.fill"),
        (id: "local_festivals", title: "Local Festivals", icon: "party.popper.fill"),
        (id: "art_galleries", title: "Art Galleries", icon: "paintbrush.fill"),
        (id: "live_music", title: "Live Music", icon: "music.note")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("What do you like about travel?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text("Select 1-5 things that you enjoy most when traveling. This helps us find destinations that match your interests.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(likeOptions, id: \.id) { like in
                        Button(action: {
                            toggleLike(like.id)
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: like.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(coordinator.userPreferences.likes.contains(like.id) ? .white : .green)
                                
                                Text(like.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(coordinator.userPreferences.likes.contains(like.id) ? .white : .primary)
                            }
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .background(coordinator.userPreferences.likes.contains(like.id) ? Color.green : Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        coordinator.userPreferences.likes.contains(like.id) ? Color.green : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                        }
                        .disabled(
                            !coordinator.userPreferences.likes.contains(like.id) &&
                            coordinator.userPreferences.likes.count >= 5
                        )
                        .opacity(
                            !coordinator.userPreferences.likes.contains(like.id) &&
                            coordinator.userPreferences.likes.count >= 5 ? 0.5 : 1.0
                        )
                    }
                }
                
                if coordinator.userPreferences.likes.count >= 5 {
                    Text("Maximum 5 likes selected")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            .padding()
        }
    }
    
    /// Handles like selection with maximum limit enforcement
    private func toggleLike(_ likeId: String) {
        if coordinator.userPreferences.likes.contains(likeId) {
            coordinator.userPreferences.likes.removeAll { $0 == likeId }
        } else if coordinator.userPreferences.likes.count < 5 {
            coordinator.userPreferences.likes.append(likeId)
        }
    }
}

struct LikesStepView_Previews: PreviewProvider {
    static var previews: some View {
        LikesStepView(coordinator: QuestionnaireCoordinator())
    }
}