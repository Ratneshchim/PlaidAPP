//
//  Transactions.swift
//  LinkDemo-SwiftUI
//
//  Created by Ratnesh on 6/10/23.
//

import SwiftUI
import Foundation


struct Transaction: Identifiable {
    var id = UUID()
    var amount: Double?
    var category: String?
    var date: String?
    var merchantName: String?
    // Add more properties as needed
}


struct TransactionView: View {
    @Binding public var transactions: [Transaction]
    
    var body: some View {
        List(transactions) { transaction in
            VStack(alignment: .leading) {
                Text("Amount: \(transaction.amount ?? 0)")
                Text("Category: \(transaction.category ?? "" )")
                Text("Date: \(transaction.date ?? "")")
                Text("Merchant: \(transaction.merchantName ?? "")")
            }
        }
    }
}
