//
//  BlockchainBalanceCatd.swift
//  BlockchainWallet
//
//  Created by csuftitan on 9/9/25.
//
import SwiftUI
import Charts
import CryptoKit
import Network

struct BlockchainBalanceCard: View {
    // ✅ CORRECTED PROPERTIES TO MATCH BlockchainBalance
    let balance: Double
    let blockchain: String
    let symbol: String
    var usdValue: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    // ✅ USING blockchainColor EXTENSION
                    .fill(blockchain.blockchainColor)
                    .frame(width: 30, height: 30)
                
                VStack(alignment: .leading) {
                    Text(symbol)
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text(blockchain)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(balance, specifier: "%.4f") \(symbol)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("$\(usdValue, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
