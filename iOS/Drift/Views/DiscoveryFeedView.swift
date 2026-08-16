import SwiftUI
import DiscoveryCore

struct DiscoveryFeedView: View {
    @EnvironmentObject var app: AppEnvironment
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            DriftTheme.background.ignoresSafeArea()

            if let rec = app.current {
                VStack(spacing: 22) {
                    topBar
                    Spacer()
                    AlbumArt(track: rec.track, size: 260)
                    VStack(spacing: 6) {
                        Text(rec.track.title)
                            .font(.title2).fontWeight(.bold)
                        Text(rec.track.artistName)
                            .font(.subheadline)
                            .foregroundStyle(DriftTheme.textSecondary)
                    }
                    whyThis(rec)
                    Spacer()
                    actionRow
                }
                .padding()
                .gesture(
                    DragGesture(minimumDistance: 30)
                        .onEnded { value in
                            if value.translation.height < -40 { app.next() }
                        }
                )
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 44))
                        .foregroundStyle(DriftTheme.accent)
                    Text("You're up to date")
                        .font(.headline)
                    Button("Generate another feed") {
                        app.generateFeed()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(DriftTheme.accent)
                }
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(DriftTheme.textSecondary)
            }
            Spacer()
            Text("Discover").font(.headline)
            Spacer()
            Text("\(app.mode.title) mode")
                .font(.caption)
                .foregroundStyle(DriftTheme.textSecondary)
        }
    }

    private func whyThis(_ rec: Recommendation) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Why this?").font(.caption).foregroundStyle(DriftTheme.textSecondary)
            ForEach(rec.explanation, id: \.self) { reason in
                Label(reason, systemImage: "info.circle")
                    .font(.caption)
                    .foregroundStyle(DriftTheme.textPrimary.opacity(0.85))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(DriftTheme.surface, in: RoundedRectangle(cornerRadius: 14))
    }

    private var actionRow: some View {
        HStack(spacing: 28) {
            Button { app.feedback(.disliked) } label: {
                Image(systemName: "hand.thumbsdown")
                    .font(.title2)
                    .foregroundStyle(DriftTheme.accentWarm)
            }
            Button { app.feedback(.liked) } label: {
                Image(systemName: "heart")
                    .font(.title2)
                    .foregroundStyle(DriftTheme.accent)
            }
            Button {
                if let rec = app.current {
                    app.openInSpotify(rec.track)
                }
            } label: {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(DriftTheme.gradient)
            }
        }
    }
}
