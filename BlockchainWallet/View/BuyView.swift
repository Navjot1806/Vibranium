// BuyView.swift
import SwiftUI

struct BuyView: View {
    @EnvironmentObject var walletManager: WalletManager
    @State private var selectedBlockchain = "Bitcoin"
    @State private var usdAmount: String = ""
    @State private var paymentMethod: PaymentMethod = .creditCard
    let blockchains = ["Bitcoin", "Ethereum", "Polygon", "Solana"]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Asset")) {
                    Picker("Blockchain", selection: $selectedBlockchain) {
                        ForEach(blockchains, id: \.self) { Text($0) }
                    }
                }

                Section(header: Text("Amount")) {
                    TextField("USD Amount", text: $usdAmount)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Payment")) {
                    Picker("Payment Method", selection: $paymentMethod) {
                        ForEach(PaymentMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                }

                Button(action: {
                    // FIX: Sanitize the input string to ensure robust conversion to Double.
                    // This handles common issues like users entering a comma (",") instead of a period (".")
                    // as the decimal separator, which causes Double() to fail silently and exit the function.
                    let cleanedAmountString = usdAmount.replacingOccurrences(of: ",", with: ".")
                    
                    guard let doubleAmount = Double(cleanedAmountString), doubleAmount > 0 else {
                        print("ERROR: Buy action failed. Invalid or zero USD amount entered: '\(usdAmount)'")
                        return
                    }
                    
                    print("ACTION: Buy \(selectedBlockchain) for $\(doubleAmount) using \(paymentMethod.rawValue)")
                    walletManager.buyCrypto(blockchain: selectedBlockchain, usdAmount: doubleAmount, paymentMethod: paymentMethod)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Continue")
                }
                .disabled(usdAmount.isEmpty)
            }
            .navigationTitle("Buy Crypto")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
