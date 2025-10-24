//
//  MarketOverviewCard.swift
//  BlockchainWallet
//
//  Created by csuftitan on 9/9/25.
//
import SwiftUI
import Charts
import CryptoKit
import Network

struct MarketOverviewCard: View {
    let blockchain: Blockchain
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(blockchain.color)
                    .frame(width: 25, height: 25)
                Text(blockchain.symbol)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            Text("$\(Double.random(in: 1000...50000), specifier: "%.0f")")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("+\(Double.random(in: 1...15), specifier: "%.1f")% 24h")
                .font(.caption)
                .foregroundColor(.green)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}
