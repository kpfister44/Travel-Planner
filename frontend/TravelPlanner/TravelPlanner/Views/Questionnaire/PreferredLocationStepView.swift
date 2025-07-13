import SwiftUI

/// Country preference selection interface for destination recommendations
struct PreferredLocationStepView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    @State private var searchText = ""
    
    var filteredCountries: [String] {
        if searchText.isEmpty {
            return QuestionnaireConstants.popularCountries
        } else {
            return QuestionnaireConstants.popularCountries.filter { 
                $0.localizedCaseInsensitiveContains(searchText) 
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("Where would you like to go?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Select a preferred destination or choose 'None' to let us surprise you with recommendations based on your preferences.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            SearchBar(text: $searchText, placeholder: "Search countries...")
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredCountries, id: \.self) { country in
                        Button(action: {
                            coordinator.userPreferences.preferredLocation = country
                        }) {
                            HStack {
                                Text(country)
                                    .font(.body)
                                    .foregroundColor(coordinator.userPreferences.preferredLocation == country ? .white : .primary)
                                
                                Spacer()
                                
                                if coordinator.userPreferences.preferredLocation == country {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(coordinator.userPreferences.preferredLocation == country ? Color.blue : Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }
}

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct PreferredLocationStepView_Previews: PreviewProvider {
    static var previews: some View {
        PreferredLocationStepView(coordinator: QuestionnaireCoordinator())
    }
}