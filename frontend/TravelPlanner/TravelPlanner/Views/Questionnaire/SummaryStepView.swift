import SwiftUI

/// Final review screen showing all user preferences with edit capability
struct SummaryStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Ready to find your perfect trip?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text("Here's a summary of your preferences. You can go back to make changes or continue to get personalized recommendations.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                VStack(spacing: 16) {
                    SummaryCard(title: "About You", icon: "person.circle") {
                        Text("Age Group: \(coordinator.userPreferences.travelerInfo.ageGroup)")
                    } editAction: {
                        coordinator.jumpToStep(.travelerInfo)
                    }
                    
                    SummaryCard(title: "Travel Dates", icon: "calendar") {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("From: \(formatDate(coordinator.userPreferences.travelDates.startDate))")
                            Text("To: \(formatDate(coordinator.userPreferences.travelDates.endDate))")
                            Text("Duration: \(tripDuration) days")
                                .foregroundColor(.secondary)
                        }
                    } editAction: {
                        coordinator.jumpToStep(.travelDates)
                    }
                    
                    SummaryCard(title: "Group Details", icon: "person.2") {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(coordinator.userPreferences.groupSize) \(coordinator.userPreferences.groupSize == 1 ? "person" : "people")")
                            Text("Type: \(coordinator.userPreferences.groupRelationship.replacingOccurrences(of: "_", with: " ").capitalized)")
                                .foregroundColor(.secondary)
                        }
                    } editAction: {
                        coordinator.jumpToStep(.groupSize)
                    }
                    
                    SummaryCard(title: "Destination Preference", icon: "globe") {
                        Text(coordinator.userPreferences.preferredLocation)
                    } editAction: {
                        coordinator.jumpToStep(.preferredLocation)
                    }
                    
                    SummaryCard(title: "Budget", icon: "dollarsign.circle") {
                        Text("$\(coordinator.userPreferences.budget.min) - $\(coordinator.userPreferences.budget.max) \(coordinator.userPreferences.budget.currency)")
                    } editAction: {
                        coordinator.jumpToStep(.budget)
                    }
                    
                    SummaryCard(title: "Travel Style", icon: "star") {
                        Text(coordinator.userPreferences.travelStyle.capitalized)
                    } editAction: {
                        coordinator.jumpToStep(.travelStyle)
                    }
                    
                    SummaryCard(title: "What You Like", icon: "heart.fill") {
                        FlowLayout(spacing: 4) {
                            ForEach(coordinator.userPreferences.likes, id: \.self) { like in
                                Text(like.replacingOccurrences(of: "_", with: " ").capitalized)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.1))
                                    .foregroundColor(.green)
                                    .cornerRadius(8)
                            }
                        }
                    } editAction: {
                        coordinator.jumpToStep(.likes)
                    }
                    
                    if !coordinator.userPreferences.dislikes.isEmpty {
                        SummaryCard(title: "What You Dislike", icon: "heart.slash.fill") {
                            FlowLayout(spacing: 4) {
                                ForEach(coordinator.userPreferences.dislikes, id: \.self) { dislike in
                                    Text(dislike.replacingOccurrences(of: "_", with: " ").capitalized)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.red.opacity(0.1))
                                        .foregroundColor(.red)
                                        .cornerRadius(8)
                                }
                            }
                        } editAction: {
                            coordinator.jumpToStep(.dislikes)
                        }
                    }
                    
                    if !coordinator.userPreferences.mustHaves.isEmpty {
                        SummaryCard(title: "Must-Haves", icon: "checkmark.circle") {
                            FlowLayout(spacing: 4) {
                                ForEach(coordinator.userPreferences.mustHaves, id: \.self) { mustHave in
                                    Text(mustHave)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.1))
                                        .foregroundColor(.green)
                                        .cornerRadius(8)
                                }
                            }
                        } editAction: {
                            coordinator.jumpToStep(.mustHaves)
                        }
                    }
                    
                    if !coordinator.userPreferences.dealBreakers.isEmpty {
                        SummaryCard(title: "Deal-Breakers", icon: "xmark.circle") {
                            FlowLayout(spacing: 4) {
                                ForEach(coordinator.userPreferences.dealBreakers, id: \.self) { dealBreaker in
                                    Text(dealBreaker)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.red.opacity(0.1))
                                        .foregroundColor(.red)
                                        .cornerRadius(8)
                                }
                            }
                        } editAction: {
                            coordinator.jumpToStep(.dealBreakers)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var tripDuration: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let startDate = formatter.date(from: coordinator.userPreferences.travelDates.startDate),
              let endDate = formatter.date(from: coordinator.userPreferences.travelDates.endDate) else {
            return 0
        }
        
        return Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

/// Reusable card component for displaying preference summaries with edit functionality
struct SummaryCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    let editAction: () -> Void
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content, editAction: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.content = content()
        self.editAction = editAction
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .foregroundColor(.blue)
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                Button("Edit") {
                    editAction()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SummaryStepView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryStepView(coordinator: QuestionnaireCoordinator())
    }
}