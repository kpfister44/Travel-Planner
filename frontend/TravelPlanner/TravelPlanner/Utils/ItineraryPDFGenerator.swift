import Foundation
import PDFKit
import UIKit

/// Utility class for generating PDF documents from itinerary data
class ItineraryPDFGenerator {
    
    // MARK: - Constants
    
    private struct PDFConstants {
        static let pageSize = CGSize(width: 612, height: 792) // US Letter size (8.5" x 11")
        static let margin: CGFloat = 50
        static let lineSpacing: CGFloat = 6
        static let sectionSpacing: CGFloat = 20
        static let titleSpacing: CGFloat = 15
        static let contentWidth = pageSize.width - (margin * 2)
    }
    
    // MARK: - Fonts
    
    private struct PDFFonts {
        static let title = UIFont.boldSystemFont(ofSize: 24)
        static let subtitle = UIFont.systemFont(ofSize: 18, weight: .medium)
        static let heading = UIFont.boldSystemFont(ofSize: 16)
        static let body = UIFont.systemFont(ofSize: 12)
        static let caption = UIFont.systemFont(ofSize: 10)
    }
    
    // MARK: - Public Methods
    
    /// Generate a PDF from the provided itinerary data
    /// - Parameters:
    ///   - itinerary: The generated itinerary
    ///   - summary: The itinerary summary
    /// - Returns: URL to the generated PDF file, or nil if generation failed
    static func generatePDF(from itinerary: GeneratedItinerary, summary: ItinerarySummary) -> URL? {
        // Create PDF document
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect(origin: .zero, size: PDFConstants.pageSize), nil)
        
        var currentY: CGFloat = PDFConstants.margin
        var pageNumber = 1
        
        // Start first page
        UIGraphicsBeginPDFPage()
        
        // Generate PDF content
        currentY = drawHeader(itinerary: itinerary, summary: summary, startingY: currentY)
        currentY = drawSummarySection(summary: summary, startingY: currentY + PDFConstants.sectionSpacing)
        currentY = drawDailySchedules(itinerary: itinerary, startingY: currentY + PDFConstants.sectionSpacing, pageNumber: &pageNumber)
        
        // Add footer to final page
        drawFooter(pageNumber: pageNumber)
        
        UIGraphicsEndPDFContext()
        
