//
//  StudentCard.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 27/11/2026.
//

import SwiftUI

struct StudentCard: View {

    let details: UserDetails

    @State private var flipCard = false
    @State private var showFullNumber = false

    private var name: String {
        let trimmed = details.userName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? String(localized: "Student") : trimmed
    }

    private var university: String {
        details.userUniversity ?? String(localized: "Not set")
    }

    private var studentNumber: String? {
        guard let number = details.studentNumber?.trimmingCharacters(in: .whitespaces),
              !number.isEmpty else { return nil }
        return number
    }

    /// The full number when revealed; otherwise only the last four characters, like a bank card.
    private var displayedStudentNumber: String {
        guard let studentNumber else { return String(localized: "Not set") }
        return showFullNumber ? studentNumber : "**** " + studentNumber.suffix(4)
    }

    /// Nil when no program is saved, so the back hides that field instead of showing a placeholder.
    private var program: String? {
        let trimmed = details.program?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }

    private var graduationYear: String {
        details.graduationDate?.formatted(.dateTime.year()) ?? String(localized: "Not set")
    }

    var body: some View {

        // Both faces share one frame so the card keeps the same size when it flips: the stack takes
        // the taller face's height and each face stretches to fill it.
        ZStack {
            front
                .modifier(FlipFace(angle: flipCard ? 180 : 0, isBack: false))

            back
                .modifier(FlipFace(angle: flipCard ? 180 : 0, isBack: true))
        }
        .fixedSize(horizontal: false, vertical: true)
        // A tap gesture rather than a Button, so the reveal button on the front can take its own taps
        // without also flipping the card (nested Buttons can both fire).
        .contentShape(RoundedRectangle(cornerRadius: Layout.radiusCard))
        .onTapGesture(perform: flip)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Flips the card")
        .accessibilityAction(named: "Flip card", flip)
    }

    private func flip() {
        withAnimation(.spring(duration: 0.6, bounce: 0.2)) {
            flipCard.toggle()
        }
    }

    // MARK: - Front

