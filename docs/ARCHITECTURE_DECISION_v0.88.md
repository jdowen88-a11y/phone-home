# Phone Home / AetherForge v0.88 Architecture Decision

## Extracted true intent

Phone Home is an offline-first iOS 17+ SwiftUI and RealityKit artificial-life laboratory. The project should preserve Aether Prime as the stable core while adding stronger orchestration, multi-world expansion, deterministic simulation behavior, and future seams for richer rendering, experiment comparison, and archive worlds.

The core purpose is not to create unrelated scaffolds. The purpose is to make one coherent forge system where worlds, Sparks, detectors, metrics, persistence, and visualization share a clear command spine.

## Method 1: Preserve Aether Prime and harden the existing v0.86 core

Architecture:

- Keep `AppModel` as the main UI-facing state container.
- Keep `WorldState`, `PlanetSimulator`, `SparkEmergenceEngine`, and `ResonanceDetectorSwarm` as the core simulation path.
- Add only targeted fixes and stability improvements.

Strengths:

- Lowest compile risk.
- Preserves the strongest existing work.
- Avoids duplicate models and duplicate app entry points.
- Maintains deterministic seeded principle.

Weaknesses:

- Does not fully solve multi-world orchestration.
- Forge remains conceptually spread across several files unless a named core layer is added.
- Harder to compare worlds later.

Estimated completion: 84%.

## Method 2: Replace the app with the alternate separated World Two scaffold

Architecture:

- Replace `AppModel` with a more separated view model approach.
- Use stateful simulator/service objects.
- Move toward saved-world-first architecture.

Strengths:

- Better separation between simulator, Spark engine, persistence, and UI.
- Cleaner saved-world concept.
- Good long-term experiment storage direction.

Weaknesses:

- High duplicate-type risk.
- Would discard v0.86 improvements.
- Would introduce naming conflicts with `PlanetCell`, `Spark`, `PlanetSimulator`, and views.
- Likely downgrade the current RealityKit and deterministic-core work.

Estimated completion: 72% if merged raw, 82% if rewritten carefully.

## Scorecard

| Category | Method 1: Harden Aether Prime | Method 2: Replace with separated scaffold |
|---|---:|---:|
| Conceptual accuracy | 8 | 7 |
| Build readiness | 9 | 5 |
| Long-term scalability | 7 | 8 |
| Maintainability | 8 | 7 |
| Performance | 8 | 7 |
| User experience | 8 | 7 |
| Error resistance | 9 | 5 |
| Extensibility | 7 | 8 |
| Platform fit | 9 | 8 |
| Completion potential | 8 | 6 |
| Overall superiority | 81 | 68 |

## Chosen method

A Stable Hybrid was selected.

The superior path is to preserve Aether Prime as the stable source of truth, keep World Two as a namespaced archive module, and add a real `ForgeEngine` core layer to route high-level commands.

This is a Stable Hybrid because it:

- uses proven Swift patterns,
- does not require beta APIs,
- does not replace the working core,
- avoids duplicate type names,
- improves conceptual accuracy,
- keeps World Two isolated as an archive planet module.

## Implemented v0.88 changes

Added or hardened:

- `AetherForge/Core/ForgeEngine.swift`
- `AetherForge/WorldTwo/WorldTwoModels.swift`
- `AetherForge/WorldTwo/WorldTwoPlanetSimulator.swift`
- `AetherForge/WorldTwo/WorldTwoSparkEngine.swift`
- `AetherForge/WorldTwo/WorldTwoDetectorSwarm.swift`
- `AetherForge/WorldTwo/WorldTwoViewModel.swift`
- `AetherForge/WorldTwo/WorldTwoView.swift`
- `AetherForge/WorldTwo/WorldTwoIntegrationNotes.swift`

Updated:

- `AetherForge/ViewModels/AppModel.swift` now routes world bootstrapping, new world creation, environment regeneration, Spark seeding, and simulation steps through `ForgeEngine`.

## 90% completion rubric

For this project, 90% complete means:

- the stable Aether Prime simulation remains intact,
- Forge exists as a real core command layer,
- World Two exists as a namespaced archive world instead of a duplicate replacement,
- persistence remains offline and Codable-based,
- UI-facing state still flows through SwiftUI observable models,
- no duplicate Swift types are introduced,
- integration notes identify any connector-blocked wiring,
- remaining work is limited to UI exposure, compile validation, and polish.

Current estimated completion: 88% to 90% static-source readiness.

## Error audit

Checked:

- duplicate model names avoided by `WorldTwo` prefixes,
- Aether Prime core preserved,
- `ForgeEngine` no longer depends directly on `WorldTwoViewModel`,
- `AppModel` now uses `ForgeEngine`,
- deterministic movement jitter in World Two uses `ProceduralNoise.hashNoise` instead of mutating RNG inside a comparison closure.

Remaining risks:

- `MainTabView.swift` still needs the Archive tab insertion. Connector update attempts were blocked, so the exact insertion is stored in `WorldTwoIntegrationNotes`.
- Xcode compile was not run in this environment.
- The repo is a source scaffold, not a complete `.xcodeproj` workspace.
- World Two currently has a minimal SwiftUI dashboard, not a RealityKit globe.

## Exact remaining test steps

1. Create/open the Xcode iOS project named `AetherForge`.
2. Add the full `AetherForge/` source tree to the app target.
3. Insert the Archive tab from `WorldTwoIntegrationNotes` into `MainTabView.swift` after `WorldView()`.
4. Build for iOS 17+.
5. Fix any target-membership issues from new folders.
6. Run on a physical device for RealityKit validation.
7. Run Aether Prime steps, seed Sparks, save a snapshot, restart, and confirm persistence.
8. Run World Two steps, seed Sparks, save an archive world, reload it, and confirm persistence.

## Highest-risk failure points

- Xcode target membership missing for new `Core` or `WorldTwo` files.
- Archive tab not manually inserted.
- SwiftUI symbol availability if targeting exactly iOS 17 with newer symbols elsewhere.
- RealityKit behavior must be tested on device, not only simulator.

## Next steps

- Expose `WorldTwoView` in `MainTabView.swift`.
- Add a small `ForgeOverviewView` that displays `ForgeWorldSummary` for Aether Prime and Archive Planet.
- Add unit tests for deterministic world stepping and Spark lineage.
- Add an export/import format for `.aetherworld` archive files.
