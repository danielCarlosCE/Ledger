//
//  StubRemoteTransactionsService.swift
//  Ledger
//
//  Created by Daniel Souza on 21.04.26.
//

import Foundation

public struct StubRemoteTransactionsService: RemoteTransactionsService {
    public enum Behavior {
        case success
        case failure(RemoteTransactionsServiceError)
        case loading
    }

    private let firstPageBehavior: Behavior
    private let loadMoreBehavior: Behavior

    public init(firstPage: Behavior, loadMore: Behavior) {
        self.firstPageBehavior = firstPage
        self.loadMoreBehavior = loadMore
    }

    public init(_ behavior: Behavior = .success) {
        self.init(firstPage: behavior, loadMore: behavior)
    }

    public func transactions(page: Int, itemsPerPage: Int) async throws(RemoteTransactionsServiceError) -> [Transaction] {
        let behavior = page == 1 ? firstPageBehavior : loadMoreBehavior
        switch behavior {
        case .loading:
            try? await Task.sleep(for: .seconds(3600))
            return []
        case .failure(let error):
            try? await Task.sleep(for: .seconds(1))
            throw error
        case .success:
            try? await Task.sleep(for: .seconds(1))
            guard itemsPerPage > 0, page >= 0 else { return [] }

            let start = page * itemsPerPage
            guard start < Self.totalCount else { return [] }

            let end = min(start + itemsPerPage, Self.totalCount)
            return self.makeTransactions(page: page, range: start..<end)
        }
    }

    // MARK: - Mock generation

    /// Total pool of mocked items. Pages are sliced from this pool using the
    /// view-specified `itemsPerPage`.
    private static let totalCount = 100

    private static let names = [
        "Daniel Souza", "Amazon", "Spotify", "Uber",
        "Salary", "Netflix", "Apple", "Rent"
    ]

    private static let statuses: [Transaction.Status] = [
        .completed, .completed, .completed, .pending, .declined
    ]

    /// Day offsets from today, cycled by absolute index.
    private static let dayOffsets = [0, 1, 7, 11, 14, 21, 27, 34, 60, 70, 77, 86, 99, 107]

    func makeTransactions(page: Int, itemsPerPage: Int) -> [Transaction] {
        guard itemsPerPage > 0, page >= 1 else { return [] }
        return makeTransactions(page: page, range: 0..<itemsPerPage)
    }

    private func makeTransactions(page: Int, range: Range<Int>) -> [Transaction] {
        let calendar = Calendar.current
        let now = Date.now

        return range.enumerated().map { localIndex, absoluteIndex in
            let name = Self.names[absoluteIndex % Self.names.count]
            let status = Self.statuses[absoluteIndex % Self.statuses.count]
            let dayOffset = Self.dayOffsets[absoluteIndex % Self.dayOffsets.count]
            let isIncoming = (absoluteIndex % 3 == 0)
            let side: Transaction.Side = isIncoming ? .credit : .debit
            let magnitude = (absoluteIndex + 1) * 12
            let value = "\(magnitude).00"
            let settledAt = calendar.date(byAdding: .day, value: -dayOffset, to: now)

            return Transaction(
                id: "p\(page)-i\(localIndex)",
                counterparty: name,
                amount: Transaction.Amount(currency: "EUR", value: value),
                status: status,
                side: side,
                settledAt: settledAt
            )
        }
    }
}
