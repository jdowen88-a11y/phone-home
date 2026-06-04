import Foundation
import SwiftUI

@MainActor
final class WorldTwoViewModel: ObservableObject {
    @Published var parameters: WorldTwoParameters = .default
    @Published var cells: [WorldTwoPlanetCell] = []
    @Published var sparks: [WorldTwoSpark] = []
    @Published var hotspots: [WorldTwoHotspot] = []
    @Published var metrics: WorldTwoMetrics = .empty
    @Published var selectedCell: WorldTwoPlanetCell?
    @Published var savedWorlds: [WorldTwoSavedWorld] = []
    @Published var currentStep: Int = 0

    private let simulator: WorldTwoPlanetSimulator
    private let sparkEngine = WorldTwoSparkEngine()
    private let detectorSwarm = WorldTwoDetectorSwarm()
    private var rng: SeededRNG

    private let worldsFile = "aetherforge-world-two-worlds.json"

    init(seed: Int = Int.random(in: 1...999_999)) {
        simulator = WorldTwoPlanetSimulator(seed: seed)
        rng = SeededRNG(seed: UInt64(seed))
        savedWorlds = LocalStore.load([WorldTwoSavedWorld].self, from: worldsFile) ?? []
        generateNewWorld()
    }

    func generateNewWorld() {
        parameters = .default
        simulator.generate(parameters: parameters)
        sparkEngine.importSparks([])
        currentStep = 0
        refreshPublishedState(forceScan: true)
    }

    func runStep(count: Int = 1) {
        guard count > 0 else { return }

        for _ in 0..<count {
            simulator.advance(parameters: parameters)
            if sparkEngine.sparks.isEmpty {
                sparkEngine.seed(count: 16, in: simulator, parameters: parameters, rng: &rng)
            }
            sparkEngine.step(in: simulator, parameters: parameters, rng: &rng)
        }

        refreshPublishedState(forceScan: true)
    }

    func seedSparks(count: Int) {
        sparkEngine.seed(count: count, in: simulator, parameters: parameters, rng: &rng)
        refreshPublishedState(forceScan: true)
    }

    func selectNormalized(x: Double, y: Double) {
        let gridX = min(max(Int(x * Double(simulator.width)), 0), simulator.width - 1)
        let gridY = min(max(Int(y * Double(simulator.height)), 0), simulator.height - 1)
        selectedCell = simulator.cell(at: WorldTwoGridPoint(x: gridX, y: gridY))
    }

    func saveCurrentWorld() {
        let world = WorldTwoSavedWorld(
            name: "World Two \(savedWorlds.count + 1)",
            createdAt: Date(),
            gridWidth: simulator.width,
            gridHeight: simulator.height,
            step: simulator.step,
            seed: simulator.seed,
            parameters: parameters,
            cells: simulator.cells,
            sparks: sparkEngine.sparks,
            hotspots: hotspots,
            metrics: metrics
        )

        savedWorlds.insert(world, at: 0)
        LocalStore.save(savedWorlds, as: worldsFile)
    }

    func loadWorld(_ world: WorldTwoSavedWorld) {
        parameters = world.parameters
        simulator.importCells(world.cells, step: world.step)
        sparkEngine.importSparks(world.sparks, emergenceEvents: world.metrics.emergenceEvents)
        hotspots = world.hotspots
        currentStep = world.step
        refreshPublishedState(forceScan: hotspots.isEmpty)
    }

    private func refreshPublishedState(forceScan: Bool) {
        cells = simulator.cells
        sparks = sparkEngine.sparks
        currentStep = simulator.step

        if forceScan || hotspots.isEmpty {
            hotspots = detectorSwarm.scan(simulator: simulator, sparks: sparks)
        }

        metrics = computeMetrics()
    }

    private func computeMetrics() -> WorldTwoMetrics {
        guard !cells.isEmpty else { return .empty }

        let count = Double(cells.count)
        let averageTemperature = cells.map(\.temperature).reduce(0, +) / count
        let waterCoverage = Double(cells.filter { $0.water > 0.35 }.count) / count
        let habitability = cells.map(\.habitability).reduce(0, +) / count
        let aliveSparks = sparks.filter(\.isAlive)
        let grounded = aliveSparks.filter { $0.groundedState == .grounded }
        let entropy = estimateEntropy(values: cells.map(\.energyField))
        let diversity = min(1.0, Double(aliveSparks.count) / 300.0)
        let coherence = 1.0 - entropy
        let activity = min(1.0, Double(hotspots.count) / 40.0)
        let complexity = (diversity * 0.35 + coherence * 0.25 + activity * 0.4).worldTwoClamped01

        return WorldTwoMetrics(
            averageTemperature: averageTemperature,
            waterCoverage: waterCoverage,
            habitabilityScore: habitability,
            sparkCount: aliveSparks.count,
            groundedSparkCount: grounded.count,
            complexityScore: complexity,
            entropyEstimate: entropy,
            emergenceEvents: sparkEngine.emergenceEvents
        )
    }

    private func estimateEntropy(values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }

        let bins = 8
        var counts = Array(repeating: 0.0, count: bins)
        for value in values {
            let index = min(bins - 1, max(0, Int(value.worldTwoClamped01 * Double(bins))))
            counts[index] += 1
        }

        let total = Double(values.count)
        let entropy = counts.reduce(0.0) { partial, count in
            guard count > 0 else { return partial }
            let p = count / total
            return partial - p * log2(p)
        }

        return (entropy / log2(Double(bins))).worldTwoClamped01
    }
}
