//
//  Route.swift
//  Qonto
//
//  Created by Daniel Souza on 21.04.26.
//

import Foundation

public enum HTTPMethod {
    case get(queryItems: [URLQueryItem] = [])
}

public struct Route<Response: Decodable> {
    public let baseURL: URL
    public let path: String
    public let method: HTTPMethod

    public init?(
        baseURL: URL? = URL(string: "https://us-central1-qonto-staging.cloudfunctions.net"),
        path: String,
        method: HTTPMethod = .get()
    ) {
        guard let baseURL else { return nil }
        self.baseURL = baseURL
        self.path = path
        self.method = method
    }
}
