import Foundation

struct WorldTwoGridPoint: Codable, Hashable {
    var x: Int
    var y: Int
}

struct WorldTwoPlanetCell: Identifiable, Codable, Hashable {
    var id: String { "\(coordinate.x)-\(coordinate.y)" }

    var coordinate: WorldTwoGridPoint
    var height: Double
    var temperature: Double
    var water: Double
    var atmosphereDensity: Double
    var energyField: Double
    var uvExposure: Double
    var chemicalGradient: Double
    var habitability: Double
}

struct WorldTwoSparkMemoryItem: Codable, Hashable {
    var step: Int
    var coordinate: WorldTwoGridPoint
    var habitability: Double
    var energy: Double
}

enum WorldTwoSparkState: String, Codable, CaseIterable {
    case volatile
    case searching
    case grounded
    case reproducing
    case dead
}

struct WorldTwoSpark: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var parentID: UUID?
    var generation: Int = 0
    var position: WorldTwoGridPoint
    var energySignature: Double
    var stability: Double
    var mutationRate: Double
    var memory: [WorldTwoSparkMemoryItem]
    var environmentAffinity: Double
    var resonanceScore: Double
    var groundedState: WorldTwoSparkState
    var age: Int

    var isAlive: Bool {
        groundedState != .dead && stability > 0.02 && energySignature > 0.01
    }
}

struct WorldTwoDetector: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var orbitalIndex: Int
    var scanRadius: Int
    var sensitivity: Double
}

struct WorldTwoHotspot: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var coordinate: WorldTwoGridPoint
    var coherence: Double
    var energyGradient: Double
    var entropy: Double
    var habitability: Double
    var sparkActivity: Double

    var score: Double {
        let lowEntropyBonus = 1.0 - entropy
        return (
            coherence * 0.25
            + energyGradient * 0.18
            + lowEntropyBonus * 0.18
            + habitability * 0.22
            + sparkActivity * 0.17
        ).worldTwoClamped01
    }
}

struct WorldTwoMetrics: Codable, Hashable {
    var averageTemperature: Double
    var waterCoverage: Double
    var habitabilityScore: Double
    var sparkCount: Int
    var groundedSparkCount: Int
    var complexityScore: Double
    var entropyEstimate: Double
    var emergenceEvents: Int

    static let empty = WorldTwoMetrics(
        averageTemperature: 0,
        waterCoverage: 0,
        habitabilityScore: 0,
        sparkCount: 0,
        groundedSparkCount: 0,
        complexityScore: 0,
        entropyEstimate: 0,
        emergenceEvents: 0
    )
}

struct WorldTwoParameters: Codable, Hashable {
    var mutationRate: Double
    var solarIntensity: Double
    var waterLevel: Double
    var atmosphereDensity: Double

    static let `default` = WorldTwoParameters(
        mutationRate: 0.08,
        solarIntensity: 1.0,
        waterLevel: 0.52,
        atmosphereDensity: 0.72
    )
}

struct WorldTwoSavedWorld: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var createdAt: Date
    var gridWidth: Int
    var gridHeight: Int
    var step: Int
    var seed: Int
    var parameters: WorldTwoParameters
    var cells: [WorldTwoPlanetCell]
    var sparks: [WorldTwoSpark]
    var hotspots: [WorldTwoHotspot]
    var metrics: WorldTwoMetrics
}

extension Double {
    var worldTwoClamped01: Double {
        min(1.0, max(0.0, self))
    }

    func worldTwoClamped(_ range: ClosedRange<Double>) -> Double {
        min(range.upperBound, max(range.lowerBound, self))
    }
}
