import Foundation

public enum EventType: String, Codable, CaseIterable {
    case playStarted
    case playProgress
    case playCompleted
    case skipped
    case liked
    case disliked
    case replayed
    case searched
    case artistOpened
    case albumOpened
    case queueAdded
    case recommendationClicked
    case openedInSpotify
}

public enum EventSource: String, Codable {
    case ourPlayer
    case spotify
    case youtubeMusic
    case manual
}

public struct PlaybackEvent: Identifiable, Codable {
    public var id: UUID
    public var anonymousUserId: String
    public var sessionId: String
    public var timestamp: Date
    public var trackId: String
    public var artistId: String
    public var recommendationId: String?
    public var position: Int?
    public var type: EventType
    public var completionRatio: Double?
    public var source: EventSource
    public var context: [String: String]

    public init(
        id: UUID = UUID(),
        anonymousUserId: String,
        sessionId: String,
        timestamp: Date = Date(),
        trackId: String,
        artistId: String,
        recommendationId: String? = nil,
        position: Int? = nil,
        type: EventType,
        completionRatio: Double? = nil,
        source: EventSource,
        context: [String: String] = [:]
    ) {
        self.id = id
        self.anonymousUserId = anonymousUserId
        self.sessionId = sessionId
        self.timestamp = timestamp
        self.trackId = trackId
        self.artistId = artistId
        self.recommendationId = recommendationId
        self.position = position
        self.type = type
        self.completionRatio = completionRatio
        self.source = source
        self.context = context
    }
}

/// Extra metadata needed by `EventEngine` when applying an event to a profile.
public struct EventContext {
    public var genres: [String]
    public var scene: String?
    public var moods: [String]

    public init(genres: [String] = [], scene: String? = nil, moods: [String] = []) {
        self.genres = genres
        self.scene = scene
        self.moods = moods
    }
}
