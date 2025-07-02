import Foundation
import PDFKit
import UIKit

class PDFExporter {
    static func generateExpenseReport(
        vehicle: Vehicle,
        fuelEntries: [FuelEntry],
        maintenanceRecords: [MaintenanceRecord],
        driveLogs: [DriveLog],
        dateRange: String,
        includeFuel: Bool,
        includeMaintenance: Bool,
        includeDrives: Bool
    ) -> Data? {
        
        let pdfMetaData = [
            kCGPDFContextCreator: "Kei-onara! App",
            kCGPDFContextAuthor: "Vehicle Owner",
            kCGPDFContextTitle: "\(vehicle.displayName) Expense Report"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4 size
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let headerFont = UIFont.boldSystemFont(ofSize: 16)
            let bodyFont = UIFont.systemFont(ofSize: 12)
            let smallFont = UIFont.systemFont(ofSize: 10)
            
            var yPosition: CGFloat = 50
            
            // Title
            let titleAttributes = [NSAttributedString.Key.font: titleFont]
            let titleString = "EXPENSE REPORT"
            titleString.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)
            yPosition += 40
            
            // Vehicle Info
            let vehicleInfo = """
            Vehicle: \(vehicle.displayName)
            Generated: \(Date().formatted())
            Period: \(dateRange)
            """
            
            let vehicleAttributes = [NSAttributedString.Key.font: bodyFont]
            vehicleInfo.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: vehicleAttributes)
            yPosition += 60
            
            // Fuel Expenses
            if includeFuel && !fuelEntries.isEmpty {
                let fuelHeaderAttributes = [NSAttributedString.Key.font: headerFont]
                "FUEL EXPENSES".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: fuelHeaderAttributes)
                yPosition += 25
                
                let fuelTableAttributes = [NSAttributedString.Key.font: smallFont]
                let fuelHeader = "Date\t\t\tLiters\tPrice/L\tTotal Cost\tOdometer"
                fuelHeader.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: fuelTableAttributes)
                yPosition += 20
                
                for entry in fuelEntries {
                    if yPosition > 750 { // Check if we need a new page
                        context.beginPage()
                        yPosition = 50
                    }
                    
                    let fuelRow = "\(entry.date.formatted(date: .abbreviated, time: .omitted))\t\t"
                        + "\(String(format: "%.2f", entry.liters))\t"
                        + "$\(String(format: "%.2f", entry.pricePerLiter))\t"
                        + "$\(String(format: "%.2f", entry.totalCost))\t"
                        + "\(Int(entry.odometer)) km"
                    
                    fuelRow.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: fuelTableAttributes)
                    yPosition += 15
                }
                yPosition += 20
            }
            
            // Maintenance Expenses
            if includeMaintenance && !maintenanceRecords.isEmpty {
                let maintenanceHeaderAttributes = [NSAttributedString.Key.font: headerFont]
                "MAINTENANCE EXPENSES".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: maintenanceHeaderAttributes)
                yPosition += 25
                
                let maintenanceTableAttributes = [NSAttributedString.Key.font: smallFont]
                let maintenanceHeader = "Date\t\t\tType\t\tCost\t\tOdometer\tNotes"
                maintenanceHeader.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: maintenanceTableAttributes)
                yPosition += 20
                
                for record in maintenanceRecords {
                    if yPosition > 750 { // Check if we need a new page
                        context.beginPage()
                        yPosition = 50
                    }
                    
                    let maintenanceRow = "\(record.date.formatted(date: .abbreviated, time: .omitted))\t\t"
                        + "\(record.type.rawValue)\t"
                        + "$\(String(format: "%.2f", record.cost ?? 0))\t"
                        + "\(Int(record.odometer)) km\t"
                        + "\(record.notes ?? "")"
                    
                    maintenanceRow.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: maintenanceTableAttributes)
                    yPosition += 15
                }
                yPosition += 20
            }
            
            // Drive Logs
            if includeDrives && !driveLogs.isEmpty {
                let driveHeaderAttributes = [NSAttributedString.Key.font: headerFont]
                "DRIVE LOGS".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: driveHeaderAttributes)
                yPosition += 25
                
                let driveTableAttributes = [NSAttributedString.Key.font: smallFont]
                let driveHeader = "Start Date\t\tDuration\tDistance\tStart Odo\tEnd Odo"
                driveHeader.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: driveTableAttributes)
                yPosition += 20
                
                for log in driveLogs {
                    if yPosition > 750 { // Check if we need a new page
                        context.beginPage()
                        yPosition = 50
                    }
                    
                    let duration = log.duration / 3600 // Convert to hours
                    let driveRow = "\(log.startTime.formatted(date: .abbreviated, time: .omitted))\t\t"
                        + "\(String(format: "%.1f", duration))h\t"
                        + "\(String(format: "%.1f", log.distance)) km\t"
                        + "\(Int(log.startOdometer)) km\t"
                        + "\(Int(log.endOdometer ?? log.startOdometer)) km"
                    
                    driveRow.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: driveTableAttributes)
                    yPosition += 15
                }
                yPosition += 20
            }
            
            // Total Expenses
            let totalFuel = fuelEntries.reduce(0) { $0 + $1.totalCost }
            let totalMaintenance = maintenanceRecords.compactMap { $0.cost }.reduce(0, +)
            let totalExpenses = totalFuel + totalMaintenance
            
            let totalAttributes = [NSAttributedString.Key.font: headerFont]
            let totalString = "TOTAL EXPENSES: $\(String(format: "%.2f", totalExpenses))"
            totalString.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: totalAttributes)
            
            // Summary
            yPosition += 40
            let summaryAttributes = [NSAttributedString.Key.font: bodyFont]
            let summary = """
            Summary:
            • Fuel Expenses: $\(String(format: "%.2f", totalFuel))
            • Maintenance Costs: $\(String(format: "%.2f", totalMaintenance))
            • Total Distance: \(String(format: "%.1f", driveLogs.reduce(0) { $0 + $1.distance })) km
            • Fuel Entries: \(fuelEntries.count)
            • Maintenance Records: \(maintenanceRecords.count)
            • Drive Sessions: \(driveLogs.count)
            """
            
            summary.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: summaryAttributes)
        }
        
        return data
    }
} 