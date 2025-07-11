import SwiftUI

/// Allows users to select travel preferences they want to avoid from preset options or add custom ones
struct DealBreakersStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    @State private var customDealBreaker = ""
    @State private var showingCustomInput = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("What should we avoid?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Select things you'd prefer to avoid. This helps us exclude destinations that might not be a good fit.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 16) {
                FlowLayout(spacing: 8) {
                    ForEach(QuestionnaireConstants.commonDealBreakers, id: \.self) { dealBreaker in
                        SelectableChip(
                            text: dealBreaker,
                            isSelected: coordinator.userPreferences.dealBreakers.contains(dealBreaker)
                        ) {
                            toggleDealBreaker(dealBreaker)
                        }
                    }
                    
                    // Custom deal-breakers
                    ForEach(coordinator.userPreferences.dealBreakers.filter { !QuestionnaireConstants.commonDealBreakers.contains($0) }, id: \.self) { customDealBreaker in
                        SelectableChip(
                            text: customDealBreaker,
                            isSelected: true,
                            isCustom: true
                        ) {
                            coordinator.userPreferences.dealBreakers.removeAll { $0 == customDealBreaker }
                        }
                    }
                    
                    // Add custom button
                    Button(action: {
                        showingCustomInput = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 12))
                            Text("Add Custom")
                                .font(.subheadline)
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                }
            }
            
            if coordinator.userPreferences.dealBreakers.isEmpty {
                Text("Optional: Skip if you're open to any destination")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .alert("Add Deal-Breaker", isPresented: $showingCustomInput) {
            TextField("Enter what to avoid", text: $customDealBreaker)
            Button("Add") {
                if !customDealBreaker.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    coordinator.userPreferences.dealBreakers.append(customDealBreaker.trimmingCharacters(in: .whitespacesAndNewlines))
                    customDealBreaker = ""
                }
            }
            Button("Cancel", role: .cancel) {
                customDealBreaker = ""
            }
        }
    }
    
    private func toggleDealBreaker(_ dealBreaker: String) {
        if coordinator.userPreferences.dealBreakers.contains(dealBreaker) {
            coordinator.userPreferences.dealBreakers.removeAll { $0 == dealBreaker }
        } else {
            coordinator.userPreferences.dealBreakers.append(dealBreaker)
        }
    }
}

struct DealBreakersStepView_Previews: PreviewProvider {
    static var previews: some View {
        DealBreakersStepView(coordinator: QuestionnaireCoordinator())
    }
}