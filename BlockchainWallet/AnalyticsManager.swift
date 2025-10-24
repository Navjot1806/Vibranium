// BlockchainWallet/AnalyticsManager.swift

import SwiftUI
import Foundation

// Struct for decoding the historical data API response
struct CoinGeckoHistoryResponse: Codable {
    let prices: [[Double]]
}

// A simple Codable struct to store our cached data
struct CachedPriceHistory: Codable {
    let timestamp: Date
    let history: [PriceHistoryPoint]
}

class AnalyticsManager: ObservableObject {
    @Published var priceHistory: [Blockchain: [PriceHistoryPoint]] = [:]

    let supportedBlockchains: [Blockchain] = [
        Blockchain(name: "Bitcoin", symbol: "BTC", color: .orange, coinGeckoId: "bitcoin"),
        Blockchain(name: "Ethereum", symbol: "ETH", color: .blue, coinGeckoId: "ethereum"),
        Blockchain(name: "Polygon", symbol: "MATIC", color: .purple, coinGeckoId: "matic-network"),
        Blockchain(name: "Solana", symbol: "SOL", color: .green, coinGeckoId: "solana")
    ]

    init() {
        // --- FIX: Pre-warm the cache for all supported blockchains ---
        Task {
            for blockchain in supportedBlockchains {
                // Fetch the default 30-day history for each coin to populate the cache.
                await fetchPriceHistory(for: blockchain, days: 30)
            }
        }
    }
    
    @MainActor
    func fetchPriceHistory(for blockchain: Blockchain, days: Int) async {
        let cacheKey = "\(blockchain.coinGeckoId)-\(days)-days"
        
        // Step 1: Try to load from cache
        if let cachedData = UserDefaults.standard.data(forKey: cacheKey),
           let cachedResponse = try? JSONDecoder().decode(CachedPriceHistory.self, from: cachedData) {
            
            self.priceHistory[blockchain] = cachedResponse.history
            print("Loaded \(cachedResponse.history.count) data points for \(blockchain.name) from cache.")
            
            // If cache is recent, skip the network fetch
            if Date().timeIntervalSince(cachedResponse.timestamp) < 900 { // 15 minutes
                print("Cache is recent for \(blockchain.name). Skipping network fetch.")
                return
            }
        }
        
        // Step 2: Fetch fresh data from the network
        print("Cache is old or missing. Fetching new price history for \(blockchain.name)...")
        
        let urlString = "https://api.coingecko.com/api/v3/coins/\(blockchain.coinGeckoId)/market_chart?vs_currency=usd&days=\(days)"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(CoinGeckoHistoryResponse.self, from: data)
            
            let historyPoints = decodedResponse.prices.compactMap { priceData -> PriceHistoryPoint? in
                guard priceData.count == 2 else { return nil }
                let timestamp = priceData[0] / 1000
                let price = priceData[1]
                return PriceHistoryPoint(date: Date(timeIntervalSince1970: timestamp), price: price)
            }
            
            // Update the view with new data
            self.priceHistory[blockchain] = historyPoints
            
            // Step 3: Save new data to cache
            let newCacheEntry = CachedPriceHistory(timestamp: Date(), history: historyPoints)
            if let dataToCache = try? JSONEncoder().encode(newCacheEntry) {
                UserDefaults.standard.set(dataToCache, forKey: cacheKey)
                print("Successfully fetched and cached \(historyPoints.count) data points for \(blockchain.name).")
            }
            
        } catch {
            print("Failed to fetch price history for \(blockchain.name): \(error.localizedDescription)")
        }
    }
}
