// BlockchainWallet/KeychainHelper.swift

import Foundation
import Security

class KeychainHelper {

    // Make this a singleton so we have a single, shared instance.
    static let standard = KeychainHelper()
    private init() {}

    // MARK: - Save
    func save(password: String, for account: String, service: String = "com.example.BlockchainWallet") {
        guard let passwordData = password.data(using: .utf8) else { return }

        // The query to find an existing item or to use for a new one.
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        // Attributes for the new item if one needs to be created, or attributes to update.
        let attributes: [String: Any] = [
            kSecValueData as String: passwordData
        ]

        // First, try to update an existing item.
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        // If the item doesn't exist, add a new one.
        if status == errSecItemNotFound {
            var newQuery = query
            newQuery[kSecValueData as String] = passwordData
            SecItemAdd(newQuery as CFDictionary, nil)
        }
    }

    // MARK: - Read
    func read(account: String, service: String = "com.example.BlockchainWallet") -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess {
            guard let retrievedData = dataTypeRef as? Data,
                  let password = String(data: retrievedData, encoding: .utf8) else {
                return nil
            }
            return password
        } else {
            return nil // No password found for this account.
        }
    }

    // MARK: - NEW: Generic Save/Update (Data/Object)
        func saveData(_ data: Data, for account: String, service: String) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]

            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]

            let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

            if status == errSecItemNotFound {
                var newQuery = query
                newQuery[kSecValueData as String] = data
                SecItemAdd(newQuery as CFDictionary, nil)
            }
            print("💾 Data saved to secure Keychain for service \(service).") //
        }
        
        // MARK: - NEW: Generic Read (Data/Object)
        func readData(account: String, service: String) -> Data? {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecReturnData as String: kCFBooleanTrue!,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]

            var dataTypeRef: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

            if status == errSecSuccess {
                return dataTypeRef as? Data
            } else {
                return nil
            }
        }

        // MARK: - Delete (UNCHANGED)
        func delete(account: String, service: String = "com.example.BlockchainWallet") {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]

            SecItemDelete(query as CFDictionary)
        }
}
