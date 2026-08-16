#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Foundation

public enum HTTPError: Error {
    case badStatus(Int)
}

/// Minimal async JSON/form HTTP helpers (portable: Apple + Linux).
public enum HTTP {
    private static func check(_ data: Data, _ response: URLResponse) throws -> (Data, HTTPURLResponse) {
        guard let http = response as? HTTPURLResponse else { throw HTTPError.badStatus(-1) }
        guard (200..<300).contains(http.statusCode) else { throw HTTPError.badStatus(http.statusCode) }
        return (data, http)
    }

    public static func getJSON(_ url: URL, headers: [String: String] = [:]) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        for (key, value) in headers { request.setValue(value, forHTTPHeaderField: key) }
        let (data, response) = try await URLSession.shared.data(for: request)
        _ = try check(data, response)
        return data
    }

    public static func postForm(_ url: URL, fields: [String: String], headers: [String: String] = [:]) async throws -> Data {
        var components = URLComponents()
        components.queryItems = fields.map { URLQueryItem(name: $0.key, value: $0.value) }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        for (key, value) in headers { request.setValue(value, forHTTPHeaderField: key) }
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
        let (data, response) = try await URLSession.shared.data(for: request)
        _ = try check(data, response)
        return data
    }

    public static func postJSON(_ url: URL, body: [String: Any], headers: [String: String] = [:]) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        for (key, value) in headers { request.setValue(value, forHTTPHeaderField: key) }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        _ = try check(data, response)
        return data
    }
}
