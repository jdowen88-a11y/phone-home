import Foundation

final class WorldTwoPlanetSimulator {
    let width: Int
    let height: Int
    let seed: Int
    private(set) var cells: [WorldTwoPlanetCell] = []
    private(set) var step: Int = 0

    init(width: Int = 72, height: Int = 48, seed: Int = Int.random(in: 1...999_999)) {
        self.width = width
        self.height = height
        self.seed = seed
    }

    func generate(parameters: WorldTwoParameters) {
        step = 0
        cells = (0..<height).flatMap { y in
            (0..<width).map { x in
                makeCell(x: x, y: y, parameters: parameters)
            }
        }
    }

    func importCells(_ imported: [WorldTwoPlanetCell], step importedStep: Int) {
        cells = imported
        step = importedStep
    }

    func advance(parameters: WorldTwoParameters) {
        guard !cells.isEmpty else {
            generate(parameters: parameters)
            return
        }

        step += 1
        cells = cells.map { cell in
            var updated = cell
            let pulse = sin(Double(step) * 0.03 + Double(cell.coordinate.x + cell.coordinate.y) * 0.09)
            updated.energyField = (updated.energyField + pulse * 0.018).worldTwoClamped01
            updated.chemicalGradient = (updated.chemicalGradient * 0.97 + updated.energyField * 0.03).worldTwoClamped01
            updated.water = (updated.water + (parameters.waterLevel - 0.5) * 0.004).worldTwoClamped01
            updated.habitability = computeHabitability(updated)
            return updated
        }
    }

    func cell(at point: WorldTwoGridPoint) -> WorldTwoPlanetCell? {
        guard point.x >= 0, point.x < width, point.y >= 0, point.y < height else { return nil }
        return cells[point.y * width + point.x]
    }

    func neighbors(of point: WorldTwoGridPoint, radius: Int = 1) -> [WorldTwoPlanetCell] {
        var result: [WorldTwoPlanetCell] = []
        for dy in -radius...radius {
            for dx in -radius...radius where !(dx == 0 && dy == 0) {
                let nx = (point.x + dx + width) % width
                let ny = min(height - 1, max(0, point.y + dy))
                if let cell = cell(at: WorldTwoGridPoint(x: nx, y: ny)) { result.append(cell) }
            }
        }
        return result
    }

    func energyGradient(at point: WorldTwoGridPoint) -> Double {
        guard let center = cell(at: point) else { return 0 }
        let local = neighbors(of: point, radius: 1)
        guard !local.isEmpty else { return 0 }
        let average = local.map(\.energyField).reduce(0, +) / Double(local.count)
        return abs(center.energyField - average).worldTwoClamped01
    }

    private func makeCell(x: Int, y: Int, parameters: WorldTwoParameters) -> WorldTwoPlanetCell {
        let nx = Double(x) / Double(width)
        let ny = Double(y) / Double(height)
        let latitude = abs(ny - 0.5) * 2.0
        let terrain = ProceduralNoise.fractalNoise(x: nx * 5.0, y: ny * 5.0, seed: seed, octaves: 5)
        let water = max(0, parameters.waterLevel - terrain + ProceduralNoise.fractalNoise(x: nx * 9.0, y: ny * 9.0, seed: seed + 1) * 0.2).worldTwoClamped01
        let atmosphere = (parameters.atmosphereDensity * (1.0 - terrain * 0.25) + ProceduralNoise.fractalNoise(x: nx * 3.0, y: ny * 3.0, seed: seed + 2) * 0.12).worldTwoClamped01
        let temperature = (0.58 * parameters.solarIntensity - latitude * 0.54 - terrain * 0.14 + water * 0.08 + 0.25).worldTwoClamped01
        let energy = ProceduralNoise.fractalNoise(x: nx * 8.0, y: ny * 8.0, seed: seed + 3)
        let chemistry = ProceduralNoise.fractalNoise(x: nx * 7.0, y: ny * 7.0, seed: seed + 4)
        let uv = ((1.0 - atmosphere) * 0.8 + latitude * 0.2).worldTwoClamped01

        var cell = WorldTwoPlanetCell(
            coordinate: WorldTwoGridPoint(x: x, y: y),
            height: terrain,
            temperature: temperature,
            water: water,
            atmosphereDensity: atmosphere,
            energyField: energy,
            uvExposure: uv,
            chemicalGradient: chemistry,
            habitability: 0
        )
        cell.habitability = computeHabitability(cell)
        return cell
    }

    private func computeHabitability(_ cell: WorldTwoPlanetCell) -> Double {
        let tempScore = 1.0 - abs(cell.temperature - 0.56) / 0.56
        let waterScore = 1.0 - abs(cell.water - 0.55) / 0.55
        let atmosphereScore = 1.0 - abs(cell.atmosphereDensity - 0.72) / 0.72
        let uvScore = 1.0 - cell.uvExposure
        let energyScore = 1.0 - abs(cell.energyField - 0.62) / 0.62
        return (tempScore.worldTwoClamped01 * 0.22 + waterScore.worldTwoClamped01 * 0.20 + atmosphereScore.worldTwoClamped01 * 0.16 + uvScore.worldTwoClamped01 * 0.12 + cell.chemicalGradient.worldTwoClamped01 * 0.16 + energyScore.worldTwoClamped01 * 0.14).worldTwoClamped01
    }
}
