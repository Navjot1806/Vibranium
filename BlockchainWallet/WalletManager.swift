// BlockchainWallet/WalletManager.swift

import SwiftUI
import CryptoKit
import Foundation

// --- NEW: A centralized, persistent store for all wallets. ---
class WalletStore {
// ... (WalletStore implementation is unchanged)
    static let shared = WalletStore()
    
    // NEW: Keychain Service for Wallet Data (SECURE STORAGE)
    private let walletDataService = "com.vibranium.wallet.data"
    
    // NEW: UserDefaults key for address -> email map (used for simulation ONLY)
    // NOTE: This map is non-sensitive and aids in simulating local transfers.
    private let addressMapKey = "walletAddressToEmailMap"

    // Keyed by user email to ensure separation between accounts.
    
    private init() {
        // Initialization logic
    }
    
    // Internal struct to hold Codable wallet data
    struct WalletData: Codable {
        var balances: [WalletBalance]
        var transactions: [TransactionRecord]
    }
    
    // Clears data based on unique email key
    public func clearWalletData(for email: String) {
        // Now deletes from Keychain
        KeychainHelper.standard.delete(account: email, service: walletDataService)
        print("🗑️ Wallet data for \(email) removed from Keychain.")
    }
    
    // Retrieve a wallet's data using the unique email key (SECURE READ)
    func getWalletData(for email: String) -> WalletData? {
        guard let data = KeychainHelper.standard.readData(account: email, service: walletDataService),
              let decodedWallets = try? JSONDecoder().decode(WalletData.self, from: data) else {
            return nil
        }
        return decodedWallets
    }

    // Update or save a wallet's data using the unique email key (SECURE WRITE)
    func updateWalletData(for email: String, with data: WalletData) {
        if let encoded = try? JSONEncoder().encode(data) {
            // Now saves to Keychain
            KeychainHelper.standard.saveData(encoded, for: email, service: walletDataService)
        }
    }
    
    // Check if a wallet data store exists for this unique email key
    func emailHasWalletData(_ email: String) -> Bool {
        return getWalletData(for: email) != nil
    }
    
    // NEW: Public helper to manage the Address Map
    func saveAddressMapping(walletAddress: String, email: String) {
        let key = walletAddress.lowercased()
        
        var map: [String: String] = [:]
        if let mapData = UserDefaults.standard.data(forKey: addressMapKey),
           let decodedMap = try? JSONDecoder().decode([String: String].self, from: mapData) {
            map = decodedMap
        }
        
        map[key] = email
        
        if let encoded = try? JSONEncoder().encode(map) {
            UserDefaults.standard.set(encoded, forKey: addressMapKey)
        }
    }
    
    func getEmailForAddress(walletAddress: String) -> String? {
        guard let mapData = UserDefaults.standard.data(forKey: addressMapKey),
              let map = try? JSONDecoder().decode([String: String].self, from: mapData) else {
            return nil
        }
        return map[walletAddress.lowercased()]
    }
    
    // This helper is no longer possible/needed due to the secure storage architecture.
    func getAllWalletEmails() -> [String] {
        return []
    }
}
// End of WalletStore

class WalletManager: ObservableObject {
// ... (properties unchanged)
    @Published var balances: [WalletBalance] = []
    @Published var transactions: [TransactionRecord] = []
    @Published var isConnected: Bool = false
    @Published var walletAddress: String = ""
    @Published var privateKey: String = ""
    @Published var consoleOutput: [String] = []

    var currentUserEmail: String?
    
    // NEW: Keychain Service for Private Key (to be used across all calls)
    private let walletKeyService = "com.example.BlockchainWallet"

    let supportedBlockchains: [Blockchain] = [
        Blockchain(name: "Bitcoin", symbol: "BTC", color: .orange, coinGeckoId: "bitcoin"),
        Blockchain(name: "Ethereum", symbol: "ETH", color: .blue, coinGeckoId: "ethereum"),
        Blockchain(name: "Polygon", symbol: "MATIC", color: .purple, coinGeckoId: "matic-network"),
        Blockchain(name: "Solana", symbol: "SOL", color: .green, coinGeckoId: "solana")
    ]
    
