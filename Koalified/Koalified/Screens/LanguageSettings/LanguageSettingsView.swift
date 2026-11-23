//
//  LanguageSettingsView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 15/11/2026.
//

import SwiftUI

struct LanguageSettingsView: View {

    /// Code of the selected language, e.g. "en" or "zh-Hans".
    @AppStorage("language") private var languageCode = "en"

    /// The row picked on this screen; the highlight reads this first. Driving the rows from
    /// `languageCode` alone isn't enough here: once a tap re-renders `RootView`, this pushed screen
    /// keeps re-running `body` on later taps but SwiftUI never redraws the rows. Owning a `@State`
    /// keeps the screen's own updates applied (confirmed by logging on iOS 27.2).
    @State private var selectedCode: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose your language")
                .primaryTextStyling()
            Text("Koalified will switch to this language, You can change this anytime.")
                .secondaryTextStyling()
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(LanguageString.languageSupported) { language in
                        SelectableRow(isSelected: language.code == (selectedCode ?? languageCode),
                                      action: {
                                          selectedCode = language.code
                                          languageCode = language.code
                                      }) {
                            VStack(alignment: .leading) {
                                Text(language.native)
                                    .font(.fredoka(.subheadline, .bold))
                                    .foregroundStyle(Color.textPrimary)

                                Text(language.english)
                                    .font(.fredoka(.caption))
                                    .foregroundStyle(Color.textSecondary)
                            }
                        }
                    }
                }
            }.scrollIndicators(.hidden)
            
            
        }.mainContainerStyling()
    }
}

#Preview {
    LanguageSettingsView()
}

