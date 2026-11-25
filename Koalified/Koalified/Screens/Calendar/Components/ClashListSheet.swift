//
//  ClashListSheet.swift
//  Koalified
//

import SwiftUI

/// Lists classes that overlap on the timetable, so each one can be opened even when the week grid stacks them.
/// Choosing a class runs `onSelect` and closes the sheet.
struct ClashListSheet: View {
    @Environment(\.dismiss) private var dismiss

    let sessions: [ClassSession]
    let onSelect: (ClassSession) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
            HStack {
                Label("\(sessions.count) classes clash", systemImage: "exclamationmark.triangle.fill")
                    .font(.fredoka(.headline, .bold))
                    .foregroundStyle(Color.redFill)
                Spacer()
                TextButton(title: "Done") { dismiss() }
            }

            ScrollView {
                VStack(spacing: Layout.sectionSpacing) {
                    ForEach(sessions) { session in
                        Button {
                            onSelect(session)
                            dismiss()
                        } label: {
                            row(session)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(Layout.borderWidth)
            }
            .scrollIndicators(.hidden)
        }
        .padding()
    }

    private func row(_ session: ClassSession) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(session.course?.color.color ?? Color.tintMint)
                .frame(width: 8)
                .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(Color.inkBorder, lineWidth: 1.5))

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(verbatim: session.course?.courseCode ?? "")
                        .font(.fredoka(.body, .bold))
                    Text(session.type.label)
                        .font(.fredoka(.body))
                }
                .foregroundStyle(Color.textPrimary)

                Text(verbatim: "\(session.start.formatted(date: .omitted, time: .shortened)) – \(session.end.formatted(date: .omitted, time: .shortened))")
                    .font(.fredoka(.subheadline))
                    .foregroundStyle(Color.textSecondary)

                if let location = session.locationText {
                    Text(verbatim: location)
                        .font(.fredoka(.subheadline))
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.body.weight(.bold))
                .foregroundStyle(Color.textPrimary)
        }
        .padding(12)
        .fixedSize(horizontal: false, vertical: true)
        .plainStyling()
    }
}
