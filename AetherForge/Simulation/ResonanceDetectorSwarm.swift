import Foundation

enum ResonanceDetectorSwarm {
    static let detectors: [Detector] = [
        Detector(orbitalPhase: 0.00, scanRadius: 2, sensitivity: 0.78),
        Detector(orbitalPhase: 0.25, scanRadius: 3, sensitivity: 0.72),
        Detector(orbitalPhase: 0.50, scanRadius: 2, sensitivity: 0.82),
        Detector(orbitalPhase: 0.75, scanRadius: 4, sensitivity: 0.66)
    ]

    static func scan(world: WorldState) -> [Hotspot] {
        var hotspots: [Hotspot] = []
        let sparkActivityMap = makeSparkActivityMap(world: world)

        for cell in world.cells {
            let local = PlanetSimulator.neighbors(of: GridPosition(x: cell.x, y: cell.y), in: world)
            let energyValues = local.map(\.energyField)
            let chemicalValues = local.map(\.chemicalGradient)
            let coherence = 1.0 - variance(energyValues)
            let energyGradient = gradientMagnitude(cell: cell, local: local)
            let entropy = PlanetSimulator.estimateEntropy(energyValues + chemicalValues)
            let lowEntropy = 1.0 - entropy
            let sparkActivity = sparkActivityMap[cell.id] ?? 0
            let detectorBoost = detectors.map { $0.sensitivity * orbitalCoverage(cell: cell, world: world, detector: $0) }.max() ?? 0.5
            let emergenceScore = ProceduralNoise.clamp(
                coherence * 0.22 + energyGradient * 0.20 + lowEntropy * 0.16 + cell.habitabilityScore * 0.22 + sparkActivity * 0.20
            ) * detectorBoost

            if emergenceScore > 0.48 {
                hotspots.append(Hotspot(
                    position: GridPosition(x: cell.x, y: cell.y),
                    coherence: ProceduralNoise.clamp(coherence),
                    energyGradient: ProceduralNoise.clamp(energyGradient),
                    entropy: ProceduralNoise.clamp(entropy),
                    habitability: cell.habitabilityScore,
                    sparkActivity: sparkActivity,
                    emergenceScore: ProceduralNoise.clamp(emergenceScore)
                ))
            }
        }

        return Array(hotspots.sorted { $0.emergenceScore > $1.emergenceScore }.prefix(32))
    }

    private static func makeSparkActivityMap(world: WorldState) -> [String: Double] {
        var counts: [String: Double] = [:]
        for spark in world.sparks {
            let cell = PlanetSimulator.cell(at: spark.position, in: world)
            counts[cell.id, default: 0] += spark.groundedState == .grounded ? 0.22 : 0.12
        }
        return counts.mapValues { ProceduralNoise.clamp($0) }
    }

    private static func gradientMagnitude(cell: PlanetCell, local: [PlanetCell]) -> Double {
        guard !local.isEmpty else { return 0 }
        let averageEnergy = local.map(\.energyField).reduce(0, +) / Double(local.count)
        let averageChemical = local.map(\.chemicalGradient).reduce(0, +) / Double(local.count)
        return ProceduralNoise.clamp(abs(cell.energyField - averageEnergy) + abs(cell.chemicalGradient - averageChemical))
    }

    private static func variance(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let mean = values.reduce(0, +) / Double(values.count)
        let variance = values.map { pow($0 - mean, 2) }.reduce(0, +) / Double(values.count)
        return ProceduralNoise.clamp(variance * 8.0)
    }

    private static func orbitalCoverage(cell: PlanetCell, world: WorldState, detector: Detector) -> Double {
        let normalizedX = Double(cell.x) / Double(world.width)
        let distance = abs(normalizedX - detector.orbitalPhase)
        let wrappedDistance = min(distance, 1.0 - distance)
        return ProceduralNoise.clamp(1.0 - wrappedDistance * 2.4)
    }
}
