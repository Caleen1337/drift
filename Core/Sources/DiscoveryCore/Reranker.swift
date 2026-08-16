import Foundation

/// Combines relevance, novelty, exploration and penalties into a final score.
public struct Reranker {
    public struct Weights {
        public let relevance: Double
        public let novelty: Double
        public let exploration: Double
        public let audio: Double
        public let repetitionPenalty: Double
        public let fatiguePenalty: Double
        public let popularityBias: Double

        public init(
            relevance: Double = 0.40,
            novelty: Double = 0.25,
            exploration: Double = 0.15,
            audio: Double = 0.10,
            repetitionPenalty: Double = 0.10,
            fatiguePenalty: Double = 0.05,
            popularityBias: Double = 0.03
        ) {
            self.relevance = relevance
            self.novelty = novelty
            self.exploration = exploration
            self.audio = audio
            self.repetitionPenalty = repetitionPenalty
            self.fatiguePenalty = fatiguePenalty
            self.popularityBias = popularityBias
        }
    }

    public let weights: Weights

    public init(weights: Weights = Weights()) {
        self.weights = weights
    }

    public func score(candidate: Candidate, profile: UserProfile, context: RankingContext) -> Double {
        let relevance = 0.6 * candidate.meldScore + 0.4 * candidate.flowScore
        let noveltyBonus = candidate.novelty * weights.novelty
        let explorationBonus = context.mode.explorationRatio * candidate.novelty * weights.exploration
        let audioBonus = (candidate.audioSimilarity ?? 0.5) * weights.audio

        let artistRepetition = Double(profile.recentArtistCount[candidate.track.artistId] ?? 0)
        let repetitionPenalty = min(artistRepetition * weights.repetitionPenalty, 0.3)

        let genreFatigue = candidate.track.genres.reduce(0.0) {
            $0 + Double(profile.recentGenreCount[$1] ?? 0)
        }
        let fatiguePenalty = min(genreFatigue * weights.fatiguePenalty, 0.2)

        let popularityPenalty = candidate.track.popularity * weights.popularityBias

        let value =
            weights.relevance * relevance
            + noveltyBonus
            + explorationBonus
            + audioBonus
            - repetitionPenalty
            - fatiguePenalty
            - popularityPenalty

        return clamp(value, 0...1)
    }
}
