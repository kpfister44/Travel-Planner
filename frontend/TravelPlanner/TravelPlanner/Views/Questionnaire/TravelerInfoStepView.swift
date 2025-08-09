import SwiftUI

/// Age group selection interface for understanding traveler demographics
struct TravelerInfoStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    
    private let ageGroups = [
        (id: "18-24", title: "18-24", subtitle: "Young adult", icon: "person.fill"),
        (id: "25-34", title: "25-34", subtitle: "Young professional", icon: "person.2.fill"),
        (id: "35-44", title: "35-44", subtitle: "Established adult", icon: "person.3.fill"),
        (id: "45-54", title: "45-54", subtitle: "Mid-career", icon: "person.2.circle.fill"),
        (id: "55-64", title: "55-64", subtitle: "Pre-retirement", icon: "person.circle.fill"),
        (id: "65+", title: "65+", subtitle: "Senior", icon: "person.crop.circle.fill")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("Tell us about yourself")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("aboutYourselfTitle")
                    
                    Text("Your age group helps us understand your travel preferences and recommend age-appropriate destinations and activities.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .accessibilityIdentifier("aboutYourselfSubtitle")
                }
                
                VStack(spacing: 12) {
                    ForEach(ageGroups, id: \.id) { ageGroup in
                        Button(action: {
                            coordinator.userPreferences.travelerInfo.ageGroup = ageGroup.id
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: ageGroup.icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(coordinator.userPreferences.travelerInfo.ageGroup == ageGroup.id ? .white : .blue)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(ageGroup.title)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(coordinator.userPreferences.travelerInfo.ageGroup == ageGroup.id ? .white : .primary)
                                    
                                    Text(ageGroup.subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(coordinator.userPreferences.travelerInfo.ageGroup == ageGroup.id ? .white.opacity(0.8) : .secondary)
                                }
                                
                                Spacer()
                                
                                if coordinator.userPreferences.travelerInfo.ageGroup == ageGroup.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(coordinator.userPreferences.travelerInfo.ageGroup == ageGroup.id ? Color.blue : Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .accessibilityIdentifier("ageGroup_\(ageGroup.id)")
                    }
                }
            }
            .padding()
        }
    }
}

struct TravelerInfoStepView_Previews: PreviewProvider {
    static var previews: some View {
        TravelerInfoStepView(coordinator: QuestionnaireCoordinator())
    }
}