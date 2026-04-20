//
//  TransactionsListView.swift
//  Qonto
//
//  Created by Daniel Souza on 20.04.26.
//

import SwiftUI

struct TransactionsListView: View {
    @State private var viewModel = TransactionsViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Transactions")
        }
        .task {
            await viewModel.load()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView() {
                Text("loading...")
            }
        case .loaded(let rows):
            List(rows) { row in
                TransactionRowView(row: row)
            }
            .listStyle(.plain)
        }
    }
}

#Preview {
    TransactionsListView()
}
