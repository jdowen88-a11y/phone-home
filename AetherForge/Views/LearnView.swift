import SwiftUI

struct LearnView: View {
    private let cards: [(String, String, String)] = [
        ("Formula Library", "Browse quantum, cryptographic, physical, and emergence formulas.", "function"),
        ("Planet Sandbox", "Generate offline procedural worlds with terrain, water, atmosphere, UV, chemistry, and energy maps.", "globe"),
        ("Spark Emergence", "Seed proto-agents that move, absorb energy, mutate, adapt, ground, reproduce, or die.", "sparkles"),
        ("Detector Swarm", "Virtual satellites scan for coherence, gradients, low entropy, habitability, and emergence hotspots.", "dot.radiowaves.left.and.right"),
        ("Reproducibility", "v0.86 adds seeded RNG, lineage, and metric history so experiments can be repeated.", "timeline.selection")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    ForEach(cards, id: \.0) { card in
                        HStack(spacing: 14) {
                            Image(systemName: card.2)
                                .font(.system(size: 28))
                                .foregroundStyle(AetherTheme.cyan)
                                .frame(width: 42)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(card.0).font(.headline)
                                Text(card.1).font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        .aetherCard()
                    }
                }
                .padding()
            }
            .background(AetherTheme.background.ignoresSafeArea())
            .navigationTitle("AetherForge")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Offline emergence laboratory")
                .font(.largeTitle.bold())
                .foregroundStyle(LinearGradient(colors: [AetherTheme.green, AetherTheme.cyan], startPoint: .leading, endPoint: .trailing))
            Text("A working MVP for formula exploration, procedural planets, Spark proto-agents, detector swarms, metric history, and RealityKit visualization.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .aetherCard()
    }
}
