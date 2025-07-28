import SwiftUI

/// Allows users to select group size and relationship type
struct GroupSizeStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    
    private let quickOptions = [1, 2, 4, 6]
    
    private let relationshipOptions = [
        (id: "solo", title: "Solo", subtitle: "Just me", icon: "person.fill"),
        (id: "couple", title: "Couple", subtitle: "Two people in a relationship", icon: "heart.fill"),
        (id: "friends", title: "Friends", subtitle: "Group of friends", icon: "person.2.fill"),
        (id: "family_with_kids", title: "Family with Kids", subtitle: "Parents and children", icon: "figure.and.child.holdinghands"),
        (id: "family_adults_only", title: "Family (Adults)", subtitle: "Adult family members", icon: "person.3.fill"),
        (id: "work_colleagues", title: "Work Colleagues", subtitle: "Business trip", icon: "briefcase.fill"),
        (id: "mixed_group", title: "Mixed Group", subtitle: "Various relationships", icon: "person.3.sequence.fill")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("Tell us about your group")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text("This helps us recommend accommodations and activities that fit your group dynamics.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            
                // Group Size Section
                VStack(spacing: 16) {
                    Text("Group Size")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(quickOptions, id: \.self) { size in
                        Button(action: {
                            coordinator.userPreferences.groupSize = size
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: size == 1 ? "person.fill" : "person.2.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(coordinator.userPreferences.groupSize == size ? .white : .blue)
                                    
                                Text("\(size) \(size == 1 ? "Person" : "People")")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(coordinator.userPreferences.groupSize == size ? .white : .primary)
                            }
                            .frame(height: 70)
                            .frame(maxWidth: .infinity)
                            .background(coordinator.userPreferences.groupSize == size ? Color.blue : Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .accessibilityIdentifier("groupSize_\(size)")
                        }
                    }
                    
                    // Custom Stepper
                    VStack(spacing: 12) {
                        Text("Or choose a custom size:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 16) {
                            Button(action: {
                                if coordinator.userPreferences.groupSize > 1 {
                                    coordinator.userPreferences.groupSize -= 1
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.blue)
                            }
                            .disabled(coordinator.userPreferences.groupSize <= 1)
                            
                            Text("\(coordinator.userPreferences.groupSize)")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .frame(minWidth: 40)
                            
                            Button(action: {
                                if coordinator.userPreferences.groupSize < 20 {
                                    coordinator.userPreferences.groupSize += 1
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.blue)
                            }
                            .disabled(coordinator.userPreferences.groupSize >= 20)
                        }
                    }
                }
                
                // Group Relationship Section
                VStack(spacing: 16) {
                    Text("Group Relationship")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                    ForEach(relationshipOptions, id: \.id) { relationship in
                        Button(action: {
                            coordinator.userPreferences.groupRelationship = relationship.id
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: relationship.icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(coordinator.userPreferences.groupRelationship == relationship.id ? .white : .blue)
                                    .frame(width: 30)
                                    
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(relationship.title)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(coordinator.userPreferences.groupRelationship == relationship.id ? .white : .primary)
                                    
                                    Text(relationship.subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(coordinator.userPreferences.groupRelationship == relationship.id ? .white.opacity(0.8) : .secondary)
                                }
                                
                                Spacer()
                                
                                if coordinator.userPreferences.groupRelationship == relationship.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(coordinator.userPreferences.groupRelationship == relationship.id ? Color.blue : Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .accessibilityIdentifier("groupRelationship_\(relationship.id)")
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct GroupSizeStepView_Previews: PreviewProvider {
    static var previews: some View {
        GroupSizeStepView(coordinator: QuestionnaireCoordinator())
    }
}