#if canImport(CryptoKit)
import CryptoKit
#else
import Crypto
#endif
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Foundation

public struct SpotifyTokens: Codable {
    public var accessToken: String
    public var refreshToken: String?
    public var expiresIn: Int
    public var scope: String
    public var receivedAt: Date

    public init(accessToken: String, refreshToken: String?, expiresIn: Int, scope: String, receivedAt: Date = Date()) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.scope = scope
        self.receivedAt = receivedAt
    }

    public var isExpired: Bool {
        Date().timeIntervalSince(receivedAt) > Double(expiresIn) - 60
    }
}

/// Spotify OAuth 2.0 Authorization Code + PKCE flow (no client secret needed).
public enum SpotifyAuth {
    public static func codeVerifier() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        for i in 0..<bytes.count { bytes[i] = UInt8.random(in: 0...255) }
        return base64URL(bytes)
    }

    public static func codeChallenge(for verifier: String) -> String {
        let digest = SHA256.hash(data: Data(verifier.utf8))
        return base64URL(Array(digest))
    }

    public static func authorizationURL(
        clientId: String,
        redirectURI: String,
        scopes: [String],
        codeChallenge: String
    ) -> URL? {
        var components = URLComponents(string: "https://accounts.spotify.com/authorize")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "scope", value: scopes.joined(separator: " ")),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "code_challenge", value: codeChallenge)
        ]
        return components.url
    }

    public static func exchangeCode(
        code: String,
        clientId: String,
        redirectURI: String,
        codeVerifier: String
    ) async throws -> SpotifyTokens {
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        let data = try await HTTP.postForm(url, fields: [
            "client_id": clientId,
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectURI,
            "code_verifier": codeVerifier
        ])
        return try decodeTokens(data)
    }

    public static func refresh(refreshToken: String, clientId: String) async throws -> SpotifyTokens {
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        let data = try await HTTP.postForm(url, fields: [
            "client_id": clientId,
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ])
        var tokens = try decodeTokens(data)
        if tokens.refreshToken == nil { tokens.refreshToken = refreshToken }
        return tokens
    }

    private static func decodeTokens(_ data: Data) throws -> SpotifyTokens {
        struct Raw: Decodable {
            let access_token: String
            let refresh_token: String?
            let expires_in: Int
            let scope: String
        }
        let raw = try JSONDecoder().decode(Raw.self, from: data)
        return SpotifyTokens(
            accessToken: raw.access_token,
            refreshToken: raw.refresh_token,
            expiresIn: raw.expires_in,
            scope: raw.scope,
            receivedAt: Date()
        )
    }

    private static func base64URL(_ bytes: [UInt8]) -> String {
        Data(bytes).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
