import Foundation

/// Matches a Spotify track to the best YouTube Music candidate.
public struct TrackMatcher {
    public let officialBonus: Double

    public init(officialBonus: Double = 0.10) {
        self.officialBonus = officialBonus
    }

    public func rank(reference: Track, candidates: [YouTubeMatch]) -> YouTubeMatch? {
        guard !candidates.isEmpty else { return nil }
        return candidates
            .map { match -> (YouTubeMatch, Double) in
                let artist = artistSimilarity(reference.artistName, match.artistName)
                let title = titleSimilarity(reference.title, match.title)
                let duration = durationSimilarity(reference.durationSeconds, match.durationSeconds)
                let score = artist * 0.35 + title * 0.35 + duration * 0.20 + (match.isOfficial ? officialBonus : 0)
                return (match, score)
            }
            .sorted { $0.1 > $1.1 }
            .first?
            .0
    }

    public func titleSimilarity(_ a: String, _ b: String) -> Double {
        tokenSimilarity(normalize(a), normalize(b))
    }

    public func artistSimilarity(_ a: String, _ b: String) -> Double {
        tokenSimilarity(normalize(a), normalize(b))
    }

    public func durationSimilarity(_ a: Int, _ b: Int) -> Double {
        guard a > 0, b > 0 else { return 0 }
        let diff = Double(abs(a - b)) / Double(a)
        return clamp(1 - diff, 0...1)
    }

    private func tokenSimilarity(_ a: String, _ b: String) -> Double {
        guard !a.isEmpty, !b.isEmpty else { return 0 }
        let setA = Set(a.split(separator: " ").map(String.init))
        let setB = Set(b.split(separator: " ").map(String.init))
        let intersection = setA.intersection(setB).count
        let union = setA.union(setB).count
        guard union > 0 else { return 0 }
        return Double(intersection) / Double(union)
    }

    private func normalize(_ input: String) -> String {
        var value = input.lowercased()
        for char in ["[", "]", "(", ")", "-", ":", ","] {
            value = value.replacingOccurrences(of: char, with: " ")
        }
        let suffixes = [
            "official video", "official audio", "official music video",
            "lyrics", "lyric video", "audio", "remastered", "official"
        ]
        for suffix in suffixes {
            if value.hasSuffix(suffix) {
                value = String(value.dropLast(suffix.count))
            }
        }
        return value.split(separator: " ").joined(separator: " ").trimmingCharacters(in: .whitespaces)
    }
}
