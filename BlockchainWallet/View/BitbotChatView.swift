// BlockchainWallet/View/BitbotChatView.swift

import SwiftUI

struct BitbotChatView: View {
    @EnvironmentObject var analyticsManager: AnalyticsManager
    @EnvironmentObject var walletManager: WalletManager
    @Environment(\.dismiss) var dismiss
    
    @State private var messageInput: String = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hello! I am Bitbot. I track market trends to give you advice. How can I help you manage your portfolio today? Ask me: 'Should I buy BTC?' or 'What is your opinion on SOL?'", isBot: true)
    ]
    
    // --- NEW: Transaction Flow State ---
    @State private var currentFlow: TransactionFlow = .inactive

    // Define the conversation flow states
    enum TransactionFlow {
        case inactive
        // Buy: asset, current step, collected amount, collected payment method
        case buy(asset: String, step: Int, usdAmount: Double?, paymentMethod: PaymentMethod?)
        // Swap: from asset, to asset, current step, collected amount
        case swap(fromAsset: String, toAsset: String?, step: Int, amount: Double?)
        
        var isTransactionActive: Bool {
            if case .inactive = self { return false }
            return true
        }
        
        var currentAsset: String? {
            switch self {
            case .buy(let asset, _, _, _): return asset
            case .swap(let fromAsset, _, _, _): return fromAsset
            case .inactive: return nil
            }
        }
    }

    struct ChatMessage: Identifiable {
        let id = UUID()
        let text: String
        let isBot: Bool
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Chat History Area
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(messages) { message in
                                ChatBubble(message: message)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    .onChange(of: messages.count) {
                        // Scroll to bottom on new message
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input Area
                HStack {
                    TextField(currentFlow.isTransactionActive ? "Type amount, payment, or 'cancel'..." : "Ask Bitbot...", text: $messageInput, axis: .vertical)
                        .padding(10)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                        .lineLimit(5)

                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                            .foregroundColor(.pink)
                    }
                    .disabled(messageInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("Bitbot - AI Advisor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func sendMessage() {
        let userText = messageInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userText.isEmpty else { return }
        
        messageInput = ""
        messages.append(ChatMessage(text: userText, isBot: false))
        
        // Simulate thinking time and respond
        Task {
            // A slight delay to simulate processing
            try await Task.sleep(for: .milliseconds(500))
            await generateBotResponse(for: userText)
        }
    }
    
    @MainActor
    private func generateBotResponse(for message: String) {
        let normalizedMessage = message.lowercased()
        
        // --- PHASE 1: Handle Active Transaction Flow (New) ---
        if currentFlow.isTransactionActive {
            processActiveFlow(for: normalizedMessage)
            return
        }

        // --- PHASE 2: Check for New Transaction Initiation (Buy, Swap, Sell) ---
        for blockchain in walletManager.supportedBlockchains {
            let symbol = blockchain.symbol.lowercased()
            let name = blockchain.name.lowercased()
            
            // Buy BTC
            if normalizedMessage.contains("buy") && (normalizedMessage.contains(symbol) || normalizedMessage.contains(name)) {
                // Initialize Buy flow
                currentFlow = .buy(asset: blockchain.name, step: 1, usdAmount: nil, paymentMethod: nil)
                messages.append(ChatMessage(text: "Understood. You want to **buy \(blockchain.symbol)**. How much USD do you want to spend? (e.g., '100')", isBot: true))
                return
            }
            
            // Selling intent is redirected to Swap (Sell BTC -> Swap BTC to ETH)
            if normalizedMessage.contains("sell") && (normalizedMessage.contains(symbol) || normalizedMessage.contains(name)) {
                // Initialize Swap flow, setting fromAsset.
                currentFlow = .swap(fromAsset: blockchain.name, toAsset: nil, step: 1, amount: nil)
                messages.append(ChatMessage(text: "Bitbot is here to help you **sell \(blockchain.symbol)**. What amount of \(blockchain.symbol) do you want to sell/swap?", isBot: true))
                return
            }

            // Swap MATIC
            if normalizedMessage.contains("swap") && (normalizedMessage.contains(symbol) || normalizedMessage.contains(name)) {
                // Initialize Swap flow (From Asset is detected, To Asset is unknown)
                currentFlow = .swap(fromAsset: blockchain.name, toAsset: nil, step: 1, amount: nil)
                messages.append(ChatMessage(text: "Let's set up a **swap from \(blockchain.symbol)**. What amount of \(blockchain.symbol) do you wish to swap?", isBot: true))
                return
            }
        }
        
        // --- PHASE 3: Handle General Chat & Market Advice (Original Logic) ---
        
        if normalizedMessage.contains("hello") || normalizedMessage.contains("hi") {
            messages.append(ChatMessage(text: "Welcome back! The crypto market is buzzing. What specific asset or action are you curious about? Or, ask me to Buy/Swap/Sell.", isBot: true))
            return
        }
        
        for blockchain in walletManager.supportedBlockchains {
            if normalizedMessage.contains(blockchain.symbol.lowercased()) || normalizedMessage.contains(blockchain.name.lowercased()) {
                messages.append(ChatMessage(text: analyzeAndAdvise(for: blockchain), isBot: true))
                return
            }
        }
        
        // Check for general 'buy/sell/swap' without an asset
        if normalizedMessage.contains("buy") || normalizedMessage.contains("sell") || normalizedMessage.contains("swap") {
            messages.append(ChatMessage(text: "I can guide you! But I need to know the specific asset. Try asking: 'Should I \(normalizedMessage.contains("buy") ? "buy" : "sell") ETH?'", isBot: true))
            return
        }

        // Final fallback
        messages.append(ChatMessage(text: "My apologies. I'm a specialized market bot. Please ask for advice on a supported asset (BTC, ETH, MATIC, SOL) or initiate a transaction: 'Buy ETH', 'Sell SOL', or 'Swap MATIC'.", isBot: true))
    }
    
    // --- NEW: Helper to process the conversation flow step-by-step ---
    @MainActor
    private func processActiveFlow(for message: String) {
        // Handle cancel/exit command
        if message.contains("cancel") || message.contains("stop") || message.contains("no") {
            currentFlow = .inactive
            messages.append(ChatMessage(text: "Transaction cancelled. I'm ready for your next command.", isBot: true))
            return
        }

        switch currentFlow {
        // --- BUY FLOW ---
        case .buy(let asset, let step, let usdAmount, let paymentMethod):
            var newFlow: TransactionFlow? = nil
            var botResponse: String? = nil
            
            // STEP 1: Get USD Amount
            if step == 1 {
                if let amount = extractAmount(from: message) {
                    newFlow = .buy(asset: asset, step: 2, usdAmount: amount, paymentMethod: nil)
                    let availableMethods = PaymentMethod.allCases.map { $0.rawValue }.joined(separator: ", ")
                    botResponse = "Great! You want to buy \(asset) for $\(String(format: "%.2f", amount)). What payment method will you use? (e.g., '\(PaymentMethod.creditCard.rawValue)', '\(PaymentMethod.bankTransfer.rawValue)')"
                } else {
                    botResponse = "I couldn't detect a valid USD amount. Please reply with a number (e.g., '100') or 'cancel'."
                }
            }
            
            // STEP 2: Get Payment Method
            else if step == 2 {
                if let method = extractPaymentMethod(from: message) {
                    newFlow = .buy(asset: asset, step: 3, usdAmount: usdAmount, paymentMethod: method)
                    botResponse = "Final check: You are about to **buy \(asset)** for **$\(String(format: "%.2f", usdAmount ?? 0))** using **\(method.rawValue)**. Please confirm by replying 'YES'."
                } else {
                    let availableMethods = PaymentMethod.allCases.map { $0.rawValue }.joined(separator: ", ")
                    botResponse = "I don't recognize that payment method. Please choose from: \(availableMethods)."
                }
            }
            
            // STEP 3: Confirmation
            else if step == 3 && message.contains("yes") {
                if let finalAmount = usdAmount, let finalMethod = paymentMethod {
                    executeBuy(asset: asset, usdAmount: finalAmount, method: finalMethod)
                    return // The executeBuy function handles messaging and flow reset
                } else {
                    botResponse = "Something went wrong with the details. Please try again or type 'cancel'."
                    newFlow = .inactive
                }
            }
            
            if let newFlow = newFlow {
                currentFlow = newFlow
            }
            if let response = botResponse {
                messages.append(ChatMessage(text: response, isBot: true))
            }
            
            case .swap(let fromAsset, let toAsset, let step, let amount): // toAsset is optional
                var newFlow: TransactionFlow? = nil
                var botResponse: String? = nil
            
            // STEP 1: Get Amount (Also for 'Sell' intent)
            if step == 1 {
                if let swapAmount = extractAmount(from: message) {
                    newFlow = .swap(fromAsset: fromAsset, toAsset: nil, step: 2, amount: swapAmount)
                    let availableSymbols = walletManager.supportedBlockchains.map { $0.symbol }.joined(separator: ", ")
                    botResponse = "Got it. You want to swap **\(String(format: "%.4f", swapAmount)) \(walletManager.supportedBlockchains.first(where: {$0.name == fromAsset})?.symbol ?? fromAsset)**. What asset do you want to swap it to? (e.g., \(availableSymbols))"
                } else {
                    botResponse = "I couldn't detect a valid amount of \(fromAsset). Please reply with a number (e.g., '0.5') or 'cancel'."
                }
            }
            
            // STEP 2: Get To Asset
            else if step == 2 {
                if let toBlockchain = extractBlockchain(from: message) {
                    newFlow = .swap(fromAsset: fromAsset, toAsset: toBlockchain.name, step: 3, amount: amount)
                    
                    let fromSymbol = walletManager.supportedBlockchains.first(where: {$0.name == fromAsset})?.symbol ?? fromAsset
                    botResponse = "Final check: You are about to **swap \(String(format: "%.4f", amount ?? 0)) \(fromSymbol)** to **\(toBlockchain.name)**. Please confirm by replying 'YES'."
                } else {
                    let availableAssets = walletManager.supportedBlockchains.map { $0.symbol }.joined(separator: ", ")
                    botResponse = "I don't recognize that asset. Please choose from: \(availableAssets) or 'cancel'."
                }
            }

            // STEP 3: Confirmation
            else if step == 3 && message.contains("yes") {
                    if let finalToAsset = toAsset, let finalAmount = amount {
                                
                        executeSwap(fromAsset: fromAsset, toAsset: finalToAsset, amount: finalAmount)
                        return // The executeSwap function handles messaging and flow reset
                    } else {
                        botResponse = "Something went wrong with the details. Please try again or type 'cancel'."
                        newFlow = .inactive
                        }
                }
            
            if let newFlow = newFlow {
                currentFlow = newFlow
            }
            if let response = botResponse {
                messages.append(ChatMessage(text: response, isBot: true))
            }
            
        case .inactive:
            break
        }
    }
    
    // --- NEW: Helper for extracting values from user input ---

    private func extractAmount(from message: String) -> Double? {
        let numericString = message.replacingOccurrences(of: ",", with: ".").filter { "0123456789.".contains($0) }
        return Double(numericString)
    }

    private func extractPaymentMethod(from message: String) -> PaymentMethod? {
        for method in PaymentMethod.allCases {
            if message.lowercased().contains(method.rawValue.lowercased()) {
                return method
            }
        }
        return nil
    }
    
    private func extractBlockchain(from message: String) -> Blockchain? {
        for blockchain in walletManager.supportedBlockchains {
            if message.lowercased().contains(blockchain.name.lowercased()) || message.lowercased().contains(blockchain.symbol.lowercased()) {
                return blockchain
            }
        }
        return nil
    }
    
    // --- NEW: Execution Helpers, using WalletManager to complete transactions ---
    
    @MainActor
    private func executeBuy(asset: String, usdAmount: Double, method: PaymentMethod) {
        walletManager.buyCrypto(blockchain: asset, usdAmount: usdAmount, paymentMethod: method)
        
        let message = "Transaction Complete: You successfully initiated a **Buy of \(asset)** for **$\(String(format: "%.2f", usdAmount))** using \(method.rawValue). Check your wallet for updated balance!"
        messages.append(ChatMessage(text: message, isBot: true))
        
        currentFlow = .inactive
    }
    
    @MainActor
    private func executeSwap(fromAsset: String, toAsset: String, amount: Double) {
        let fromBalance = walletManager.balances.first(where: { $0.blockchain == fromAsset })?.balance ?? 0.0
        
        if fromBalance < amount {
            messages.append(ChatMessage(text: "Transaction Failed: Insufficient balance. You only have \(String(format: "%.4f", fromBalance)) \(walletManager.supportedBlockchains.first(where: {$0.name == fromAsset})?.symbol ?? fromAsset).", isBot: true))
        } else {
            walletManager.swapCrypto(fromBlockchain: fromAsset, toBlockchain: toAsset, amount: amount)
            
            let fromSymbol = walletManager.supportedBlockchains.first(where: {$0.name == fromAsset})?.symbol ?? fromAsset
            let toSymbol = walletManager.supportedBlockchains.first(where: {$0.name == toAsset})?.symbol ?? toAsset

            let message = "Transaction Complete: You successfully **Swapped \(String(format: "%.4f", amount)) \(fromSymbol)** to **\(toSymbol)**. Check your wallet for updated balances!"
            messages.append(ChatMessage(text: message, isBot: true))
        }
        
        currentFlow = .inactive
    }
    
    // Core logic: Simulate advice generation based on 30-day trend (Original code)
    private func analyzeAndAdvise(for blockchain: Blockchain) -> String {
        guard let history = analyticsManager.priceHistory[blockchain], history.count >= 20 else {
            // Re-fetch the data if it's missing or insufficient
            Task {
                await analyticsManager.fetchPriceHistory(for: blockchain, days: 30)
            }
            return "Bitbot is fetching the latest 30-day market data for \(blockchain.symbol). Please wait one moment and ask again."
        }
        
        // Use the full available history for a more dramatic analysis (if full 30 days are present)
        let oldestPrice = history.first?.price ?? 0.0
        let currentPrice = history.last?.price ?? 0.0
        
        let percentageChange = ((currentPrice / oldestPrice) - 1) * 100
        let trend = currentPrice > oldestPrice ? "UP" : "DOWN"
        
        let baseMessage = "Based on my real-time (simulated) 30-day tracking, \(blockchain.name) (\(blockchain.symbol)) is currently trending **\(trend)** with a **\(percentageChange > 0 ? "+" : "")\(String(format: "%.2f", percentageChange))%** move over the period."
        
        if percentageChange >= 15.0 {
            return baseMessage + "\n\n**Bitbot's Opinion: STRONG SELL/EXCHANGE.** The asset is overbought. Consider realizing significant profits or exchanging for a stablecoin now."
        } else if percentageChange >= 5.0 {
            return baseMessage + "\n\n**Bitbot's Opinion: SELL.** The rally looks mature. It's time to take some profits off the table."
        } else if percentageChange >= 0.0 {
            return baseMessage + "\n\n**Bitbot's Opinion: HOLD.** The moderate trend suggests stability. Hold your position, but be ready to sell if the trend slows down."
        } else if percentageChange >= -10.0 {
            return baseMessage + "\n\n**Bitbot's Opinion: BUY.** The dip appears to be a consolidation phase. This is a good opportunity to accumulate more."
        } else {
            return baseMessage + "\n\n**Bitbot's Opinion: STRONG BUY.** The market is oversold. This offers a historically low entry point for the long term."
        }
    }
}

// Helper view for the impressive chat bubble styling
struct ChatBubble: View {
    let message: BitbotChatView.ChatMessage
    
    var body: some View {
        HStack {
            if message.isBot {
                Image(systemName: "brain.head.profile.fill")
                    .foregroundColor(.pink)
                    .frame(width: 30, height: 30)
            }
            
            Text(message.text)
                .padding(10)
                .background(message.isBot ? Color.pink.opacity(0.15) : Color.blue.opacity(0.15))
                .foregroundColor(message.isBot ? .primary : .blue)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(message.isBot ? Color.pink : Color.blue, lineWidth: 1)
                )
            
            if !message.isBot {
                Spacer()
            }
            if message.isBot {
                Spacer()
            }
        }
        .id(message.id)
        .frame(maxWidth: .infinity, alignment: message.isBot ? .leading : .trailing)
        .padding(.leading, message.isBot ? 0 : 50)
        .padding(.trailing, message.isBot ? 50 : 0)
    }
}
