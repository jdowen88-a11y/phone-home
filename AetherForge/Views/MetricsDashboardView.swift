import SwiftUI

struct MetricsDashboardView: View {
    let metrics: SimulationMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Metrics Dashboard").font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MetricPill(title: "Avg Temp", value: metrics.averageTemperature.percent, color: AetherTheme.cyan)
                MetricPill(title: "Water", value: metrics.waterCoverage.percent, color: AetherTheme.blue)
                MetricPill(title: "Habitability", value: metrics.habitabilityScore.percent, color: AetherTheme.green)
                MetricPill(title: "Sparks", value: "\(metrics.sparkCount)", color: AetherTheme.cyan)
                MetricPill(title: "Grounded", value: "\(metrics.groundedSparkCount)", color: AetherTheme.green)
                MetricPill(title: "Complexity", value: metrics.complexityScore.percent, color: AetherTheme.warning)
                MetricPill(title: "Entropy", value: metrics.entropyEstimate.percent, color: AetherTheme.cyan)
                MetricPill(title: "Events", value: "\(metrics.emergenceEvents)", color: AetherTheme.green)
            }
        }
        .aetherCard()
    }
}