    private func getFallbackPrice(for blockchain: String) -> Double {
            switch blockchain {
            case "Bitcoin": return 60000.0
            case "Ethereum": return 4000.0
            case "Polygon": return 0.75
            case "Solana": return 150.0
            default: return 1.0
        }
    }
        
    init() {
        // Balances and credentials will now be loaded on login, not on init.
    }
    
    // WalletManager.swift - LoadWallet (Modified for Security and Clarity)

    func loadWallet(for email: String) {
        self.currentUserEmail = email
        
        // 1. Check if a private key exists in Keychain (Keyed by email, using correct service)
        if let existingPrivateKey = KeychainHelper.standard.read(account: email, service: walletKeyService) {
            self.privateKey = existingPrivateKey
            
            // 🌟 Address is derived from the key, but the EMAIL is the storage key.
            self.walletAddress = "0x" + String(existingPrivateKey.prefix(40))
            
            // NEW: Ensure the address mapping is updated when a wallet is loaded/switched.
            WalletStore.shared.saveAddressMapping(walletAddress: self.walletAddress, email: email)

            // 2. Load balances and transactions from the SECURE WalletStore.
            if let walletData = WalletStore.shared.getWalletData(for: email) {
                self.balances = walletData.balances
                self.transactions = walletData.transactions
                
                logToConsole("🔑 Existing wallet credentials loaded for \(email).")
                logToConsole("✅ Wallet data loaded SECURELY from store for unique account \(email).")
            } else {
                // No stored data for this email, but key exists (first load/bug case)
                logToConsole("⚠️ Wallet key found but no data in SECURE store for \(email). Initializing new data.")
                setupInitialBalances() // Saves securely.
            }
            self.isConnected = true
            Task { await fetchLivePrices() }
        } else {
            // === MODIFIED BLOCK START ===
            // No credentials found, AUTO-CREATE a new wallet for the account.
            logToConsole("⚠️ No wallet credentials found for \(email). Automatically creating a new wallet.")
            generateNewWallet(for: email) // This handles all subsequent setup (saving key, initial balances, setting isConnected=true, fetching prices).
            // === MODIFIED BLOCK END ===
        }
    }
    
    // MARK: - Wallet Credentials Management

    func generateNewWallet(for email: String) {
        logToConsole("🔐 GENERATING NEW WALLET CREDENTIALS...")
        let privateKeyData = SymmetricKey(size: .bits256)
        let newPrivateKey = privateKeyData.withUnsafeBytes { Data($0).base64EncodedString() }
        
        // 1. Save the key to Keychain using the dedicated service.
        KeychainHelper.standard.save(password: newPrivateKey, for: email, service: walletKeyService)
        
        self.privateKey = newPrivateKey
        self.walletAddress = "0x" + String(newPrivateKey.prefix(40))
        self.isConnected = true
        
        // NEW: Save the address mapping immediately after generating the key/address
        WalletStore.shared.saveAddressMapping(walletAddress: self.walletAddress, email: email)

        setupInitialBalances() // This calls saveWalletData(), which now uses the email.
        logToConsole("🔑 Private key generated and securely saved.")
        logToConsole("📍 Wallet address: \(walletAddress)")
        Task { await fetchLivePrices() }
    }

    // REMOVED: `isKeyAlreadyInUse` because accessing other users' keys for a collision check is insecure.

    // 2. Update importExistingWallet
    func importExistingWallet(privateKey: String, for email: String) -> Bool {
        logToConsole("🔑 ATTEMPTING TO IMPORT EXISTING WALLET...")
        
        var cleanedPrivateKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedPrivateKey.lowercased().hasPrefix("0x") {
            cleanedPrivateKey.removeFirst(2)
        }
        
        // Removed the collision check for improved security architecture.
        
        let derivedAddress = "0x" + String(cleanedPrivateKey.prefix(40))
        
        // 3. Save the key to the current user's keychain (keychain is keyed by email)
        KeychainHelper.standard.save(password: cleanedPrivateKey, for: email, service: walletKeyService)
        
        // 4. Update manager state and load data from store
        self.privateKey = cleanedPrivateKey
        self.walletAddress = derivedAddress
        self.isConnected = true
        
        // NEW: Save the address mapping after updating the walletAddress
        WalletStore.shared.saveAddressMapping(walletAddress: self.walletAddress, email: email)
        
        // This re-reads/initializes the balances/txs using the unique EMAIL key.
        // NOTE: loadWallet already calls Task { await fetchLivePrices() } at its end.
        loadWallet(for: email)
        
        logToConsole("✅ Wallet key imported and securely saved for unique account \(email).")
        // REMOVED: Redundant Task { await fetchLivePrices() } call
        return true
    }

