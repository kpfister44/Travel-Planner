import SwiftUI

/// Step 18: Allows users to set dining preferences for breakfast, lunch, and dinner
struct MealPreferencesStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("How do you prefer to dine?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Tell us your dining preferences so we can plan your meals and find the best food experiences.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            ScrollView {
                VStack(spacing: 24) {
                    // Breakfast preferences
                    MealTypeSection(
                        mealType: "Breakfast",
                        currentSelection: coordinator.itineraryPreferences.mealPreferences.breakfast,
                        onSelectionChanged: { newType in
                            coordinator.itineraryPreferences.mealPreferences.breakfast = newType
                        }
                    )
                    
                    // Lunch preferences
                    MealTypeSection(
                        mealType: "Lunch", 
                        currentSelection: coordinator.itineraryPreferences.mealPreferences.lunch,
                        onSelectionChanged: { newType in
                            coordinator.itineraryPreferences.mealPreferences.lunch = newType
                        }
                    )
                    
                    // Dinner preferences
                    MealTypeSection(
                        mealType: "Dinner",
                        currentSelection: coordinator.itineraryPreferences.mealPreferences.dinner,
                        onSelectionChanged: { newType in
                            coordinator.itineraryPreferences.mealPreferences.dinner = newType
                        }
                    )
                    
                    // Dietary restrictions
                    DietaryRestrictionsSection(
                        selectedRestrictions: coordinator.itineraryPreferences.mealPreferences.dietaryRestrictions,
                        onRestrictionsChanged: { restrictions in
                            coordinator.itineraryPreferences.mealPreferences.dietaryRestrictions = restrictions
                        }
                    )
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
}

/// Section for selecting meal venue type for breakfast, lunch, or dinner
struct MealTypeSection: View {
    let mealType: String
    let currentSelection: MealVenueType
    let onSelectionChanged: (MealVenueType) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(mealType)
                .font(.headline)
                .fontWeight(.medium)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(availableVenueTypes, id: \.self) { venueType in
                    Button(action: {
                        onSelectionChanged(venueType)
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: iconForVenueType(venueType))
                                .font(.title2)
                                .foregroundColor(currentSelection == venueType ? .white : .blue)
                            
                            Text(venueType.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(currentSelection == venueType ? .white : .primary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .background(
                            currentSelection == venueType
                            ? Color.blue
                            : Color(.systemGray6)
                        )
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var availableVenueTypes: [MealVenueType] {
        switch mealType.lowercased() {
        case "breakfast":
            return [.hotel, .cafe, .localRestaurant, .skip]
        case "lunch":
            return [.localRestaurant, .quickBite, .cafe, .skip]
        case "dinner":
            return [.localRestaurant, .fineDining, .hotel, .skip]
        default:
            return MealVenueType.allCases
        }
    }
    
    private func iconForVenueType(_ type: MealVenueType) -> String {
        switch type {
        case .hotel:
            return "bed.double"
        case .cafe:
            return "cup.and.saucer"
        case .localRestaurant:
            return "fork.knife"
        case .fineDining:
            return "wineglass"
        case .quickBite:
            return "takeoutbag.and.cup.and.straw"
        case .skip:
            return "xmark"
        }
    }
}

/// Section for selecting dietary restrictions
struct DietaryRestrictionsSection: View {
    let selectedRestrictions: [String]
    let onRestrictionsChanged: ([String]) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dietary Restrictions (Optional)")
                .font(.headline)
                .fontWeight(.medium)
            
            FlowLayout(spacing: 8) {
                ForEach(ItineraryConstants.commonDietaryRestrictions, id: \.self) { restriction in
                    SelectableChip(
                        text: formatRestrictionName(restriction),
                        isSelected: selectedRestrictions.contains(restriction)
                    ) {
                        toggleRestriction(restriction)
                    }
                }
            }
            
            if !selectedRestrictions.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Selected restrictions:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(selectedRestrictions.map(formatRestrictionName).joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func toggleRestriction(_ restriction: String) {
        var newRestrictions = selectedRestrictions
        if newRestrictions.contains(restriction) {
            newRestrictions.removeAll { $0 == restriction }
        } else {
            newRestrictions.append(restriction)
        }
        onRestrictionsChanged(newRestrictions)
    }
    
    private func formatRestrictionName(_ restriction: String) -> String {
        return restriction.replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}

struct MealPreferencesStepView_Previews: PreviewProvider {
    static var previews: some View {
        MealPreferencesStepView(coordinator: QuestionnaireCoordinator())
    }
}