import SwiftUI

/// Date selection interface with automatic end date constraint and format conversion
struct TravelDatesStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var dateValidationError: String?
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("When are you planning to travel?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Select your travel dates to get the most accurate recommendations.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Start Date")
                        .font(.headline)
                    
                    DatePicker("", selection: $startDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("End Date")
                        .font(.headline)
                    
                    DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Validation error message
            if let error = dateValidationError {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                .transition(.opacity)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            setupInitialDates()
        }
        .onChange(of: startDate) { _ in
            updateCoordinatorDates()
        }
        .onChange(of: endDate) { _ in
            updateCoordinatorDates()
        }
    }
    
    /// Maximum allowed end date (10 days from start date)
    private var maxEndDate: Date {
        Calendar.current.date(byAdding: .day, value: 10, to: startDate) ?? startDate
    }
    
    /// Initializes date pickers from coordinator's stored string values
    private func setupInitialDates() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let start = formatter.date(from: coordinator.userPreferences.travelDates.startDate) {
            startDate = start
        } else {
            startDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        }
        
        if let end = formatter.date(from: coordinator.userPreferences.travelDates.endDate) {
            endDate = end
        } else {
            endDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: startDate) ?? startDate
        }
    }
    
    /// Converts Date objects to API-compatible string format and validates trip length
    private func updateCoordinatorDates() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        // Always save the current dates to coordinator (no modifications)
        coordinator.userPreferences.travelDates.startDate = formatter.string(from: startDate)
        coordinator.userPreferences.travelDates.endDate = formatter.string(from: endDate)
        
        // Validate trip length (only show warnings, don't modify dates)
        let calendar = Calendar.current
        let daysDifference = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        
        withAnimation(.easeInOut(duration: 0.3)) {
            if daysDifference > 10 {
                dateValidationError = "Please select a trip of 10 days or less for the best recommendations"
            } else if daysDifference < 0 {
                dateValidationError = "End date must be after start date"
            } else {
                dateValidationError = nil
                coordinator.validationErrors = [] // Clear any existing questionnaire errors only when dates are valid
            }
        }
    }
}

struct TravelDatesStepView_Previews: PreviewProvider {
    static var previews: some View {
        TravelDatesStepView(coordinator: QuestionnaireCoordinator())
    }
}