        // Save PDF to temporary file
        return savePDFData(pdfData, filename: generateFileName(for: itinerary))
    }
    
    // MARK: - Header Section
    
    private static func drawHeader(itinerary: GeneratedItinerary, summary: ItinerarySummary, startingY: CGFloat) -> CGFloat {
        var currentY = startingY
        let contentRect = CGRect(x: PDFConstants.margin, y: 0, width: PDFConstants.contentWidth, height: 0)
        
        // Title - Destination
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: PDFFonts.title,
            .foregroundColor: UIColor.black
        ]
        
        let title = itinerary.destination
        let titleSize = title.size(withAttributes: titleAttributes)
        let titleRect = CGRect(x: contentRect.minX, y: currentY, width: contentRect.width, height: titleSize.height)
        title.draw(in: titleRect, withAttributes: titleAttributes)
        currentY += titleSize.height + PDFConstants.titleSpacing
        
        // Date range and duration
        if let firstDay = itinerary.dailySchedules.first,
           let lastDay = itinerary.dailySchedules.last {
            let dateRange = "\(formatDate(firstDay.date)) - \(formatDate(lastDay.date))"
            let duration = "\(itinerary.totalDays) days • \(summary.totalActivities) activities"
            
            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: PDFFonts.subtitle,
                .foregroundColor: UIColor.darkGray
            ]
            
            let dateSize = dateRange.size(withAttributes: subtitleAttributes)
            let dateRect = CGRect(x: contentRect.minX, y: currentY, width: contentRect.width, height: dateSize.height)
            dateRange.draw(in: dateRect, withAttributes: subtitleAttributes)
            currentY += dateSize.height + PDFConstants.lineSpacing
            
            let durationSize = duration.size(withAttributes: subtitleAttributes)
            let durationRect = CGRect(x: contentRect.minX, y: currentY, width: contentRect.width, height: durationSize.height)
            duration.draw(in: durationRect, withAttributes: subtitleAttributes)
            currentY += durationSize.height + PDFConstants.lineSpacing
        }
        
        // Key statistics
        currentY += 10
        currentY = drawKeyStatistics(summary: summary, startingY: currentY)
        
        return currentY
    }
    
    private static func drawKeyStatistics(summary: ItinerarySummary, startingY: CGFloat) -> CGFloat {
        var currentY = startingY
        
        let statsTitle = "Trip Overview"
        let headingAttributes: [NSAttributedString.Key: Any] = [
            .font: PDFFonts.heading,
            .foregroundColor: UIColor.black
        ]
        
        let titleSize = statsTitle.size(withAttributes: headingAttributes)
        let titleRect = CGRect(x: PDFConstants.margin, y: currentY, width: PDFConstants.contentWidth, height: titleSize.height)
        statsTitle.draw(in: titleRect, withAttributes: headingAttributes)
        currentY += titleSize.height + PDFConstants.lineSpacing
        
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: PDFFonts.body,
            .foregroundColor: UIColor.black
        ]
        
        // Statistics
        let stats = [
            "Estimated Budget: \(formatCurrency(summary.totalCost))",
            "Total Activities: \(summary.totalActivities)",
            "Optimization Score: \(Int(summary.optimizationScore * 100))% match to preferences"
        ]
        
        for stat in stats {
            let statSize = stat.size(withAttributes: bodyAttributes)
            let statRect = CGRect(x: PDFConstants.margin + 10, y: currentY, width: PDFConstants.contentWidth - 10, height: statSize.height)
            stat.draw(in: statRect, withAttributes: bodyAttributes)
            currentY += statSize.height + PDFConstants.lineSpacing
        }
        
        return currentY
    }
    
    // MARK: - Summary Section
    
    private static func drawSummarySection(summary: ItinerarySummary, startingY: CGFloat) -> CGFloat {
        var currentY = startingY
        
        // Add a separator line
        let separatorY = currentY
        let separatorPath = UIBezierPath()
        separatorPath.move(to: CGPoint(x: PDFConstants.margin, y: separatorY))
        separatorPath.addLine(to: CGPoint(x: PDFConstants.pageSize.width - PDFConstants.margin, y: separatorY))
        UIColor.lightGray.setStroke()
        separatorPath.lineWidth = 0.5
        separatorPath.stroke()
        
        currentY += 15
        
        return currentY
    }
    
    // MARK: - Daily Schedules
    
    private static func drawDailySchedules(itinerary: GeneratedItinerary, startingY: CGFloat, pageNumber: inout Int) -> CGFloat {
        var currentY = startingY
        
        let headingAttributes: [NSAttributedString.Key: Any] = [
            .font: PDFFonts.heading,
            .foregroundColor: UIColor.black
        ]
        
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: PDFFonts.body,
            .foregroundColor: UIColor.black
        ]
        
        let captionAttributes: [NSAttributedString.Key: Any] = [
            .font: PDFFonts.caption,
            .foregroundColor: UIColor.darkGray
        ]
        
        for day in itinerary.dailySchedules {
            // Check if we need a new page
            if currentY > PDFConstants.pageSize.height - 150 {
                // Add footer to current page
                drawFooter(pageNumber: pageNumber)
                
                // Start new page
                pageNumber += 1
                UIGraphicsBeginPDFPage()
                currentY = PDFConstants.margin
            }
            
            // Day header
            let dayTitle = "Day \(day.dayNumber) - \(day.theme)"
            let titleSize = dayTitle.size(withAttributes: headingAttributes)
            let titleRect = CGRect(x: PDFConstants.margin, y: currentY, width: PDFConstants.contentWidth, height: titleSize.height)
            dayTitle.draw(in: titleRect, withAttributes: headingAttributes)
            currentY += titleSize.height + PDFConstants.lineSpacing
            
            // Day info
            let dayInfo = "Cost: \(formatCurrency(day.dailyCost)) • Walking: \(day.walkingDistance)"
            let infoSize = dayInfo.size(withAttributes: captionAttributes)
            let infoRect = CGRect(x: PDFConstants.margin, y: currentY, width: PDFConstants.contentWidth, height: infoSize.height)
            dayInfo.draw(in: infoRect, withAttributes: captionAttributes)
            currentY += infoSize.height + PDFConstants.lineSpacing + 5
            
            // Activities
            for activity in day.activities {
                // Check for page break within day
                if currentY > PDFConstants.pageSize.height - 100 {
                    drawFooter(pageNumber: pageNumber)
                    pageNumber += 1
                    UIGraphicsBeginPDFPage()
                    currentY = PDFConstants.margin
                }
                
                // Activity time
                let timeText = "\(activity.startTime) - \(activity.endTime)"
                let timeSize = timeText.size(withAttributes: bodyAttributes)
                let timeRect = CGRect(x: PDFConstants.margin + 10, y: currentY, width: 80, height: timeSize.height)
                timeText.draw(in: timeRect, withAttributes: bodyAttributes)
                
                // Activity details
                let activityText = "\(activity.activity.name) (\(activity.activity.type))"
                let activitySize = activityText.size(withAttributes: bodyAttributes)
                let activityRect = CGRect(x: PDFConstants.margin + 100, y: currentY, width: PDFConstants.contentWidth - 100, height: activitySize.height)
                activityText.draw(in: activityRect, withAttributes: bodyAttributes)
                
                currentY += max(timeSize.height, activitySize.height) + PDFConstants.lineSpacing
                
                // Activity notes (if available)
                if let notes = activity.activity.notes, !notes.isEmpty {
                    let notesText = "   \(notes)"
                    let notesSize = notesText.size(withAttributes: captionAttributes)
                    let notesRect = CGRect(x: PDFConstants.margin + 100, y: currentY, width: PDFConstants.contentWidth - 100, height: notesSize.height)
                    notesText.draw(in: notesRect, withAttributes: captionAttributes)
                    currentY += notesSize.height + PDFConstants.lineSpacing
                }
            }
            
            currentY += PDFConstants.sectionSpacing
        }
        
        return currentY
    }
    
    // MARK: - Footer
    
    private static func drawFooter(pageNumber: Int) {
        let footerY = PDFConstants.pageSize.height - PDFConstants.margin + 20
        
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: PDFFonts.caption,
            .foregroundColor: UIColor.gray
        ]
        
        // Page number (right side)
        let pageText = "Page \(pageNumber)"
        let pageSize = pageText.size(withAttributes: footerAttributes)
        let pageRect = CGRect(
            x: PDFConstants.pageSize.width - PDFConstants.margin - pageSize.width,
            y: footerY,
            width: pageSize.width,
            height: pageSize.height
        )
        pageText.draw(in: pageRect, withAttributes: footerAttributes)
        
        // Generated info (left side)
        let generatedText = "Generated by Travel Planner • \(formatCurrentDate())"
        let generatedRect = CGRect(x: PDFConstants.margin, y: footerY, width: PDFConstants.contentWidth - pageSize.width - 20, height: pageSize.height)
        generatedText.draw(in: generatedRect, withAttributes: footerAttributes)
    }
    
    // MARK: - File Management
    
    private static func savePDFData(_ pdfData: NSMutableData, filename: String) -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let documentsURL = documentsPath else { return nil }
        
        let fileURL = documentsURL.appendingPathComponent(filename)
        
        do {
            try pdfData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving PDF: \(error)")
            return nil
        }
    }
    
    private static func generateFileName(for itinerary: GeneratedItinerary) -> String {
        let destination = itinerary.destination
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "/", with: "-")
        
        if let firstDay = itinerary.dailySchedules.first,
           let lastDay = itinerary.dailySchedules.last {
            let startDate = formatDateForFilename(firstDay.date)
            let endDate = formatDateForFilename(lastDay.date)
            return "\(destination)_Itinerary_\(startDate)-\(endDate).pdf"
        }
        
        return "\(destination)_Itinerary.pdf"
    }
    
    // MARK: - Formatting Helpers
    
    private static func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d, yyyy"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
    
    private static func formatDateForFilename(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMMd"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString.replacingOccurrences(of: "-", with: "")
    }
    
    private static func formatCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: Date())
    }
    
    private static func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(Int(amount))"
    }
}