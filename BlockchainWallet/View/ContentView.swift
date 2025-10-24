// BlockchainWallet/View/ContentView.swift
//
// MODIFIED by AI for Video Splash Screen and NavigationView Fix
//
import SwiftUI

struct ContentView: View {
    @StateObject private var walletManager = WalletManager()
    @StateObject private var analyticsManager = AnalyticsManager()
    @StateObject private var authManager = AuthenticationManager()

    @State private var isLoading = true
    @State private var isSplashReadyToDismiss = false
    
    private let primaryPink = Color(red: 1.0, green: 0.08, blue: 0.58)
    private let darkBackground = Color(red: 0.05, green: 0.05, blue: 0.05)

    var body: some View {
        ZStack {
            darkBackground.edgesIgnoringSafeArea(.all)
            
            Group {
                // --- MODIFIED: Use !isSplashReadyToDismiss for splash screen ---
                if !isSplashReadyToDismiss {
                    // Pass the binding to the splash view. It now controls the timing.
                    SplashView(isSplashReadyToDismiss: $isSplashReadyToDismiss)
                } else if authManager.isLoggedIn {
                    // 🌟 MODIFIED: ALWAYS go to the TabView if logged in.
                    // The wallet connection check is now handled inside WalletDashboardViewImpl.
                    NavigationView {
                        TabView {
                            WalletDashboardView()
                                .environmentObject(walletManager)
                                .environmentObject(analyticsManager) // <-- ADDED: Pass AnalyticsManager for Bitbot
                                .tabItem {Image(systemName: "wallet.pass.fill");Text("Wallet")}
                              
                            AnalyticsView()
                                .environmentObject(analyticsManager)
                                .environmentObject(walletManager)
                                .tabItem { Image(systemName: "chart.line.uptrend.xyaxis"); Text("Analytics") }
                              
                            TransactionsViewsImpl()
                                .environmentObject(walletManager)
                                .tabItem { Image(systemName: "arrow.left.arrow.right"); Text("Transactions") }
                              
                            SettingsView()
                                .environmentObject(walletManager)
                                .environmentObject(authManager)
                                .tabItem { Image(systemName: "gear"); Text("Settings") }
                        }
                        // Accent color removed for default blue/system tint
                    } // End of NavigationView
                    .navigationViewStyle(.stack) // Recommended style for modern iOS apps
                        
                } else {
                    LoginView()
                        .environmentObject(authManager)
                        .accentColor(primaryPink)
                }
            }
            .preferredColorScheme(.dark)
            .onAppear { // <-- FIX 1: Check and load session on app launch/reappear
                if authManager.validateSession(), let email = authManager.currentUserEmail {
                    walletManager.loadWallet(for: email)
                }
            }
            .onChange(of: authManager.currentUserEmail) { oldEmail, newEmail in
                    if let email = newEmail {
                        walletManager.loadWallet(for: email)
                    } else {
                        // FIX 2: User logged out: reset UI state to zero/empty
                        walletManager.isConnected = false
                        walletManager.resetInMemoryState() // <-- NEW: Resets in-memory balances and address
                    }
                }
        }
    }
}
