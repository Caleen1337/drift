import SwiftUI
import DiscoveryCore

struct RootTabView: View {
    @EnvironmentObject var app: AppEnvironment
    @State private var showPlayer = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                DiscoverView()
                    .tabItem { Label("Discover", systemImage: "sparkles") }
                SearchView()
                    .tabItem { Label("Search", systemImage: "magnifyingglass") }
                LibraryView()
                    .tabItem { Label("Library", systemImage: "books.vertical") }
                MeView()
                    .tabItem { Label("Me", systemImage: "person.crop.circle") }
            }
            .tint(DriftTheme.accent)

            if let rec = app.current {
                MiniPlayerBar(recommendation: rec) {
                    showPlayer = true
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 6)
            }
        }
        .background(DriftTheme.background.ignoresSafeArea())
        .sheet(isPresented: $showPlayer) {
            PlayerView()
                .environmentObject(app)
        }
    }
}

private struct MiniPlayerBar: View {
    let recommendation: Recommendation
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                AlbumArt(track: recommendation.track, size: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text(recommendation.track.title)
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundStyle(DriftTheme.textPrimary)
                    Text(recommendation.track.artistName)
                        .font(.caption)
                        .foregroundStyle(DriftTheme.textSecondary)
                }
                Spacer()
                Image(systemName: "play.fill")
                    .foregroundStyle(DriftTheme.accent)
            }
            .padding(8)
            .background(DriftTheme.surfaceHigh, in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
