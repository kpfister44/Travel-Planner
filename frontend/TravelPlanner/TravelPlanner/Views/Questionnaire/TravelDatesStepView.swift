import SwiftUI

/// Date selection interface with automatic end date constraint and format conversion
struct TravelDatesStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    
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
                    
                    DatePicker("", selection: $startDate, in: Date()..., displayedComponents: .date)
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
    
    /// Converts Date objects to API-compatible string format
    private func updateCoordinatorDates() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        coordinator.userPreferences.travelDates.startDate = formatter.string(from: startDate)
        coordinator.userPreferences.travelDates.endDate = formatter.string(from: endDate)
    }
}

struct TravelDatesStepView_Previews: PreviewProvider {
    static var previews: some View {
        TravelDatesStepView(coordinator: QuestionnaireCoordinator())
    }
}