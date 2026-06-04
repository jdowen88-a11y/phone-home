import Foundation

/// Named forge layer for routing high-level AetherForge actions.
///
/// The app already had the behavior spread across AppModel, PlanetSimulator,
/// SparkEmergenceEngine, and ResonanceDetectorSwarm. This file gives that layer
/// a real home without replacing the existing v0.86 engine.
@MainActor
enum ForgeEngine {
    static let version = "0.88"
    static let primeDisplayName = "Aether Prime"
    static let archiveDisplayName = "Archive Planet"

    static func refreshDerivedData(for world: inout WorldState, appendHistory: Bool = true) {
        world.hotspots = ResonanceDetectorSwarm.scan(world: world)
        world.metrics = PlanetSimulator.calculateMetrics(world)

        if appendHistory {
            PlanetSimulator.appendMetricsFrame(&world)
        }
    }

    static func ensureBootstrapped(_ world: inout WorldState) {
        refreshDerivedData(for: &world, appendHistory: false)

        if world.metricsHistory.isEmpty {
            PlanetSimulator.appendMetricsFrame(&world)
        }
    }

    static func createPrimeWorld(
        name: String,
        seed: Int,
        solarIntensity: Double,
        waterLevel: Double,
        atmosphereDensity: Double
    ) -> WorldState {
        PlanetSimulator.makeWorld(
            name: name,
            seed: seed,
            solarIntensity: solarIntensity,
            waterLevel: waterLevel,
            atmosphereDensity: atmosphereDensity
        )
    }

    static func createPrimeWorldLikeCurrent(_ current: WorldState) -> WorldState {
        createPrimeWorld(
            name: "Aether-\(Int.random(in: 10...99))",
            seed: Int.random(in: 1...999_999),
            solarIntensity: current.solarIntensity,
            waterLevel: current.waterLevel,
            atmosphereDensity: current.atmosphereDensity
        )
    }

    static func seedPrimeSparks(
        world: inout WorldState,
        count: Int,
        mutationRate: Double
    ) {
        SparkEmergenceEngine.seedSparks(
            in: &world,
            count: count,
            baseMutationRate: mutationRate
        )
        refreshDerivedData(for: &world)
    }

    static func runPrimeSteps(
        world: inout WorldState,
        count: Int,
        maxSparkCount: Int
    ) {
        guard count > 0 else { return }

        for _ in 0..<count {
            PlanetSimulator.runStep(&world, maxSparkCount: maxSparkCount)
        }
    }

    static func regeneratePrimeEnvironment(world: inout WorldState) {
        PlanetSimulator.regenerateEnvironment(&world)
    }

    static func summarizePrimeWorld(_ world: WorldState) -> ForgeWorldSummary {
        ForgeWorldSummary(
            slot: .aetherPrime,
            name: world.name,
            stepIndex: world.stepIndex,
            sparkCount: world.sparks.count,
            groundedSparkCount: world.metrics.groundedSparkCount,
            hotspotCount: world.hotspots.count,
            complexityScore: world.metrics.complexityScore
        )
    }

    static func summarizeArchiveWorld(
        stepIndex: Int,
        sparkCount: Int,
        groundedSparkCount: Int,
        hotspotCount: Int,
        complexityScore: Double,
        name: String = archiveDisplayName
    ) -> ForgeWorldSummary {
        ForgeWorldSummary(
            slot: .archivePlanet,
            name: name,
            stepIndex: stepIndex,
            sparkCount: sparkCount,
            groundedSparkCount: groundedSparkCount,
            hotspotCount: hotspotCount,
            complexityScore: complexityScore
        )
    }
}

enum ForgeWorldSlot: String, CaseIterable, Identifiable, Codable, Hashable {
    case aetherPrime = "Aether Prime"
    case archivePlanet = "Archive Planet"

    var id: String { rawValue }
}

struct ForgeWorldSummary: Identifiable, Codable, Hashable {
    var id: String { slot.rawValue }
    var slot: ForgeWorldSlot
    var name: String
    var stepIndex: Int
    var sparkCount: Int
    var groundedSparkCount: Int
    var hotspotCount: Int
    var complexityScore: Double
}
