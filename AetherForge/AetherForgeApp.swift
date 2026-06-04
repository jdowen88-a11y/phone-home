import SwiftUI

@main
struct AetherForgeApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appModel)
                .preferredColorScheme(.dark)
        }
    }
}
