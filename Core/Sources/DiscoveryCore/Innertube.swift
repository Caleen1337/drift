#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Foundation

public struct YouTubeVideoDetails {
    public let title: String
    public let author: String
    public let lengthSeconds: Int

    public init(title: String, author: String, lengthSeconds: Int) {
        self.title = title
        self.author = author
        self.lengthSeconds = lengthSeconds
    }
}

/// Minimal YouTube Music Innertube client (metadata only: search + video details).
/// The actual audio stream layer is provided by the Metrolist-derived playback code.
public final class InnertubeClient {
    public let apiKey: String
    private let context: [String: Any]

    public init(apiKey: String) {
        self.apiKey = apiKey
        self.context = [
            "client": [
                "clientName": "WEB_REMIX",
                "clientVersion": "1.0"
            ]
        ]
    }

    /// Returns deduplicated video ids for a song search.
    public func searchSongs(query: String) async throws -> [String] {
        let url = URL(string: "https://music.youtube.com/youtubei/v1/search?key=\(apiKey)")!
        var body = context
        body["query"] = query
        let data = try await HTTP.postJSON(url, body: body)
        let root = try JSONSerialization.jsonObject(with: data)
        var ids: [String] = []
        collectVideoIds(root, into: &ids)
        return uniquePreservingOrder(ids)
    }

    /// Flat metadata for a video id (does not touch streaming data).
    public func videoDetails(videoId: String) async throws -> YouTubeVideoDetails {
        let url = URL(string: "https://music.youtube.com/youtubei/v1/player?key=\(apiKey)")!
        var body = context
        body["videoId"] = videoId
        let data = try await HTTP.postJSON(url, body: body)
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let details = root["videoDetails"] as? [String: Any],
              let title = details["title"] as? String,
              let author = details["author"] as? String,
              let length = details["lengthSeconds"] as? String,
              let seconds = Int(length) else {
            throw ProviderError.notFound
        }
        return YouTubeVideoDetails(title: title, author: author, lengthSeconds: seconds)
    }

    private func collectVideoIds(_ node: Any, into ids: inout [String]) {
        if let dict = node as? [String: Any] {
            if let id = dict["videoId"] as? String { ids.append(id) }
            for value in dict.values { collectVideoIds(value, into: &ids) }
        } else if let array = node as? [Any] {
            for value in array { collectVideoIds(value, into: &ids) }
        }
    }

    private func uniquePreservingOrder(_ ids: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for id in ids where !seen.contains(id) {
            seen.insert(id)
            result.append(id)
        }
        return result
    }
}
