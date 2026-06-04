import Foundation

enum ProceduralNoise {
    static func clamp(_ value: Double, _ minValue: Double = 0, _ maxValue: Double = 1) -> Double {
        min(max(value, minValue), maxValue)
    }

    static func hashNoise(x: Int, y: Int, seed: Int) -> Double {
        let n = sin(Double(x) * 12.9898 + Double(y) * 78.233 + Double(seed) * 37.719) * 43758.5453
        return n - floor(n)
    }

    static func smoothNoise(x: Double, y: Double, seed: Int) -> Double {
        let xi = Int(floor(x))
        let yi = Int(floor(y))
        let xf = x - Double(xi)
        let yf = y - Double(yi)
        let a = hashNoise(x: xi, y: yi, seed: seed)
        let b = hashNoise(x: xi + 1, y: yi, seed: seed)
        let c = hashNoise(x: xi, y: yi + 1, seed: seed)
        let d = hashNoise(x: xi + 1, y: yi + 1, seed: seed)
        let u = xf * xf * (3 - 2 * xf)
        let v = yf * yf * (3 - 2 * yf)
        let ab = a + (b - a) * u
        let cd = c + (d - c) * u
        return ab + (cd - ab) * v
    }

    static func fractalNoise(x: Double, y: Double, seed: Int, octaves: Int = 4) -> Double {
        var amplitude = 1.0
        var frequency = 1.0
        var total = 0.0
        var normalizer = 0.0
        for octave in 0..<octaves {
            total += smoothNoise(x: x * frequency, y: y * frequency, seed: seed + octave * 97) * amplitude
            normalizer += amplitude
            amplitude *= 0.5
            frequency *= 2.0
        }
        return total / max(normalizer, 0.0001)
    }
}
