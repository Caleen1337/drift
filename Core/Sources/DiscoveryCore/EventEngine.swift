import Foundation

public enum DiscoverySignals {
    public static let like = 1.0
    public static let dislike = -1.0
    public static let immediateSkip = -0.7
    public static let lateSkip = -0.1
    public static let fullPlay = 0.3
    public static let replay = 0.8
    public static let openedInSpotify = 0.2
    public static let artistOpened = 0.2

    public static func weight(for event: PlaybackEvent) -> Double {
        switch event.type {
        case .liked: return like
        case .disliked: return dislike
        case .skipped:
            if let ratio = event.completionRatio, ratio >= 0.8 { return lateSkip }
            return immediateSkip
        case .playCompleted: return fullPlay
        case .replayed: return replay
        case .openedInSpotify: return openedInSpotify
        case .artistOpened: return artistOpened
        default: return 0
        }
    }
}

/// Applies a stream of events to a `UserProfile` (FlowNeuro-inspired learning).
public struct EventEngine {
    public let decay: Double
    public let noveltyNudge: Double

    public init(decay: Double = 0.995, noveltyNudge: Double = 0.02) {
        self.decay = decay
        self.noveltyNudge = noveltyNudge
    }

    public func apply(_ event: PlaybackEvent, context: EventContext, to profile: inout UserProfile) {
        // 1. Fatigue counters (always tracked).
        profile.recentArtistCount[event.artistId, default: 0] += 1
        for genre in context.genres {
            profile.recentGenreCount[genre, default: 0] += 1
        }
        profile.heardTrackIds.insert(event.trackId)

        // 2. Gentle decay so the profile follows taste drift over time.
        profile.artistAffinity = decayMap(profile.artistAffinity)
        profile.genreAffinity = decayMap(profile.genreAffinity)
        profile.sceneAffinity = decayMap(profile.sceneAffinity)
        profile.eraAffinity = decayMap(profile.eraAffinity)
        profile.moodAffinity = decayMap(profile.moodAffinity)

        // 3. Explicit feedback weight.
        let signal = DiscoverySignals.weight(for: event)
        if signal != 0 {
            profile.artistAffinity[event.artistId] = clamp(
                (profile.artistAffinity[event.artistId] ?? 0) + signal, -1...1)
            for genre in context.genres {
                profile.genreAffinity[genre] = clamp(
                    (profile.genreAffinity[genre] ?? 0) + signal * 0.6, -1...1)
            }
            if let scene = context.scene {
                profile.sceneAffinity[scene] = clamp(
                    (profile.sceneAffinity[scene] ?? 0) + signal * 0.5, -1...1)
            }
            for mood in context.moods {
                profile.moodAffinity[mood] = clamp(
                    (profile.moodAffinity[mood] ?? 0) + signal * 0.4, -1...1)
            }
            if event.type == .disliked {
                profile.negativeArtistScore[event.artistId, default: 0] += 1
            }
        }

        // 4. Artist exploration boosts.
        switch event.type {
        case .artistOpened:
            profile.artistAffinity[event.artistId] = clamp(
                (profile.artistAffinity[event.artistId] ?? 0) + DiscoverySignals.artistOpened, -1...1)
            profile.explorationTendency = clamp(profile.explorationTendency + noveltyNudge, 0...1)
        case .replayed:
            profile.noveltyTolerance = clamp(profile.noveltyTolerance - noveltyNudge, 0...1)
        default:
            break
        }

        // 5. Novelty feedback: recommendations flagged as novel nudge tolerance.
        if event.context["isNovel"] == "true" {
            if event.type == .liked || event.type == .playCompleted {
                profile.noveltyTolerance = clamp(profile.noveltyTolerance + noveltyNudge, 0...1)
            } else if event.type == .disliked || event.type == .skipped {
                profile.noveltyTolerance = clamp(profile.noveltyTolerance - noveltyNudge, 0...1)
            }
        }

        // 6. Block lists.
        if event.context["blockArtist"] == "true" {
            profile.blockedArtists.insert(event.artistId)
        }
        if event.context["blockGenre"] == "true" {
            profile.blockedGenres.formUnion(context.genres)
        }

        profile.updatedAt = event.timestamp
    }

    private func decayMap(_ map: [String: Double]) -> [String: Double] {
        var result: [String: Double] = [:]
        for (key, value) in map {
            let decayed = value * decay
            if abs(decayed) > 0.005 { result[key] = decayed }
        }
        return result
    }
}
