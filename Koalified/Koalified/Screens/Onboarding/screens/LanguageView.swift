//
//  LanguageView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI

struct LanguageView: View {
    let languageSupported: [Language] = [
        Language(native: "English", english: "English", code: "en"),
        Language(native: "简体中文", english: "Chinese (Simplified)", code: "zh-Hans"),
        Language(native: "繁體中文", english: "Chinese (Traditional)", code: "zh-Hant"),
        Language(native: "हिन्दी", english: "Hindi", code: "hi"),
        Language(native: "Bahasa Indonesia", english: "Indonesian", code: "id"),
        Language(native: "한국어", english: "Korean", code: "ko"),
        Language(native: "Tiếng Việt", english: "Vietnamese", code: "vi"),
        Language(native: "日本語", english: "Japanese", code: "ja"),
    ]
    
    let onNext: () -> Void
    
    @AppStorage("language") private var languageCode = "en"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Step 1 of 3")
                .font(.subheadline)
                .foregroundStyle(Color.inkSecondary)
            Text("Choose your language")
                .foregroundStyle(Color.inkPrimary)
                .fontWeight(.bold)
                .font(.largeTitle)
            Text("Koalified will switch to this language. You can change it later in Settings.")
                .font(.subheadline)
                .foregroundStyle(Color.inkSecondary)
            
            ScrollView {
                ForEach(languageSupported) {language in
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
                        }.padding(14)
                            .background(Color.surface, in: RoundedRectangle(cornerRadius: Layout.radiusSmall))
                            .overlay {
                                RoundedRectangle(cornerRadius: Layout.radiusSmall)
                                    .strokeBorder(language.code == languageCode ? Color.inkPop : Color.cardBorder,
                                                  lineWidth: language.code == languageCode ? 2 : 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            
            PrimaryButton(title: "Continue", action: onNext)
            
        }.padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color.canvas)
    }
}

#Preview {
    LanguageView(onNext: {})
}
