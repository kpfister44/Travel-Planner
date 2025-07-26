import SwiftUI

/// Step 19: Allows users to select transportation preferences and accommodation area
struct TransportationStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("How do you like to get around?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Help us plan your transportation and accommodation preferences for the best experience.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            ScrollView {
                VStack(spacing: 24) {
                    // Transportation preferences
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Transportation Preference")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        VStack(spacing: 12) {
                            ForEach(TransportationType.allCases, id: \.self) { transportType in
                                TransportationOptionCard(
                                    transportType: transportType,
                                    isSelected: coordinator.itineraryPreferences.transportation == transportType,
                                    onSelect: {
                                        coordinator.itineraryPreferences.transportation = transportType
                                    }
                                )
                            }
                        }
                    }
                    
                    // Accommodation area preferences
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Accommodation Area Preference")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Text("Where would you prefer to stay?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(ItineraryConstants.accommodationAreas, id: \.self) { area in
                                AccommodationAreaButton(
                                    area: area,
                                    isSelected: coordinator.itineraryPreferences.accommodationArea == area,
                                    onSelect: {
                                        coordinator.itineraryPreferences.accommodationArea = area
                                    }
                                )
                            }
                        }
                    }
                    
                    // Summary of selections
                    if coordinator.itineraryPreferences.transportation != .walkingAndPublic || 
                       !coordinator.itineraryPreferences.accommodationArea.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Preferences:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Transportation:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(coordinator.itineraryPreferences.transportation.displayName)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                
                                if !coordinator.itineraryPreferences.accommodationArea.isEmpty {
                                    HStack {
                                        Text("Accommodation:")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(formatAccommodationArea(coordinator.itineraryPreferences.accommodationArea))
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                }
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
    
    private func formatAccommodationArea(_ area: String) -> String {
        return area.replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}

/// Card component for transportation type selection
struct TransportationOptionCard: View {
    let transportType: TransportationType
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Transportation icon
                Image(systemName: transportType.iconName)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 30, height: 30)
                
                // Transportation details
                VStack(alignment: .leading, spacing: 4) {
                    Text(transportType.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(transportType.description)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                } else {
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 1)
                        .frame(width: 20, height: 20)
                }
            }
            .padding()
            .background(
                isSelected 
                ? Color.blue 
                : Color(.systemGray6)
            )
            .cornerRadius(12)
        }
    }
}

/// Button component for accommodation area selection
struct AccommodationAreaButton: View {
    let area: String
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                Image(systemName: iconForArea(area))
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(formatAreaName(area))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(
                isSelected 
                ? Color.blue 
                : Color(.systemGray6)
            )
            .cornerRadius(12)
        }
    }
    
    private func iconForArea(_ area: String) -> String {
        switch area {
        case "city_center":
            return "building.2"
        case "historic_district":
            return "building.columns"
        case "business_district":
            return "building.2.crop.circle"
        case "waterfront":
            return "water.waves"
        case "near_airport":
            return "airplane"
        case "shopping_area":
            return "bag"
        case "nightlife_district":
            return "moon.stars"
        case "quiet_residential":
            return "house"
        case "tourist_area":
            return "camera"
        default:
            return "mappin"
        }
    }
    
    private func formatAreaName(_ area: String) -> String {
        return area.replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}

struct TransportationStepView_Previews: PreviewProvider {
    static var previews: some View {
        TransportationStepView(coordinator: QuestionnaireCoordinator())
    }
}