import Foundation

public struct SessionContext: Codable {
    public enum Period: String, Codable {
        case morning
        case work
        case evening
        case deep
    }

    public var period: Period
    public var hour: Int
    public var weekday: Int
    public var isWeekend: Bool

    public init(period: Period = .evening, hour: Int = 18, weekday: Int = 1, isWeekend: Bool = false) {
        self.period = period
        self.hour = hour
        self.weekday = weekday
        self.isWeekend = isWeekend
    }

    public static func current(_ date: Date = Date(), calendar: Calendar = .current) -> SessionContext {
        let hour = calendar.component(.hour, from: date)
        let weekday = calendar.component(.weekday, from: date)
        let isWeekend = weekday == 1 || weekday == 7
        let period: Period
        switch hour {
        case 5..<11: period = .morning
        case 11..<17: period = .work
        case 17..<23: period = .evening
        default: period = .deep
        }
        return SessionContext(period: period, hour: hour, weekday: weekday, isWeekend: isWeekend)
    }
}

public struct UserProfile: Codable {
    public var artistAffinity: [String: Double]
    public var genreAffinity: [String: Double]
    public var sceneAffinity: [String: Double]
    public var eraAffinity: [String: Double]
    public var moodAffinity: [String: Double]
    public var negativeArtistScore: [String: Double]
    public var blockedArtists: Set<String>
    public var blockedGenres: Set<String>
    public var recentArtistCount: [String: Int]
    public var recentGenreCount: [String: Int]
    public var heardTrackIds: Set<String>
    public var noveltyTolerance: Double
    public var explorationTendency: Double
    public var updatedAt: Date

    public init(
        artistAffinity: [String: Double] = [:],
        genreAffinity: [String: Double] = [:],
        sceneAffinity: [String: Double] = [:],
        eraAffinity: [String: Double] = [:],
        moodAffinity: [String: Double] = [:],
        negativeArtistScore: [String: Double] = [:],
        blockedArtists: Set<String> = [],
        blockedGenres: Set<String> = [],
        recentArtistCount: [String: Int] = [:],
        recentGenreCount: [String: Int] = [:],
        heardTrackIds: Set<String> = [],
        noveltyTolerance: Double = 0.5,
        explorationTendency: Double = 0.5,
        updatedAt: Date = Date()
    ) {
        self.artistAffinity = artistAffinity
        self.genreAffinity = genreAffinity
        self.sceneAffinity = sceneAffinity
        self.eraAffinity = eraAffinity
        self.moodAffinity = moodAffinity
        self.negativeArtistScore = negativeArtistScore
        self.blockedArtists = blockedArtists
        self.blockedGenres = blockedGenres
        self.recentArtistCount = recentArtistCount
        self.recentGenreCount = recentGenreCount
        self.heardTrackIds = heardTrackIds
        self.noveltyTolerance = noveltyTolerance
        self.explorationTendency = explorationTendency
        self.updatedAt = updatedAt
    }
}

public enum DiscoveryMode: String, Codable, CaseIterable {
    case safe
    case balanced
    case deep
    case chaos

    public var title: String {
        switch self {
        case .safe: return "Safe"
        case .balanced: return "Balanced"
        case .deep: return "Deep"
        case .chaos: return "Chaos"
        }
    }

    public var explorationRatio: Double {
        switch self {
        case .safe: return 0.2
        case .balanced: return 0.4
        case .deep: return 0.7
        case .chaos: return 0.95
        }
    }
}
