//
//  ProfileAvatarButton.swift
//  Koalified
//

import SwiftUI

/// Round mint avatar in a screen header that opens the Profile screen.
struct ProfileAvatarButton: View {
    var body: some View {
        NavigationLink {
            ProfileView()
        } label: {
            Image("user")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.onMint)
                .frame(width: 48, height: 48)
                .background(Color.mintFill, in: Circle())
                .overlay(Circle().strokeBorder(Color.inkBorder, lineWidth: 2))
        }
    }
}

#Preview {
    NavigationStack {
        ProfileAvatarButton()
    }
}
