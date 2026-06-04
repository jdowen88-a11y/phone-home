# Phone Home — AetherForge v0.86

Offline-first iOS 17+ SwiftUI/RealityKit artificial-life and emergence laboratory.

AetherForge v0.86 upgrades the original MVP by adding deterministic seeded simulation, Spark lineage tracking, metric history frames, stronger RealityKit scene organization, and a roadmap toward true 3D picking, mesh terrain, and experiment comparison.

## Build target

- Xcode
- iOS 17.0+
- SwiftUI
- RealityKit
- UIKit
- Foundation
- simd

## Project layout

```text
AetherForge/
├── AetherForgeApp.swift
├── Models/
├── Data/
├── Persistence/
├── Simulation/
├── ViewModels/
└── Views/
docs/
```

## Status

This repository is seeded as a build-forward MVP scaffold. Create a new iOS SwiftUI project named `AetherForge`, then copy the `AetherForge/` source tree into the Xcode project target.

## Core v0.86 principle

Same seed + same parameters + same steps should produce the same simulation path.
