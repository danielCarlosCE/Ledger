//
//  TransactionsViewModel.swift
//  Qonto
//
//  Created by Daniel Souza on 20.04.26.
//

import Foundation

@Observable
final class TransactionsViewModel {

    private(set) var state: State = .idle

    private var itemsPerPage: Int = 0
    private var isLoadingMore: Bool = false
    private var source: DataSource = .remote
    private let remote: RemoteTransactionsService
    private let local: LocalTransactionsService

    init(
        remote: RemoteTransactionsService = DefaultRemoteTransactionsService(),
        local: LocalTransactionsService = DefaultLocalTransactionsService()
    ) {
        self.remote = remote
        self.local = local
    }

    func load(itemsPerPage: Int) async {
        self.itemsPerPage = itemsPerPage
        state = .loading
        source = .remote
        do {
            let transactions = try await remote.transactions(page: 1, itemsPerPage: itemsPerPage)
            setFirstPage(transactions)
            await refreshCache(with: transactions)
        } catch RemoteTransactionsServiceError.offline {
            await fallbackToCacheIfPossible()
        } catch {
            state = .error(.general)
        }
    }

    /// Safe to call repeatedly — in-flight calls are ignored. Allows retry after an error.
    func loadMore() async {
        guard
            case .loaded(var content) = state,
            !isLoadingMore,
            content.loadMoreState != .ended
        else {
            return
        }

        isLoadingMore = true
        defer { isLoadingMore = false }

        content.loadMoreState = .hasMore
        state = .loaded(content)

        let nextPage = content.page + 1
        switch source {
        case .local:  await loadMoreLocal(page: nextPage)
        case .remote: await loadMoreRemote(page: nextPage)
        }
    }

    private func loadMoreLocal(page: Int) async {
        let transactions = await local.transactions(page: page, itemsPerPage: itemsPerPage)
        appendNextPage(transactions, page: page)
    }

    private func loadMoreRemote(page: Int) async {
        do {
            let transactions = try await remote.transactions(page: page, itemsPerPage: itemsPerPage)
            appendNextPage(transactions, page: page)
            await local.save(transactions)
        } catch RemoteTransactionsServiceError.offline {
            setLoadMoreError(.offline)
        } catch {
            setLoadMoreError(.general)
        }
    }

    private func setFirstPage(_ transactions: [Transaction]) {
        let rows = makeRows(from: transactions)
        let loadMoreState: LoadMoreState = transactions.count == itemsPerPage ? .hasMore : .ended
        state = .loaded(State.Content(rows: rows, page: 1, loadMoreState: loadMoreState))
    }

    private func appendNextPage(_ transactions: [Transaction], page: Int) {
        guard case .loaded(var updated) = state else { return }
        let newRows = makeRows(from: transactions)
        updated.rows.append(contentsOf: newRows)
        updated.page = page
        updated.loadMoreState = transactions.count == itemsPerPage ? .hasMore : .ended
        state = .loaded(updated)
    }

    private func refreshCache(with transactions: [Transaction]) async {
        await local.deleteAll()
        await local.save(transactions)
    }

    private func fallbackToCacheIfPossible() async {
        let cached = await local.transactions(page: 1, itemsPerPage: itemsPerPage)
        guard !cached.isEmpty else {
            state = .error(.offline)
            return
        }
        source = .local
        setFirstPage(cached)
    }

    private func setLoadMoreError(_ kind: ErrorKind) {
        guard case .loaded(var content) = state else { return }
        content.loadMoreState = .error(kind)
        state = .loaded(content)
    }

    // MARK: - Domain → UI mapping

    private func makeRows(from transactions: [Transaction]) -> [TransactionRow] {
        transactions.map { transaction in
            TransactionRow(
                id: transaction.id,
                counterparty: transaction.counterparty,
                amount: formatAmount(transaction.amount, side: transaction.side),
                isIncoming: transaction.side == .credit,
                status: rowStatus(from: transaction.status),
                date: humanReadableDate(for: transaction.settledAt)
            )
        }
    }

    private func formatAmount(_ amount: Transaction.Amount, side: Transaction.Side) -> String {
        let sign = side == .credit ? "+" : "-"
        return "\(sign)\(amount.value) \(amount.currency)"
    }

    private func rowStatus(from status: Transaction.Status) -> TransactionRow.Status {
        switch status {
        case .completed: .completed
        case .pending: .pending
        case .declined: .declined
        }
    }

    private func humanReadableDate(for date: Date?) -> String? {
        guard let date else { return nil }
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}

extension TransactionsViewModel {

    // MARK: - Types

    enum State {
        case idle
        case loading
        case loaded(Content)
        case error(ErrorKind)

        struct Content {
            var rows: [TransactionRow]
            var page: Int
            var loadMoreState: LoadMoreState = .hasMore
        }
    }

    enum LoadMoreState: Equatable {
        case hasMore
        case error(ErrorKind)
        case ended
    }

    enum DataSource {
        case remote
        case local
    }

    enum ErrorKind: Equatable {
        case offline
        case general

        var title: String {
            switch self {
            case .offline: "You're offline"
            case .general: "Something went wrong"
            }
        }

        var message: String {
            switch self {
            case .offline: "Check your connection and try again."
            case .general: "Please try again in a moment."
            }
        }
    }
}
