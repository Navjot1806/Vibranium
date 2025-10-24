//
//  InflationChartView.swift
//  BlockchainWallet
//
//  Created by csuftitan on 9/9/25.
//
import SwiftUI
import Charts
import CryptoKit
import Network

struct InflationChartView: View {
    let blockchain: Blockchain
    let data: [InflationData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("\(blockchain.name) Inflation Rate")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("12M")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            Chart(data) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Inflation Rate", item.rate)
                )
                .foregroundStyle(blockchain.color)
                .lineStyle(StrokeStyle(lineWidth: 2))
                
                AreaMark(
                    x: .value("Date", item.date),
                    y: .value("Inflation Rate", item.rate)
                )
                .foregroundStyle(blockchain.color.opacity(0.2))
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let rate = value.as(Double.self) {
                            Text("\(rate, specifier: "%.1f")%")
                                .font(.caption)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month, count: 3)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Current Rate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(data.last?.rate ?? 0, specifier: "%.2f")%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Avg. 12M")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(data.map(\.rate).reduce(0, +) / Double(data.count), specifier: "%.2f")%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

