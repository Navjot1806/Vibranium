// BlockchainWallet/View/SettingsView.swift

import SwiftUI
import LocalAuthentication
import UIKit

struct SettingsView: View {
    @EnvironmentObject var walletManager: WalletManager
    @EnvironmentObject var authManager: AuthenticationManager
    
    // --- REMOVED: showingResetConfirmation and showingResetSuccess states (from previous steps) ---
    @State private var showingDeleteConfirmation = false
    @State private var showingCopyFeedback = false
    // @State private var showingWalletSetupSheet = false // REMOVED
    // @State private var isImportingWallet = false // REMOVED

    // Function to handle the clean logout (no data deletion)
    private func executeLogout() {
        // Disconnect UI status and log out. Wallet data remains in storage.
        walletManager.isConnected = false
        authManager.logout()
    }

    var body: some View {
        NavigationView {
            List {
                // MARK: - Wallet Information Section
                Section(header: Text("Wallet Information")) {
                    
                    // --- Wallet Address & Copy Button ---
                    Button(action: {
                        // Only copy if the address is not empty
                        if !walletManager.walletAddress.isEmpty {
                            UIPasteboard.general.string = walletManager.walletAddress
                            showingCopyFeedback = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showingCopyFeedback = false
                            }
                        }
                    }) {
                        HStack {
                            Text("Wallet Address")
                                .foregroundColor(.primary) // Ensure visibility in Dark Mode
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                // 🌟 FIX: Use placeholder text if address is empty
                                Text(walletManager.walletAddress.isEmpty ? "No Address Loaded" : walletManager.walletAddress)
                                    .font(.caption)
                                    .foregroundColor(walletManager.walletAddress.isEmpty ? .gray : .secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                
                                if showingCopyFeedback {
                                    Text("Copied! 🎉")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                    .disabled(walletManager.walletAddress.isEmpty) // Disable button if no address is loaded
                    
                    // --- REMOVED: CREATE/IMPORT BUTTONS ---
                    
                    // Show actions only when a wallet is connected
                    if walletManager.isConnected {
                        // NEW: Re-added for the single-wallet model
                        NavigationLink(destination: BackupPhraseView()) {
                            Text("View Backup Phrase")
                        }

                        NavigationLink(destination: CryptoAssetsView()) {
                            Text("View All Crypto Assets")
                        }
                    }

                    NavigationLink(destination: SecuritySettingsView()) { Text("Security") }
                }
                
                // MARK: - Management Section (Delete, Logout)
                Section(header: Text("Management")) {
                    
                    // 1. Delete Account Button
                    Button(action: { showingDeleteConfirmation = true }) {
                        Text("Delete Account").foregroundColor(.red)
                    }
                    
                    // 2. Logout Button
                    Button(action: executeLogout) {
                        Text("Logout").foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Settings")
            
            // 3. Alert for Delete Account Confirmation
            .alert(isPresented: $showingDeleteConfirmation) {
                Alert(
                    title: Text("PERMANENTLY Delete Account?"),
                    message: Text("This will delete ALL login credentials and wallet data stored locally. You will be logged out."),
                    primaryButton: .destructive(Text("Delete")) {
                        authManager.deleteAccount()
                    },
                    secondaryButton: .cancel()
                )
            }
            
            // 4. Sheet for Wallet Setup (REMOVED)
        }
    }
}

struct CryptoAssetsView: View {
// ... (CryptoAssetsView is unchanged)
    @EnvironmentObject var walletManager: WalletManager
    
    var body: some View {
        List {
            ForEach(walletManager.balances) { balance in
                HStack {
                    VStack(alignment: .leading) {
                        Text(balance.blockchain)
                            .font(.headline)
                        Text(balance.symbol)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("\(balance.balance, specifier: "%.6f")")
                            .font(.headline)
                        Text("$\(balance.usdValue, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Crypto Assets")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task {
                        await walletManager.fetchLivePrices()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
}
