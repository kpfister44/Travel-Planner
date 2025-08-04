import SwiftUI

/// Step 21: Allows users to select from LLM-suggested activities for itinerary generation
struct ActivitySelectionStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("Choose your activities")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                if let destination = coordinator.selectedDestination {
                    Text("Based on your preferences, here are personalized activities for \(destination.name)")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    Text("Select the activities you'd like to include in your itinerary")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            
            if coordinator.isLoadingSuggestedActivities {
                // Loading state
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.2)
                    
                    Text("Finding perfect activities for you...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let suggestionsResponse = coordinator.activitySuggestionsResponse {
                // Activity selection interface
                VStack(spacing: 16) {
                    // Selection counter
                    HStack {
                        Text("\(coordinator.selectedActivities.count) activities selected")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if coordinator.selectedActivities.count >= 3 {
                            Text("Great selection!")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Text("Select at least 1 activity")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Activities list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(suggestionsResponse.suggestedActivities) { activity in
                                ActivityCard(
                                    activity: activity,
                                    isSelected: coordinator.selectedActivities.contains { $0.id == activity.id },
                                    onToggle: {
                                        toggleActivitySelection(activity)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                }
            } else {
                // Error state
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    
                    Text("Unable to load activity suggestions")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text("Please try again or go back to review your preferences")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Try Again") {
                        coordinator.retryActivitySuggestions()
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func toggleActivitySelection(_ activity: SuggestedActivity) {
        if let index = coordinator.selectedActivities.firstIndex(where: { $0.id == activity.id }) {
            coordinator.selectedActivities.remove(at: index)
        } else {
            coordinator.selectedActivities.append(activity)
        }
    }
}

/// Individual activity card with selection capability
struct ActivityCard: View {
    let activity: SuggestedActivity
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with selection state
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(activity.name)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        HStack {
                            Text(activity.category.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.caption)
                                .foregroundColor(.blue)
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Text(activity.estimatedDuration)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Selection indicator
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    } else {
                        Circle()
                            .stroke(Color(.systemGray4), lineWidth: 2)
                            .frame(width: 24, height: 24)
                    }
                }
                
                // Description
                Text(activity.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                // Details row
                HStack {
                    // Location
                    if let location = activity.location {
                        Label(location, systemImage: "location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Cost and rating
                    HStack(spacing: 8) {
                        Text(activity.cost)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        if let rating = activity.rating {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                Text(String(format: "%.1f", rating))
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
                
                // Why recommended
                if let whyRecommended = activity.whyRecommended {
                    Text("💡 \(whyRecommended)")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(
                isSelected 
                ? Color.blue.opacity(0.1) 
                : Color(.systemGray6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.blue : Color.clear,
                        lineWidth: 2
                    )
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActivitySelectionStepView_Previews: PreviewProvider {
    static var previews: some View {
        let coordinator = QuestionnaireCoordinator()
        coordinator.activitySuggestionsResponse = MockData.mockActivitySuggestionsResponse()
        coordinator.selectedActivities = [coordinator.activitySuggestionsResponse!.suggestedActivities[0]]
        return ActivitySelectionStepView(coordinator: coordinator)
    }
}