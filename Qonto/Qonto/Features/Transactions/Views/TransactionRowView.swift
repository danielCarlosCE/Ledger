//
//  TransactionRowView.swift
//  Qonto
//
//  Created by Daniel Souza on 20.04.26.
//

import SwiftUI

struct TransactionRowView: View {
    let row: TransactionRow

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(row.counterpartyName)
                Spacer()
                Text(row.amount)
                    .fontWeight(.semibold)
                    .foregroundStyle(row.isIncoming ? .green : .red)
            }
            HStack(spacing: 6) {
                Image(systemName: "circle.fill")
                    .font(.system(size: 6))
                    .foregroundStyle(statusColor)
                Text(statusText)
                Text("·")
                Text(row.date)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(row.accessibilityLabel)
    }

    private var statusText: String {
        switch row.status {
        case .completed: "Completed"
        case .pending: "Pending"
        case .declined: "Declined"
        }
    }

    private var statusColor: Color {
        switch row.status {
        case .completed: .green
        case .pending: .orange
        case .declined: .red
        }
    }
}

#Preview {
    List {
        TransactionRowView(row: TransactionRow(
            id: "1", counterpartyName: "Salary", amount: "+3200 EUR",
            isIncoming: true, status: .completed, date: "Today"
        ))
        TransactionRowView(row: TransactionRow(
            id: "2", counterpartyName: "Amazon", amount: "-89 EUR",
            isIncoming: false, status: .completed, date: "Yesterday"
        ))
        TransactionRowView(row: TransactionRow(
            id: "3", counterpartyName: "Spotify", amount: "-9 EUR",
            isIncoming: false, status: .pending, date: "April 14th"
        ))
        TransactionRowView(row: TransactionRow(
            id: "4", counterpartyName: "Uber", amount: "-12 EUR",
            isIncoming: false, status: .declined, date: "March 28th"
        ))
    }
    .listStyle(.plain)
}
