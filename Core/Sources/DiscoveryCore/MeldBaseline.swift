import Foundation

/// Baseline relevance scorer inspired by Meld.
public struct MeldBaseline {
    public struct Weights {
        public let artistAffinity: Double
        public let genreOverlap: Double
        public let sourceRelevance: Double
        public let recency: Double
        public let popularitySimilarity: Double

        public init(
            artistAffinity: Double = 0.30,
            genreOverlap: Double = 0.20,
            sourceRelevance: Double = 0.25,
            recency: Double = 0.15,
            popularitySimilarity: Double = 0.10
        ) {
            self.artistAffinity = artistAffinity
            self.genreOverlap = genreOverlap
            self.sourceRelevance = sourceRelevance
            self.recency = recency
            self.popularitySimilarity = popularitySimilarity
        }
    }

    public let weights: Weights

    public init(weights: Weights = Weights()) {
        self.weights = weights
    }

    public func score(
        track: Track,
        profile: UserProfile,
        referencePopularity: Double = 0.5,
        now: Date = Date()
    ) -> Double {
        let artistScore = normalize(profile.artistAffinity[track.artistId] ?? 0)
        let genreScore = genreOverlapScore(track.genres, profile: profile)
        let recencyScore = recencyScore(track.releaseYear, now: now)
        let popularityScore = 1 - min(abs(track.popularity - referencePopularity) * 2, 1)
        let sourceScore = 0.5

        let value =
            weights.artistAffinity * artistScore
            + weights.genreOverlap * genreScore
            + weights.sourceRelevance * sourceScore
            + weights.recency * recencyScore
            + weights.popularitySimilarity * popularityScore

        return clamp(value, 0...1)
    }

    private func genreOverlapScore(_ genres: [String], profile: UserProfile) -> Double {
        guard !genres.isEmpty else { return 0 }
        let scores = genres.map { normalize(profile.genreAffinity[$0] ?? 0) }
        return clamp(mean(scores), 0...1)
    }

    private func recencyScore(_ releaseYear: Int?, now: Date) -> Double {
        guard let year = releaseYear else { return 0.5 }
        let current = Calendar.current.component(.year, from: now)
        let age = max(0, current - year)
        return clamp(1 - Double(age) * 0.08, 0.2...1)
    }

    private func normalize(_ affinity: Double) -> Double {
        (clamp(affinity, -1...1) + 1) / 2
    }
}
