import SwiftUI

/// Destination selection step view that integrates with the questionnaire flow
struct DestinationSelectionStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content area
            if coordinator.isLoadingDestinations {
                loadingView
            } else if let errors = coordinator.destinationResponse?.errors, !errors.isEmpty {
                errorView(errors: errors)
            } else if let recommendations = coordinator.destinationResponse?.recommendations {
                destinationListView(recommendations: recommendations)
            } else {
                emptyStateView
            }
        }
    }
    
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Finding perfect destinations for you...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Error View
    private func errorView(errors: [APIError]) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Unable to load destinations")
                .font(.headline)
            
            ForEach(errors, id: \.code) { error in
                Text(error.message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Try Again") {
                coordinator.loadDestinations()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "map")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No destinations found")
                .font(.headline)
            
            Text("We couldn't find destinations matching your preferences. Please try adjusting your criteria.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                coordinator.loadDestinations()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Destination List View
    private func destinationListView(recommendations: [Destination]) -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(recommendations) { destination in
                    DestinationCard(
                        destination: destination,
                        isSelected: coordinator.selectedDestination?.id == destination.id,
                        onSelect: {
                            coordinator.selectDestination(destination)
                        }
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Preview
struct DestinationSelectionStepView_Previews: PreviewProvider {
    static var previews: some View {
        let coordinator = QuestionnaireCoordinator()
        coordinator.currentStep = .destinationSelection
        coordinator.destinationResponse = MockData.mockDestinationResponse()
        
        return DestinationSelectionStepView(coordinator: coordinator)
    }
}