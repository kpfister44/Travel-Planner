import SwiftUI

/// Allows users to select essential travel requirements from preset options or add custom ones
struct MustHavesStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    @State private var customMustHave = ""
    @State private var showingCustomInput = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("What are your must-haves?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Select features that are essential for your trip. These help us filter destinations that match your needs.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 16) {
                FlowLayout(spacing: 8) {
                    ForEach(QuestionnaireConstants.commonMustHaves, id: \.self) { mustHave in
                        SelectableChip(
                            text: mustHave,
                            isSelected: coordinator.userPreferences.mustHaves.contains(mustHave)
                        ) {
                            toggleMustHave(mustHave)
                        }
                    }
                    
                    // Custom must-haves
                    ForEach(coordinator.userPreferences.mustHaves.filter { !QuestionnaireConstants.commonMustHaves.contains($0) }, id: \.self) { customMustHave in
                        SelectableChip(
                            text: customMustHave,
                            isSelected: true,
                            isCustom: true
                        ) {
                            coordinator.userPreferences.mustHaves.removeAll { $0 == customMustHave }
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
            
            if coordinator.userPreferences.mustHaves.isEmpty {
                Text("Optional: Skip if you don't have specific requirements")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .alert("Add Must-Have", isPresented: $showingCustomInput) {
            TextField("Enter requirement", text: $customMustHave)
            Button("Add") {
                if !customMustHave.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    coordinator.userPreferences.mustHaves.append(customMustHave.trimmingCharacters(in: .whitespacesAndNewlines))
                    customMustHave = ""
                }
            }
            Button("Cancel", role: .cancel) {
                customMustHave = ""
            }
        }
    }
    
    private func toggleMustHave(_ mustHave: String) {
        if coordinator.userPreferences.mustHaves.contains(mustHave) {
            coordinator.userPreferences.mustHaves.removeAll { $0 == mustHave }
        } else {
            coordinator.userPreferences.mustHaves.append(mustHave)
        }
    }
}

/// Reusable chip component for selectable options with optional delete functionality
struct SelectableChip: View {
    let text: String
    let isSelected: Bool
    let isCustom: Bool
    let action: () -> Void
    
    init(text: String, isSelected: Bool, isCustom: Bool = false, action: @escaping () -> Void) {
        self.text = text
        self.isSelected = isSelected
        self.isCustom = isCustom
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                if isCustom {
                    Image(systemName: "xmark")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(16)
        }
    }
}

/// Custom layout that arranges views in a flowing pattern, wrapping to new lines as needed
struct FlowLayout: Layout {
    let spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: LayoutSubviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let subviewSize = subview.sizeThatFits(.unspecified)
                
                if currentX + subviewSize.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: subviewSize.width, height: subviewSize.height))
                
                currentX += subviewSize.width + spacing
                lineHeight = max(lineHeight, subviewSize.height)
            }
            
            size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

struct MustHavesStepView_Previews: PreviewProvider {
    static var previews: some View {
        MustHavesStepView(coordinator: QuestionnaireCoordinator())
    }
}