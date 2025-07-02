//
//  Kei_onara_App.swift
//  Kei-onara!
//
//  Created by Jason Salas on 7/1/25.
//

import SwiftUI

@main
struct Kei_onara_App: App {
    var body: some Scene {
        WindowGroup {
            DashboardView(vehicleManager: VehicleManager())
        }
    }
}
