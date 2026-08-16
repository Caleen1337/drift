import Foundation

public enum ProviderError: Error {
    case notImplemented
    case notFound
    case unauthorized
}

public protocol MusicProvider {
    var providerId: String { get }
    func search(query: String) async throws -> [Track]
    func resolve(_ track: Track) async throws -> Track
}

public struct SpotifyProvider: MusicProvider {
    public let providerId = "spotify"
    public let client: SpotifyClient?

    public init(client: SpotifyClient? = nil) {
        self.client = client
    }

    public func search(query: String) async throws -> [Track] {
        guard let client else { throw ProviderError.unauthorized }
        return try await client.search(query: query)
    }

    public func resolve(_ track: Track) async throws -> Track {
        if track.spotifyId != nil { return track }
        guard let client else { throw ProviderError.unauthorized }
        let results = try await client.search(query: "\(track.artistName) \(track.title)")
        guard let match = results.first(where: { abs($0.durationSeconds - track.durationSeconds) <= 5 }) ?? results.first else {
            throw ProviderError.notFound
        }
        return match
    }

    public func openInSpotifyURL(track: Track) -> URL? {
        if let id = track.spotifyId {
            return URL(string: "spotify:track:\(id)")
        }
        let query = "\(track.artistName) \(track.title)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://open.spotify.com/search/\(query)")
    }
}

public struct YouTubeMusicProvider: MusicProvider {
    public let providerId = "youtube"
    public let client: InnertubeClient?
    private let matcher = TrackMatcher()

    public init(client: InnertubeClient? = nil) {
        self.client = client
    }

    public func search(query: String) async throws -> [Track] {
        guard let client else { throw ProviderError.unauthorized }
        let ids = try await client.searchSongs(query: query)
        var tracks: [Track] = []
        for id in ids.prefix(5) {
            let details = try await client.videoDetails(videoId: id)
            tracks.append(Track(
                id: "yt:\(id)",
                title: details.title,
                artistId: "yt:artist:\(details.author)",
                artistName: details.author,
                durationSeconds: details.lengthSeconds,
                youtubeVideoId: id
            ))
        }
        return tracks
    }

    public func resolve(_ track: Track) async throws -> Track {
        if track.youtubeVideoId != nil { return track }
        guard let client else { throw ProviderError.unauthorized }
        let ids = try await client.searchSongs(query: "\(track.artistName) \(track.title)")
        var matches: [YouTubeMatch] = []
        for id in ids.prefix(5) {
            let details = try await client.videoDetails(videoId: id)
            matches.append(YouTubeMatch(
                videoId: id,
                title: details.title,
                artistName: details.author,
                durationSeconds: details.lengthSeconds
            ))
        }
        guard let best = matcher.rank(reference: track, candidates: matches) else {
            throw ProviderError.notFound
        }
        var resolved = track
        resolved.youtubeVideoId = best.videoId
        return resolved
    }
}

/// Resolves a playable stream URL for a track.
/// The YouTube implementation is provided by the Metrolist-derived playback layer.
public protocol StreamResolver {
    func streamURL(for track: Track) async throws -> URL
}

public struct ProviderRouter {
    public let spotify: SpotifyProvider
    public let youtube: YouTubeMusicProvider

    public init(spotify: SpotifyProvider = SpotifyProvider(), youtube: YouTubeMusicProvider = YouTubeMusicProvider()) {
        self.spotify = spotify
        self.youtube = youtube
    }
}

/// Simple JSON persistence helpers for profile / events.
public enum Store {
    public static func encode<T: Encodable>(_ value: T) throws -> Data {
        try JSONEncoder().encode(value)
    }

    public static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try JSONDecoder().decode(type, from: data)
    }
}
