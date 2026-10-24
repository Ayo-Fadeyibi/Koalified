//
//  ImportTimetableView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI

struct ImportTimetableView: View {
    let onDone: () -> Void
    @State private var link = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Import your timetable")
                .font(.largeTitle.bold())
                .foregroundStyle(Color.inkPrimary)

            TextField("Paste your timetable link", text: $link)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.URL)
                .padding(16)
                .background(Color.white, in: RoundedRectangle(cornerRadius: Layout.radiusSmall))
                .overlay {
                    RoundedRectangle(cornerRadius: Layout.radiusSmall)
                        .strokeBorder(Color.cardBorder, lineWidth: 1)
                }

            Spacer()

            PrimaryButton(title: "Import", action: onDone)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.canvas)
    }
}

#Preview {
    ImportTimetableView(onDone: {})
}
