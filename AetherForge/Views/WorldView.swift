import SwiftUI

struct WorldView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    PlanetRealityView()
                        .frame(height: 420)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(AetherTheme.cyan.opacity(0.25), lineWidth: 1))
                        .padding(.horizontal)

                    if let cell = model.selectedCell {
                        selectedCellCard(cell).padding(.horizontal)
                    }

                    MetricsDashboardView(metrics: model.world.metrics).padding(.horizontal)
                    MetricsHistoryView(frames: model.world.metricsHistory).padding(.horizontal)
                    hotspotList.padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(AetherTheme.background.ignoresSafeArea())
            .navigationTitle(model.world.name)
            .toolbar {
                Button { withAnimation(.spring()) { model.newWorld() } } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
            }
        }
    }

    private func selectedCellCard(_ cell: PlanetCell) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Selected Region \(cell.x), \(cell.y)")
                .font(.headline)
                .foregroundStyle(AetherTheme.cyan)
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                GridRow { Text("Temp"); Text(cell.temperature.percent) }
                GridRow { Text("Water"); Text(cell.water.percent) }
                GridRow { Text("Energy"); Text(cell.energyField.percent) }
                GridRow { Text("Chemistry"); Text(cell.chemicalGradient.percent) }
                GridRow { Text("Habitability"); Text(cell.habitabilityScore.percent).foregroundStyle(AetherTheme.green) }
            }
            .font(.caption.monospacedDigit())
        }
        .aetherCard()
    }

    private var hotspotList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Emergence Hotspots").font(.headline)
            ForEach(model.world.hotspots.prefix(6)) { hotspot in
                HStack {
                    VStack(alignment: .leading) {
                        Text("Region \(hotspot.position.x), \(hotspot.position.y)").font(.subheadline.bold())
                        Text("Coherence \(hotspot.coherence.percent) · Entropy \(hotspot.entropy.percent)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(hotspot.emergenceScore.percent)
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(AetherTheme.green)
                }
                .padding(.vertical, 6)
            }
        }
        .aetherCard()
    }
}
