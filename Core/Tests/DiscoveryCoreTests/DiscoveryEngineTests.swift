import XCTest
@testable import DiscoveryCore

final class DiscoveryEngineTests: XCTestCase {

    private func sampleTrack(id: String, artist: String, genre: String, popularity: Double = 0.4) -> Track {
        Track(
            id: id,
            title: "Track \(id)",
            artistId: "artist-\(artist)",
            artistName: artist,
            genres: [genre],
            releaseYear: 2019,
            popularity: popularity,
            moods: ["Night"],
            scene: "UK electronic"
        )
    }

    func testMeldScoreStaysInRange() {
        let baseline = MeldBaseline()
        var profile = UserProfile()
        profile.artistAffinity["artist-Burial"] = 0.9
        profile.genreAffinity["Dubstep"] = 0.8
        let track = sampleTrack(id: "t1", artist: "Burial", genre: "Dubstep")
        let score = baseline.score(track: track, profile: profile)
        XCTAssertTrue((0...1).contains(score), "score must be in 0...1, got \(score)")
    }

    func testRerankerPenalizesRepetition() {
        var profile = UserProfile()
        profile.recentArtistCount["artist-Burial"] = 10
        let track = sampleTrack(id: "t1", artist: "Burial", genre: "Dubstep")
        let candidate = Candidate(track: track, meldScore: 0.9, flowScore: 0.9, novelty: 0.2)
        let score = Reranker().score(candidate: candidate, profile: profile, context: RankingContext())
        XCTAssertLessThan(score, 0.8)
    }

    func testFeedRespectsMaxPerArtist() {
        var profile = UserProfile()
        profile.genreAffinity["Dubstep"] = 0.8
        let tracks = (0..<12).map {
            sampleTrack(id: "b\($0)", artist: "Burial", genre: "Dubstep")
        } + (0..<12).map {
            sampleTrack(id: "f\($0)", artist: "ForestSwords", genre: "Ambient")
        }
        let engine = DiscoveryEngine(feedSize: 10)
        let feed = engine.makeFeed(from: tracks, profile: profile, context: RankingContext(mode: .deep))
        let maxBurial = feed.filter { $0.track.artistId == "artist-Burial" }.count
        XCTAssertLessThanOrEqual(maxBurial, engine.maxPerArtist)
    }

    func testTrackMatcherPrefersExactArtist() {
        let reference = Track(
            id: "spotify-1",
            title: "Archangel",
            artistId: "burial",
            artistName: "Burial",
            durationSeconds: 238
        )
        let exact = YouTubeMatch(videoId: "A", title: "Archangel", artistName: "Burial", durationSeconds: 240, isOfficial: true)
        let wrong = YouTubeMatch(videoId: "B", title: "Archangel (live cover)", artistName: "Someone Else", durationSeconds: 400)
        let best = TrackMatcher().rank(reference: reference, candidates: [wrong, exact])
        XCTAssertEqual(best?.videoId, "A")
    }
}
