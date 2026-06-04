import SwiftUI
import RealityKit
import UIKit
import simd

struct PlanetRealityView: View {
    @EnvironmentObject private var model: AppModel
    @State private var previousDrag: CGSize = .zero

    var body: some View {
        RealityPlanetContainer()
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let dx = value.translation.width - previousDrag.width
                        let dy = value.translation.height - previousDrag.height
                        previousDrag = value.translation
                        model.cameraYaw += Double(dx) * 0.008
                        model.cameraPitch = min(max(model.cameraPitch + Double(dy) * 0.004, -0.9), 0.9)
                    }
                    .onEnded { _ in previousDrag = .zero }
            )
    }
}

struct RealityPlanetContainer: UIViewRepresentable {
    @EnvironmentObject private var model: AppModel

    func makeCoordinator() -> Coordinator {
        Coordinator(model: model)
    }

    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        view.environment.background = .color(.black)
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tap)
        context.coordinator.installScene(in: view)
        return view
    }

    func updateUIView(_ view: ARView, context: Context) {
        context.coordinator.model = model
        context.coordinator.updateScene(in: view)
    }

    final class Coordinator: NSObject {
        var model: AppModel
        private var rootAnchor = AnchorEntity(world: .zero)
        private var planetGroup = Entity()
        private var lastStep = -1
        private var lastSparkCount = -1
        private var lastHotspotCount = -1
        private var lastSeed = -1

        init(model: AppModel) {
            self.model = model
        }

        func installScene(in view: ARView) {
            view.scene.anchors.removeAll()
            rootAnchor = AnchorEntity(world: .zero)
            view.scene.addAnchor(rootAnchor)

            let light = DirectionalLight()
            light.light.intensity = 1800
            light.position = SIMD3<Float>(1.5, 2.0, 2.0)
            light.look(at: .zero, from: light.position, relativeTo: nil)
            rootAnchor.addChild(light)

            let camera = PerspectiveCamera()
            camera.name = "camera"
            rootAnchor.addChild(camera)

            planetGroup = Entity()
            planetGroup.name = "planetGroup"
            rootAnchor.addChild(planetGroup)

            rebuildPlanet()
            updateCamera()
        }

        func updateScene(in view: ARView) {
            if rootAnchor.scene == nil {
                installScene(in: view)
            }

            if lastStep != model.world.stepIndex || lastSparkCount != model.world.sparks.count || lastHotspotCount != model.world.hotspots.count || lastSeed != model.world.seed {
                rebuildPlanet()
            }

            updateCamera()
        }

        private func rebuildPlanet() {
            planetGroup.children.removeAll()
            addBasePlanet()
            addTerrainTiles()
            if model.settings.showSparkMarkers { addSparkMarkers() }
            if model.settings.showHotspots { addHotspotMarkers() }
            lastStep = model.world.stepIndex
            lastSparkCount = model.world.sparks.count
            lastHotspotCount = model.world.hotspots.count
            lastSeed = model.world.seed
        }

        private func addBasePlanet() {
            let mesh = MeshResource.generateSphere(radius: 1.0)
            var material = PhysicallyBasedMaterial()
            material.baseColor = .init(tint: UIColor(red: 0.02, green: 0.08, blue: 0.10, alpha: 1))
            material.roughness = 0.85
            let planet = ModelEntity(mesh: mesh, materials: [material])
            planet.name = "planet"
            planetGroup.addChild(planet)
        }

        private func addTerrainTiles() {
            let stride = max(model.world.width / 24, 1)
            for cell in model.world.cells where cell.x % stride == 0 && cell.y % stride == 0 {
                let position = spherePosition(x: cell.x, y: cell.y, width: model.world.width, height: model.world.height, radius: 1.012 + Float(cell.terrainHeight) * 0.035)
                let mesh = MeshResource.generateSphere(radius: 0.018 + Float(cell.habitabilityScore) * 0.01)
                var material = UnlitMaterial()
                material.color = .init(tint: terrainColor(cell))
                let tile = ModelEntity(mesh: mesh, materials: [material])
                tile.position = position
                tile.name = "cell-\(cell.x)-\(cell.y)"
                planetGroup.addChild(tile)
            }
        }

        private func addSparkMarkers() {
            for spark in model.world.sparks.prefix(240) {
                let position = spherePosition(x: spark.position.x, y: spark.position.y, width: model.world.width, height: model.world.height, radius: spark.groundedState == .grounded ? 1.12 : 1.08)
                let mesh = MeshResource.generateSphere(radius: spark.groundedState == .grounded ? 0.026 : 0.018)
                var material = UnlitMaterial()
                material.color = .init(tint: spark.groundedState == .grounded ? UIColor.systemGreen : UIColor.cyan)
                let marker = ModelEntity(mesh: mesh, materials: [material])
                marker.position = position
                marker.name = "spark"
                planetGroup.addChild(marker)
            }
        }

        private func addHotspotMarkers() {
            for hotspot in model.world.hotspots.prefix(24) {
                let position = spherePosition(x: hotspot.position.x, y: hotspot.position.y, width: model.world.width, height: model.world.height, radius: 1.17)
                let mesh = MeshResource.generateSphere(radius: 0.022 + Float(hotspot.emergenceScore) * 0.018)
                var material = UnlitMaterial()
                material.color = .init(tint: UIColor.systemYellow.withAlphaComponent(0.95))
                let marker = ModelEntity(mesh: mesh, materials: [material])
                marker.position = position
                marker.name = "hotspot"
                planetGroup.addChild(marker)
            }
        }

        private func updateCamera() {
            guard let camera = rootAnchor.findEntity(named: "camera") else { return }
            let radius: Float = 3.1
            let yaw = Float(model.cameraYaw)
            let pitch = Float(model.cameraPitch)
            let x = radius * sin(yaw) * cos(pitch)
            let y = radius * sin(pitch)
            let z = radius * cos(yaw) * cos(pitch)
            camera.look(at: .zero, from: SIMD3<Float>(x, y, z), relativeTo: nil)

            if model.settings.autoRotatePlanet {
                planetGroup.transform.rotation *= simd_quatf(angle: 0.006, axis: SIMD3<Float>(0, 1, 0))
            }
        }

        private func spherePosition(x: Int, y: Int, width: Int, height: Int, radius: Float) -> SIMD3<Float> {
            let u = Float(x) / Float(width)
            let v = Float(y) / Float(height)
            let longitude = u * Float.pi * 2.0
            let latitude = (v - 0.5) * Float.pi
            return SIMD3<Float>(radius * cos(latitude) * sin(longitude), radius * sin(latitude), radius * cos(latitude) * cos(longitude))
        }

        private func terrainColor(_ cell: PlanetCell) -> UIColor {
            if cell.water > 0.56 {
                return UIColor(red: 0.02, green: 0.18 + cell.water * 0.20, blue: 0.42 + cell.water * 0.42, alpha: 1)
            }
            if cell.habitabilityScore > 0.62 {
                return UIColor(red: 0.08, green: 0.42 + cell.habitabilityScore * 0.35, blue: 0.20, alpha: 1)
            }
            if cell.terrainHeight > 0.72 {
                return UIColor(red: 0.55, green: 0.52, blue: 0.47, alpha: 1)
            }
            return UIColor(red: 0.22 + cell.terrainHeight * 0.25, green: 0.18 + cell.chemicalGradient * 0.25, blue: 0.10, alpha: 1)
        }

        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let view = recognizer.view else { return }
            let point = recognizer.location(in: view)
            let longitude = point.x / max(view.bounds.width, 1)
            let latitude = point.y / max(view.bounds.height, 1)
            model.selectedCell = model.cellAtNormalized(longitude: longitude, latitude: latitude)
        }
    }
}
