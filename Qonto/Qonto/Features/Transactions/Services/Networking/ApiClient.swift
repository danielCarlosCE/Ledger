//
//  ApiClient.swift
//  Qonto
//
//  Created by Daniel Souza on 21.04.26.
//

import Foundation

public final class ApiClient {
    private let session: URLSession

    /// ISO8601 with fractional seconds matches the backend's `settledAt`
    /// values (e.g. `"2026-03-26T03:33:09.163Z"`).
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func fetch<Response: Decodable>(_ route: Route<Response>) async throws -> Response {
        guard let request = makeRequest(for: route) else { throw URLError(.badURL) }
        let (data, response) = try await session.data(for: request)
        guard
            let httpResponse = response as? HTTPURLResponse,
            (200..<300).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(Response.self, from: data)
    }

    private func makeRequest<Response>(for route: Route<Response>) -> URLRequest? {
        switch route.method {
        case let .get(queryItems):
            guard var components = URLComponents(url: route.baseURL, resolvingAgainstBaseURL: false) else {
                return nil
            }
            components.path = (components.path + route.path).replacingOccurrences(of: "//", with: "/")
            components.queryItems = queryItems.isEmpty ? nil : queryItems
            guard let url = components.url else { return nil }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            return request
        }
    }
}
