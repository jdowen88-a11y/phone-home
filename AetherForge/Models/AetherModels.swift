import Foundation
import SwiftUI

enum FormulaCategory: String, CaseIterable, Codable, Identifiable {
    case physicalConstants = "Physical Constants"
    case quantumFoundations = "Quantum Foundations"
    case quantumGates = "Quantum Gates"
    case quantumAlgorithms = "Quantum Algorithms"
    case quantumErrorCorrection = "Quantum Error Correction"
    case cryptography = "Cryptography"
    case emergenceMathematics = "Emergence Mathematics"

    var id: String { rawValue }
}

enum FormulaDifficulty: String, CaseIterable, Codable, Identifiable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    var id: String { rawValue }
}

struct Formula: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let category: FormulaCategory
    let difficulty: FormulaDifficulty
    let equationText: String
    let explanation: String
    let usageTip: String
    let relatedConcepts: [String]
}

struct GridPosition: Codable, Hashable {
    var x: Int
    var y: Int
}

enum SparkGroundedState: String, Codable, CaseIterable {
    case drifting
    case adapting
    case grounded
    case unstable
}

struct Spark: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var parentID: UUID?
    var generation: Int = 0
    var position: GridPosition
    var energySignature: Double
    var stability: Double
    var mutationRate: Double
    var memory: [Double]
    var environmentAffinity: Double
    var resonanceScore: Double
    var groundedState: SparkGroundedState
}

struct PlanetCell: Identifiable, Codable, Hashable {
    var id: String { "\(x)-\(y)" }
    var x: Int
    var y: Int
    var temperature: Double
    var water: Double
    var atmosphereDensity: Double
    var terrainHeight: Double
    var energyField: Double
    var uvExposure: Double
    var chemicalGradient: Double
    var habitabilityScore: Double
}

struct Hotspot: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var position: GridPosition
    var coherence: Double
    var energyGradient: Double
    var entropy: Double
    var habitability: Double
    var sparkActivity: Double
    var emergenceScore: Double
}

struct Detector: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var orbitalPhase: Double
    var scanRadius: Int
    var sensitivity: Double
}

struct SimulationMetrics: Codable, Hashable {
    var averageTemperature: Double = 0
    var waterCoverage: Double = 0
    var habitabilityScore: Double = 0
    var sparkCount: Int = 0
    var groundedSparkCount: Int = 0
    var complexityScore: Double = 0
    var entropyEstimate: Double = 0
    var emergenceEvents: Int = 0
}

struct MetricsFrame: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var stepIndex: Int
    var metrics: SimulationMetrics
}

struct WorldState: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var seed: Int
    var rng: SeededRNG
    var width: Int
    var height: Int
    var solarIntensity: Double
    var waterLevel: Double
    var atmosphereDensity: Double
    var cells: [PlanetCell]
    var sparks: [Spark]
    var hotspots: [Hotspot]
    var metrics: SimulationMetrics
    var metricsHistory: [MetricsFrame]
    var stepIndex: Int
}

struct UserSettings: Codable, Hashable {
    var autoRotatePlanet: Bool = true
    var showSparkMarkers: Bool = true
    var showHotspots: Bool = true
    var simulationSpeed: Double = 1
    var maxSparkCount: Int = 450
}
