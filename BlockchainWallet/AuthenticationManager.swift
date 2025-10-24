// BlockchainWallet/AuthenticationManager.swift

import Foundation
import Combine

class AuthenticationManager: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUserEmail: String?
    
    // --- NEW: Keys for UserDefaults and Keychain Service ---
    private let userDefaultsKey = "lastLoggedInUserEmail"
    private let authService = "com.vibranium.auth" // Distinct service ID for passwords
    private let walletService = "com.example.BlockchainWallet" // Default service ID for wallet keys
    private let walletKeyService = "com.example.BlockchainWallet" // Key for Private Key string
    private let walletDataService = "com.vibranium.wallet.data" // Key for Encrypted WalletData object
    
    init() {
        if let email = UserDefaults.standard.string(forKey: userDefaultsKey) {
                    self.currentUserEmail = email
                    print("Loaded last known user email: \(email). User must re-authenticate.")
                }
    }
    
    func validateSession() -> Bool {
        guard let email = currentUserEmail else {
            return false
        }
            // Check if credentials for the last user exist (simulating a quick Keychain lookup for a session)
        if KeychainHelper.standard.read(account: email, service: authService) != nil {
            isLoggedIn = true
            print("Session validated for \(email).")
            return true
        }
        return false
    }

    func signUp(user: User) -> Bool {
        // --- MODIFIED: Use distinct service ID ---
        if KeychainHelper.standard.read(account: user.email, service: authService) != nil {
            return false
        }
        KeychainHelper.standard.save(password: user.password, for: user.email, service: authService)
        print("User signed up and credentials saved to Keychain.")
        return true
    }

    func login(credentials: Credentials) -> Bool {
        // --- MODIFIED: Use distinct service ID ---
        guard let storedPassword = KeychainHelper.standard.read(account: credentials.email, service: authService) else {
            return false
        }
        
        if credentials.password == storedPassword {
            isLoggedIn = true
            // --- MODIFIED: Set and persist the current user's email on successful login ---
            currentUserEmail = credentials.email
            UserDefaults.standard.set(credentials.email, forKey: userDefaultsKey)
            print("Login successful for \(credentials.email).")
            return true
        }
        
        return false
    }
    
    func logout() {
        isLoggedIn = false
        // --- MODIFIED: Clear the user email and persistent login on logout ---
        currentUserEmail = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        print("User logged out and persistent login cleared.")
    }
    
    // --- NEW: Function to delete the user's account ---
    func deleteAccount() {
        guard let email = currentUserEmail else {
            print("ERROR: Cannot delete account, no current user email.")
            return
        }
        
        // 1. Delete Wallet Private Key from Keychain
        KeychainHelper.standard.delete(account: email, service: walletKeyService) //
                
                // 2. Delete Login Credentials (Password) from Keychain
        KeychainHelper.standard.delete(account: email, service: authService) //
                
                // 3. Delete Wallet Data from SECURE Keychain Storage
        KeychainHelper.standard.delete(account: email, service: walletDataService)
                
                // 4. Clear session and log out
        logout()
                
        print("🗑️ User account and all associated credentials and wallet data deleted for \(email).")
    }
}

struct User {
// ... (User struct is unchanged)
    let email: String
    let password: String
}

struct Credentials {
// ... (Credentials struct is unchanged)
    var email: String
    var password: String
}
