import Foundation

final class WorldTwoDetectorSwarm {
    private(set) var detectors: [WorldTwoDetector]

    init(count: Int = 9) {
        detectors = (0..<count).map {
            WorldTwoDetector(
                orbitalIndex: $0,
                scanRadius: 3 + ($0 % 4),
                sensitivity: 0.55 + Double($0 % 5) * 0.07
            )
        }
    }

    func scan(simulator: WorldTwoPlanetSimulator, sparks: [WorldTwoSpark]) -> [WorldTwoHotspot] {
        guard !simulator.cells.isEmpty else { return [] }
        var candidates: [WorldTwoHotspot] = []

        for cell in simulator.cells {
            let detector = detectors[cell.coordinate.x % detectors.count]
            let coherence = localCoherence(around: cell.coordinate, simulator: simulator, radius: detector.scanRadius)
            let entropy = localEntropy(around: cell.coordinate, simulator: simulator, radius: detector.scanRadius)
            let activity = sparkActivity(around: cell.coordinate, sparks: sparks, radius: detector.scanRadius)

            let hotspot = WorldTwoHotspot(
                coordinate: cell.coordinate,
                coherence: coherence,
                energyGradient: simulator.energyGradient(at: cell.coordinate),
                entropy: entropy,
                habitability: cell.habitability,
                sparkActivity: activity
            )

            if hotspot.score > 0.68 * detector.sensitivity {
                candidates.append(hotspot)
            }
        }

        return Array(candidates.sorted { $0.score > $1.score }.prefix(40))
    }

    private func localCoherence(around point: WorldTwoGridPoint, simulator: WorldTwoPlanetSimulator, radius: Int) -> Double {
        guard let center = simulator.cell(at: point) else { return 0 }
        let cells = simulator.neighbors(of: point, radius: radius)
        guard !cells.isEmpty else { return 0 }
        let averageDelta = cells.map { abs($0.energyField - center.energyField) }.reduce(0, +) / Double(cells.count)
        return (1.0 - averageDelta).worldTwoClamped01
    }

    private func localEntropy(around point: WorldTwoGridPoint, simulator: WorldTwoPlanetSimulator, radius: Int) -> Double {
        let cells = simulator.neighbors(of: point, radius: radius)
        guard !cells.isEmpty else { return 1 }

        let bins = 6
        var counts = Array(repeating: 0.0, count: bins)
        for cell in cells {
            let index = min(bins - 1, max(0, Int(cell.energyField * Double(bins))))
            counts[index] += 1
        }

        let total = Double(cells.count)
        let entropy = counts.reduce(0.0) { partial, count in
            guard count > 0 else { return partial }
            let p = count / total
            return partial - p * log2(p)
        }

        return (entropy / log2(Double(bins))).worldTwoClamped01
    }

    private func sparkActivity(around point: WorldTwoGridPoint, sparks: [WorldTwoSpark], radius: Int) -> Double {
        let activeCount = sparks.filter {
            abs($0.position.x - point.x) <= radius &&
            abs($0.position.y - point.y) <= radius &&
            $0.isAlive
        }.count

        return (Double(activeCount) / Double(max(radius * radius, 1))).worldTwoClamped01
    }
}
