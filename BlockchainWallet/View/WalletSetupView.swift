// BlockchainWallet/View/WalletSetupView.swift

import SwiftUI
import Charts
import CryptoKit
import Network
import Combine

struct WalletSetupView: View {
    @EnvironmentObject var walletManager: WalletManager
    @State private var showingImportSheet = false
    @State private var privateKeyInput = ""
    @Binding var currentUserEmail: String?
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // --- NEW: Dismiss environment for modal presentation ---
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        // --- MODIFIED: Removed NavigationView for cleaner modal presentation ---
        VStack(spacing: 30) {
            
            VStack(spacing: 20) {
                Image(systemName: "wallet.pass.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Wallet Setup") // MODIFIED: Changed title
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your gateway to decentralized finance")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 15) {
                Button(action: {
                    if let email = currentUserEmail {
                        walletManager.generateNewWallet(for: email)
                        // --- NEW: Dismiss the sheet on successful creation ---
                        dismiss()
                    }
                }) {
                    Text("Create New Wallet")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    privateKeyInput = ""
                    showingImportSheet = true
                }) {
                    Text("Import Existing Wallet")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
            }
            .padding(.horizontal, 30)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            
        }
        .padding()
        // --- NEW: Add a navigation title and Cancel button for the sheet/modal ---
        .navigationTitle("Wallet Setup")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingImportSheet) {
            // ImportWalletView is wrapped in a NavigationView and dismissed on its own.
            ImportWalletView(privateKeyInput: $privateKeyInput) {
                showingImportSheet = false // Dismiss nested sheet
                
                if let email = currentUserEmail {
                    let success = walletManager.importExistingWallet(privateKey: privateKeyInput, for: email)
                    
                    if success {
                        // --- NEW: Dismiss the main setup sheet on successful import ---
                        dismiss()
                    } else {
                        alertTitle = "Import Failed"
                        alertMessage = "No existing wallet data found for this key. Please create a new wallet first."
                        showingAlert = true
                    }
                } else {
                    alertTitle = "Error"
                    alertMessage = "User is not logged in."
                    showingAlert = true
                }
            }
        }
    }
}
