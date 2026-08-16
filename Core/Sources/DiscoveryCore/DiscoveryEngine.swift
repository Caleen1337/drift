import Foundation

/// Orchestrates candidate generation, filtering, reranking and diversification.
public struct DiscoveryEngine {
    public let reranker: Reranker
    public let baseline: MeldBaseline
    public let flow: FlowProfile
    public let maxPerArtist: Int
    public let feedSize: Int
    public let modelVersion: String

    public init(
        reranker: Reranker = Reranker(),
        baseline: MeldBaseline = MeldBaseline(),
        flow: FlowProfile = FlowProfile(),
        maxPerArtist: Int = 3,
        feedSize: Int = 20,
        modelVersion: String = "v1"
    ) {
        self.reranker = reranker
        self.baseline = baseline
        self.flow = flow
        self.maxPerArtist = maxPerArtist
        self.feedSize = feedSize
        self.modelVersion = modelVersion
    }

    public func makeCandidates(from tracks: [Track], profile: UserProfile) -> [Candidate] {
        tracks.map { track in
            Candidate(
                track: track,
                meldScore: baseline.score(track: track, profile: profile),
                flowScore: flow.score(track: track, profile: profile),
                novelty: novelty(for: track, profile: profile),
                familiarity: familiarity(for: track, profile: profile)
            )
        }
    }

    public func makeFeed(
        from tracks: [Track],
        profile: UserProfile,
        context: RankingContext
    ) -> [Recommendation] {
        var candidates = makeCandidates(from: tracks, profile: profile)

        // Hard filters: blocked and already-heard content.
        candidates = candidates.filter { candidate in
            let track = candidate.track
            if profile.blockedArtists.contains(track.artistId) { return false }
            if track.genres.contains(where: { profile.blockedGenres.contains($0) }) { return false }
            if profile.heardTrackIds.contains(track.id) { return false }
            return true
        }

        // Score and sort.
        var scored: [(candidate: Candidate, score: Double)] = candidates.map {
            ($0, reranker.score(candidate: $0, profile: profile, context: context))
        }
        scored.sort { $0.score > $1.score }

        // Greedy, diversified selection (limit repeats of the same artist).
        var artistCounts: [String: Int] = [:]
        var picks: [Candidate] = []
        for item in scored {
            let artistId = item.candidate.track.artistId
            if (artistCounts[artistId] ?? 0) >= maxPerArtist { continue }
            artistCounts[artistId, default: 0] += 1
            picks.append(item.candidate)
            if picks.count >= feedSize { break }
        }

        // Exploration budget: make sure a share of the feed is novel.
        let novelThreshold = 0.7
        let targetNovelCount = Int(Double(feedSize) * context.mode.explorationRatio)
        let currentNovelCount = picks.filter { $0.novelty >= novelThreshold }.count

        if currentNovelCount < targetNovelCount {
            let pickedIds = Set(picks.map { $0.id })
            let novelCandidates = scored
                .map { $0.candidate }
                .filter { $0.novelty >= novelThreshold && !pickedIds.contains($0.id) }
            for extra in novelCandidates {
                if picks.count >= feedSize { break }
                if (artistCounts[extra.track.artistId] ?? 0) >= maxPerArtist { continue }
                artistCounts[extra.track.artistId, default: 0] += 1
                picks.append(extra)
            }
        }

        return picks.map { candidate in
            Recommendation(
                track: candidate.track,
                finalScore: scored.first(where: { $0.candidate.id == candidate.id })?.score ?? 0,
                explanation: explain(candidate, profile: profile),
                modelVersion: modelVersion
            )
        }
    }

    public func novelty(for track: Track, profile: UserProfile) -> Double {
        var score = 1.0
        if profile.heardTrackIds.contains(track.id) { score -= 0.5 }
        if (profile.artistAffinity[track.artistId] ?? 0) > 0.2 { score -= 0.3 }
        if track.genres.contains(where: { (profile.genreAffinity[$0] ?? 0) > 0.2 }) { score -= 0.1 }
        if track.popularity > 0.7 { score -= 0.1 }
        return clamp(score, 0...1)
    }

    public func familiarity(for track: Track, profile: UserProfile) -> Double {
        var score = 0.0
        if profile.heardTrackIds.contains(track.id) { score += 0.5 }
        score += clamp(profile.artistAffinity[track.artistId] ?? 0, 0...1) * 0.4
        score += clamp(mean(track.genres.map { profile.genreAffinity[$0] ?? 0 }), 0...1) * 0.1
        return clamp(score, 0...1)
    }

    private func explain(_ candidate: Candidate, profile: UserProfile) -> [String] {
        var reasons: [String] = []
        let topGenre = candidate.track.genres.max {
            (profile.genreAffinity[$0] ?? 0) < (profile.genreAffinity[$1] ?? 0)
        }
        if let genre = topGenre, (profile.genreAffinity[genre] ?? 0) > 0 {
            reasons.append("Because you like \(genre)")
        }
        if (profile.artistAffinity[candidate.track.artistId] ?? 0) > 0 {
            reasons.append("Because you listened to \(candidate.track.artistName)")
        }
        if candidate.novelty >= 0.7 {
            reasons.append("New artist exploration")
        }
        if candidate.novelty < 0.3 {
            reasons.append("Close to your taste")
        }
        if reasons.isEmpty {
            reasons.append("A serendipitous pick outside your usual rotation")
        }
        return reasons
    }
}
