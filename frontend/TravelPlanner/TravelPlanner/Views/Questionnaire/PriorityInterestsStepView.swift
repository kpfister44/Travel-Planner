import SwiftUI

/// Step 17: Allows users to select and prioritize their top interests for itinerary planning
struct PriorityInterestsStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    
    // Available interests based on activity categories and user preferences
    private var availableInterests: [String] {
        let baseInterests = [
            "cultural_experiences",
            "outdoor_activities", 
            "food_and_dining",
            "nightlife",
            "shopping",
            "entertainment",
            "historical_sites",
            "natural_attractions"
        ]
        
        // Add user's high-interest activities from previous step
        let highInterestActivities = coordinator.itineraryPreferences.activityTypes.highInterestActivities
        
        // Combine and deduplicate
        let combined = baseInterests + coordinator.userPreferences.likes
        return Array(Set(combined)).sorted()
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("What are your top priorities?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Select up to 5 interests that matter most to you. These will guide our itinerary recommendations.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    // Selected interests (reorderable)
                    if !coordinator.itineraryPreferences.priorityInterests.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Top Priorities (tap and hold to reorder):")
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            ForEach(coordinator.itineraryPreferences.priorityInterests.indices, id: \.self) { index in
                                PriorityInterestRow(
                                    interest: coordinator.itineraryPreferences.priorityInterests[index],
                                    position: index + 1,
                                    onRemove: {
                                        removeInterest(coordinator.itineraryPreferences.priorityInterests[index])
                                    }
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Available interests to add
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Available Interests:")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(availableInterests.filter { !coordinator.itineraryPreferences.priorityInterests.contains($0) }, id: \.self) { interest in
                                SelectableChip(
                                    text: formatInterestName(interest),
                                    isSelected: false
                                ) {
                                    addInterest(interest)
                                }
                            }
                        }
                    }
                    
                    // Count and limit indicator
                    HStack {
                        Text("\(coordinator.itineraryPreferences.priorityInterests.count)/5 priorities selected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if coordinator.itineraryPreferences.priorityInterests.count >= 5 {
                            Text("Maximum reached")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func addInterest(_ interest: String) {
        if coordinator.itineraryPreferences.priorityInterests.count < 5 &&
           !coordinator.itineraryPreferences.priorityInterests.contains(interest) {
            coordinator.itineraryPreferences.priorityInterests.append(interest)
        }
    }
    
    private func removeInterest(_ interest: String) {
        coordinator.itineraryPreferences.priorityInterests.removeAll { $0 == interest }
    }
    
    private func formatInterestName(_ interest: String) -> String {
        return interest.replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}

/// Individual priority interest row with drag handle and remove button
struct PriorityInterestRow: View {
    let interest: String
    let position: Int
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            // Position indicator
            Text("\(position).")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .frame(width: 20, alignment: .leading)
            
            // Interest name
            Text(formatInterestName(interest))
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            // Drag handle
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.secondary)
                .font(.caption)
            
            // Remove button
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 16))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func formatInterestName(_ interest: String) -> String {
        return interest.replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}

struct PriorityInterestsStepView_Previews: PreviewProvider {
    static var previews: some View {
        let coordinator = QuestionnaireCoordinator()
        coordinator.itineraryPreferences.priorityInterests = ["cultural_experiences", "food_and_dining"]
        return PriorityInterestsStepView(coordinator: coordinator)
    }
}