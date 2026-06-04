import Foundation

enum FormulaSeed {
    static func f(
        _ id: String,
        _ title: String,
        _ category: FormulaCategory,
        _ difficulty: FormulaDifficulty,
        _ equation: String,
        _ explanation: String,
        _ usage: String,
        _ related: [String]
    ) -> Formula {
        Formula(id: id, title: title, category: category, difficulty: difficulty, equationText: equation, explanation: explanation, usageTip: usage, relatedConcepts: related)
    }

    static let all: [Formula] = [
        f("pc001", "Speed of Light", .physicalConstants, .beginner, "c = 299,792,458 m/s", "The invariant propagation speed of light in vacuum.", "Use as the conversion bridge between mass and energy.", ["Relativity", "Photons"]),
        f("pc002", "Planck Constant", .physicalConstants, .beginner, "h = 6.62607015e-34 J s", "Relates photon energy to frequency.", "Use when converting oscillation frequency into quantum energy.", ["Photon Energy", "Quantum Scale"]),
        f("pc003", "Reduced Planck Constant", .physicalConstants, .beginner, "ℏ = h / 2π", "Angular-momentum form of Planck constant.", "Use in Schrödinger and commutator equations.", ["Angular Momentum", "Wavefunctions"]),
        f("pc004", "Gravitational Constant", .physicalConstants, .beginner, "G = 6.67430e-11 N m²/kg²", "Sets gravitational attraction strength.", "Use for simplified orbital or planetary mass calculations.", ["Gravity", "Planet Mass"]),
        f("pc005", "Boltzmann Constant", .physicalConstants, .intermediate, "kB = 1.380649e-23 J/K", "Links temperature and microscopic energy.", "Use to estimate thermal noise or entropy.", ["Entropy", "Thermodynamics"]),
        f("pc006", "Photon Energy", .physicalConstants, .beginner, "E = h f", "Energy grows linearly with frequency.", "Use for radiation and UV exposure intuition.", ["Frequency", "Radiation"]),
        f("qf001", "Schrödinger Equation", .quantumFoundations, .advanced, "iℏ ∂ψ/∂t = Hψ", "Describes quantum state evolution.", "Use as the core mental model for state dynamics.", ["Hamiltonian", "Wavefunction"]),
        f("qf002", "Born Rule", .quantumFoundations, .beginner, "P(x) = |ψ(x)|²", "Probability is squared amplitude.", "Use when interpreting simulated resonance likelihood.", ["Measurement", "Probability"]),
        f("qf003", "Normalization", .quantumFoundations, .beginner, "∫ |ψ(x)|² dx = 1", "Total probability must equal one.", "Use when keeping distributions stable.", ["Probability", "State Vector"]),
        f("qf004", "Heisenberg Uncertainty", .quantumFoundations, .intermediate, "Δx Δp ≥ ℏ / 2", "Position and momentum precision trade off.", "Use as a model for constrained observation.", ["Measurement", "Momentum"]),
        f("qf005", "Density Matrix", .quantumFoundations, .advanced, "ρ = Σ pᵢ |ψᵢ⟩⟨ψᵢ|", "Represents mixed quantum states.", "Use for noisy or partially known systems.", ["Mixed States", "Noise"]),
        f("qg001", "Pauli-X Gate", .quantumGates, .beginner, "X|0⟩ = |1⟩, X|1⟩ = |0⟩", "Quantum bit flip.", "Use as the simplest binary inversion.", ["Qubit", "Bit Flip"]),
        f("qg002", "Pauli-Z Gate", .quantumGates, .beginner, "Z|1⟩ = -|1⟩", "Phase flip gate.", "Use for sign inversion in superposition.", ["Phase Flip", "Qubit"]),
        f("qg003", "Hadamard Gate", .quantumGates, .beginner, "H|0⟩ = (|0⟩ + |1⟩)/√2", "Creates equal superposition.", "Use as the entry point to quantum parallelism.", ["Superposition", "Interference"]),
        f("qg004", "CNOT Gate", .quantumGates, .intermediate, "CNOT|a,b⟩ = |a,b⊕a⟩", "Controlled bit flip.", "Use to create entanglement.", ["Entanglement", "Control"]),
        f("qa001", "Grover Iteration", .quantumAlgorithms, .advanced, "G = D O", "Oracle marking followed by diffusion amplification.", "Use for search amplification intuition.", ["Search", "Amplitude"]),
        f("qa002", "Grover Speedup", .quantumAlgorithms, .intermediate, "O(√N)", "Unstructured search requires about square-root queries.", "Use when comparing quantum vs classical search.", ["Complexity", "Search"]),
        f("qa003", "Quantum Fourier Transform", .quantumAlgorithms, .advanced, "|x⟩ → 1/√N Σy e^(2πixy/N)|y⟩", "Maps values into frequency-like phase structure.", "Use for periodicity detection.", ["Fourier", "Periodicity"]),
        f("qa004", "Phase Estimation", .quantumAlgorithms, .advanced, "U|ψ⟩ = e^(2πiφ)|ψ⟩", "Estimates eigenphase of a unitary.", "Use as a model for resonance frequency detection.", ["Eigenvalues", "Phase"]),
        f("qe001", "Three-Qubit Bit Flip Code", .quantumErrorCorrection, .intermediate, "|0⟩ → |000⟩", "Redundant encoding corrects one bit flip.", "Use to explain resilience by replication.", ["Redundancy", "Correction"]),
        f("qe002", "Syndrome Measurement", .quantumErrorCorrection, .intermediate, "s = H e", "Error signatures identify correction actions.", "Use for detector diagnostics.", ["Errors", "Parity"]),
        f("qe003", "Surface Code Distance", .quantumErrorCorrection, .advanced, "logical error ≈ exp(-αd)", "Larger code distance suppresses logical errors.", "Use for stability scaling intuition.", ["Surface Code", "Threshold"]),
        f("cr001", "RSA Modulus", .cryptography, .intermediate, "N = p q", "RSA security relies on difficulty of factoring N.", "Use for classical public-key context.", ["RSA", "Factoring"]),
        f("cr002", "Diffie-Hellman Exchange", .cryptography, .intermediate, "K = g^(ab) mod p", "Two parties derive a shared secret publicly.", "Use for key exchange intuition.", ["Key Exchange", "Discrete Log"]),
        f("cr003", "HMAC", .cryptography, .intermediate, "HMAC = H((K⊕opad)||H((K⊕ipad)||m))", "Keyed hash authentication.", "Use for tamper-resistant local records.", ["Authentication", "Hashing"]),
        f("cr004", "Merkle Root", .cryptography, .intermediate, "root = H(left || right)", "Tree commitment summarizes many records.", "Use for snapshot integrity chains.", ["Merkle Tree", "Integrity"]),
        f("em001", "Logistic Growth", .emergenceMathematics, .beginner, "dx/dt = r x(1 - x/K)", "Growth slows near carrying capacity.", "Use for spark population control.", ["Population", "Capacity"]),
        f("em002", "Entropy", .emergenceMathematics, .beginner, "H = -Σ pᵢ log pᵢ", "Measures uncertainty or spread.", "Use for detector low-entropy scoring.", ["Information", "Disorder"]),
        f("em003", "Reaction Diffusion", .emergenceMathematics, .advanced, "∂u/∂t = Du∇²u + f(u,v)", "Diffusion and reaction generate spatial patterns.", "Use for chemical gradient evolution.", ["Patterns", "Chemistry"]),
        f("em004", "Complexity Estimate", .emergenceMathematics, .intermediate, "C ≈ diversity × interaction × memory", "Practical synthetic measure for emergent richness.", "Use for MVP metrics.", ["Complexity", "Agents"]),
        f("em005", "Resonance Score", .emergenceMathematics, .intermediate, "R = coherence × stability × affinity", "Synthetic measure of alignment.", "Use to detect grounded sparks.", ["Coherence", "Stability"]),
        f("em006", "Emergence Threshold", .emergenceMathematics, .intermediate, "event if R > τ and H < η", "Emergence appears when resonance is high and entropy is low.", "Use for event triggering.", ["Thresholds", "Events"])
    ]
}
