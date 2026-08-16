#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Foundation

/// Thin Spotify Web API client (search, recently played). Auth via `SpotifyAuth`.
public final class SpotifyClient {
    public let clientId: String
    public let redirectURI: String
    private var tokens: SpotifyTokens?
    private let decoder = JSONDecoder()

    public init(clientId: String, redirectURI: String) {
        self.clientId = clientId
        self.redirectURI = redirectURI
    }

    public var isAuthorized: Bool { tokens != nil }

    public func makeAuthorizationURL(scopes: [String], codeVerifier: String) -> URL? {
        SpotifyAuth.authorizationURL(
            clientId: clientId,
            redirectURI: redirectURI,
            scopes: scopes,
            codeChallenge: SpotifyAuth.codeChallenge(for: codeVerifier)
        )
    }

    public func handleRedirect(url: URL, codeVerifier: String) async throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            throw ProviderError.unauthorized
        }
        tokens = try await SpotifyAuth.exchangeCode(
            code: code,
            clientId: clientId,
            redirectURI: redirectURI,
            codeVerifier: codeVerifier
        )
    }

    private func authorizedHeaders() async throws -> [String: String] {
        guard var current = tokens else { throw ProviderError.unauthorized }
        if current.isExpired, let refresh = current.refreshToken {
            current = try await SpotifyAuth.refresh(refreshToken: refresh, clientId: clientId)
            tokens = current
        }
        return ["Authorization": "Bearer \(current.accessToken)"]
    }

    public func search(query: String) async throws -> [Track] {
        let headers = try await authorizedHeaders()
        var components = URLComponents(string: "https://api.spotify.com/v1/search")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "track"),
            URLQueryItem(name: "limit", value: "20")
        ]
        let data = try await HTTP.getJSON(components.url!, headers: headers)
        let result = try decoder.decode(SearchResponse.self, from: data)
        return result.tracks.items.map(Self.mapTrack)
    }

    public func recentlyPlayed(limit: Int = 50) async throws -> [Track] {
        let headers = try await authorizedHeaders()
        var components = URLComponents(string: "https://api.spotify.com/v1/me/player/recently-played")!
        components.queryItems = [URLQueryItem(name: "limit", value: String(limit))]
        let data = try await HTTP.getJSON(components.url!, headers: headers)
        struct Response: Decodable {
            struct Item: Decodable { let track: SpotifyTrack }
            let items: [Item]
        }
        let result = try decoder.decode(Response.self, from: data)
        return result.items.map { Self.mapTrack($0.track) }
    }

    public static func mapTrack(_ t: SpotifyTrack) -> Track {
        Track(
            id: "spotify:\(t.id)",
            title: t.name,
            artistId: "spotify:artist:\(t.artists.first?.id ?? "unknown")",
            artistName: t.artists.first?.name ?? "Unknown",
            albumId: t.album?.id,
            albumName: t.album?.name,
            durationSeconds: (t.duration_ms ?? 0) / 1000,
            isrc: t.external_ids?.isrc,
            spotifyId: t.id,
            releaseYear: Int(t.album?.release_date?.prefix(4) ?? ""),
            popularity: Double(t.popularity ?? 0) / 100.0
        )
    }
}

public struct SpotifyTrack: Decodable {
    public let id: String
    public let name: String
    public let duration_ms: Int?
    public let popularity: Int?
    public let artists: [SpotifyArtist]
    public let album: SpotifyAlbum?
    public let external_ids: SpotifyExternalIDs?
}

public struct SpotifyArtist: Decodable {
    public let id: String
    public let name: String
}

public struct SpotifyAlbum: Decodable {
    public let id: String
    public let name: String
    public let release_date: String?
}

public struct SpotifyExternalIDs: Decodable {
    public let isrc: String?
}

private struct SearchResponse: Decodable {
    struct Tracks: Decodable { let items: [SpotifyTrack] }
    let tracks: Tracks
}
