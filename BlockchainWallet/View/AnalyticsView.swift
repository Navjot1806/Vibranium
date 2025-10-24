// BlockchainWallet/View/AnalyticsView.swift

import SwiftUI
import Charts

enum TimeRange: String, CaseIterable {
    case day = "1D"
    case week = "7D"
    case month = "1M"
    case year = "1Y"
    
    var days: Int {
        switch self {
        case .day: return 1
        case .week: return 7
        case .month: return 30
        case .year: return 365
        }
    }
}

struct AnalyticsView: View {
    @EnvironmentObject var analyticsManager: AnalyticsManager
    @EnvironmentObject var walletManager: WalletManager
    @State private var selectedBlockchain: Blockchain?
    @State private var selectedTimeRange: TimeRange = .month
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    BlockchainSelectorView(
                        supportedBlockchains: walletManager.supportedBlockchains,
                        selectedBlockchain: $selectedBlockchain
                    )
                    
                    if let blockchain = selectedBlockchain,
                       let history = analyticsManager.priceHistory[blockchain],
                       !history.isEmpty {
                        
                        TimeRangePicker(selectedTimeRange: $selectedTimeRange)

                        PriceChartView(blockchain: blockchain, priceHistory: history)
                        
                    } else {
                        VStack {
                            ProgressView()
                                .padding(.bottom, 10)
                            Text("Loading Chart Data...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 300)
                    }
                    
                    MarketOverviewCards(walletManager: walletManager)
                }
                .padding(.vertical)
            }
            .navigationTitle("Analytics")
            // --- NEW: Refresh Button ---
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        fetchData() // Manually trigger a refresh
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        // --- FIX: Use .onAppear and .onChange for reliable data fetching ---
        .onAppear(perform: fetchData)
        .onChange(of: selectedBlockchain) {
            fetchData()
        }
        .onChange(of: selectedTimeRange) {
            fetchData()
        }
    }

    // --- NEW: A helper function to fetch data ---
    private func fetchData() {
        // Set a default blockchain if one isn't selected
        let blockchainToFetch = selectedBlockchain ?? walletManager.supportedBlockchains.first
        
        // Update the state if it was nil
        if selectedBlockchain == nil {
            selectedBlockchain = blockchainToFetch
        }
        
        // Ensure we have a blockchain to fetch for
        guard let blockchain = blockchainToFetch else { return }
        
        // Run the async fetch task
        Task {
            await analyticsManager.fetchPriceHistory(for: blockchain, days: selectedTimeRange.days)
        }
    }
}


// Extracted subviews for better organization
struct TimeRangePicker: View {
    @Binding var selectedTimeRange: TimeRange
    
    var body: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
}

struct BlockchainSelectorView: View {
    let supportedBlockchains: [Blockchain]
    @Binding var selectedBlockchain: Blockchain?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(supportedBlockchains, id: \.self) { blockchain in
                    Button(action: {
                        selectedBlockchain = blockchain
                    }) {
                        HStack {
                            Circle().fill(blockchain.color).frame(width: 20, height: 20)
                            Text(blockchain.symbol).font(.subheadline).fontWeight(.medium)
                        }
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(selectedBlockchain == blockchain ? blockchain.color.opacity(0.2) : Color(.systemGray6))
                        .cornerRadius(20)
                    }
                    .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct MarketOverviewCards: View {
    @ObservedObject var walletManager: WalletManager
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
            ForEach(walletManager.supportedBlockchains, id: \.self) { blockchain in
                MarketOverviewCard(blockchain: blockchain)
            }
        }
        .padding(.horizontal)
    }
}
