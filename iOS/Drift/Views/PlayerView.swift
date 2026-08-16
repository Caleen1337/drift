import SwiftUI
import UIKit
import DiscoveryCore

struct PlayerView: View {
    @EnvironmentObject var app: AppEnvironment
    @Environment(\.dismiss) var dismiss
    @State private var isPlaying = false

    var body: some View {
        ZStack {
            DriftTheme.background.ignoresSafeArea()

            if let rec = app.current {
                VStack(spacing: 28) {
                    handle
                    Spacer()
                    AlbumArt(track: rec.track, size: 280)
                    VStack(spacing: 6) {
                        Text(rec.track.title).font(.title2).fontWeight(.bold)
                        Text(rec.track.artistName).font(.subheadline).foregroundStyle(DriftTheme.textSecondary)
                    }
                    progress
                    controls
                    sourceButtons(rec.track)
                    Spacer()
                }
                .padding()
            }
        }
    }

    private var handle: some View {
        Capsule()
            .fill(DriftTheme.textSecondary)
            .frame(width: 40, height: 5)
    }

    private var progress: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(DriftTheme.surfaceHigh)
                    Capsule().fill(DriftTheme.gradient).frame(width: geo.size.width * 0.3)
                }
            }
            .frame(height: 5)
            HStack {
                Text("-0:48").font(.caption).foregroundStyle(DriftTheme.textSecondary)
                Spacer()
                Text("3:42").font(.caption).foregroundStyle(DriftTheme.textSecondary)
            }
        }
    }

    private var controls: some View {
        HStack(spacing: 42) {
            Button { } label: {
                Image(systemName: "backward.fill").font(.title2).foregroundStyle(DriftTheme.textPrimary)
            }
            Button {
                isPlaying.toggle()
            } label: {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(DriftTheme.gradient)
            }
            Button { } label: {
                Image(systemName: "forward.fill").font(.title2).foregroundStyle(DriftTheme.textPrimary)
            }
        }
    }

    private func sourceButtons(_ track: Track) -> some View {
        HStack(spacing: 12) {
            Button {
                // "Play here" uses the Metrolist-derived YouTube provider.
                isPlaying = true
            } label: {
                Label("Play here", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(DriftTheme.accent)

            Button {
                app.openInSpotify(track)
            } label: {
                Label("Open in Spotify", systemImage: "arrow.up.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(DriftTheme.accent)
        }
        .font(.subheadline.weight(.semibold))
    }
}
