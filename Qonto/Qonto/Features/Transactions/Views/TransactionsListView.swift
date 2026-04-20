//
//  TransactionsListView.swift
//  Qonto
//
//  Created by Daniel Souza on 20.04.26.
//

import SwiftUI

struct TransactionsListView: View {
    var body: some View {
        NavigationStack {
            List {
                TransactionRowView(name: "Daniel Souza", amount: "+24 EUR", isPositive: true, status: "Completed", statusColor: .green, date: "Today")
                TransactionRowView(name: "Amazon", amount: "-89 EUR", isPositive: false, status: "Completed", statusColor: .green, date: "Yesterday")
                TransactionRowView(name: "Spotify", amount: "-9 EUR", isPositive: false, status: "Pending", statusColor: .orange, date: "April 14th")
                TransactionRowView(name: "Salary", amount: "+3200 EUR", isPositive: true, status: "Completed", statusColor: .green, date: "April 1st")
                TransactionRowView(name: "Uber", amount: "-12 EUR", isPositive: false, status: "Declined", statusColor: .red, date: "March 28th")
            }
            .listStyle(.plain)
            .navigationTitle("Transactions")
        }
    }
}

#Preview {
    TransactionsListView()
}
