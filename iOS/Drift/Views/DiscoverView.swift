import SwiftUI
import DiscoveryCore

struct DiscoverView: View {
    @EnvironmentObject var app: AppEnvironment
    @State private var showFeed = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    modePicker
                    startButton
                    TrackShelf(
                        title: "Picked for you",
                        subtitle: "strong matches",
                        tracks: Array(MockData.tracks.prefix(4))
                    )
                    TrackShelf(
                        title: "Go deeper",
                        subtitle: "less obvious artists",
                        tracks: Array(MockData.tracks.suffix(4))
                    )
                    TrackShelf(
                        title: "Something unexpected",
                        subtitle: "one weird thing",
                        tracks: [MockData.tracks[5], MockData.tracks[6]]
                    )
                }
                .padding()
            }
            .background(DriftTheme.background)
            .navigationTitle("Discover")
            .fullScreenCover(isPresented: $showFeed) {
                DiscoveryFeedView()
                    .environmentObject(app)
            }
        }
    }

    private var modePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What do you want to discover?").font(.headline)
            HStack(spacing: 8) {
                ForEach(DiscoveryMode.allCases, id: \.self) { mode in
                    Button {
                        app.mode = mode
                    } label: {
                        Text(mode.title)
                            .font(.subheadline).fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(app.mode == mode ? AnyShapeStyle(DriftTheme.gradient) : AnyShapeStyle(DriftTheme.surface))
                            .foregroundStyle(app.mode == mode ? .white : DriftTheme.textSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var startButton: some View {
        Button {
            app.generateFeed()
            showFeed = true
        } label: {
            HStack {
                Image(systemName: "play.fill")
                Text("Start discovery")
                Spacer()
                Image(systemName: "arrow.right")
            }
            .font(.headline)
            .padding()
            .background(DriftTheme.gradient)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
