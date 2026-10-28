//
//  LanguageData.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 28/10/2026.
//

import Foundation

/// A language the app can be shown in.
struct Language: Identifiable {
    let id = UUID()
    let native: String  // 简体中文
    let english: String // Chinese (Simplified)
    let code: String    // e.g. "en", "zh-Hans"
}

/// Holds the list of languages offered on the language picker.
enum LanguageString {
    /// Every supported language; keep in sync with the languages in the string catalog.
    static let languageSupported: [Language] = [
        Language(native: "English", english: "English", code: "en"),
        Language(native: "简体中文", english: "Chinese (Simplified)", code: "zh-Hans"),
        Language(native: "繁體中文", english: "Chinese (Traditional)", code: "zh-Hant"),
        Language(native: "हिन्दी", english: "Hindi", code: "hi"),
        Language(native: "Bahasa Indonesia", english: "Indonesian", code: "id"),
        Language(native: "한국어", english: "Korean", code: "ko"),
        Language(native: "Tiếng Việt", english: "Vietnamese", code: "vi"),
        Language(native: "日本語", english: "Japanese", code: "ja"),
    ]
}
