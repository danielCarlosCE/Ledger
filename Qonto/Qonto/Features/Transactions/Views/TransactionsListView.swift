//
//  TransactionsListView.swift
//  Qonto
//
//  Created by Daniel Souza on 20.04.26.
//

import SwiftUI

struct TransactionsListView: View {
    @State private var viewModel: TransactionsViewModel
    // Bumped on load-more retry to force a fresh ProgressView identity — see `.id(...)` on the sentinel.
    @State private var loadMoreKey = UUID()
    private let itemsPerPage: Int

    init(itemsPerPage: Int = 20, viewModel: TransactionsViewModel) {
        self.itemsPerPage = itemsPerPage
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Transactions")
        }
        .task {
            await viewModel.load(itemsPerPage: itemsPerPage)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle: EmptyView()
        case .loading:
            ProgressView() {
                Text("loading...")
            }
        case .loaded(let content):
            List {
                ForEach(content.rows) { row in
                    TransactionRowView(row: row)
                }

                loadMoreFooter(for: content)
            }
            .listStyle(.plain)
        case .error(let kind):
            ContentUnavailableView {
                Label(kind.title, systemImage: icon(for: kind))
            } description: {
                Text(kind.message)
            } actions: {
                Button("Try again") {
                    Task { await viewModel.load(itemsPerPage: itemsPerPage) }
                }
            }
        }
    }

    @ViewBuilder
    private func loadMoreFooter(for content: TransactionsViewModel.State.Content) -> some View {
        switch content.loadMoreState {
        case .hasMore:
            ProgressView()
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
                .accessibilityLabel("Loading more transactions")
                // ProgressView's UIKit-backed indicator may not resume after reuse; page + retry key
                // gives a fresh id for most cases (new page on scroll, new key on retry).
                .id("\(content.page)-\(loadMoreKey)")
                .onAppear {
                    Task { await viewModel.loadMore() }
                }

        case .error(let kind):
            HStack {
                Spacer()
                VStack(spacing: 8) {
                    Label(kind.message, systemImage: icon(for: kind))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Try again") {
                        loadMoreKey = UUID()
                        Task { await viewModel.loadMore() }
                    }
                    .buttonStyle(.bordered)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden)

        case .ended:
            EmptyView()
        }
    }

    private func icon(for kind: TransactionsViewModel.ErrorKind) -> String {
        switch kind {
        case .offline: "wifi.slash"
        case .general: "exclamationmark.triangle"
        }
    }
}

private let previewItemsPerPage = 15

#Preview("Success") {
    TransactionsListView(
        itemsPerPage: previewItemsPerPage,
        viewModel: TransactionsViewModel(remote: StubRemoteTransactionsService(.success))
    )
}

#Preview("Offline") {
    TransactionsListView(
        itemsPerPage: previewItemsPerPage,
        viewModel: TransactionsViewModel(remote: StubRemoteTransactionsService(.failure(.offline)))
    )
}

#Preview("General Error") {
    TransactionsListView(
        itemsPerPage: previewItemsPerPage,
        viewModel: TransactionsViewModel(remote: StubRemoteTransactionsService(.failure(.general(NSError()))))
    )
}

#Preview("Loading") {
    TransactionsListView(
        itemsPerPage: previewItemsPerPage,
        viewModel: TransactionsViewModel(remote: StubRemoteTransactionsService(.loading))
    )
}

#Preview("Load more fails") {
    TransactionsListView(
        itemsPerPage: previewItemsPerPage,
        viewModel: TransactionsViewModel(
            remote: StubRemoteTransactionsService(firstPage: .success, loadMore: .failure(.offline))
        )
    )
}
