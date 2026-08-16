import SwiftUI

@main
struct DriftApp: App {
    @StateObject private var app = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(app)
                .preferredColorScheme(.dark)
        }
    }
}
