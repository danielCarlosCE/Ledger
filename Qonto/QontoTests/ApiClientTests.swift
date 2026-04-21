//
//  ApiClientTests.swift
//  QontoTests
//
//  Created by Daniel Souza on 21.04.26.
//

import Testing
import Foundation
@testable import Qonto

struct DefaultApiClientTests {

    @Test("Given an ISO8601 date with fractional seconds, when decoded, then the parsed Date matches the expected instant")
    func decoderParsesFractionalSecondsDate() throws {
        let client = DefaultApiClient()
        let json = Data("""
        {
            "settledAt": "2025-06-15T10:30:45.000Z"
        }
        """.utf8)

        struct Wrapper: Decodable { let settledAt: Date }
        let decoded = try client.decoder.decode(Wrapper.self, from: json)

        var comps = DateComponents()
        comps.year = 2025
        comps.month = 6
        comps.day = 15
        comps.hour = 10
        comps.minute = 30
        comps.second = 45
        comps.timeZone = TimeZone(identifier: "UTC")
        let expected = Calendar(identifier: .gregorian).date(from: comps)!

        #expect(decoded.settledAt == expected)
    }
}
