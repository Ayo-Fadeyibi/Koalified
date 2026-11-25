//
//  ProfileAvatarButton.swift
//  Koalified
//

import SwiftUI

/// Round avatar in a screen header that opens the Profile screen.
struct ProfileAvatarButton: View {
    var body: some View {
        NavigationLink(value: ProfileRoot()) {
            if #available(iOS 26.0, *) {
                avatar
                    .glassEffect(.regular.tint(Color.mintFill).interactive(), in: Circle())
            } else {
                avatar
                    .background(Color.mintFill, in: Circle())
                    .overlay(Circle().strokeBorder(Color.inkBorder, lineWidth: 2))
            }
        }
    }

    private var avatar: some View {
        Image("user")
            .font(.title3.weight(.semibold))
            .foregroundStyle(Color.onMint)
            .frame(width: 48, height: 48)
    }
}

#Preview {
    NavigationStack {
        ProfileAvatarButton()
    }
}
