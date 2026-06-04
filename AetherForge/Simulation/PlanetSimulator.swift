import Foundation

enum PlanetSimulator {
    static func makeWorld(
        name: String = "Aether-01",
        seed: Int = Int.random(in: 1...999_999),
        width: Int = 48,
        height: Int = 24,
        solarIntensity: Double = 0.72,
        waterLevel: Double = 0.54,
        atmosphereDensity: Double = 0.62
    ) -> WorldState {
        let cells = generateCells(
            width: width,
            height: height,
            seed: seed,
            solarIntensity: solarIntensity,
            waterLevel: waterLevel,
            atmosphereDensity: atmosphereDensity
        )
        var world = WorldState(
            name: name,
            seed: seed,
            rng: SeededRNG(seed: UInt64(seed)),
            width: width,
            height: height,
            solarIntensity: solarIntensity,
            waterLevel: waterLevel,
            atmosphereDensity: atmosphereDensity,
            cells: cells,
            sparks: [],
            hotspots: [],
            metrics: SimulationMetrics(),
            metricsHistory: [],
            stepIndex: 0
        )
        world.hotspots = ResonanceDetectorSwarm.scan(world: world)
        world.metrics = calculateMetrics(world)
        appendMetricsFrame(&world)
        return world
    }

    static func regenerateEnvironment(_ world: inout WorldState) {
        world.cells = generateCells(
            width: world.width,
            height: world.height,
            seed: world.seed,
            solarIntensity: world.solarIntensity,
            waterLevel: world.waterLevel,
            atmosphereDensity: world.atmosphereDensity
        )
        world.hotspots = ResonanceDetectorSwarm.scan(world: world)
        world.metrics = calculateMetrics(world)
        appendMetricsFrame(&world)
    }

    static func runStep(_ world: inout WorldState, maxSparkCount: Int) {
        world.stepIndex += 1
        diffuseChemistry(&world)
        SparkEmergenceEngine.step(world: &world, maxSparkCount: maxSparkCount)
        world.hotspots = ResonanceDetectorSwarm.scan(world: world)
        world.metrics = calculateMetrics(world)
        appendMetricsFrame(&world)
    }

    static func appendMetricsFrame(_ world: inout WorldState) {
        world.metricsHistory.append(MetricsFrame(stepIndex: world.stepIndex, metrics: world.metrics))
        if world.metricsHistory.count > 500 {
            world.metricsHistory.removeFirst(world.metricsHistory.count - 500)
        }
    }

    static func cellIndex(x: Int, y: Int, width: Int, height: Int) -> Int {
        let wrappedX = (x + width) % width
        let clampedY = min(max(y, 0), height - 1)
        return clampedY * width + wrappedX
    }

    static func cell(at position: GridPosition, in world: WorldState) -> PlanetCell {
        world.cells[cellIndex(x: position.x, y: position.y, width: world.width, height: world.height)]
    }

    static func neighbors(of position: GridPosition, in world: WorldState) -> [PlanetCell] {
        let offsets = [(-1,0), (1,0), (0,-1), (0,1), (-1,-1), (1,1), (-1,1), (1,-1)]
        return offsets.map {
            world.cells[cellIndex(x: position.x + $0.0, y: position.y + $0.1, width: world.width, height: world.height)]
        }
    }

