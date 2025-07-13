import SwiftUI

/// Single-select interface for choosing travel style with descriptive options
struct TravelStyleStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    
    private let travelStyles = [
        (id: "adventure", title: "Adventure", subtitle: "Thrilling activities and exploration", icon: "mountain.2.fill"),
        (id: "relaxed", title: "Relaxed", subtitle: "Slow pace and leisure activities", icon: "leaf.fill"),
        (id: "balanced", title: "Balanced", subtitle: "Mix of activities and relaxation", icon: "scale.3d"),
        (id: "luxury", title: "Luxury", subtitle: "Premium experiences and comfort", icon: "star.fill")
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("What's your travel style?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("This helps us match you with destinations and activities that fit your preferred pace and interests.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 16) {
                ForEach(travelStyles, id: \.id) { style in
                    Button(action: {
                        coordinator.userPreferences.travelStyle = style.id
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: style.icon)
                                .font(.system(size: 24))
                                .foregroundColor(coordinator.userPreferences.travelStyle == style.id ? .white : .blue)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(style.title)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(coordinator.userPreferences.travelStyle == style.id ? .white : .primary)
                                
                                Text(style.subtitle)
                                    .font(.subheadline)
                                    .foregroundColor(coordinator.userPreferences.travelStyle == style.id ? .white.opacity(0.8) : .secondary)
                            }
                            
                            Spacer()
                            
                            if coordinator.userPreferences.travelStyle == style.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(coordinator.userPreferences.travelStyle == style.id ? Color.blue : Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct TravelStyleStepView_Previews: PreviewProvider {
    static var previews: some View {
        TravelStyleStepView(coordinator: QuestionnaireCoordinator())
    }
}