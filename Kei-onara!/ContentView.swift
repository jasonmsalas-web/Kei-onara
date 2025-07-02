//
//  ContentView.swift
//  Kei-onara!
//
//  Created by Jason Salas on 7/1/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vehicleManager = VehicleManager()
    
    var body: some View {
        DashboardView(vehicleManager: vehicleManager)
    }
}

#Preview {
    ContentView()
}
