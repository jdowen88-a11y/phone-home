import SwiftUI

enum AetherTheme {
    static let background = Color(red: 0.02, green: 0.04, blue: 0.07)
    static let card = Color(red: 0.06, green: 0.10, blue: 0.14)
    static let cardSecondary = Color(red: 0.08, green: 0.14, blue: 0.18)
    static let cyan = Color(red: 0.15, green: 0.85, blue: 1.0)
    static let green = Color(red: 0.35, green: 1.0, blue: 0.58)
    static let blue = Color(red: 0.25, green: 0.45, blue: 1.0)
    static let warning = Color(red: 1.0, green: 0.72, blue: 0.25)
}

struct AetherCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AetherTheme.card)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(AetherTheme.cyan.opacity(0.16), lineWidth: 1))
            )
            .shadow(color: AetherTheme.cyan.opacity(0.08), radius: 12, x: 0, y: 8)
    }
}

extension View {
    func aetherCard() -> some View { modifier(AetherCard()) }
}

extension Double {
    var percent: String { "\(Int((self * 100).rounded()))%" }
    var fixed2: String { String(format: "%.2f", self) }
}

struct MetricPill: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.headline.monospacedDigit()).foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .aetherCard()
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AetherTheme.green.opacity(configuration.isPressed ? 0.22 : 0.34))
            .foregroundStyle(AetherTheme.green)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AetherTheme.cardSecondary.opacity(configuration.isPressed ? 0.7 : 1.0))
            .foregroundStyle(AetherTheme.cyan)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
