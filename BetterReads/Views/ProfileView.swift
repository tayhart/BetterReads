//
//  ProfileView.swift
//  BetterReads
//
//  User profile view with Supabase authentication state.
//

import SwiftUI

struct ProfileView: View {
    @Environment(Router.self) private var router
    @State private var authService = AuthService.shared
    @State private var isSigningOut = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Color.cta)

                Text("Welcome, \(authService.displayName ?? "Reader")")
                    .font(.title2)
                    .fontWeight(.bold)

                if let email = authService.email {
                    Text(email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 40)

            Spacer()

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            // Actions
            if authService.isAuthenticated {
                Button(role: .destructive) {
                    signOut()
                } label: {
                    if isSigningOut {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Sign Out")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(isSigningOut)
            } else {
                Button {
                    router.navigate(to: .authentication)
                } label: {
                    Text("Sign In or Create Account")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.cta)
            }

            Spacer()
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.primaryBackground)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func signOut() {
        isSigningOut = true
        errorMessage = nil

        Task {
            do {
                try await authService.signOut()
            } catch {
                errorMessage = error.localizedDescription
            }
            isSigningOut = false
        }
    }
}

#Preview("Signed In") {
    NavigationStack {
        ProfileView()
    }
    .environment(Router())
}

#Preview("Signed Out") {
    NavigationStack {
        ProfileView()
    }
    .environment(Router())
}
