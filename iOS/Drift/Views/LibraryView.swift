import SwiftUI
import DiscoveryCore

struct LibraryView: View {
    @EnvironmentObject var app: AppEnvironment

    var body: some View {
        NavigationStack {
            List {
                Section("Rabbit hole") {
                    if app.rabbitHole.isEmpty {
                        Text("Your exploration paths will appear here.")
                            .font(.caption)
                            .foregroundStyle(DriftTheme.textSecondary)
                    } else {
                        ForEach(app.rabbitHole) { track in
                            HStack(spacing: 12) {
                                AlbumArt(track: track, size: 44)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(track.title).font(.subheadline).fontWeight(.semibold)
                                    Text(track.artistName).font(.caption).foregroundStyle(DriftTheme.textSecondary)
                                }
                            }
                        }
                    }
                }

                Section("History") {
                    Label("Heard \(app.profile.heardTrackIds.count) tracks", systemImage: "clock")
                    Label("Blocked artists: \(app.profile.blockedArtists.count)", systemImage: "hand.raised")
                }

                Section("Saved discoveries") {
                    Text("Liked discoveries will appear here.")
                        .font(.caption)
                        .foregroundStyle(DriftTheme.textSecondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(DriftTheme.background)
            .navigationTitle("Library")
        }
    }
}
