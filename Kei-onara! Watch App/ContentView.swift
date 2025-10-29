import SwiftUI
import CoreLocation
import WatchKit

struct ContentView: View {
    @StateObject private var locationManager = WatchLocationManager()
    @State private var currentSpeed: Double = 0.0
    @State private var currentHeading: Double = 0.0
    @State private var speedUnit: SpeedUnit = .mph
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 8) {
                // Speed Display
                VStack(spacing: 4) {
                    Text("\(Int(currentSpeed))")
                        .font(.system(size: 48, weight: .thin, design: .rounded))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    
                    Text(speedUnit.rawValue.uppercased())
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                        .tracking(1)
                }
                
                // Direction Display
                VStack(spacing: 4) {
                    Image(systemName: directionIcon)
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(currentHeading))
                    
                    Text(directionText)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                        .tracking(1)
                }
            }
        }
        .onAppear {
            locationManager.requestLocationPermission()
        }
        .onReceive(locationManager.$currentSpeed) { speed in
            currentSpeed = speed
        }
        .onReceive(locationManager.$currentHeading) { heading in
            currentHeading = heading
        }
    }
    
    private var directionIcon: String {
        let heading = currentHeading
        if heading >= 337.5 || heading < 22.5 {
            return "arrow.up"
        } else if heading >= 22.5 && heading < 67.5 {
            return "arrow.up.right"
        } else if heading >= 67.5 && heading < 112.5 {
            return "arrow.right"
        } else if heading >= 112.5 && heading < 157.5 {
            return "arrow.down.right"
        } else if heading >= 157.5 && heading < 202.5 {
            return "arrow.down"
        } else if heading >= 202.5 && heading < 247.5 {
            return "arrow.down.left"
        } else if heading >= 247.5 && heading < 292.5 {
            return "arrow.left"
        } else {
            return "arrow.up.left"
        }
    }
    
    private var directionText: String {
        let heading = currentHeading
        if heading >= 337.5 || heading < 22.5 {
            return "N"
        } else if heading >= 22.5 && heading < 67.5 {
            return "NE"
        } else if heading >= 67.5 && heading < 112.5 {
            return "E"
        } else if heading >= 112.5 && heading < 157.5 {
            return "SE"
        } else if heading >= 157.5 && heading < 202.5 {
            return "S"
        } else if heading >= 202.5 && heading < 247.5 {
            return "SW"
        } else if heading >= 247.5 && heading < 292.5 {
            return "W"
        } else {
            return "NW"
        }
    }
}

enum SpeedUnit: String, CaseIterable {
    case mph = "mph"
    case kmh = "km/h"
    
    func convert(_ speed: Double) -> Double {
        switch self {
        case .mph:
            return speed * 2.23694 // m/s to mph
        case .kmh:
            return speed * 3.6 // m/s to km/h
        }
    }
}

#Preview {
    ContentView()
} 