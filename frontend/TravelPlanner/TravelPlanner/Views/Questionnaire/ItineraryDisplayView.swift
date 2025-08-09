import SwiftUI
import UIKit

/// Final step: Displays the complete generated itinerary to the user
struct ItineraryDisplayView: View {
    @ObservedObject var coordinator: QuestionnaireCoordinator
    @State private var expandedDays: Set<Int> = []
    @State private var isExporting = false
    @State private var showingShareSheet = false
    @State private var pdfURL: URL?
    
    private var itinerary: GeneratedItinerary? {
        coordinator.generatedItinerary?.itinerary
    }
    
    private var summary: ItinerarySummary? {
        coordinator.generatedItinerary?.summary
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let itinerary = itinerary, let summary = summary {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header Section
                        itineraryHeader(itinerary: itinerary, summary: summary)
                        
                        // Daily Schedule Cards
                        LazyVStack(spacing: 16) {
                            ForEach(itinerary.dailySchedules, id: \.dayNumber) { day in
                                DayScheduleCard(
                                    day: day,
                                    isExpanded: expandedDays.contains(day.dayNumber)
                                ) {
                                    toggleDayExpansion(day.dayNumber)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Summary Statistics
                        itinerarySummarySection(summary: summary)
                        
                        // Action Buttons
                        actionButtons()
                    }
                    .padding(.vertical)
                }
            } else {
                // Loading or error state
                VStack(spacing: 24) {
                    Spacer()
                    
                    if coordinator.isGeneratingItinerary {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            
                            Text("Generating your perfect itinerary...")
                                .font(.title2)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                            
                            Text("This may take a few seconds while we optimize your activities and schedule.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                            
                            Text("Unable to generate itinerary")
                                .font(.headline)
                            
                            if !coordinator.validationErrors.isEmpty {
                                Text(coordinator.validationErrors.first ?? "Please try again or go back to modify your preferences.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            } else {
                                Text("Please try again or go back to modify your preferences.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            Button("Try Again") {
                                coordinator.retryItineraryGeneration()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let pdfURL = pdfURL {
                ShareSheet(items: [pdfURL])
            }
        }
    }
    
    // MARK: - Header Section
    @ViewBuilder
    private func itineraryHeader(itinerary: GeneratedItinerary, summary: ItinerarySummary) -> some View {
        VStack(spacing: 16) {
            // Destination and dates
            VStack(spacing: 8) {
                Text(itinerary.destination)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                if let firstDay = itinerary.dailySchedules.first,
                   let lastDay = itinerary.dailySchedules.last {
                    Text("\(formatDate(firstDay.date)) - \(formatDate(lastDay.date))")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                Text("\(itinerary.totalDays) days • \(summary.totalActivities) activities")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .fontWeight(.medium)
            }
            
            // Key stats
            HStack(spacing: 24) {
                StatCard(
                    icon: "dollarsign.circle",
                    title: "Estimated Cost",
                    value: formatCurrency(summary.totalCost),
                    color: .green
                )
                
                StatCard(
                    icon: "star.circle",
                    title: "Optimization",
                    value: "\(Int(summary.optimizationScore * 100))%",
                    color: .blue
                )
                
                StatCard(
                    icon: "checkmark.circle",
                    title: "Activities",
                    value: "\(summary.totalActivities)",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    // MARK: - Summary Section
    @ViewBuilder
    private func itinerarySummarySection(summary: ItinerarySummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar")
                    .foregroundColor(.blue)
                    .font(.title3)
                
                Text("Trip Summary")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                SummaryRow(label: "Estimated Budget", value: formatCurrency(summary.totalCost))
                SummaryRow(label: "Total Activities", value: "\(summary.totalActivities)")
                SummaryRow(label: "Optimization Score", value: "\(Int(summary.optimizationScore * 100))% match to your preferences")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Action Buttons
    @ViewBuilder
    private func actionButtons() -> some View {
        VStack(spacing: 16) {
            // Export button with PDF generation
            Button(action: {
                exportToPDF()
            }) {
                HStack {
                    if isExporting {
                        ProgressView()
                            .scaleEffect(0.8)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "square.and.arrow.up")
                    }
                    Text(isExporting ? "Generating PDF..." : "Export Itinerary")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isExporting ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .font(.headline)
            }
            .disabled(isExporting)
            
            // Start over button
            Button(action: {
                coordinator.resetQuestionnaire()
            }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Plan Another Trip")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(12)
                .font(.headline)
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    // MARK: - PDF Export
    private func exportToPDF() {
        guard let itinerary = itinerary, let summary = summary else {
            print("No itinerary data available for export")
            return
        }
        
        isExporting = true
        
        // Generate PDF in background
        DispatchQueue.global(qos: .userInitiated).async {
            let pdfURL = ItineraryPDFGenerator.generatePDF(from: itinerary, summary: summary)
            
            DispatchQueue.main.async {
                self.isExporting = false
                
                if let pdfURL = pdfURL {
                    self.pdfURL = pdfURL
                    self.showingShareSheet = true
                } else {
                    // Handle error - could show an alert here
                    print("Failed to generate PDF")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func toggleDayExpansion(_ dayNumber: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if expandedDays.contains(dayNumber) {
                expandedDays.remove(dayNumber)
            } else {
                expandedDays.insert(dayNumber)
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(Int(amount))"
    }
}

// MARK: - Supporting Views

/// Individual day schedule card with expandable activities
struct DayScheduleCard: View {
    let day: DailySchedule
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Day header (always visible)
            Button(action: onTap) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Day \(day.dayNumber)")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(day.theme)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(formatCurrency(day.dailyCost))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                        
                        Text(day.walkingDistance)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding()
            }
            .buttonStyle(PlainButtonStyle())
            
            // Activities (expandable)
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(Array(day.activities.enumerated()), id: \.offset) { index, activity in
                        ActivityRow(activity: activity, isLast: index == day.activities.count - 1)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(Int(amount))"
    }
}

/// Individual activity row within a day
struct ActivityRow: View {
    let activity: ScheduledActivity
    let isLast: Bool
    
    private var activityTypeColor: Color {
        switch activity.activity.type {
        case "cultural": return .blue
        case "dining": return .orange
        case "outdoor": return .green
        case "historical": return .purple
        case "logistics": return .gray
        case "entertainment": return .pink
        case "shopping": return .red
        case "food": return .orange
        default: return .blue
        }
    }
    
    private var activityTypeIcon: String {
        switch activity.activity.type {
        case "cultural": return "building.columns"
        case "dining": return "fork.knife"
        case "outdoor": return "leaf"
        case "historical": return "books.vertical"
        case "logistics": return "suitcase"
        case "entertainment": return "theatermasks"
        case "shopping": return "bag"
        case "food": return "fork.knife"
        default: return "star"
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Time column
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.startTime)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(activity.endTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 50, alignment: .leading)
            
            // Timeline indicator
            VStack(spacing: 4) {
                Circle()
                    .fill(activityTypeColor)
                    .frame(width: 10, height: 10)
                
                if !isLast {
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(width: 2, height: 30)
                }
            }
            
            // Activity details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: activityTypeIcon)
                        .foregroundColor(activityTypeColor)
                        .font(.subheadline)
                    
                    Text(activity.activity.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                }
                
                if let notes = activity.activity.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// Small stat card for the header
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

/// Summary row for trip statistics
struct SummaryRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - ShareSheet

/// UIKit share sheet wrapper for SwiftUI
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
struct ItineraryDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        let coordinator = QuestionnaireCoordinator()
        coordinator.generatedItinerary = MockData.mockItineraryResponse()
        coordinator.selectedDestination = Destination(
            id: "dest_001",
            name: "Barcelona, Spain",
            country: "Spain",
            matchScore: 92,
            estimatedCost: 1650,
            highlights: ["Architecture", "Food", "Culture"],
            whyRecommended: "Perfect match for your preferences",
            imageURL: nil
        )
        
        return ItineraryDisplayView(coordinator: coordinator)
    }
}