    private func saveWalletData() {
            // Save the current state to the persistent, secure WalletStore, keyed by the EMAIL.
            guard let email = self.currentUserEmail else { return }
            
            let walletData = WalletStore.WalletData(balances: self.balances, transactions: self.transactions)
            WalletStore.shared.updateWalletData(for: email, with: walletData)
            logToConsole("💾 Wallet data saved securely.")
        }

    // MARK: - Live Price Fetching
    
    @MainActor
    func fetchLivePrices() async {
        logToConsole("📊 FETCHING LIVE MARKET PRICES...")
        
        let ids = supportedBlockchains.map { $0.coinGeckoId }.joined(separator: ",")
        guard let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=\(ids)&vs_currencies=usd") else {
            logToConsole("❌ Invalid URL for price fetching.")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let priceResponse = try JSONDecoder().decode(CoinGeckoPriceResponse.self, from: data)
            
            for i in 0..<balances.count {
                let blockchain = supportedBlockchains[i]
                let price: Double
                switch blockchain.coinGeckoId {
                case "bitcoin": price = priceResponse.bitcoin.usd
                case "ethereum": price = priceResponse.ethereum.usd
                case "matic-network": price = priceResponse.polygon.usd
                case "solana": price = priceResponse.solana.usd
                default: price = 0
                }
                
                // === FIX: Robust update to trigger UI refresh ===
                var updatedBalance = balances[i] // Create a copy of the struct
                updatedBalance.usdValue = updatedBalance.balance * price // Update the USD value on the copy
                balances[i] = updatedBalance // Re-assign the copy to trigger @Published update
                // ===============================================
            }
            logToConsole("✅ Live prices updated successfully.")
            
        } catch {
            logToConsole("❌ Error fetching or decoding prices: \(error.localizedDescription)")
        }
    }
    
    // ⬇️ FIX: Set initial balances to 0.0 ⬇️
    private func setupInitialBalances() {
        logToConsole("🔧 INITIALIZING NEW WALLET (ALL BALANCES RESET TO ZERO) FOR \(self.currentUserEmail ?? "UNKNOWN")...")
        
        // Ensure balances array is completely overwritten with zeroed values.
        balances = supportedBlockchains.map { blockchain in
            WalletBalance(blockchain: blockchain.name, symbol: blockchain.symbol, balance: 0.0, usdValue: 0.0)
        }
        // Ensure transactions are empty.
        transactions = []
        
        saveWalletData() // Crucial: Save the initial empty state keyed by email.
    }
    // ⬆️ FIX: Set initial balances to 0.0 ⬆️

    // MARK: - Internal UI State Management

    // NEW Function to safely clear the in-memory UI state to all zeros.
    func resetInMemoryState() {
        self.walletAddress = ""
        self.privateKey = ""
        // Recreate the balances array with supported blockchains and 0.0 values
        self.balances = self.supportedBlockchains.map {
            WalletBalance(blockchain: $0.name, symbol: $0.symbol, balance: 0.0, usdValue: 0.0)
        }
        self.transactions = []
        self.isConnected = false
        logToConsole("🗑️ In-memory wallet state reset to zero/empty.")
    }
    
    // MARK: - Helper Functions (logToConsole moved here and made internal)
    
    // FIX: Removed 'private' to make it callable from other parts of the app (like Views).
    func logToConsole(_ message: String) {
        DispatchQueue.main.async {
            let timestamp = DateFormatter.consoleFormatter.string(from: Date())
            self.consoleOutput.append("[\(Date())] \(message)")
        }
    }
    
    // MARK: - Transaction Functions
    
    // NEW: Internal helper function to update wallet data for a receive action (used by both receiveCrypto and sendCrypto)
    private func _simulateReceive(blockchain: String, amount: Double, toAddress: String, fromAddress: String, currentData: WalletStore.WalletData?, isSelf: Bool) -> WalletStore.WalletData {
        
        // Create a basic starting WalletData if none exists in the store
        let initialBalances = supportedBlockchains.map { WalletBalance(blockchain: $0.name, symbol: $0.symbol, balance: 0.0, usdValue: 0.0) }
        var walletData = currentData ?? WalletStore.WalletData(balances: initialBalances, transactions: [])
        
        if let index = walletData.balances.firstIndex(where: { $0.blockchain == blockchain }) {
            
            let oldBalance = walletData.balances[index].balance
            let oldUsdValue = walletData.balances[index].usdValue
            
            walletData.balances[index].balance += amount
            
            let livePrice = oldBalance > 0 ? (oldUsdValue / oldBalance) : 0
            let priceToUse = livePrice > 0.0 ? livePrice : getFallbackPrice(for: blockchain)
            
            walletData.balances[index].usdValue = walletData.balances[index].balance * priceToUse
                        
            let transaction = TransactionRecord(id: UUID().uuidString, type: .receive, blockchain: blockchain, amount: amount, toAddress: toAddress, fromAddress: fromAddress, gasUsed: 0, status: .confirmed, timestamp: Date())
            walletData.transactions.insert(transaction, at: 0)
            
            if isSelf {
                // If it's the current user, update the live UI state too
                // Note: balances are updated in the store for persistence, but here we update the @Published property
                self.balances = walletData.balances
                self.transactions = walletData.transactions
                logToConsole("💰 Received \(amount) \(blockchain) from \(fromAddress)")
                
                // Immediately update USD value for display
                Task { await fetchLivePrices() }
            } else {
                logToConsole("📦 Successfully recorded receive for off-chain wallet: \(toAddress)")
            }
        }
        return walletData
    }

    // ORIGINAL PUBLIC RECEIVE FUNCTION (Updated to use the new helper and save to store)
    func receiveCrypto(blockchain: String, amount: Double, fromAddress: String) {
        guard let email = currentUserEmail else { return }
        
        // 1. Get current data from store
        let currentData = WalletStore.shared.getWalletData(for: email)
        
        // 2. Update data via helper (isSelf is true here)
        let updatedData = _simulateReceive(blockchain: blockchain, amount: amount, toAddress: self.walletAddress, fromAddress: fromAddress, currentData: currentData, isSelf: true)
        
        // 3. Save the updated data
        WalletStore.shared.updateWalletData(for: email, with: updatedData)
    }
    
    func sendCrypto(blockchain: String, amount: Double, toAddress: String) {
            logToConsole("ACTION: Attempting to send \(amount) \(blockchain) to \(toAddress)")
            
            guard let myEmail = currentUserEmail else {
                logToConsole("❌ ERROR: Sender is not logged in.")
                return
            }

            // 1. Sender validation
            guard let myBalanceIndex = balances.firstIndex(where: { $0.blockchain == blockchain }),
                  balances[myBalanceIndex].balance >= amount else {
                logToConsole("❌ Insufficient balance to send \(amount) \(blockchain).")
                return
            }
            
            // 2. Check if the recipient address belongs to another local user (simulation)
            let recipientEmail = WalletStore.shared.getEmailForAddress(walletAddress: toAddress)
            
            if let recipientEmail = recipientEmail {
                // A. INTER-ACCOUNT TRANSFER (Simulation)
                logToConsole("✅ Recipient \(toAddress) found locally. Simulating immediate receive for \(recipientEmail).")

                // a) Update Recipient's WalletData in secure store
                // === FIX: Use if-let to safely load data and prevent data corruption ===
                if let recipientData = WalletStore.shared.getWalletData(for: recipientEmail) {
                    // If data is safely loaded, proceed with the receive simulation.
                    let updatedRecipientData = _simulateReceive(blockchain: blockchain, amount: amount, toAddress: toAddress, fromAddress: walletAddress, currentData: recipientData, isSelf: false) // isSelf is FALSE
                    WalletStore.shared.updateWalletData(for: recipientEmail, with: updatedRecipientData)
                    logToConsole("✅ Recipient data updated securely with new balance and transaction history.")
                } else {
                    // Data load failed: Fallback to treating as external send.
                    logToConsole("❌ CRITICAL: Could not load existing wallet data for local recipient \(recipientEmail). Transfer recorded, but recipient's balance WILL NOT update until their next manual transaction.")
                }
                
            } else {
                // B. OUT-OF-NETWORK TRANSFER (Original Logic)
                logToConsole("⚠️ Recipient not found locally. Simulating out-of-network transfer.")
            }

            // --- SENDER SIDE UPDATE ---
            
            // 3. Deduct from sender's live state
            balances[myBalanceIndex].balance -= amount
            
            // 4. Add transaction for sender (Sender is always logged as a .send)
            let sendTransaction = TransactionRecord(id: UUID().uuidString, type: .send, blockchain: blockchain, amount: amount, toAddress: toAddress, fromAddress: walletAddress, gasUsed: 0.001, status: .confirmed, timestamp: Date())
            transactions.insert(sendTransaction, at: 0)
            
            logToConsole("✅ Sent \(amount) \(blockchain). Transaction confirmed.")
            
            // 5. Save sender's data and refresh prices
            saveWalletData()
        Task { await fetchLivePrices()
        }
    }

    func swapCrypto(fromBlockchain: String, toBlockchain: String, amount: Double) {
        logToConsole("ACTION: Swap \(amount) \(fromBlockchain) to \(toBlockchain)")
        if let fromIndex = balances.firstIndex(where: { $0.blockchain == fromBlockchain }),
           let toIndex = balances.firstIndex(where: { $0.blockchain == toBlockchain }),
           balances[fromIndex].balance >= amount {
            balances[fromIndex].balance -= amount
            balances[toIndex].balance += amount
            
            // FIX: Immediately update the usdValue for the TO asset to reflect the new balance.
            // Find the price to use (use live price if available, otherwise fallback)
            let toLivePrice = balances[toIndex].balance > 0 ? (balances[toIndex].usdValue / (balances[toIndex].balance - amount)) : 0
            
            let fallbackPrice: Double = {
                switch toBlockchain {
                case "Bitcoin": return 60000.0
                case "Ethereum": return 4000.0
                case "Polygon": return 0.75
                case "Solana": return 150.0
                default: return 1.0
                }
            }()
            
            let priceToUse = toLivePrice > 0.0 ? toLivePrice : fallbackPrice
            
            balances[toIndex].usdValue = balances[toIndex].balance * priceToUse
            // End FIX

            let transaction = TransactionRecord(id: UUID().uuidString, type: .swap, blockchain: "\(fromBlockchain) -> \(toBlockchain)", amount: amount, toAddress: walletAddress, fromAddress: walletAddress, gasUsed: 0.002, status: .confirmed, timestamp: Date())
            transactions.insert(transaction, at: 0)
            saveWalletData() // Save after transaction
            Task { await fetchLivePrices() }
        }
    }

    func buyCrypto(blockchain: String, usdAmount: Double, paymentMethod: PaymentMethod) {
        logToConsole("ACTION: Buy \(blockchain) for $\(usdAmount) via \(paymentMethod.rawValue)")
        if let index = balances.firstIndex(where: { $0.blockchain == blockchain }) {
            
            // Get the latest live price (usdValue / balance)
            let livePrice = balances[index].balance > 0 ? (balances[index].usdValue / balances[index].balance) : 0
            var updatedBalance = balances[index]
            
            // Use a recent, more realistic fallback price if the live price is unavailable (<= 0).
            let fallbackPrice: Double = {
                switch blockchain {
                case "Bitcoin": return 60000.0 // Realistic fallback for BTC
                case "Ethereum": return 4000.0  // Realistic fallback for ETH
                case "Polygon": return 0.75     // Realistic fallback for MATIC
                case "Solana": return 150.0      // Realistic fallback for SOL
                default: return 1.0
                }
            }()
            
            let priceToUse = livePrice > 0.0 ? livePrice : fallbackPrice
            
            let cryptoAmount = usdAmount / priceToUse
            
            // 2. Modify the copy
            updatedBalance.balance += cryptoAmount
            
            updatedBalance.usdValue = updatedBalance.balance * priceToUse
                            
            balances[index] = updatedBalance
            
            let transaction = TransactionRecord(id: UUID().uuidString, type: .buy, blockchain: blockchain, amount: cryptoAmount, toAddress: walletAddress, fromAddress: "Fiat Exchange", gasUsed: 0, status: .confirmed, timestamp: Date())
            transactions.insert(transaction, at: 0)
            saveWalletData() // Save after transaction
            Task { await fetchLivePrices() }
        }
    }
}
