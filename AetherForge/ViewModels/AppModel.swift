import Foundation
import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published var formulas: [Formula] = FormulaSeed.all
    @Published var favoriteFormulaIDs: Set<String> = []
    @Published var world: WorldState
    @Published var settings: UserSettings
    @Published var selectedCell: PlanetCell?
    @Published var mutationRate: Double = 0.08
    @Published var cameraYaw: Double = 0
    @Published var cameraPitch: Double = 0.15

    private let favoritesFile = "aetherforge-favorites.json"
    private let settingsFile = "aetherforge-settings.json"
    private let snapshotFile = "aetherforge-latest-world.json"

    init() {
        let loadedSettings = LocalStore.load(UserSettings.self, from: settingsFile) ?? UserSettings()
        let loadedFavorites = LocalStore.load(Set<String>.self, from: favoritesFile) ?? []
        var loadedWorld = LocalStore.load(WorldState.self, from: snapshotFile) ?? PlanetSimulator.makeWorld()
        loadedWorld.hotspots = ResonanceDetectorSwarm.scan(world: loadedWorld)
        loadedWorld.metrics = PlanetSimulator.calculateMetrics(loadedWorld)
        if loadedWorld.metricsHistory.isEmpty {
            PlanetSimulator.appendMetricsFrame(&loadedWorld)
        }
        settings = loadedSettings
        favoriteFormulaIDs = loadedFavorites
        world = loadedWorld
    }

    func toggleFavorite(_ formula: Formula) {
        if favoriteFormulaIDs.contains(formula.id) {
            favoriteFormulaIDs.remove(formula.id)
        } else {
            favoriteFormulaIDs.insert(formula.id)
        }
        LocalStore.save(favoriteFormulaIDs, as: favoritesFile)
    }

    func newWorld() {
        let seed = Int.random(in: 1...999999)
        world = PlanetSimulator.makeWorld(
            name: "Aether-\(Int.random(in: 10...99))",
            seed: seed,
            solarIntensity: world.solarIntensity,
            waterLevel: world.waterLevel,
            atmosphereDensity: world.atmosphereDensity
        )
        saveSnapshot()
    }

    func regenerateEnvironment() {
        PlanetSimulator.regenerateEnvironment(&world)
        saveSnapshot()
    }

    func seedSparks(count: Int = 24) {
        SparkEmergenceEngine.seedSparks(in: &world, count: count, baseMutationRate: mutationRate)
        world.hotspots = ResonanceDetectorSwarm.scan(world: world)
        world.metrics = PlanetSimulator.calculateMetrics(world)
        PlanetSimulator.appendMetricsFrame(&world)
        saveSnapshot()
    }

    func runSteps(_ count: Int) {
        for _ in 0..<count {
            PlanetSimulator.runStep(&world, maxSparkCount: settings.maxSparkCount)
        }
        saveSnapshot()
    }

    func updateSimulationParameters(solarIntensity: Double? = nil, waterLevel: Double? = nil, atmosphereDensity: Double? = nil) {
        if let solarIntensity { world.solarIntensity = solarIntensity }
        if let waterLevel { world.waterLevel = waterLevel }
        if let atmosphereDensity { world.atmosphereDensity = atmosphereDensity }
        PlanetSimulator.regenerateEnvironment(&world)
        saveSnapshot()
    }

    func saveSnapshot() {
        LocalStore.save(world, as: snapshotFile)
    }

    func saveSettings() {
        LocalStore.save(settings, as: settingsFile)
    }

    func cellAtNormalized(longitude: Double, latitude: Double) -> PlanetCell? {
        let x = min(max(Int(longitude * Double(world.width)), 0), world.width - 1)
        let y = min(max(Int(latitude * Double(world.height)), 0), world.height - 1)
        let index = PlanetSimulator.cellIndex(x: x, y: y, width: world.width, height: world.height)
        return world.cells[index]
    }
}
