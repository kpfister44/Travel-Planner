import SwiftUI

/// Main questionnaire view that manages the guided step-by-step flow
struct QuestionnaireView: View {
    @StateObject private var coordinator = QuestionnaireCoordinator()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Bar
                ProgressView(value: coordinator.currentStep.progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(height: 4)
                    .padding(.horizontal)
                
                // Step Content
                stepView
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                
                // Navigation Controls
                navigationControls
                    .padding()
                    .background(Color(.systemGray6))
            }
            .navigationTitle(coordinator.currentStep.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            coordinator.resetQuestionnaire()
                        }
                    }
                }
            }
        }
        .onChange(of: coordinator.currentStep) { _ in
            coordinator.validateCurrentStep()
        }
    }
    
    /// Returns the appropriate view for the current questionnaire step
    @ViewBuilder
    private var stepView: some View {
        switch coordinator.currentStep {
        case .welcome:
            WelcomeStepView()
        case .travelDates:
            TravelDatesStepView(coordinator: coordinator)
        case .groupSize:
            GroupSizeStepView(coordinator: coordinator)
        case .budget:
            BudgetStepView(coordinator: coordinator)
        case .travelStyle:
            TravelStyleStepView(coordinator: coordinator)
        case .interests:
            InterestsStepView(coordinator: coordinator)
        case .mustHaves:
            MustHavesStepView(coordinator: coordinator)
        case .dealBreakers:
            DealBreakersStepView(coordinator: coordinator)
        case .summary:
            SummaryStepView(coordinator: coordinator)
        }
    }
    
    /// Bottom navigation with back/next buttons and validation errors
    private var navigationControls: some View {
        HStack {
            // Back Button
            Button("Back") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    coordinator.previousStep()
                }
            }
            .disabled(!coordinator.canGoBack)
            .opacity(coordinator.canGoBack ? 1.0 : 0.3)
            
            Spacer()
            
            // Error Messages
            if !coordinator.validationErrors.isEmpty {
                VStack(alignment: .trailing, spacing: 4) {
                    ForEach(coordinator.validationErrors, id: \.self) { error in
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 8)
            }
            
            Spacer()
            
            // Next/Finish Button
            Button(coordinator.currentStep == .summary ? "Get Recommendations" : "Next") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if coordinator.currentStep == .summary {
                        coordinator.completeQuestionnaire()
                        // TODO: Navigate to destinations view or make API call
                    } else {
                        coordinator.nextStep()
                    }
                }
            }
            .disabled(!coordinator.canGoForward)
            .buttonStyle(.borderedProminent)
            .opacity(coordinator.canGoForward ? 1.0 : 0.6)
        }
    }
}

struct QuestionnaireView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionnaireView()
    }
}