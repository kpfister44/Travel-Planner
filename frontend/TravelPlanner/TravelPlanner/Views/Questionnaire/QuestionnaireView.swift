import SwiftUI

/// Main questionnaire view that manages the guided step-by-step flow
struct QuestionnaireView: View {
    @StateObject private var coordinator = QuestionnaireCoordinator()
    @Environment(\.presentationMode) var presentationMode
    
    /// Dynamic button text based on current step
    private var nextButtonText: String {
        switch coordinator.currentStep {
        case .summary:
            return "Get Recommendations"
        case .destinationSelection:
            return "Next"
        case .activityTypes:
            return "Get Activities"
        case .activitySelection:
            return "Next"
        case .itinerarySummary:
            return "Generate Itinerary"
        default:
            return "Next"
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
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
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            coordinator.resetQuestionnaire()
                        }
                    }
                }
            })
            .safeAreaInset(edge: .top) {
                // Progress Bar positioned below navigation bar
                ProgressView(value: coordinator.currentStep.progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(height: 4)
                    .padding(.horizontal)
                    .background(Color(.systemBackground))
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
        case .travelerInfo:
            TravelerInfoStepView(coordinator: coordinator)
        case .travelDates:
            TravelDatesStepView(coordinator: coordinator)
        case .groupSize:
            GroupSizeStepView(coordinator: coordinator)
        case .preferredLocation:
            PreferredLocationStepView(coordinator: coordinator)
        case .budget:
            BudgetStepView(coordinator: coordinator)
        case .travelStyle:
            TravelStyleStepView(coordinator: coordinator)
        case .likes:
            LikesStepView(coordinator: coordinator)
        case .dislikes:
            DislikesStepView(coordinator: coordinator)
        case .mustHaves:
            MustHavesStepView(coordinator: coordinator)
        case .dealBreakers:
            DealBreakersStepView(coordinator: coordinator)
        case .summary:
            SummaryStepView(coordinator: coordinator)
        case .destinationSelection:
            DestinationSelectionStepView(coordinator: coordinator)
        // Improved itinerary questionnaire steps
        case .activityTypes:
            ActivityTypesStepView(coordinator: coordinator)
        case .activitySelection:
            ActivitySelectionStepView(coordinator: coordinator)
        case .travelPace:
            TravelPaceStepView(coordinator: coordinator)
        case .mustSeeAttractions:
            MustSeeAttractionsStepView(coordinator: coordinator)
        case .mealPreferences:
            MealPreferencesStepView(coordinator: coordinator)
        case .transportation:
            TransportationStepView(coordinator: coordinator)
        case .itinerarySummary:
            ItinerarySummaryStepView(coordinator: coordinator)
        case .itineraryDisplay:
            ItineraryDisplayView(coordinator: coordinator)
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
            
            // Next/Finish Button (hide on itinerary display)
            if coordinator.currentStep != .itineraryDisplay {
                Button(nextButtonText) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        switch coordinator.currentStep {
                        case .summary:
                            coordinator.completeQuestionnaire()
                        case .destinationSelection:
                            coordinator.nextStep() // Move to activity types step
                        case .activityTypes:
                            coordinator.completeActivityTypes()
                        case .activitySelection:
                            coordinator.selectActivities(coordinator.selectedActivities)
                        case .itinerarySummary:
                            coordinator.completeItinerarySummary()
                        default:
                            coordinator.nextStep()
                        }
                    }
                }
                .disabled(!coordinator.canGoForward || coordinator.isGeneratingItinerary)
                .buttonStyle(.borderedProminent)
                .opacity((coordinator.canGoForward && !coordinator.isGeneratingItinerary) ? 1.0 : 0.6)
            }
        }
        .opacity(coordinator.currentStep == .itineraryDisplay ? 0 : 1)
    }
}

struct QuestionnaireView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionnaireView()
    }
}