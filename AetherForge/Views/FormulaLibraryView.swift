import SwiftUI

struct FormulaLibraryView: View {
    @EnvironmentObject private var model: AppModel
    @State private var searchText = ""
    @State private var selectedCategory: FormulaCategory?
    @State private var showFavoritesOnly = false

    private var filtered: [Formula] {
        model.formulas.filter { formula in
            let blob = [formula.title, formula.equationText, formula.explanation, formula.relatedConcepts.joined(separator: " ")].joined(separator: " ")
            let matchesSearch = searchText.isEmpty || blob.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil || formula.category == selectedCategory
            let matchesFavorite = !showFavoritesOnly || model.favoriteFormulaIDs.contains(formula.id)
            return matchesSearch && matchesCategory && matchesFavorite
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filters
                List(filtered) { formula in
                    FormulaRow(formula: formula, isFavorite: model.favoriteFormulaIDs.contains(formula.id)) {
                        model.toggleFavorite(formula)
                    }
                    .listRowBackground(AetherTheme.background)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(AetherTheme.background.ignoresSafeArea())
            .navigationTitle("Formulas")
            .searchable(text: $searchText, prompt: "Search formulas")
        }
    }

    private var filters: some View {
        VStack(spacing: 12) {
            Toggle("Favorites only", isOn: $showFavoritesOnly)
                .toggleStyle(.switch)
                .tint(AetherTheme.green)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Button("All") { selectedCategory = nil }
                        .buttonStyle(FilterButtonStyle(isSelected: selectedCategory == nil))
                    ForEach(FormulaCategory.allCases) { category in
                        Button(category.rawValue) { selectedCategory = category }
                            .buttonStyle(FilterButtonStyle(isSelected: selectedCategory == category))
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(AetherTheme.card.opacity(0.7))
    }
}

struct FormulaRow: View {
    let formula: Formula
    let isFavorite: Bool
    let onFavorite: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formula.title).font(.headline)
                    Text(formula.category.rawValue).font(.caption).foregroundStyle(AetherTheme.cyan)
                }
                Spacer()
                Button(action: onFavorite) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundStyle(isFavorite ? AetherTheme.warning : .secondary)
                }
                .buttonStyle(.plain)
            }
            Text(formula.equationText).font(.system(.body, design: .monospaced)).foregroundStyle(AetherTheme.green)
            Text(formula.explanation).font(.subheadline).foregroundStyle(.secondary)
            Text("Tip: \(formula.usageTip)").font(.caption).foregroundStyle(.secondary)
            HStack {
                Text(formula.difficulty.rawValue)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(AetherTheme.blue.opacity(0.22))
                    .clipShape(Capsule())
                ForEach(formula.relatedConcepts.prefix(3), id: \.self) { concept in
                    Text(concept)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(AetherTheme.green.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct FilterButtonStyle: ButtonStyle {
    let isSelected: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? AetherTheme.green.opacity(0.28) : AetherTheme.cardSecondary)
            .foregroundStyle(isSelected ? AetherTheme.green : .secondary)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
    }
}
