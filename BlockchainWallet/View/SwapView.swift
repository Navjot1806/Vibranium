// SwapView.swift
import SwiftUI

struct SwapView: View {
    @EnvironmentObject var walletManager: WalletManager
    @State private var fromBlockchain = "Bitcoin"
    @State private var toBlockchain = "Ethereum"
    @State private var amount: String = ""
    let blockchains = ["Bitcoin", "Ethereum", "Polygon", "Solana"]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("From")) {
                    Picker("Asset", selection: $fromBlockchain) {
                        ForEach(blockchains, id: \.self) { Text($0) }
                    }
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("To")) {
                    Picker("Asset", selection: $toBlockchain) {
                        ForEach(blockchains, id: \.self) { Text($0) }
                    }
                }

                Button(action: {
                    guard let doubleAmount = Double(amount) else { return }
                    print("ACTION: Swap \(doubleAmount) \(fromBlockchain) to \(toBlockchain)")
                    walletManager.swapCrypto(fromBlockchain: fromBlockchain, toBlockchain: toBlockchain, amount: doubleAmount)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Review Swap")
                }
                .disabled(amount.isEmpty || fromBlockchain == toBlockchain)
            }
            .navigationTitle("Swap Crypto")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