    private var front: some View {
        // Header and body are flat fills stacked with no gap; the outer shape clips them so their
        // corners match the card's border exactly.
        VStack(spacing: 0) {
            HStack {
                Text("Koalified.")
                    .font(.fredoka(.title, .bold))
                    .foregroundStyle(Color.mintFill)

                Spacer()

                // Labelled as the student's own profile, not a "student card", so it isn't mistaken for an
                // official ID. Matches the back's heading.
                Text("STUDENT PROFILE")
                    .font(.fredoka(.subheadline, .semibold))
                    .foregroundStyle(Color.textPrimary)
            }
            .padding()
            .background(Color.tintAmber)

            Rectangle()
                .fill(Color.inkBorder)
                .frame(height: Layout.borderWidth)

            VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
                HStack(alignment: .center, spacing: 16) {
                    Image("user")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color.greenDeep)
                        .padding(16)
                        .frame(width: 110, height: 130)
                        .background(Color.tintMint, in: RoundedRectangle(cornerRadius: Layout.radiusSmall))
                        .overlay(
                            RoundedRectangle(cornerRadius: Layout.radiusSmall)
                                .strokeBorder(Color.inkBorder, lineWidth: Layout.borderWidth)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("STUDENT NAME")
                            .font(.fredoka(.caption, .semibold))
                            .foregroundStyle(Color.onMint.opacity(0.75))

                        Text(name)
                            .font(.fredoka(.title2, .bold))
                            .foregroundStyle(Color.greenDeep)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(university)
                            .font(.fredoka(.subheadline))
                            .foregroundStyle(Color.onMint.opacity(0.75))
                            .padding(.bottom, 4)

                        Text("STUDENT NUMBER")
                            .font(.fredoka(.caption, .semibold))
                            .foregroundStyle(Color.onMint.opacity(0.75))

                        HStack(spacing: 6) {
                            Text(displayedStudentNumber)
                                .font(.fredoka(.headline, .semibold))
                                .foregroundStyle(Color.onMint)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .contentTransition(.numericText())

                            if studentNumber != nil {
                                Button {
                                    withAnimation(.snappy) {
                                        showFullNumber.toggle()
                                    }
                                } label: {
                                    Image(systemName: showFullNumber ? "eye.slash" : "eye")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.greenDeep)
                                        .frame(width: 28, height: 28)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(showFullNumber ? "Hide student number" : "Show student number")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                // Takes any extra height the taller back face gives the card, keeping the row centred.
                .frame(maxHeight: .infinity)

                // The main safeguard against this being taken for a real ID, so it's a bordered chip
                // in a contrasting colour rather than small print.
                Label("Personal reference · not an official ID", systemImage: "info.circle.fill")
                    .font(.fredoka(.caption, .bold))
                    .foregroundStyle(Color.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.tintAmber, in: Capsule())
                    .overlay(Capsule().strokeBorder(Color.inkBorder, lineWidth: 1.5))
            }
            .padding()
            .frame(maxHeight: .infinity)
            .background(Color.mintFill)
        }
        .cardOutline()
    }

    // MARK: - Back

    private var back: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Koalified.")
                    .font(.fredoka(.title, .bold))
                    .foregroundStyle(.white)

                Spacer()

                Text("STUDENT PROFILE")
                    .font(.fredoka(.subheadline, .semibold))
                    .foregroundStyle(Color.tintMint)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("ACADEMIC DETAILS")
                    .font(.fredoka(.caption, .semibold))
                    .tracking(1.5)
                    .foregroundStyle(Color.textPrimary.opacity(0.7))

                detail("University", university)

                Rectangle()
                    .fill(Color.textSecondary.opacity(0.25))
                    .frame(height: 1)

                HStack(alignment: .top, spacing: 12) {
                    if let program {
                        detail("Program", program, lineLimit: 2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    detail("Expected graduation", graduationYear)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardSurface, in: RoundedRectangle(cornerRadius: Layout.radiusCard))
            .overlay(
                RoundedRectangle(cornerRadius: Layout.radiusCard)
                    .strokeBorder(Color.inkBorder, lineWidth: Layout.borderWidth)
            )

            Spacer(minLength: 0)

            // The disclaimer is the most important line here, so it's larger and solid white to stay
            // readable over the stripes.
            VStack(alignment: .leading, spacing: 4) {
                Text("Not an official university identification card.")
                    .font(.fredoka(.subheadline, .semibold))
                Text("Made for students, by students.")
                    .font(.fredoka(.footnote, .medium))
            }
            .foregroundStyle(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            Color.greenDeep
                .overlay(DiagonalStripes().foregroundStyle(.white.opacity(0.06)))
        }
        .cardOutline()
    }

    /// A small label above a bold value, used in the back's academic details panel.
    private func detail(_ label: LocalizedStringKey, _ value: String, lineLimit: Int = 1) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.fredoka(.subheadline))
                .foregroundStyle(Color.textPrimary.opacity(0.7))

            Text(value)
                .font(.fredoka(.title3, .bold))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(lineLimit)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Helpers

private extension View {
    /// Clips to the card's rounded shape and draws the thick ink border on top.
    func cardOutline() -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: Layout.radiusCard))
            .overlay(
                RoundedRectangle(cornerRadius: Layout.radiusCard)
                    .strokeBorder(Color.inkBorder, lineWidth: Layout.borderWidth)
            )
    }
}

/// Rotates one face of the card around the vertical axis. It's animatable so the face can hide itself
/// exactly when the card passes edge-on (90°); fading by opacity instead would show both faces mid-flip.
private struct FlipFace: ViewModifier, Animatable {
    var angle: Double
    let isBack: Bool

    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    private var isVisible: Bool { isBack ? angle > 90 : angle <= 90 }

    func body(content: Content) -> some View {
        content
            // The back starts turned away so it reads the right way round once the card has flipped.
            .rotation3DEffect(.degrees(isBack ? angle - 180 : angle), axis: (x: 0, y: 1, z: 0), perspective: 0.4)
            .opacity(isVisible ? 1 : 0)
            // The hidden face still sits in the stack, so stop it swallowing taps meant for the visible one.
            .allowsHitTesting(isVisible)
            .accessibilityHidden(!isVisible)
    }
}

/// Faint diagonal stripes for the back of the card.
private struct DiagonalStripes: Shape {
    var spacing: CGFloat = 44
    var stripeWidth: CGFloat = 14

    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Start far enough left that the slanted stripes still cover the bottom-left corner.
        var x = -rect.height
        while x < rect.width {
            path.move(to: CGPoint(x: x, y: rect.maxY))
            path.addLine(to: CGPoint(x: x + rect.height, y: rect.minY))
            path.addLine(to: CGPoint(x: x + rect.height + stripeWidth, y: rect.minY))
            path.addLine(to: CGPoint(x: x + stripeWidth, y: rect.maxY))
            path.closeSubpath()
            x += spacing
        }
        return path
    }
}

#Preview {
    StudentCard(details: UserDetails(
        userName: "Alex Morgan",
        studentNumber: "s12341234",
        graduationDate: Calendar.current.date(from: DateComponents(year: 2027)),
        userUniversity: "University of Queensland",
        program: "Bachelor of Computer Science"
    ))
    .padding(Layout.screenPadding)
}
