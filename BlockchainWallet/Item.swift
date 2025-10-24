//
//  Item.swift
//  BlockchainWallet
//
//  Created by csuftitan on 9/9/25.
//
import SwiftUI
import Charts
import CryptoKit
import Network
import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