    private static func generateCells(
        width: Int,
        height: Int,
        seed: Int,
        solarIntensity: Double,
        waterLevel: Double,
        atmosphereDensity: Double
    ) -> [PlanetCell] {
        var cells: [PlanetCell] = []
        cells.reserveCapacity(width * height)

        for y in 0..<height {
            for x in 0..<width {
                let nx = Double(x) / Double(width)
                let ny = Double(y) / Double(height)
                let latitude = abs((ny - 0.5) * 2.0)
                let continental = ProceduralNoise.fractalNoise(x: nx * 5.0, y: ny * 3.0, seed: seed, octaves: 5)
                let ridge = ProceduralNoise.fractalNoise(x: nx * 15.0, y: ny * 9.0, seed: seed + 400, octaves: 3)
                let terrainHeight = ProceduralNoise.clamp(continental * 0.78 + ridge * 0.22)
                let water = ProceduralNoise.clamp(waterLevel - terrainHeight * 0.58 + 0.22)
                let equatorHeat = 1.0 - latitude
                let temperature = ProceduralNoise.clamp(
                    solarIntensity * (0.25 + equatorHeat * 0.85) + atmosphereDensity * 0.18 - terrainHeight * 0.28 - water * 0.08
                )
                let energyNoise = ProceduralNoise.fractalNoise(x: nx * 8.0, y: ny * 8.0, seed: seed + 900, octaves: 4)
                let energyField = ProceduralNoise.clamp(energyNoise * 0.55 + solarIntensity * 0.32 + terrainHeight * 0.12 - water * 0.05)
                let uvExposure = ProceduralNoise.clamp(solarIntensity * (1.0 - atmosphereDensity * 0.76) * (0.7 + equatorHeat * 0.3))
                let chemicalNoise = ProceduralNoise.fractalNoise(x: nx * 10.0, y: ny * 10.0, seed: seed + 1700, octaves: 4)
                let chemicalGradient = ProceduralNoise.clamp(chemicalNoise * 0.55 + water * 0.22 + atmosphereDensity * 0.15 + terrainHeight * 0.08)
                let habitableTemp = 1.0 - abs(temperature - 0.55) / 0.55
                let habitableWater = 1.0 - abs(water - 0.45) / 0.55
                let habitableAtmosphere = 1.0 - abs(atmosphereDensity - 0.65) / 0.65
                let safeUV = 1.0 - uvExposure
                let habitabilityScore = ProceduralNoise.clamp(habitableTemp * 0.28 + habitableWater * 0.22 + habitableAtmosphere * 0.16 + safeUV * 0.17 + chemicalGradient * 0.17)

                cells.append(PlanetCell(
                    x: x,
                    y: y,
                    temperature: temperature,
                    water: water,
                    atmosphereDensity: atmosphereDensity,
                    terrainHeight: terrainHeight,
                    energyField: energyField,
                    uvExposure: uvExposure,
                    chemicalGradient: chemicalGradient,
                    habitabilityScore: habitabilityScore
                ))
            }
        }
        return cells
    }

    private static func diffuseChemistry(_ world: inout WorldState) {
        var updated = world.cells
        for cell in world.cells {
            let localNeighbors = neighbors(of: GridPosition(x: cell.x, y: cell.y), in: world)
            let averageChemical = localNeighbors.map(\.chemicalGradient).reduce(0, +) / Double(localNeighbors.count)
            let averageEnergy = localNeighbors.map(\.energyField).reduce(0, +) / Double(localNeighbors.count)
            let index = cellIndex(x: cell.x, y: cell.y, width: world.width, height: world.height)
            updated[index].chemicalGradient = ProceduralNoise.clamp(cell.chemicalGradient * 0.96 + averageChemical * 0.04)
            updated[index].energyField = ProceduralNoise.clamp(cell.energyField * 0.98 + averageEnergy * 0.02)
            updated[index].habitabilityScore = ProceduralNoise.clamp(updated[index].habitabilityScore * 0.94 + updated[index].chemicalGradient * 0.03 + (1.0 - updated[index].uvExposure) * 0.03)
        }
        world.cells = updated
    }

    static func calculateMetrics(_ world: WorldState) -> SimulationMetrics {
        guard !world.cells.isEmpty else { return SimulationMetrics() }
        let count = Double(world.cells.count)
        let averageTemperature = world.cells.map(\.temperature).reduce(0, +) / count
        let waterCoverage = Double(world.cells.filter { $0.water > 0.5 }.count) / count
        let habitabilityScore = world.cells.map(\.habitabilityScore).reduce(0, +) / count
        let groundedCount = world.sparks.filter { $0.groundedState == .grounded }.count
        let sparkDiversity = Set(world.sparks.map { Int($0.energySignature * 10) }).count
        let memoryMass = world.sparks.map { $0.memory.reduce(0, +) }.reduce(0, +)
        let complexityScore = ProceduralNoise.clamp(Double(sparkDiversity) / 10.0 * 0.35 + Double(world.sparks.count) / 450.0 * 0.35 + memoryMass / max(Double(world.sparks.count), 1.0) * 0.30)
        let entropyEstimate = estimateEntropy(world.cells.map(\.energyField))
        let emergenceEvents = world.hotspots.filter { $0.emergenceScore > 0.72 }.count + groundedCount
        return SimulationMetrics(
            averageTemperature: averageTemperature,
            waterCoverage: waterCoverage,
            habitabilityScore: habitabilityScore,
            sparkCount: world.sparks.count,
            groundedSparkCount: groundedCount,
            complexityScore: complexityScore,
            entropyEstimate: entropyEstimate,
            emergenceEvents: emergenceEvents
        )
    }

    static func estimateEntropy(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let bucketCount = 8
        var buckets = Array(repeating: 0.0, count: bucketCount)
        for value in values {
            let index = min(max(Int(value * Double(bucketCount)), 0), bucketCount - 1)
            buckets[index] += 1
        }
        let total = Double(values.count)
        let entropy = buckets.reduce(0.0) { partial, bucket in
            guard bucket > 0 else { return partial }
            let p = bucket / total
            return partial - p * log2(p)
        }
        return ProceduralNoise.clamp(entropy / log2(Double(bucketCount)))
    }
}
