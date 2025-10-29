//
//  Kei_onara_App.swift
//  Kei-onara!
//
//  Created by Jason Salas on 7/1/25.
//

import SwiftUI
import UIKit

@main
struct Kei_onara_App: App {
    @StateObject private var vehicleManager = VehicleManager()
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var siriShortcutsManager = SiriShortcutsManager.shared
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vehicleManager)
                .environmentObject(notificationManager)
                .environmentObject(siriShortcutsManager)
                .onAppear {
                    // Initialize app components
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        // Configure app settings
        configureAppearance()
        
        // Initialize managers
        notificationManager.requestPermission()
        siriShortcutsManager.setupShortcuts()
        
        // Check for achievements
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            notificationManager.checkForAchievements(vehicleManager: vehicleManager)
        }
    }
    
    private func configureAppearance() {
        // Configure global app appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Configure global dark mode support
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = vehicleManager.settings.isDarkModeEnabled ? .dark : .light
            }
        }
    }
}
