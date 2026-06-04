import Foundation

final class WorldTwoSparkEngine {
    private(set) var sparks: [WorldTwoSpark] = []
    private(set) var emergenceEvents: Int = 0

    func importSparks(_ imported: [WorldTwoSpark], emergenceEvents: Int = 0) {
        sparks = imported
        self.emergenceEvents = emergenceEvents
    }

    func seed(count: Int, in simulator: WorldTwoPlanetSimulator, parameters: WorldTwoParameters, rng: inout SeededRNG) {
        let candidates = Array(simulator.cells.sorted { $0.habitability > $1.habitability }.prefix(max(count * 4, count)))
        guard !candidates.isEmpty else { return }

        for _ in 0..<count {
            let cell = candidates[rng.nextInt(in: 0...(candidates.count - 1))]
            sparks.append(
                WorldTwoSpark(
                    position: cell.coordinate,
                    energySignature: rng.nextDouble(in: 0.35...0.75),
                    stability: rng.nextDouble(in: 0.35...0.7),
                    mutationRate: parameters.mutationRate,
                    memory: [],
                    environmentAffinity: rng.nextDouble(in: 0.25...0.75),
                    resonanceScore: 0,
                    groundedState: .searching,
                    age: 0
                )
            )
        }
    }

    func step(in simulator: WorldTwoPlanetSimulator, parameters: WorldTwoParameters, rng: inout SeededRNG, maxSparks: Int = 700) {
        var next: [WorldTwoSpark] = []
        var children: [WorldTwoSpark] = []

        for var spark in sparks where spark.isAlive {
            spark.age += 1
            move(&spark, simulator: simulator)
            updateEnergy(&spark, simulator: simulator)
            mutate(&spark, parameters: parameters, rng: &rng)
            adapt(&spark)
            updateState(&spark)

            if spark.stability < 0.035 || spark.energySignature < 0.015 || spark.age > 500 {
                spark.groundedState = .dead
            }

            if spark.isAlive {
                if let child = makeChildIfReady(spark, simulator: simulator, rng: &rng) {
                    children.append(child)
                    emergenceEvents += 1
                }
                next.append(spark)
            }
        }

        sparks = Array((next + children).prefix(maxSparks))
    }

    private func move(_ spark: inout WorldTwoSpark, simulator: WorldTwoPlanetSimulator) {
        let options = simulator.neighbors(of: spark.position, radius: 1)
        guard let selected = options.max(by: { moveScore($0, spark, simulator) < moveScore($1, spark, simulator) }) else { return }
        spark.position = selected.coordinate
    }

    private func moveScore(_ cell: WorldTwoPlanetCell, _ spark: WorldTwoSpark, _ simulator: WorldTwoPlanetSimulator) -> Double {
        let affinity = 1.0 - abs(cell.habitability - spark.environmentAffinity)
        let energyFit = 1.0 - abs(cell.energyField - spark.energySignature)
        let jitter = ProceduralNoise.hashNoise(x: cell.coordinate.x + spark.age, y: cell.coordinate.y + spark.generation, seed: simulator.seed) * 0.1
        return affinity * 0.35 + energyFit * 0.35 + simulator.energyGradient(at: cell.coordinate) * 0.2 + jitter
    }

    private func updateEnergy(_ spark: inout WorldTwoSpark, simulator: WorldTwoPlanetSimulator) {
        guard let cell = simulator.cell(at: spark.position) else { return }
        let energyFit = 1.0 - abs(cell.energyField - spark.energySignature)
        spark.stability = (spark.stability + energyFit * cell.habitability * 0.08 - cell.uvExposure * 0.035).worldTwoClamped01
        spark.resonanceScore = (energyFit * 0.4 + cell.habitability * 0.35 + cell.chemicalGradient * 0.25).worldTwoClamped01
        spark.memory.append(WorldTwoSparkMemoryItem(step: simulator.step, coordinate: spark.position, habitability: cell.habitability, energy: cell.energyField))
        if spark.memory.count > 16 { spark.memory.removeFirst() }
    }

    private func mutate(_ spark: inout WorldTwoSpark, parameters: WorldTwoParameters, rng: inout SeededRNG) {
        let rate = (spark.mutationRate + parameters.mutationRate) * 0.5
        guard rng.chance(rate) else { return }
        spark.energySignature = (spark.energySignature + rng.nextDouble(in: -0.08...0.08)).worldTwoClamped01
        spark.environmentAffinity = (spark.environmentAffinity + rng.nextDouble(in: -0.06...0.06)).worldTwoClamped01
        spark.stability = (spark.stability - rate * rng.nextDouble(in: 0.01...0.09)).worldTwoClamped01
        spark.mutationRate = (spark.mutationRate + rng.nextDouble(in: -0.01...0.01)).worldTwoClamped(0.005...0.35)
    }

    private func adapt(_ spark: inout WorldTwoSpark) {
        guard let recent = spark.memory.last else { return }
        spark.environmentAffinity = (spark.environmentAffinity + (recent.habitability - spark.environmentAffinity) * 0.025).worldTwoClamped01
        spark.energySignature = (spark.energySignature + (recent.energy - spark.energySignature) * 0.018).worldTwoClamped01
    }

    private func updateState(_ spark: inout WorldTwoSpark) {
        if spark.stability > 0.78 && spark.resonanceScore > 0.72 && spark.age > 8 {
            spark.groundedState = .grounded
        } else if spark.stability < 0.2 {
            spark.groundedState = .volatile
        } else {
            spark.groundedState = .searching
        }
    }

    private func makeChildIfReady(_ spark: WorldTwoSpark, simulator: WorldTwoPlanetSimulator, rng: inout SeededRNG) -> WorldTwoSpark? {
        guard spark.groundedState == .grounded, spark.stability > 0.9, spark.resonanceScore > 0.82, rng.chance(0.08) else { return nil }
        let target = simulator.neighbors(of: spark.position, radius: 2).max { $0.habitability < $1.habitability }?.coordinate ?? spark.position
        return WorldTwoSpark(parentID: spark.id, generation: spark.generation + 1, position: target, energySignature: (spark.energySignature + rng.nextDouble(in: -0.035...0.035)).worldTwoClamped01, stability: 0.52, mutationRate: spark.mutationRate, memory: [], environmentAffinity: spark.environmentAffinity, resonanceScore: 0, groundedState: .searching, age: 0)
    }
}
