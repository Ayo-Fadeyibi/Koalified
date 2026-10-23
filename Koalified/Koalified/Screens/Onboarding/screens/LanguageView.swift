//
//  LanguageView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI

struct LanguageView: View {
    let languageSupported: [Language] = [
        Language(native: "English", english: "English"),
           Language(native: "简体中文", english: "Chinese (Simplified)"),
           Language(native: "繁體中文", english: "Chinese (Traditional)"),
           Language(native: "हिन्दी", english: "Hindi"),
           Language(native: "Bahasa Indonesia", english: "Indonesian"),
           Language(native: "한국어", english: "Korean"),
           Language(native: "Tiếng Việt", english: "Vietnamese"),
           Language(native: "日本語", english: "Japanese")
    ]
    
    let onNext: () -> Void
    
    @AppStorage("language") private var selectedLanguage = "English"
    
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
                        selectedLanguage = language.english
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
                            if language.english == selectedLanguage {
                                Image(systemName: "checkmark")
                                    .font(.body.weight(.bold))
                                    .foregroundStyle(Color.inkPop)
                            }
                        }.padding(14)
                            .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(language.english == selectedLanguage ? Color.inkPop : Color.cardBorder,
                                                  lineWidth: language.english == selectedLanguage ? 2 : 1)
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
