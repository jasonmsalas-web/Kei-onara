import Foundation
import UIKit

class GoogleDriveBackupManager: ObservableObject {
    @Published var isBackingUp = false
    @Published var isRestoring = false
    @Published var backupStatus = ""
    
    private let backupFileName = "kei-onara-backup.json"
    private let backupFolderName = "Kei-onara! Backups"
    private var documentPickerDelegate: DocumentPickerDelegate?
    
    // MARK: - Backup
    
    func backupToGoogleDrive(vehicleManager: VehicleManager, completion: @escaping (Error?) -> Void) {
        isBackingUp = true
        backupStatus = "Preparing backup data..."
        
        // Create backup data structure
        let backupData = BackupData(
            vehicles: vehicleManager.vehicles,
            driveLogs: vehicleManager.driveLogs,
            fuelEntries: vehicleManager.fuelEntries,
            maintenanceRecords: vehicleManager.maintenanceRecords,
            settings: vehicleManager.settings,
            timestamp: Date()
        )
        
        // Encode to JSON
        guard let jsonData = try? JSONEncoder().encode(backupData) else {
            backupStatus = "Failed to encode backup data"
            isBackingUp = false
            completion(NSError(domain: "BackupError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode backup data"]))
            return
        }
        
        backupStatus = "Creating backup file..."
        
        // Save to temporary directory and show sharing options
        saveBackupToDocuments(jsonData: jsonData, completion: completion)
    }
    
    private func saveBackupToDocuments(jsonData: Data, completion: @escaping (Error?) -> Void) {
        let timestamp = Date().formatted(date: .abbreviated, time: .omitted).replacingOccurrences(of: " ", with: "-")
        let filename = "kei-onara-backup-\(timestamp).json"
        
        // Create a temporary file in the app's temporary directory
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempURL = tempDirectory.appendingPathComponent(filename)
        
        do {
            try jsonData.write(to: tempURL)
            backupStatus = "Backup prepared successfully"
            isBackingUp = false
            
            // Create a data object that can be shared more easily
            DispatchQueue.main.async {
                self.showShareSheet(for: jsonData, filename: filename)
            }
            
            completion(nil)
        } catch {
            backupStatus = "Failed to save backup: \(error.localizedDescription)"
            isBackingUp = false
            completion(error)
        }
    }
    
    private func showShareSheet(for jsonData: Data, filename: String) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else { return }
            
            // Find the topmost presented view controller
            var topController = rootViewController
            while let presentedController = topController.presentedViewController {
                topController = presentedController
            }
            
            // Create a custom activity item that provides better file handling
            let activityItem = BackupDataActivityItem(jsonData: jsonData, filename: filename)
            let activityVC = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
            
            // Configure for Google Drive and other cloud services
            activityVC.excludedActivityTypes = [
                .assignToContact,
                .addToReadingList,
                .openInIBooks,
                .markupAsPDF,
                .print
            ]
            
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            topController.present(activityVC, animated: true)
        }
    }
    
    // MARK: - Restore
    
    func restoreFromGoogleDrive(vehicleManager: VehicleManager, completion: @escaping (Error?) -> Void) {
        isRestoring = true
        backupStatus = "Selecting backup file..."
        
        // Show document picker to select backup file
        showDocumentPicker { [weak self] url in
            guard let self = self else { return }
            
            self.backupStatus = "Reading backup file..."
            
            do {
                let jsonData = try Data(contentsOf: url)
                let backupData = try JSONDecoder().decode(BackupData.self, from: jsonData)
                
                self.backupStatus = "Restoring data..."
                
                // Restore all data
                vehicleManager.vehicles = backupData.vehicles
                vehicleManager.fuelEntries = backupData.fuelEntries
                vehicleManager.maintenanceRecords = backupData.maintenanceRecords
                vehicleManager.driveLogs = backupData.driveLogs
                vehicleManager.settings = backupData.settings
                
                // Save to local storage
                vehicleManager.saveAllData()
                
                self.backupStatus = "Restore completed successfully!"
                self.isRestoring = false
                completion(nil)
                
            } catch {
                self.backupStatus = "Failed to restore: \(error.localizedDescription)"
                self.isRestoring = false
                completion(error)
            }
        }
    }
    
    private func showDocumentPicker(completion: @escaping (URL) -> Void) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else { return }
            
            // Find the topmost presented view controller
            var topController = rootViewController
            while let presentedController = topController.presentedViewController {
                topController = presentedController
            }
            
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
            let delegate = DocumentPickerDelegate(completion: completion)
            documentPicker.delegate = delegate
            
            // Store delegate reference to prevent deallocation
            self.documentPickerDelegate = delegate
            
            topController.present(documentPicker, animated: true)
        }
    }
}

// MARK: - Document Picker Delegate

class DocumentPickerDelegate: NSObject, UIDocumentPickerDelegate {
    private let completion: (URL) -> Void
    
    init(completion: @escaping (URL) -> Void) {
        self.completion = completion
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        completion(url)
    }
}

// MARK: - Custom Activity Item for Data Sharing

class BackupDataActivityItem: NSObject, UIActivityItemSource {
    private let jsonData: Data
    private let filename: String
    
    init(jsonData: Data, filename: String) {
        self.jsonData = jsonData
        self.filename = filename
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return jsonData
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return jsonData
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "Kei-onara! Backup - \(filename)"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "public.json"
    }
}

 