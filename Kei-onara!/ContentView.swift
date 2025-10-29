//
//  ContentView.swift
//  Kei-onara!
//
//  Created by Jason Salas on 7/1/25.
//

import SwiftUI

struct ContentView: View {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                // iPadOS Interface
                iPadOSView(vehicleManager: appDelegate.vehicleManager)
            } else {
                // iOS Interface
                SplashScreenView()
            }
        }
    }
}

#Preview {
    ContentView()
}
