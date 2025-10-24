// BlockchainWallet/Models.swift

import SwiftUI
import Foundation

// --- MODIFIED: Made the structs Codable to allow saving ---
struct WalletData: Codable {
    var balances: [WalletBalance]
    var transactions: [TransactionRecord]
}

struct TransactionRecord: Codable, Identifiable {
    let id: String
    let type: TransactionType
    let blockchain: String
    let amount: Double
    let toAddress: String
    let fromAddress: String
    let gasUsed: Double
    let status: TransactionStatus
    let timestamp: Date
}

// Enums with raw values are automatically Codable
enum TransactionType: String, Codable, CaseIterable {
    case send = "Send"
    case receive = "Receive"
    case swap = "Swap"
    case buy = "Buy"
}

enum TransactionStatus: String, Codable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case failed = "Failed"
}

enum PaymentMethod: String, Codable, CaseIterable {
    case creditCard = "Credit Card"
    case bankTransfer = "Bank Transfer"
    case paypal = "PayPal"
    case applePay = "Apple Pay"
}

struct Blockchain: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let symbol: String
    let color: Color
    let coinGeckoId: String
}

struct WalletBalance: Identifiable, Codable {
    let id: UUID
    let blockchain: String
    let symbol: String
    var balance: Double
    var usdValue: Double
    
    // Custom initializer for creating new balances
    init(blockchain: String, symbol: String, balance: Double, usdValue: Double) {
        self.id = UUID()
        self.blockchain = blockchain
        self.symbol = symbol
        self.balance = balance
        self.usdValue = usdValue
    }
}

struct InflationData: Identifiable {
    let id = UUID()
    let date: Date
    let rate: Double
}

// --- All extensions remain the same ---
extension String {
    var blockchainColor: Color {
        switch self.lowercased() {
        case "bitcoin", "btc":
            return .orange
        case "ethereum", "eth":
            return .blue
        case "polygon", "matic":
            return .purple
        case "solana", "sol":
            return .green
        default:
            return .gray
        }
    }
}

extension TransactionStatus {
    var blockchainStatusColor: Color {
        switch self {
        case .pending:
            return .orange
        case .confirmed:
            return .green
        case .failed:
            return .red
        }
    }
}

extension String {
    var blockchainSymbol: String {
        switch self.lowercased() {
        case "bitcoin":
            return "BTC"
        case "ethereum":
            return "ETH"
        case "polygon":
            return "MATIC"
        case "solana":
            return "SOL"
        default:
            return self.uppercased()
        }
    }
}

extension DateFormatter {
    static let consoleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}

struct PriceHistoryPoint: Identifiable, Codable{
    let id = UUID()
    let date: Date
    let price: Double
}
