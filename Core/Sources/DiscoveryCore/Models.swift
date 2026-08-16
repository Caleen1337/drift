import Foundation

/// A canonical music track, decoupled from any single provider.
public struct Track: Identifiable, Codable, Hashable {
    public var id: String
    public var title: String
    public var artistId: String
    public var artistName: String
    public var albumId: String?
    public var albumName: String?
    public var durationSeconds: Int
    public var isrc: String?
    public var spotifyId: String?
    public var youtubeVideoId: String?
    public var genres: [String]
    public var tags: [String]
    public var era: String?
    public var releaseYear: Int?
    public var popularity: Double
    public var energy: Double?
    public var tempo: Double?
    public var moods: [String]
    public var label: String?
    public var scene: String?

    public init(
        id: String,
        title: String,
        artistId: String,
        artistName: String,
        albumId: String? = nil,
        albumName: String? = nil,
        durationSeconds: Int = 0,
        isrc: String? = nil,
        spotifyId: String? = nil,
        youtubeVideoId: String? = nil,
        genres: [String] = [],
        tags: [String] = [],
        era: String? = nil,
        releaseYear: Int? = nil,
        popularity: Double = 0.0,
        energy: Double? = nil,
        tempo: Double? = nil,
        moods: [String] = [],
        label: String? = nil,
        scene: String? = nil
    ) {
        self.id = id
        self.title = title
        self.artistId = artistId
        self.artistName = artistName
        self.albumId = albumId
        self.albumName = albumName
        self.durationSeconds = durationSeconds
        self.isrc = isrc
        self.spotifyId = spotifyId
        self.youtubeVideoId = youtubeVideoId
        self.genres = genres
        self.tags = tags
        self.era = era
        self.releaseYear = releaseYear
        self.popularity = popularity
        self.energy = energy
        self.tempo = tempo
        self.moods = moods
        self.label = label
        self.scene = scene
    }
}

public struct Artist: Identifiable, Codable, Hashable {
    public var id: String
    public var name: String
    public var genres: [String]
    public var scene: String?
    public var relatedArtistIds: [String]
    public var popularity: Double

    public init(
        id: String,
        name: String,
        genres: [String] = [],
        scene: String? = nil,
        relatedArtistIds: [String] = [],
        popularity: Double = 0.0
    ) {
        self.id = id
        self.name = name
        self.genres = genres
        self.scene = scene
        self.relatedArtistIds = relatedArtistIds
        self.popularity = popularity
    }
}

public struct Album: Identifiable, Codable, Hashable {
    public var id: String
    public var title: String
    public var artistId: String
    public var releaseYear: Int?
    public var trackIds: [String]

    public init(
        id: String,
        title: String,
        artistId: String,
        releaseYear: Int? = nil,
        trackIds: [String] = []
    ) {
        self.id = id
        self.title = title
        self.artistId = artistId
        self.releaseYear = releaseYear
        self.trackIds = trackIds
    }
}

/// A candidate from YouTube Music for a given track (used by `TrackMatcher`).
public struct YouTubeMatch: Identifiable {
    public var id: String { videoId }
    public var videoId: String
    public var title: String
    public var artistName: String
    public var durationSeconds: Int
    public var isOfficial: Bool
    public var score: Double

    public init(
        videoId: String,
        title: String,
        artistName: String,
        durationSeconds: Int,
        isOfficial: Bool = false,
        score: Double = 0
    ) {
        self.videoId = videoId
        self.title = title
        self.artistName = artistName
        self.durationSeconds = durationSeconds
        self.isOfficial = isOfficial
        self.score = score
    }
}
