import SwiftUI

/// Step 16: Allows users to select must-see attractions for their destination
struct MustSeeAttractionsStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    @State private var customAttraction = ""
    @State private var showingCustomInput = false
    
    // Mock attractions for the selected destination
    private var destinationAttractions: [String] {
        guard let destination = coordinator.selectedDestination else {
            return []
        }
        
        // In a real app, this would be fetched from an API or database
        // For now, we'll use some mock data based on destination name
        switch destination.name.lowercased() {
        case "paris":
            return ["Eiffel Tower", "Louvre Museum", "Notre-Dame Cathedral", "Arc de Triomphe", "Montmartre", "Seine River Cruise", "Palace of Versailles", "Musée d'Orsay"]
        case "tokyo":
            return ["Senso-ji Temple", "Tokyo Skytree", "Shibuya Crossing", "Meiji Shrine", "Tsukiji Fish Market", "Imperial Palace", "Harajuku District", "Mount Fuji Day Trip"]
        case "barcelona":
            return ["Sagrada Familia", "Park Güell", "Las Ramblas", "Gothic Quarter", "Casa Batlló", "La Boqueria Market", "Montjuïc Hill", "Beach at Barceloneta"]
        case "rome":
            return ["Colosseum", "Vatican City", "Trevi Fountain", "Roman Forum", "Pantheon", "Spanish Steps", "Castel Sant'Angelo", "Trastevere District"]
        default:
            return ["Historic City Center", "Main Museum", "Popular Viewpoint", "Cultural District", "Traditional Market", "Religious Site", "Waterfront Area", "Local Landmark"]
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("Any must-see attractions?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                if let destination = coordinator.selectedDestination {
                    Text("Popular attractions in \(destination.name)")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    Text("Select attractions you definitely want to visit")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            
            ScrollView {
                VStack(spacing: 16) {
                    // Popular attractions grid
                    FlowLayout(spacing: 8) {
                        ForEach(destinationAttractions, id: \.self) { attraction in
                            SelectableChip(
                                text: attraction,
                                isSelected: coordinator.itineraryPreferences.mustSeeAttractions.contains(attraction)
                            ) {
                                toggleAttraction(attraction)
                            }
                        }
                        
                        // Custom attractions
                        ForEach(coordinator.itineraryPreferences.mustSeeAttractions.filter { !destinationAttractions.contains($0) }, id: \.self) { customAttraction in
                            SelectableChip(
                                text: customAttraction,
                                isSelected: true,
                                isCustom: true
                            ) {
                                removeAttraction(customAttraction)
                            }
                        }
                    }
                    
                    // Add custom attraction button
                    Button(action: {
                        showingCustomInput = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Custom Attraction")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Selected attractions count
                    if !coordinator.itineraryPreferences.mustSeeAttractions.isEmpty {
                        Text("\(coordinator.itineraryPreferences.mustSeeAttractions.count) attraction\(coordinator.itineraryPreferences.mustSeeAttractions.count == 1 ? "" : "s") selected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                    
                    // Selected attractions list
                    if !coordinator.itineraryPreferences.mustSeeAttractions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Selected Attractions:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            ForEach(coordinator.itineraryPreferences.mustSeeAttractions, id: \.self) { attraction in
                                HStack {
                                    Text("• \(attraction)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        removeAttraction(attraction)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .font(.caption)
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
        .alert("Add Custom Attraction", isPresented: $showingCustomInput) {
            TextField("Attraction name", text: $customAttraction)
            Button("Add") {
                addCustomAttraction()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter the name of an attraction you want to visit")
        }
    }
    
    private func toggleAttraction(_ attraction: String) {
        if coordinator.itineraryPreferences.mustSeeAttractions.contains(attraction) {
            removeAttraction(attraction)
        } else {
            coordinator.itineraryPreferences.mustSeeAttractions.append(attraction)
        }
    }
    
    private func removeAttraction(_ attraction: String) {
        coordinator.itineraryPreferences.mustSeeAttractions.removeAll { $0 == attraction }
    }
    
    private func addCustomAttraction() {
        let trimmed = customAttraction.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !coordinator.itineraryPreferences.mustSeeAttractions.contains(trimmed) {
            coordinator.itineraryPreferences.mustSeeAttractions.append(trimmed)
        }
        customAttraction = ""
    }
}

struct MustSeeAttractionsStepView_Previews: PreviewProvider {
    static var previews: some View {
        let coordinator = QuestionnaireCoordinator()
        coordinator.selectedDestination = Destination(
            id: "1",
            name: "Paris",
            country: "France",
            matchScore: 95,
            estimatedCost: 150,
            highlights: ["Culture", "Food", "Art"],
            whyRecommended: "Perfect for cultural experiences",
            imageURL: nil
        )
        return MustSeeAttractionsStepView(coordinator: coordinator)
    }
}