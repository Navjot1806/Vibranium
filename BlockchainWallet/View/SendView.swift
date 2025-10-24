// SendView.swift
import SwiftUI

struct SendView: View {
    @EnvironmentObject var walletManager: WalletManager
    @State private var toAddress: String = ""
    @State private var amount: String = ""
    @State private var selectedBlockchain = "Bitcoin"
    let blockchains = ["Bitcoin", "Ethereum", "Polygon", "Solana"]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recipient")) {
                    TextField("Recipient Address", text: $toAddress)
                }

                Section(header: Text("Asset & Amount")) {
                    Picker("Blockchain", selection: $selectedBlockchain) {
                        ForEach(blockchains, id: \.self) {
                            Text($0)
                        }
                    }
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }

                Button(action: {
                    // Ensure robust conversion to Double
                    let cleanedAmountString = amount.replacingOccurrences(of: ",", with: ".")
                    guard let doubleAmount = Double(cleanedAmountString), doubleAmount > 0 else {
                        // In a real app, you would show an error alert here
                        print("ERROR: Send action failed. Invalid or zero amount entered: '\(amount)'")
                        return
                    }
                    
                    print("ACTION: Send \(doubleAmount) \(selectedBlockchain) to \(toAddress)")
                    
                    // --- CALLS THE INTER-ACCOUNT TRANSACTION LOGIC ---
                    walletManager.sendCrypto(blockchain: selectedBlockchain, amount: doubleAmount, toAddress: toAddress)
                    
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Confirm Send")
                }
                .disabled(toAddress.isEmpty || amount.isEmpty)
            }
            .navigationTitle("Send Crypto")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
