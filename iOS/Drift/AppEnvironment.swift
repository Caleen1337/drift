import SwiftUI
import UIKit
import DiscoveryCore

@MainActor
final class AppEnvironment: ObservableObject {
    @Published var profile = UserProfile()
    @Published var queue: [Recommendation] = []
    @Published var currentIndex: Int?
    @Published var mode: DiscoveryMode = .balanced
    @Published var rabbitHole: [Track] = []

    let engine = DiscoveryEngine(feedSize: 12)
    let eventEngine = EventEngine()

    let spotifyProvider: SpotifyProvider = {
        if AppConfig.spotifyClientID.hasPrefix("YOUR_") {
            return SpotifyProvider()
        }
        return SpotifyProvider(
            client: SpotifyClient(clientId: AppConfig.spotifyClientID, redirectURI: AppConfig.spotifyRedirectURI)
        )
    }()

    let youtubeProvider: YouTubeMusicProvider = {
        if AppConfig.youtubeMusicAPIKey.hasPrefix("YOUR_") {
            return YouTubeMusicProvider()
        }
        return YouTubeMusicProvider(client: InnertubeClient(apiKey: AppConfig.youtubeMusicAPIKey))
    }()

    var current: Recommendation? {
        guard let index = currentIndex, queue.indices.contains(index) else { return nil }
        return queue[index]
    }

    func generateFeed() {
        let context = RankingContext(mode: mode, session: .current())
        queue = engine.makeFeed(from: MockData.tracks, profile: profile, context: context)
        currentIndex = queue.isEmpty ? nil : 0
    }

    func feedback(_ type: EventType, ratio: Double? = nil) {
        guard let rec = current else { return }
        var event = PlaybackEvent(
            anonymousUserId: "dev",
            sessionId: "session",
            trackId: rec.track.id,
            artistId: rec.track.artistId,
            recommendationId: rec.id.uuidString,
            position: currentIndex,
            type: type,
            completionRatio: ratio,
            source: .manual
        )
        if rec.finalScore >= 0.6 && rec.track.popularity < 0.4 {
            event.context["isNovel"] = "true"
        }
        let context = EventContext(genres: rec.track.genres, scene: rec.track.scene, moods: rec.track.moods)
        eventEngine.apply(event, context: context, to: &profile)
        next()
    }

    func next() {
        guard let index = currentIndex else { return }
        currentIndex = index + 1 < queue.count ? index + 1 : nil
    }

    func openInSpotify(_ track: Track) {
        if let url = SpotifyProvider().openInSpotifyURL(track: track) {
            UIApplication.shared.open(url)
        }
    }
}
