import Foundation

/// Paste your own credentials here.
/// WARNING: do not commit real secrets to a public repository.
enum AppConfig {
    // Spotify — create an app at https://developer.spotify.com/dashboard
    static let spotifyClientID = "YOUR_SPOTIFY_CLIENT_ID"
    static let spotifyRedirectURI = "drift://callback"

    // YouTube Music Innertube WEB_REMIX API key (used for search / playback metadata).
    static let youtubeMusicAPIKey = "YOUR_INNERTUBE_API_KEY"
}
