//
//  TimetableLinkStore.swift
//  Koalified
//
//  Keeps the student's private timetable link in the Keychain. The link is a secret:
//  anyone holding it can read the timetable, so it is never logged or put in UserDefaults.
//

import Foundation
import Security

enum TimetableLinkStore {
    private static let service = "Koalified.timetableLink"
    private static let account = "icalURL"

    private static var baseQuery: [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: service,
         kSecAttrAccount as String: account]
    }

    /// Saves the link, replacing any earlier one. Returns false if the Keychain refused it.
    @discardableResult
    static func save(_ url: URL) -> Bool {
        guard let data = url.absoluteString.data(using: .utf8) else { return false }
        SecItemDelete(baseQuery as CFDictionary)
        var item = baseQuery
        item[kSecValueData as String] = data
        // Stays on this phone: not in backups and not moved to a new device.
        item[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        return SecItemAdd(item as CFDictionary, nil) == errSecSuccess
    }

    /// The saved link, or nil if there isn't one.
    static func load() -> URL? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data,
              let text = String(data: data, encoding: .utf8) else { return nil }
        return URL(string: text)
    }

    static func delete() {
        SecItemDelete(baseQuery as CFDictionary)
    }
}
