// BlockchainWallet/View/PriceChartView.swift

import SwiftUI
import Charts

struct PriceChartView: View {
    let blockchain: Blockchain
    let priceHistory: [PriceHistoryPoint]
    
    // Find the min and max prices to set the chart's Y-axis scale
    private var minPrice: Double {
        priceHistory.min(by: { $0.price < $1.price })?.price ?? 0
    }
    private var maxPrice: Double {
        priceHistory.max(by: { $0.price < $1.price })?.price ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            HStack {
                Text("\(blockchain.name) Price")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                // The time range picker will be in the parent view.
            }

            // Price Details
            VStack(alignment: .leading, spacing: 4) {
                Text("$\(priceHistory.last?.price ?? 0, specifier: "%.2f")")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Calculate and display price change
                let priceChange = (priceHistory.last?.price ?? 0) - (priceHistory.first?.price ?? 0)
                let percentageChange = ((priceHistory.last?.price ?? 0) / (priceHistory.first?.price ?? 1)) - 1
                
                HStack(spacing: 8) {
                    Image(systemName: priceChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                    Text("\(priceChange, specifier: "%.2f") (\(percentageChange * 100, specifier: "%.2f")%)")
                }
                .font(.subheadline)
                .foregroundColor(priceChange >= 0 ? .green : .red)
            }

            // Chart
            if !priceHistory.isEmpty {
                Chart(priceHistory) { item in
                    // Main price line
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Price", item.price)
                    )
                    .foregroundStyle(blockchain.color)
                    .interpolationMethod(.cardinal) // Smoother line
                    
                    // Gradient area below the line
                    AreaMark(
                        x: .value("Date", item.date),
                        y: .value("Price", item.price)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [blockchain.color.opacity(0.4), .clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.cardinal)
                }
                .chartYScale(domain: minPrice...maxPrice) // Dynamic scale
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let price = value.as(Double.self) {
                                Text("$\(price, specifier: "%.0f")")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .chartXAxis(.hidden) // Hide X-axis for a cleaner look
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}
