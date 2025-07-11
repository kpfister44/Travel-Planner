import SwiftUI

/// Introduction screen explaining the questionnaire process and expected outcomes
struct WelcomeStepView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // App Icon/Logo
            Image(systemName: "airplane.departure")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 16) {
                Text("Plan Your Perfect Trip")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Answer a few quick questions and we'll recommend destinations that match your travel style and preferences.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                    Text("Takes 2-3 minutes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.blue)
                    Text("Personalized recommendations")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "map")
                        .foregroundColor(.blue)
                    Text("Smart itinerary planning")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct WelcomeStepView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeStepView()
    }
}