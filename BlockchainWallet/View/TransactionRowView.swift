//
//  TransactionRowView.swift
//  BlockchainWallet
//
//  Created by csuftitan on 9/9/25.
//
import SwiftUI
import Charts
import CryptoKit
import Network

struct TransactionRowView: View {
    let transaction: TransactionRecord
    let walletAddress: String
    var isReceived: Bool {
        transaction.toAddress.lowercased() == walletAddress.lowercased()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Blockchain indicator
            Circle()
                .fill(transaction.blockchain.blockchainColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: isReceived ? "arrow.down" : "arrow.up")
                        .foregroundColor(.white)
                        .font(.caption)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(transaction.blockchain.blockchainSymbol)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(isReceived ? "+" : "-")\(transaction.amount, specifier: "%.4f")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isReceived ? .green : .red)
                }
                
                HStack {
                    Text(isReceived ? "From" : "To")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String((isReceived ? transaction.fromAddress : transaction.toAddress).prefix(10)) + "...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Circle()
                        .fill(transaction.status.blockchainStatusColor)
                        .frame(width: 8, height: 8)
                }
                
                Text(transaction.timestamp, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
