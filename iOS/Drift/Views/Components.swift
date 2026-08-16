import SwiftUI
import DiscoveryCore

struct AlbumArt: View {
    let track: Track
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.3 + Double(abs(track.artistName.hashValue % 40)) / 100, green: 0.35, blue: 0.8),
                    DriftTheme.accentWarm.opacity(0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(String(track.artistName.prefix(1)).uppercased())
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundStyle(.white.opacity(0.92))
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22))
    }
}

struct TrackCard: View {
    let track: Track

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AlbumArt(track: track, size: 140)
            Text(track.title)
                .font(.subheadline).fontWeight(.semibold)
                .foregroundStyle(DriftTheme.textPrimary)
                .lineLimit(1)
            Text(track.artistName)
                .font(.caption)
                .foregroundStyle(DriftTheme.textSecondary)
                .lineLimit(1)
        }
        .frame(width: 140, alignment: .leading)
    }
}

struct TrackShelf: View {
    let title: String
    let subtitle: String?
    let tracks: [Track]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(title).font(.headline)
                Spacer()
                if let subtitle {
                    Text(subtitle).font(.caption).foregroundStyle(DriftTheme.textSecondary)
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(tracks) { track in
                        TrackCard(track: track)
                    }
                }
            }
        }
    }
}

struct TasteBar: View {
    let name: String
    let value: Double

    private var normalized: Double {
        clamp((value + 1) / 2, 0...1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name).font(.subheadline)
                Spacer()
                Text("\(Int(normalized * 100))%")
                    .font(.caption)
                    .foregroundStyle(DriftTheme.textSecondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(DriftTheme.surfaceHigh)
                    Capsule().fill(DriftTheme.gradient)
                        .frame(width: geo.size.width * normalized)
                }
            }
            .frame(height: 8)
        }
    }
}
