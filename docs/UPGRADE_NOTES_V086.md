# AetherForge v0.86 Upgrade Notes

v0.86 exists because the safe v0.75 MVP was build-forward but not yet serious enough as a reproducible lab.

## Major changes

1. Added `SeededRNG.swift` using a SplitMix64-style deterministic generator.
2. Added `WorldState.rng` so simulation steps consume stored deterministic state.
3. Added `MetricsFrame` and `WorldState.metricsHistory` for time-series tracking.
4. Added Spark lineage fields: `parentID` and `generation`.
5. Reworked Spark mutation, seeding, and reproduction to use `world.rng` instead of unstable hash-derived randomness.
6. Reworked RealityKit scene hierarchy so terrain, Sparks, and hotspots rotate with the planet as one `planetGroup`.

## Known remaining limitation

Tap selection still uses screen-space normalized coordinates. True planet picking requires ray/sphere math or collision-based picking and is planned for v0.90.

## Important reproducibility note

New-world creation can still choose a random seed. Once the world exists, internal simulation stepping is deterministic from the stored RNG state.
