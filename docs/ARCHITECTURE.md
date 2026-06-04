# Architecture

```text
AetherForge/
├── AetherForgeApp.swift
├── Models/
│   └── AetherModels.swift
├── Data/
│   └── FormulaSeed.swift
├── Persistence/
│   └── LocalStore.swift
├── Simulation/
│   ├── SeededRNG.swift
│   ├── ProceduralNoise.swift
│   ├── PlanetSimulator.swift
│   ├── SparkEmergenceEngine.swift
│   └── ResonanceDetectorSwarm.swift
├── ViewModels/
│   └── AppModel.swift
└── Views/
    ├── Theme.swift
    ├── MainTabView.swift
    ├── LearnView.swift
    ├── FormulaLibraryView.swift
    ├── WorldView.swift
    ├── ResearchLabView.swift
    ├── MetricsDashboardView.swift
    ├── MetricsHistoryView.swift
    ├── PlanetRealityView.swift
    └── SettingsView.swift
```

## Data flow

`AppModel` owns the active `WorldState`, settings, favorites, camera controls, and selected cell.

`PlanetSimulator` creates and steps worlds.

`SparkEmergenceEngine` mutates and evolves Sparks using `WorldState.rng`.

`ResonanceDetectorSwarm` scans the current world for emergence hotspots.

`PlanetRealityView` renders a non-AR RealityKit planet scene using a dedicated `planetGroup`, so base planet, terrain, Sparks, and hotspots rotate together.

## Persistence

The current MVP uses local JSON files in the app Documents directory. SwiftData migration is planned after the source tree stabilizes.
