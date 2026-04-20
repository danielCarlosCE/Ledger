//
//  TransactionRowView.swift
//  Qonto
//
//  Created by Daniel Souza on 20.04.26.
//

import SwiftUI

struct TransactionRowView: View {
    let name: String
    let amount: String
    let isPositive: Bool
    let status: String
    let statusColor: Color
    let date: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                Spacer()
                Text(amount)
                    .fontWeight(.semibold)
                    .foregroundStyle(isPositive ? .green : .red)
            }
            HStack(spacing: 6) {
                Image(systemName: "circle.fill")
                    .font(.system(size: 6))
                    .foregroundStyle(statusColor)
                    .accessibilityHidden(true)
                Text(status)
                Text("·")
                Text(date)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySentence)
    }

    var accessibilitySentence: String {
        let digits = amount.drop { !$0.isNumber }
        let preposition = isPositive ? "from" : "to"
        return "\(status) payment of \(digits) \(preposition) \(name), \(date)"
    }
}

#Preview {
    List {
        TransactionRowView(name: "Salary", amount: "+3200 EUR", isPositive: true, status: "Completed", statusColor: .green, date: "Today")
        TransactionRowView(name: "Amazon", amount: "-89 EUR", isPositive: false, status: "Completed", statusColor: .green, date: "Yesterday")
        TransactionRowView(name: "Spotify", amount: "-9 EUR", isPositive: false, status: "Pending", statusColor: .orange, date: "April 14th")
        TransactionRowView(name: "Uber", amount: "-12 EUR", isPositive: false, status: "Declined", statusColor: .red, date: "March 28th")
    }
    .listStyle(.plain)
}
