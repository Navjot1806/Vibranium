// BlockchainWallet/View/TranscationView.swift

import SwiftUI

struct TransactionsViewsImpl: View {
    @EnvironmentObject var walletManager: WalletManager
    @State private var selectedFilter: TransactionFilter = .all
    
    enum TransactionFilter: String, CaseIterable {
        case all = "All"
        case sent = "Sent"
        case received = "Received"
        case pending = "Pending"
    }
    
    // --- MODIFIED: Added primary filtering logic based on wallet address ---
    var filteredTransactions: [TransactionRecord] {
        let walletAddress = walletManager.walletAddress.lowercased()
        
        // 1. Filter transactions to include ONLY those belonging to the current wallet
        let ownerTransactions = walletManager.transactions.filter { transaction in
            // A transaction belongs to the wallet if the wallet address is the sender OR the receiver.
            return transaction.fromAddress.lowercased() == walletAddress ||
                   transaction.toAddress.lowercased() == walletAddress
        }
        
        // 2. Sort by timestamp (newest first)
        let sortedTransactions = ownerTransactions.sorted(by: { $0.timestamp > $1.timestamp })
        
        // 3. Apply the view filter (All, Sent, Received, Pending)
        switch selectedFilter {
        case .all:
            return sortedTransactions
            
        case .sent:
            // "Sent" means the current wallet is the sender (fromAddress) for send and swap actions.
            // Swaps are complex, but in this model, they are grouped under 'Sent' (from an external view perspective).
            return sortedTransactions.filter {
                ($0.type == .send || $0.type == .swap) && $0.fromAddress.lowercased() == walletAddress
            }
            
        case .received:
            // "Received" means the current wallet is the receiver (toAddress) for receive and buy actions.
            return sortedTransactions.filter {
                ($0.type == .buy || $0.type == .receive) && $0.toAddress.lowercased() == walletAddress
            }
            
        case .pending:
            // Pending status is checked across all owner transactions.
            return sortedTransactions.filter { $0.status == .pending }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(TransactionFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if filteredTransactions.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "tray.fill")
                            .font(.largeTitle)
                            .foregroundColor(.secondary.opacity(0.5))
                            .padding(.bottom, 5)
                        Text("No Transactions")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Your \(selectedFilter.rawValue.lowercased()) transactions will appear here.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Spacer()
                    }
                    .padding()
                } else {
                    List {
                        ForEach(filteredTransactions) { transaction in
                            TransactionRowView(transaction: transaction, walletAddress: walletManager.walletAddress)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Transactions")
        }
    }
}
