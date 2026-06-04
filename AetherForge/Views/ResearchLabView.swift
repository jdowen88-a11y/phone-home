import SwiftUI

struct ResearchLabView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    controls
                    MetricsDashboardView(metrics: model.world.metrics)
                    MetricsHistoryView(frames: model.world.metricsHistory)
                    sparkStateSummary
                }
                .padding()
            }
            .background(AetherTheme.background.ignoresSafeArea())
            .navigationTitle("Research Lab")
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Simulation Controls").font(.title2.bold())
            Text("Seed: \(model.world.seed) · Step: \(model.world.stepIndex)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)

            slider("Mutation Rate", value: $model.mutationRate, range: 0.01...0.40, display: model.mutationRate.fixed2)
            slider("Solar Intensity", value: Binding(get: { model.world.solarIntensity }, set: { model.updateSimulationParameters(solarIntensity: $0) }), range: 0.25...1.0, display: model.world.solarIntensity.percent)
            slider("Water Level", value: Binding(get: { model.world.waterLevel }, set: { model.updateSimulationParameters(waterLevel: $0) }), range: 0.05...0.95, display: model.world.waterLevel.percent)
            slider("Atmosphere Density", value: Binding(get: { model.world.atmosphereDensity }, set: { model.updateSimulationParameters(atmosphereDensity: $0) }), range: 0.05...1.0, display: model.world.atmosphereDensity.percent)

            HStack {
                Button("Seed Sparks") { withAnimation(.spring()) { model.seedSparks(count: 32) } }
                    .buttonStyle(PrimaryButtonStyle())
                Button("Run 1 Step") { withAnimation(.easeInOut) { model.runSteps(1) } }
                    .buttonStyle(SecondaryButtonStyle())
            }

            HStack {
                Button("Run 25 Steps") { withAnimation(.easeInOut) { model.runSteps(25) } }
                    .buttonStyle(SecondaryButtonStyle())
                Button("Save Snapshot") { model.saveSnapshot() }
                    .buttonStyle(SecondaryButtonStyle())
            }
        }
        .aetherCard()
    }

    private var sparkStateSummary: some View {
        let grouped = Dictionary(grouping: model.world.sparks, by: \.groundedState)
        return VStack(alignment: .leading, spacing: 12) {
            Text("Spark State Distribution").font(.headline)
            ForEach(SparkGroundedState.allCases, id: \.self) { state in
                let count = grouped[state]?.count ?? 0
                HStack {
                    Text(state.rawValue.capitalized)
                    Spacer()
                    Text("\(count)")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(state == .grounded ? AetherTheme.green : AetherTheme.cyan)
                }
            }
        }
        .aetherCard()
    }

    private func slider(_ title: String, value: Binding<Double>, range: ClosedRange<Double>, display: String) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                Text(display).font(.caption.monospacedDigit()).foregroundStyle(AetherTheme.green)
            }
            Slider(value: value, in: range).tint(AetherTheme.green)
        }
    }
}
