import XCTest
@testable import DiscoveryCore

final class SpotifyAuthTests: XCTestCase {
    func testCodeVerifierFormat() {
        let verifier = SpotifyAuth.codeVerifier()
        XCTAssertEqual(verifier.count, 43)
        XCTAssertFalse(verifier.contains("+"))
        XCTAssertFalse(verifier.contains("/"))
        XCTAssertFalse(verifier.contains("="))
    }

    func testCodeChallengeFormat() {
        let verifier = SpotifyAuth.codeVerifier()
        let challenge = SpotifyAuth.codeChallenge(for: verifier)
        XCTAssertEqual(challenge.count, 43)
        XCTAssertNotEqual(challenge, verifier)
    }

    func testCodeChallengeIsDeterministic() {
        let verifier = "test-verifier-1234567890"
        let a = SpotifyAuth.codeChallenge(for: verifier)
        let b = SpotifyAuth.codeChallenge(for: verifier)
        XCTAssertEqual(a, b)
    }
}
