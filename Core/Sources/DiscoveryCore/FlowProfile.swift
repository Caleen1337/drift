import Foundation

/// FlowNeuro-inspired local preference model.
public struct FlowProfile {
    public struct Weights {
        public let artist: Double
        public let genre: Double
        public let scene: Double
        public let mood: Double

        public init(artist: Double = 0.35, genre: Double = 0.25, scene: Double = 0.20, mood: Double = 0.20) {
            self.artist = artist
            self.genre = genre
            self.scene = scene
            self.mood = mood
        }
    }

    public let weights: Weights

    public init(weights: Weights = Weights()) {
        self.weights = weights
    }

    public func score(track: Track, profile: UserProfile) -> Double {
        let artist = normalize(profile.artistAffinity[track.artistId] ?? 0)
        let genre = normalize(mean(track.genres.map { profile.genreAffinity[$0] ?? 0 }))
        let scene = normalize(profile.sceneAffinity[track.scene ?? ""] ?? 0)
        let mood = normalize(mean(track.moods.map { profile.moodAffinity[$0] ?? 0 }))

        let value =
            weights.artist * artist
            + weights.genre * genre
            + weights.scene * scene
            + weights.mood * mood

        return clamp(value, 0...1)
    }

    private func normalize(_ affinity: Double) -> Double {
        (clamp(affinity, -1...1) + 1) / 2
    }
}
