import SwiftUI
import DiscoveryCore

struct SearchView: View {
    @State private var query = ""

    private var results: [Track] {
        guard !query.isEmpty else { return MockData.tracks }
        return MockData.tracks.filter {
            $0.title.localizedCaseInsensitiveContains(query)
            || $0.artistName.localizedCaseInsensitiveContains(query)
            || $0.genres.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    var body: some View {
        NavigationStack {
            List(results) { track in
                HStack(spacing: 12) {
                    AlbumArt(track: track, size: 48)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.title).font(.subheadline).fontWeight(.semibold)
                        Text(track.artistName).font(.caption).foregroundStyle(DriftTheme.textSecondary)
                    }
                }
                .listRowBackground(DriftTheme.surface)
            }
            .scrollContentBackground(.hidden)
            .background(DriftTheme.background)
            .searchable(text: $query, prompt: "Artists, tracks, genres")
            .navigationTitle("Search")
        }
    }
}
