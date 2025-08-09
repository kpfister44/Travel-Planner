import SwiftUI

struct BudgetPreset: Identifiable {
    let id: String
    let min: Int
    let max: Int
    let label: String
}

/// Allows users to select their budget range through preset options or custom dual-thumb slider
struct BudgetStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    
    @State private var minBudget: Double = 500
    @State private var maxBudget: Double = 2000
    
    private let budgetPresets: [BudgetPreset] = [
        BudgetPreset(id: "budget_low", min: 500, max: 1000, label: "Budget\n$500-$1K"),
        BudgetPreset(id: "budget_moderate", min: 1000, max: 2500, label: "Moderate\n$1K-$2.5K"),
        BudgetPreset(id: "budget_comfortable", min: 2500, max: 5000, label: "Comfortable\n$2.5K-$5K"),
        BudgetPreset(id: "budget_luxury", min: 5000, max: 10000, label: "Luxury\n$5K-$10K+")
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("What's your budget range?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("This includes flights, accommodation, food, and activities for your entire trip.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 24) {
                // Budget Presets
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(budgetPresets, id: \.min) { preset in
                        Button(action: {
                            minBudget = Double(preset.min)
                            maxBudget = Double(preset.max)
                            updateCoordinatorBudget()
                        }) {
                            VStack(spacing: 8) {
                                Text(preset.label)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(
                                        coordinator.userPreferences.budget.min == preset.min &&
                                        coordinator.userPreferences.budget.max == preset.max
                                        ? .white : .primary
                                    )
                            }
                            .frame(height: 70)
                            .frame(maxWidth: .infinity)
                            .background(
                                coordinator.userPreferences.budget.min == preset.min &&
                                coordinator.userPreferences.budget.max == preset.max
                                ? Color.blue : Color(.systemGray6)
                            )
                            .cornerRadius(12)
                        }
                        .accessibilityIdentifier(preset.id)
                    }
                }
                
                // Custom Range Slider
                VStack(spacing: 16) {
                    Text("Or set a custom range:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Min: $\(Int(minBudget))")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text("Max: $\(Int(maxBudget))")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("$0")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("$15K")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            RangeSlider(
                                minValue: $minBudget,
                                maxValue: $maxBudget,
                                bounds: 0...15000,
                                step: 100
                            )
                            .frame(height: 30)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            setupInitialBudget()
        }
        .onChange(of: minBudget) { _ in
            updateCoordinatorBudget()
        }
        .onChange(of: maxBudget) { _ in
            updateCoordinatorBudget()
        }
    }
    
    private func setupInitialBudget() {
        minBudget = Double(coordinator.userPreferences.budget.min)
        maxBudget = Double(coordinator.userPreferences.budget.max)
    }
    
    private func updateCoordinatorBudget() {
        coordinator.userPreferences.budget.min = Int(minBudget)
        coordinator.userPreferences.budget.max = Int(maxBudget)
    }
}

/// Custom dual-thumb range slider for selecting min and max budget values
struct RangeSlider: View {
    @Binding var minValue: Double
    @Binding var maxValue: Double
    let bounds: ClosedRange<Double>
    let step: Double
    
    @State private var minOffset: CGFloat = 0
    @State private var maxOffset: CGFloat = 0
    @State private var sliderWidth: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(height: 4)
                    .cornerRadius(2)
                
                // Active range
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: max(0, maxOffset - minOffset), height: 4)
                    .cornerRadius(2)
                    .offset(x: minOffset)
                
                // Min thumb
                Circle()
                    .fill(Color.blue)
                    .frame(width: 24, height: 24)
                    .offset(x: minOffset - 12)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newOffset = max(0, min(maxOffset - 24, value.location.x - 12))
                                minOffset = newOffset
                                updateMinValue(geometry: geometry)
                            }
                    )
                
                // Max thumb
                Circle()
                    .fill(Color.blue)
                    .frame(width: 24, height: 24)
                    .offset(x: maxOffset - 12)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newOffset = max(minOffset + 24, min(geometry.size.width, value.location.x - 12))
                                maxOffset = newOffset
                                updateMaxValue(geometry: geometry)
                            }
                    )
            }
            .onAppear {
                sliderWidth = geometry.size.width
                updateOffsets(geometry: geometry)
            }
            .onChange(of: minValue) { _ in
                updateOffsets(geometry: geometry)
            }
            .onChange(of: maxValue) { _ in
                updateOffsets(geometry: geometry)
            }
        }
    }
    
    /// Converts slider values to visual thumb positions
    private func updateOffsets(geometry: GeometryProxy) {
        let range = bounds.upperBound - bounds.lowerBound
        let minPercent = (minValue - bounds.lowerBound) / range
        let maxPercent = (maxValue - bounds.lowerBound) / range
        
        minOffset = CGFloat(minPercent) * geometry.size.width
        maxOffset = CGFloat(maxPercent) * geometry.size.width
    }
    
    /// Converts min thumb position to stepped value, ensuring it doesn't exceed max
    private func updateMinValue(geometry: GeometryProxy) {
        let percent = minOffset / geometry.size.width
        let range = bounds.upperBound - bounds.lowerBound
        let newValue = bounds.lowerBound + Double(percent) * range
        let steppedValue = round(newValue / step) * step
        minValue = max(bounds.lowerBound, min(maxValue - step, steppedValue))
    }
    
    /// Converts max thumb position to stepped value, ensuring it doesn't go below min
    private func updateMaxValue(geometry: GeometryProxy) {
        let percent = maxOffset / geometry.size.width
        let range = bounds.upperBound - bounds.lowerBound
        let newValue = bounds.lowerBound + Double(percent) * range
        let steppedValue = round(newValue / step) * step
        maxValue = max(minValue + step, min(bounds.upperBound, steppedValue))
    }
}

struct BudgetStepView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetStepView(coordinator: QuestionnaireCoordinator())
    }
}