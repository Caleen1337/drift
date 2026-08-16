import Foundation
import DiscoveryCore

enum MockData {
    static let tracks: [Track] = [
        Track(
            id: "burial-archangel", title: "Archangel", artistId: "burial", artistName: "Burial",
            albumId: "untrue", albumName: "Untrue", durationSeconds: 238,
            spotifyId: "3R0t0bY2H8Sd1CmXNCl5T7", genres: ["UK Garage", "Dubstep", "Electronic"],
            era: "00s", releaseYear: 2007, popularity: 0.58,
            moods: ["Melancholic", "Night"], scene: "UK electronic"
        ),
        Track(
            id: "forest-swords-irby", title: "The Weight of Gold", artistId: "forest-swords", artistName: "Forest Swords",
            durationSeconds: 244, genres: ["Ambient", "Experimental"], era: "10s", releaseYear: 2017,
            popularity: 0.31, moods: ["Atmospheric", "Night"], scene: "UK electronic"
        ),
        Track(
            id: "andy-stott-faith", title: "Faith in Strangers", artistId: "andy-stott", artistName: "Andy Stott",
            durationSeconds: 356, genres: ["Dub Techno", "Ambient"], era: "10s", releaseYear: 2014,
            popularity: 0.28, moods: ["Dark", "Hypnotic"], scene: "UK electronic"
        ),
        Track(
            id: "four-tet-evening", title: "Evening Side", artistId: "four-tet", artistName: "Four Tet",
            durationSeconds: 560, genres: ["Electronic", "Microhouse"], era: "10s", releaseYear: 2015,
            popularity: 0.42, moods: ["Warm", "Deep"], scene: "UK electronic"
        ),
        Track(
            id: "aphex-avril", title: "Avril 14th", artistId: "aphex", artistName: "Aphex Twin",
            durationSeconds: 125, genres: ["Ambient", "IDM"], era: "00s", releaseYear: 2001,
            popularity: 0.66, moods: ["Melancholic", "Warm"], scene: "IDM"
        ),
        Track(
            id: "floating-points-king", title: "King Bromeliad", artistId: "floating-points", artistName: "Floating Points",
            durationSeconds: 562, genres: ["Jazz", "Electronic"], era: "10s", releaseYear: 2015,
            popularity: 0.36, moods: ["Organic", "Deep"], scene: "UK electronic"
        ),
        Track(
            id: "ben-frost-theory", title: "Theory of Machines", artistId: "ben-frost", artistName: "Ben Frost",
            durationSeconds: 294, genres: ["Experimental", "Drone"], era: "10s", releaseYear: 2014,
            popularity: 0.2, moods: ["Dark", "Intense"], scene: "Experimental"
        ),
        Track(
            id: "bjork-hyper", title: "Hyperballad", artistId: "bjork", artistName: "Björk",
            durationSeconds: 320, genres: ["Art Pop", "Electronic"], era: "90s", releaseYear: 1995,
            popularity: 0.63, moods: ["Dreamy", "Warm"], scene: "Art pop"
        )
    ]

    static let artists: [Artist] = [
        Artist(id: "burial", name: "Burial", genres: ["UK Garage", "Dubstep"], scene: "UK electronic", popularity: 0.6),
        Artist(id: "forest-swords", name: "Forest Swords", genres: ["Ambient"], scene: "UK electronic", popularity: 0.3),
        Artist(id: "aphex", name: "Aphex Twin", genres: ["IDM", "Ambient"], scene: "IDM", popularity: 0.7)
    ]
}
