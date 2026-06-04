import SwiftUI

struct WorldTwoView: View {
    @StateObject private var model = WorldTwoViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    header
                    metrics
                    controls
                    parameters
                    hotspotList
                    savedWorlds
                }
                .padding()
            }
            .background(AetherTheme.background.ignoresSafeArea())
            .navigationTitle("World Two")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Archive Planet")
                .font(.largeTitle.bold())
                .foregroundStyle(AetherTheme.green)
            Text("A second CPU-first procedural world that runs beside Aether Prime without replacing the v0.86 core engine.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .aetherCard()
    }

    private var metrics: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 135), spacing: 12)], spacing: 12) {
            MetricPill(title: "Temp", value: model.metrics.averageTemperature.percent, color: AetherTheme.blue)
            MetricPill(title: "Water", value: model.metrics.waterCoverage.percent, color: AetherTheme.cyan)
            MetricPill(title: "Habitability", value: model.metrics.habitabilityScore.percent, color: AetherTheme.green)
            MetricPill(title: "Sparks", value: "\(model.metrics.sparkCount)", color: .white)
            MetricPill(title: "Grounded", value: "\(model.metrics.groundedSparkCount)", color: AetherTheme.green)
            MetricPill(title: "Complexity", value: model.metrics.complexityScore.percent, color: AetherTheme.warning)
        }
    }

    private var controls: some View {
        VStack(spacing: 12) {
            HStack {
                Button("Step") { model.runStep() }
                    .buttonStyle(SecondaryButtonStyle())
                Button("+25") { model.runStep(count: 25) }
                    .buttonStyle(SecondaryButtonStyle())
            }

            HStack {
                Button("Seed Sparks") { model.seedSparks(count: 24) }
                    .buttonStyle(PrimaryButtonStyle())
                Button("Save") { model.saveCurrentWorld() }
                    .buttonStyle(SecondaryButtonStyle())
            }

            Button("New Archive Planet") { model.generateNewWorld() }
                .buttonStyle(SecondaryButtonStyle())

            Text("Current step: \(model.currentStep)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .aetherCard()
    }

    private var parameters: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("World Two Parameters")
                .font(.headline)
            WorldTwoParameterSlider(title: "Mutation", value: $model.parameters.mutationRate, range: 0.005...0.35)
            WorldTwoParameterSlider(title: "Solar", value: $model.parameters.solarIntensity, range: 0.55...1.6)
            WorldTwoParameterSlider(title: "Water", value: $model.parameters.waterLevel, range: 0.1...0.9)
            WorldTwoParameterSlider(title: "Atmosphere", value: $model.parameters.atmosphereDensity, range: 0.1...1.0)
        }
        .aetherCard()
    }

    private var hotspotList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Top Archive Hotspots")
                .font(.headline)
            ForEach(model.hotspots.prefix(8)) { hotspot in
                HStack {
                    Text("Region \(hotspot.coordinate.x), \(hotspot.coordinate.y)")
                    Spacer()
                    Text(hotspot.score.percent)
                        .foregroundStyle(AetherTheme.green)
                }
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
            }
        }
        .aetherCard()
    }

    private var savedWorlds: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Saved Archive Worlds")
                .font(.headline)

            if model.savedWorlds.isEmpty {
                Text("No World Two saves yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(model.savedWorlds.prefix(8)) { world in
                    Button {
                        model.loadWorld(world)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(world.name)
                                Text("Step \(world.step) · \(world.metrics.sparkCount) sparks")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .aetherCard()
    }
}

struct WorldTwoParameterSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                Spacer()
                Text(value.fixed2)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(AetherTheme.green)
            }
            Slider(value: $value, in: range)
                .tint(AetherTheme.green)
        }
    }
}
