import Foundation

public struct Candidate: Identifiable {
    public var id: String { track.id }
    public var track: Track
    public var meldScore: Double
    public var flowScore: Double
    public var novelty: Double
    public var familiarity: Double
    public var audioSimilarity: Double?

    public init(
        track: Track,
        meldScore: Double = 0,
        flowScore: Double = 0,
        novelty: Double = 0,
        familiarity: Double = 0,
        audioSimilarity: Double? = nil
    ) {
        self.track = track
        self.meldScore = meldScore
        self.flowScore = flowScore
        self.novelty = novelty
        self.familiarity = familiarity
        self.audioSimilarity = audioSimilarity
    }
}

public struct RankingContext {
    public var mode: DiscoveryMode
    public var session: SessionContext
    public var now: Date

    public init(mode: DiscoveryMode = .balanced, session: SessionContext = .current(), now: Date = Date()) {
        self.mode = mode
        self.session = session
        self.now = now
    }
}

public struct Recommendation: Identifiable {
    public var id: UUID
    public var track: Track
    public var finalScore: Double
    public var explanation: [String]
    public var modelVersion: String
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        track: Track,
        finalScore: Double,
        explanation: [String] = [],
        modelVersion: String = "v1",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.track = track
        self.finalScore = finalScore
        self.explanation = explanation
        self.modelVersion = modelVersion
        self.createdAt = createdAt
    }
}
