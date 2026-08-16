import SwiftUI
import DiscoveryCore

private struct TasteRow: Identifiable {
    let name: String
    let value: Double
    var id: String { name }
}

struct MeView: View {
    @EnvironmentObject var app: AppEnvironment

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    tasteSection("Genres", values: app.profile.genreAffinity)
                    tasteSection("Artists", values: app.profile.artistAffinity)

                    HStack(spacing: 12) {
                        statCard("Novelty tolerance", value: app.profile.noveltyTolerance)
                        statCard("Exploration", value: app.profile.explorationTendency)
                    }

                    Button {
                        app.profile = UserProfile()
                    } label: {
                        Label("Reset profile", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(DriftTheme.surface, in: RoundedRectangle(cornerRadius: 14))
                            .foregroundStyle(DriftTheme.accentWarm)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
            }
            rows = values.sorted { $0.value > $1.value }.prefix(6)
            .map { TasteRow(name: $0.key, value: $0.value) }
        return VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            ForEach(rows) { row in
                TasteBar(name: row.name, value: row
    private func tasteSection(_ title: String, values: [String: Double]) -> some View {
        let sorted = values.sorted { $0.value > $1.value }.prefix(6)
        return VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            ForEach(Array(sorted), id: \.key) { item in
                TasteBar(name: item.key, value: item.value)
            }
        }
    }

    private func statCard(_ title: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(DriftTheme.textSecondary)
            Text("\(Int(value * 100))%")
                .font(.title2).fontWeight(.bold)
                .foregroundStyle(DriftTheme.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(DriftTheme.surface, in: RoundedRectangle(cornerRadius: 14))
    }
}
