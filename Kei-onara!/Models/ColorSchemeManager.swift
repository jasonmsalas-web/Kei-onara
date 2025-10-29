import SwiftUI

class ColorSchemeManager: ObservableObject {
    @Published var isDarkMode: Bool = false
    
    // MARK: - Background Colors
    
    var backgroundColor: Color {
        isDarkMode ? Color.black : Color.white
    }
    
    var secondaryBackgroundColor: Color {
        isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color.gray.opacity(0.05)
    }
    
    // MARK: - Text Colors
    
    var primaryTextColor: Color {
        isDarkMode ? Color.white : Color.black
    }
    
    var secondaryTextColor: Color {
        isDarkMode ? Color.gray : Color.gray
    }
    
    var accentTextColor: Color {
        isDarkMode ? Color.blue : Color.blue
    }
    
    // MARK: - Card Colors
    
    var cardBackgroundColor: Color {
        isDarkMode ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white
    }
    
    var cardBorderColor: Color {
        isDarkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1)
    }
    
    // MARK: - Button Colors
    
    var primaryButtonColor: Color {
        isDarkMode ? Color.blue : Color.blue
    }
    
    var secondaryButtonColor: Color {
        isDarkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1)
    }
    
    var destructiveButtonColor: Color {
        isDarkMode ? Color.red : Color.red
    }
    
    // MARK: - Glass Effects
    
    var glassBackgroundColor: Color {
        isDarkMode ? Color(red: 0.2, green: 0.2, blue: 0.2).opacity(0.8) : Color.white.opacity(0.9)
    }
    
    var glassBorderColor: Color {
        isDarkMode ? Color.gray.opacity(0.4) : Color.gray.opacity(0.2)
    }
    
    // MARK: - Leather Card Colors
    
    var leatherBackgroundColor: Color {
        isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.98, green: 0.96, blue: 0.92)
    }
    
    var leatherBorderColor: Color {
        isDarkMode ? Color(red: 0.3, green: 0.3, blue: 0.3) : Color(red: 0.8, green: 0.75, blue: 0.65)
    }
    
    // MARK: - Progress Colors
    
    var progressBackgroundColor: Color {
        isDarkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1)
    }
    
    var progressFillColor: Color {
        isDarkMode ? Color.blue : Color.blue
    }
    
    // MARK: - Status Colors
    
    var successColor: Color {
        isDarkMode ? Color.green : Color.green
    }
    
    var warningColor: Color {
        isDarkMode ? Color.orange : Color.orange
    }
    
    var errorColor: Color {
        isDarkMode ? Color.red : Color.red
    }
    
    // MARK: - Navigation Colors
    
    var navigationBackgroundColor: Color {
        isDarkMode ? Color.black : Color.white
    }
    
    var navigationBarColor: Color {
        isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color.white
    }
    
    // MARK: - Form Colors
    
    var textFieldBackgroundColor: Color {
        isDarkMode ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.gray.opacity(0.05)
    }
    
    var textFieldBorderColor: Color {
        isDarkMode ? Color.gray.opacity(0.4) : Color.gray.opacity(0.2)
    }
    
    var textFieldTextColor: Color {
        isDarkMode ? Color.white : Color.black
    }
    
    // MARK: - List Colors
    
    var listBackgroundColor: Color {
        isDarkMode ? Color.black : Color.white
    }
    
    var listRowBackgroundColor: Color {
        isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color.white
    }
    
    var listRowSeparatorColor: Color {
        isDarkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1)
    }
    
    // MARK: - Utility Methods
    
    func updateDarkMode(_ isDark: Bool) {
        isDarkMode = isDark
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
    }
} 