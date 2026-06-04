import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            LearnView().tabItem { Label("Learn", systemImage: "sparkles") }
            FormulaLibraryView().tabItem { Label("Formulas", systemImage: "function") }
            WorldView().tabItem { Label("World", systemImage: "globe.americas.fill") }
            ResearchLabView().tabItem { Label("Lab", systemImage: "atom") }
            SettingsView().tabItem { Label("Settings", systemImage: "slider.horizontal.3") }
        }
        .tint(AetherTheme.green)
    }
}
