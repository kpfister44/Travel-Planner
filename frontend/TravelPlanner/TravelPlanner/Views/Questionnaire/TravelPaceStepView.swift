import SwiftUI

/// Step 14: Allows users to select their travel pace, daily schedule, and maximum activities per day
struct TravelPaceStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("What's your ideal travel pace?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Tell us how you like to structure your days and we'll plan accordingly.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            ScrollView {
                VStack(spacing: 24) {
                // Travel Pace Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("Travel Pace")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    VStack(spacing: 12) {
                        ForEach(TravelPace.allCases, id: \.self) { pace in
                            Button(action: {
                                coordinator.itineraryPreferences.pace = pace
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(pace.displayName)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text(pace.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    
                                    if coordinator.itineraryPreferences.pace == pace {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    } else {
                                        Circle()
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                            .frame(width: 20, height: 20)
                                    }
                                }
                                .padding()
                                .background(
                                    coordinator.itineraryPreferences.pace == pace
                                    ? Color.blue.opacity(0.1)
                                    : Color(.systemGray6)
                                )
                                .cornerRadius(12)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
                
                // Daily Schedule
                VStack(alignment: .leading, spacing: 16) {
                    Text("Daily Schedule")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    VStack(spacing: 16) {
                        // Start Time
                        HStack {
                            Text("Start exploring at:")
                                .font(.subheadline)
                            Spacer()
                            Menu {
                                ForEach(ItineraryConstants.availableTimeSlots, id: \.self) { time in
                                    Button(time) {
                                        coordinator.itineraryPreferences.dailyStartTime = time
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(formatTime(coordinator.itineraryPreferences.dailyStartTime))
                                        .fontWeight(.medium)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // End Time
                        HStack {
                            Text("Wind down by:")
                                .font(.subheadline)
                            Spacer()
                            Menu {
                                ForEach(ItineraryConstants.availableTimeSlots, id: \.self) { time in
                                    Button(time) {
                                        coordinator.itineraryPreferences.dailyEndTime = time
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(formatTime(coordinator.itineraryPreferences.dailyEndTime))
                                        .fontWeight(.medium)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                
                // Max Activities Per Day
                VStack(alignment: .leading, spacing: 16) {
                    Text("Maximum Activities Per Day")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    HStack {
                        Text("I prefer up to:")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Menu {
                            ForEach(ItineraryConstants.maxActivitiesOptions, id: \.self) { count in
                                Button("\(count) activities") {
                                    coordinator.itineraryPreferences.maxActivitiesPerDay = count
                                }
                            }
                        } label: {
                            HStack {
                                Text("\(coordinator.itineraryPreferences.maxActivitiesPerDay) activities")
                                    .fontWeight(.medium)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func formatTime(_ time: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let date = formatter.date(from: time) else {
            return time
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "h:mm a"
        return displayFormatter.string(from: date)
    }
}

struct TravelPaceStepView_Previews: PreviewProvider {
    static var previews: some View {
        TravelPaceStepView(coordinator: QuestionnaireCoordinator())
    }
}