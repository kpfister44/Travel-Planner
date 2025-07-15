import SwiftUI

/// Individual destination card component displaying recommendation details
struct DestinationCard: View {
    let destination: Destination
    let isSelected: Bool
    let onSelect: () -> Void
    
    /// Color for match score indicator
    private var matchScoreColor: Color {
        switch destination.matchScore {
        case 90...100: return .green
        case 75...89: return .blue
        case 60...74: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with destination name and match score
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(destination.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(destination.country)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Match score indicator
                    matchScoreView
                }
                
                // Cost and highlights
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Estimated Cost")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(destination.formattedCost)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                }
                
                // Highlights chips
                highlightsView
                
                // Why recommended
                VStack(alignment: .leading, spacing: 4) {
                    Text("Why We Recommend")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(destination.whyRecommended)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                // Action button
                HStack {
                    Spacer()
                    
                    Text(isSelected ? "Selected" : "Select This Destination")
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .accentColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? Color.accentColor : Color.clear)
                                .stroke(Color.accentColor, lineWidth: 2)
                        )
                    
                    Spacer()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.accentColor : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    // MARK: - Match Score View
    private var matchScoreView: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0.0, to: destination.matchPercentage)
                    .stroke(
                        matchScoreColor,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: destination.matchPercentage)
                
                Text("\(destination.matchScore)%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Text("Match")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Highlights View
    private var highlightsView: some View {
        FlowLayout(spacing: 8) {
            ForEach(destination.highlights, id: \.self) { highlight in
                Text(highlight)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.accentColor.opacity(0.1))
                    )
                    .foregroundColor(.accentColor)
            }
        }
    }
}


// MARK: - Preview
struct DestinationCard_Previews: PreviewProvider {
    static var previews: some View {
        let mockDestination = MockData.mockDestinationResponse().recommendations!.first!
        
        VStack {
            DestinationCard(
                destination: mockDestination,
                isSelected: false,
                onSelect: {}
            )
            
            DestinationCard(
                destination: mockDestination,
                isSelected: true,
                onSelect: {}
            )
        }
        .padding()
    }
}