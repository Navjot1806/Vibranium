// BlockchainWallet/CoinGeckoAPI.swift

import Foundation

// This struct matches the JSON response from the CoinGecko API.
// We only need the 'usd' price, so that's the only property we'll decode.
// Example: {"bitcoin": {"usd": 65000.00}, "ethereum": {"usd": 3500.00}}

struct CoinGeckoPriceResponse: Codable {
    let bitcoin: PriceData
    let ethereum: PriceData
    let polygon: PriceData
    let solana: PriceData
    
    // Custom coding keys to map "matic-network" from the API to "polygon"
    enum CodingKeys: String, CodingKey {
        case bitcoin, ethereum, solana
        case polygon = "matic-network"
    }
}

struct PriceData: Codable {
    let usd: Double
}
