//
//  Route.swift
//  Ledger
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

    public init(
        baseURL: URL = Config.apiBaseURL,
        path: String,
        method: HTTPMethod = .get()
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
    }
}
