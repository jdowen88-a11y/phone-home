import Foundation

enum SparkEmergenceEngine {
    static func seedSparks(in world: inout WorldState, count: Int, baseMutationRate: Double) {
        let candidates = world.cells
            .filter { $0.habitabilityScore > 0.46 && $0.energyField > 0.35 }
            .sorted { $0.habitabilityScore + $0.energyField > $1.habitabilityScore + $1.energyField }

        guard !candidates.isEmpty else { return }

        for _ in 0..<count {
            let index = world.rng.nextInt(in: 0...(candidates.count - 1))
            let cell = candidates[index]
            world.sparks.append(
                Spark(
                    parentID: nil,
                    generation: 0,
                    position: GridPosition(x: cell.x, y: cell.y),
                    energySignature: world.rng.nextDouble(),
                    stability: 0.42 + cell.habitabilityScore * 0.32,
                    mutationRate: baseMutationRate,
                    memory: [cell.energyField, cell.chemicalGradient],
                    environmentAffinity: 0.4 + cell.habitabilityScore * 0.4,
                    resonanceScore: 0.2,
                    groundedState: .drifting
                )
            )
        }
    }

    static func step(world: inout WorldState, maxSparkCount: Int) {
        var nextSparks: [Spark] = []
        nextSparks.reserveCapacity(min(maxSparkCount, world.sparks.count * 2 + 8))

        for var spark in world.sparks {
            move(&spark, in: world)
            absorbEnergy(&spark, in: world)
            adapt(&spark, in: world)
            mutate(&spark, rng: &world.rng)

            guard spark.stability > 0.05 else { continue }
            guard spark.groundedState != .unstable else { continue }

            if spark.stability > 0.78 && spark.resonanceScore > 0.58 {
                spark.groundedState = .grounded
            } else if spark.stability > 0.45 {
                spark.groundedState = .adapting
            } else {
                spark.groundedState = .drifting
            }

            nextSparks.append(spark)

            if shouldReproduce(spark, rng: &world.rng), nextSparks.count < maxSparkCount {
                nextSparks.append(makeChild(from: spark, world: world, rng: &world.rng))
            }
        }

        if nextSparks.count > maxSparkCount {
            nextSparks = Array(
                nextSparks
                    .sorted { $0.stability + $0.resonanceScore > $1.stability + $1.resonanceScore }
                    .prefix(maxSparkCount)
            )
        }

        world.sparks = nextSparks
    }

    private static func move(_ spark: inout Spark, in world: WorldState) {
        let neighbors = PlanetSimulator.neighbors(of: spark.position, in: world)
        if let best = neighbors.max(by: { movementScore($0, spark: spark) < movementScore($1, spark: spark) }) {
            spark.position = GridPosition(x: best.x, y: best.y)
        }
    }

    private static func movementScore(_ cell: PlanetCell, spark: Spark) -> Double {
        let energyMatch = 1.0 - abs(cell.energyField - spark.energySignature)
        let safety = 1.0 - cell.uvExposure
        return cell.habitabilityScore * 0.38 + cell.energyField * 0.22 + cell.chemicalGradient * 0.17 + energyMatch * 0.16 + safety * 0.07
    }

    private static func absorbEnergy(_ spark: inout Spark, in world: WorldState) {
        let cell = PlanetSimulator.cell(at: spark.position, in: world)
        let energyMatch = 1.0 - abs(cell.energyField - spark.energySignature)
        let environmentalFit = 1.0 - abs(cell.habitabilityScore - spark.environmentAffinity)
        let gain = cell.energyField * 0.055 + energyMatch * 0.035 + environmentalFit * 0.025
        let stress = cell.uvExposure * 0.06 + abs(cell.temperature - 0.55) * 0.035
        spark.stability = ProceduralNoise.clamp(spark.stability + gain - stress, 0, 1.35)
        spark.resonanceScore = ProceduralNoise.clamp(energyMatch * 0.35 + environmentalFit * 0.25 + cell.chemicalGradient * 0.20 + spark.stability * 0.20)
        spark.memory.append(cell.habitabilityScore)
        if spark.memory.count > 12 { spark.memory.removeFirst() }
    }

    private static func adapt(_ spark: inout Spark, in world: WorldState) {
        let cell = PlanetSimulator.cell(at: spark.position, in: world)
        let learningRate = 0.035
        let reward = cell.habitabilityScore * 0.55 + cell.energyField * 0.25 + cell.chemicalGradient * 0.20
        let error = reward - spark.environmentAffinity
        spark.environmentAffinity = ProceduralNoise.clamp(spark.environmentAffinity + learningRate * error)
        spark.energySignature = ProceduralNoise.clamp(spark.energySignature * 0.985 + cell.energyField * 0.015)
    }

    private static func mutate(_ spark: inout Spark, rng: inout SeededRNG) {
        let noise = rng.nextDouble(in: -0.5...0.5)
        spark.energySignature = ProceduralNoise.clamp(spark.energySignature + noise * spark.mutationRate * 0.18)
        spark.environmentAffinity = ProceduralNoise.clamp(spark.environmentAffinity + noise * spark.mutationRate * 0.12)
        spark.stability = ProceduralNoise.clamp(spark.stability - abs(noise) * spark.mutationRate * 0.055, 0, 1.35)
        if spark.stability < 0.12 && spark.mutationRate > 0.28 {
            spark.groundedState = .unstable
        }
    }

    private static func shouldReproduce(_ spark: Spark, rng: inout SeededRNG) -> Bool {
        guard spark.stability > 1.03 else { return false }
        guard spark.resonanceScore > 0.68 else { return false }
        return rng.nextDouble() > 0.82
    }

    private static func makeChild(from parent: Spark, world: WorldState, rng: inout SeededRNG) -> Spark {
        var child = parent
        child.id = UUID()
        child.parentID = parent.id
        child.generation = parent.generation + 1
        child.stability = parent.stability * 0.54
        child.mutationRate = ProceduralNoise.clamp(parent.mutationRate * rng.nextDouble(in: 0.98...1.06), 0.01, 0.5)
        child.groundedState = .drifting
        let options = PlanetSimulator.neighbors(of: parent.position, in: world)
        if let destination = options.max(by: { $0.habitabilityScore < $1.habitabilityScore }) {
            child.position = GridPosition(x: destination.x, y: destination.y)
        }
        return child
    }
}
