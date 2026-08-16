import SwiftUI

enum DriftTheme {
    static let background = Color(red: 0.055, green: 0.06, blue: 0.09)
    static let surface = Color(red: 0.10, green: 0.11, blue: 0.16)
    static let surfaceHigh = Color(red: 0.16, green: 0.17, blue: 0.24)
    static let accent = Color(red: 0.48, green: 0.80, blue: 1.0)
    static let accentWarm = Color(red: 0.98, green: 0.55, blue: 0.45)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.6)

    static let gradient = LinearGradient(
        colors: [accent, Color(red: 0.55, green: 0.42, blue: 0.95)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
