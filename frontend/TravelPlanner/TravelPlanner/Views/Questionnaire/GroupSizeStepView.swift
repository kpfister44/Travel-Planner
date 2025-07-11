import SwiftUI

/// Allows users to select group size through quick options or custom stepper control
struct GroupSizeStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    
    private let quickOptions = [1, 2, 4, 6]
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("How many people are traveling?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("This helps us recommend accommodations and activities that fit your group size.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 24) {
                // Quick Options
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(quickOptions, id: \.self) { size in
                        Button(action: {
                            coordinator.userPreferences.groupSize = size
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: size == 1 ? "person.fill" : "person.2.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(coordinator.userPreferences.groupSize == size ? .white : .blue)
                                
                                Text("\(size) \(size == 1 ? "Person" : "People")")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(coordinator.userPreferences.groupSize == size ? .white : .primary)
                            }
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .background(coordinator.userPreferences.groupSize == size ? Color.blue : Color(.systemGray6))
                            .cornerRadius(12)
                        }
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
            
            Spacer()
        }
        .padding()
    }
}

struct GroupSizeStepView_Previews: PreviewProvider {
    static var previews: some View {
        GroupSizeStepView(coordinator: QuestionnaireCoordinator())
    }
}