//
//  AddWidgetSheet.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 24/10/2026.
//

import SwiftUI

/// Sheet explaining how to add the Koalified widget from the Home Screen, with a button to widget settings.
struct AddWidgetSheet: View {
    @Environment(\.dismiss) private var dismiss
    /// Called when the user taps "Widget settings".
    let onSettings: () -> Void
    
    var body: some View {
        VStack (alignment: .leading, spacing: 12) {
            HStack {
                Text("Add a widget")
                    .font(.fredoka(.title2, .bold))
                    .foregroundStyle(Color.inkPrimary)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .foregroundStyle(Color.accentText)
                        .font(.fredoka(.body, .bold))
                }
            }
            
            Text("Preview")
            
            Spacer()
            
            Text("Widgets are added from your Home Screen: touch and hold, tap +, then choose Koalified and a size.")
                .font(.fredoka(.caption))
                .foregroundStyle(Color.inkSecondary)
            
            PrimaryButton(title: "Widget settings"){
                onSettings()
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
            .background(Color.canvas)
    }
}


#Preview {
    AddWidgetSheet(onSettings: {})
}
