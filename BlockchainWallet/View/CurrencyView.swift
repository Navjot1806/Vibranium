// BlockchainWallet/View/CurrencyView.swift

import SwiftUI

struct CurrencyView: View {
    @State private var selectedCurrency = "USD"
    let currencies = ["USD - United States Dollar", "EUR - Euro", "GBP - British Pound", "JPY - Japanese Yen"]

    var body: some View {
        Form {
            Section(header: Text("Display Currency")) {
                Picker("Select Currency", selection: $selectedCurrency) {
                    ForEach(currencies, id: \.self) { currency in
                        Text(currency)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
        }
        .navigationTitle("Currency")
        .navigationBarTitleDisplayMode(.inline)
    }
}
