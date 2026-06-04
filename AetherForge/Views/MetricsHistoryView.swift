import SwiftUI

struct MetricsHistoryView: View {
    let frames: [MetricsFrame]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Metrics History")
                .font(.headline)

            if frames.isEmpty {
                Text("No recorded frames yet. Run the simulation to collect history.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(frames.suffix(8)) { frame in
                    HStack {
                        Text("Step \(frame.stepIndex)")
                            .font(.caption.monospacedDigit())
                        Spacer()
                        Text("S \(frame.metrics.sparkCount)")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(AetherTheme.cyan)
                        Text("C \(frame.metrics.complexityScore.percent)")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(AetherTheme.warning)
                        Text("E \(frame.metrics.entropyEstimate.percent)")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(AetherTheme.green)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .aetherCard()
    }
}
