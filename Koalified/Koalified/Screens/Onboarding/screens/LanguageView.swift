//
//  LanguageView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI

/// Onboarding step 1: pick the app language. The choice is saved to `language` in AppStorage,
/// and `RootView` applies it as the app's locale straight away.
struct LanguageView: View {

    let onNext: () -> Void

    /// Code of the selected language, e.g. "en" or "zh-Hans".
    @AppStorage("language") private var languageCode = "en"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Step 1 of 3")
                .secondaryTextStyling()
            Text("Choose your language")
                .primaryTextStyling()
            Text("Koalified will switch to this language. You can change it later in Settings.")
                .secondaryTextStyling()
            
            ScrollView {
                ForEach(LanguageString.languageSupported) {language in
                    Button {
                        languageCode = language.code
                    } label: {
                        HStack {
                            VStack (alignment: .leading) {
                                Text(language.native)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.inkPrimary)
                                
                                Text(language.english)
                                    .font(.caption)
                                    .foregroundStyle(Color.inkSecondary)
                            }
                            
                            Spacer()
                            if language.code == languageCode {
                                Image(systemName: "checkmark")
                                    .font(.body.weight(.bold))
                                    .foregroundStyle(Color.accentText)
                            }
                        }.boxStyling(bgColor: Color.surface, cRadius: Layout.radiusSmall, sColor: language.code == languageCode ? Color.inkPop : Color.cardBorder, lWidth: language.code == languageCode ? 2 : 1)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            PrimaryButton(title: "Continue", action: onNext)
            
        }.mainContainerStyling()
    }
}

#Preview {
    LanguageView(onNext: {})
}
