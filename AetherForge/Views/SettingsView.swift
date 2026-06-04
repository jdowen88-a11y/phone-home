import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Viewer") {
                    Toggle("Auto-rotate planet", isOn: $model.settings.autoRotatePlanet)
                    Toggle("Show Spark markers", isOn: $model.settings.showSparkMarkers)
                    Toggle("Show hotspot markers", isOn: $model.settings.showHotspots)
                }

                Section("Simulation") {
                    Stepper("Max Sparks: \(model.settings.maxSparkCount)", value: $model.settings.maxSparkCount, in: 50...1200, step: 50)
                    Slider(value: $model.settings.simulationSpeed, in: 0.25...3.0) { Text("Simulation Speed") }
                    Text("Speed \(model.settings.simulationSpeed.fixed2)x").foregroundStyle(.secondary)
                }

                Section {
                    Button("Save Settings") { model.saveSettings() }
                    Button("Regenerate Current Environment") { model.regenerateEnvironment() }
                    Button("Create New World") { model.newWorld() }
                        .foregroundStyle(AetherTheme.warning)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AetherTheme.background)
            .navigationTitle("Settings")
        }
    }
}
