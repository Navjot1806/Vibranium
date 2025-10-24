// BlockchainWallet/View/WalletDashboardView.swift

import SwiftUI

struct WalletDashboardView: View {
    @EnvironmentObject var walletManager: WalletManager
    @EnvironmentObject var analyticsManager: AnalyticsManager
    @State private var showingSendSheet = false
    @State private var showingReceiveSheet = false
    @State private var showingSwapSheet = false
    @State private var showingBuySheet = false
    
    // --- NEW: State for Bitbot ---
    @State private var showingBitbotChat = false
    
    var totalUSDValue: Double {
        walletManager.balances.reduce(0) { $0 + $1.usdValue }
    }
    
    var body: some View {
        NavigationView{
        ZStack {
            // 1. Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            // 2. Main Scrollable Content
            ScrollView {
                VStack(spacing: 20) {
                    // Total Balance Card
                    VStack(spacing: 10) {
                        Text("Total Portfolio Value")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Display 0.00 if not connected/balances are empty
                        Text("$\(totalUSDValue, specifier: "%.2f")")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        HStack {
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(.green)
                            Text("+12.5% (24h)")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    
                    // Blockchain Balances
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                        ForEach(walletManager.balances) { balance in
                            BlockchainBalanceCard(
                                balance: balance.balance,
                                blockchain: balance.blockchain,
                                symbol: balance.symbol,
                                usdValue: balance.usdValue
                            )
                        }
                    }
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Quick Actions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            // Buttons now disabled if no wallet is connected
                            QuickActionButton(icon: "arrow.up", title: "Send", color: .red) { showingSendSheet = true }
                                .disabled(!walletManager.isConnected)
                            QuickActionButton(icon: "arrow.down", title: "Receive", color: .green) { showingReceiveSheet = true }
                                .disabled(!walletManager.isConnected)
                            QuickActionButton(icon: "arrow.2.squarepath", title: "Swap", color: .blue) { showingSwapSheet = true }
                                .disabled(!walletManager.isConnected)
                            QuickActionButton(icon: "plus", title: "Buy", color: .purple) { showingBuySheet = true }
                                .disabled(!walletManager.isConnected)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 30)
                }
                .padding()
                .navigationTitle("Wallet")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            Task { await walletManager.fetchLivePrices() }
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                        // Disable refresh if no wallet is connected
                        .disabled(!walletManager.isConnected)
                    }
                }
            } // End ScrollView                            Task { await walletManager.fetchLivePrices()
            // 3. Apply Navigation Modifiers to the main scrollable content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // --- MODIFIED: Bitbot Button Overlay (ALWAYS SHOW) ---
            // The bot chat itself handles the 'no wallet' guidance.
            VStack {
                Spacer() // Pushes content to the bottom
                HStack {
                    // FIX: Moved Spacer to the beginning to push content to the right
                    Spacer()
                    BitbotButtonView {
                        showingBitbotChat = true
                    }
                    // FIX: Changed leading padding to trailing padding for right side spacing
                    .padding(.trailing, 20)
                    .padding(.bottom, 80) // Vertical spacing (above the standard Tab Bar)
                    // REMOVED: The old Spacer() that was here
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // End Bitbot Button Overlay
            
        } // End ZStack
    }
        // Sheet presentation modifiers remain unchanged
        .sheet(isPresented: $showingSendSheet) { SendView().environmentObject(walletManager) }
        .sheet(isPresented: $showingReceiveSheet) { ReceiveView().environmentObject(walletManager) }
        .sheet(isPresented: $showingSwapSheet) { SwapView().environmentObject(walletManager) }
        .sheet(isPresented: $showingBuySheet) { BuyView().environmentObject(walletManager) }
        
        // --- NEW: Bitbot Chat Sheet ---
        .sheet(isPresented: $showingBitbotChat) {
            BitbotChatView()
                .environmentObject(walletManager)
                .environmentObject(analyticsManager)
        }
    }
}

struct CryptoBalanceRowView: View {
    @EnvironmentObject var walletManager: WalletManager // Access to balances is still needed if this were used standalone
    let balance: WalletBalance
    
    var body: some View {
        HStack(spacing: 15) {
            // Left: Icon and Asset Names (Ethereum / ETH)
            HStack(spacing: 12) {
                Circle()
                    .fill(balance.blockchain.blockchainColor)
                    .frame(width: 30, height: 30)
                
                VStack(alignment: .leading) {
                    Text(balance.blockchain) // Ethereum
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text(balance.symbol) // ETH
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Right: USD Value and Token Amount ($3,140.20 / 0.00082 ETH)
            VStack(alignment: .trailing) {
                Text("$\(balance.usdValue, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                // Use a realistic balance format (showing up to 5 decimal places)
                Text("\(balance.balance, specifier: "%.5f") \(balance.symbol)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(Color.clear)
    }
}

