//
//  ProfileView.swift
//  BetterReads
//
//  SwiftUI replacement for ProfileViewController
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @State private var currentUser: User?
    @State private var authListenerHandle: AuthStateDidChangeListenerHandle?

    var onSignInTapped: (() -> Void)?

    var body: some View {
        VStack {
            HStack {
                Text("Welcome, \(currentUser?.displayName ?? "friend")")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.top, 40)
            .padding(.horizontal, 40)

            Spacer()

            if currentUser == nil {
                Button("Sign in or Sign up to see more") {
                    onSignInTapped?()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.cta)
                .foregroundStyle(.primary)
            } else {
                Button("Sign out") {
                    signOut()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.cta)
                .foregroundStyle(.primary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.primaryBackground)
        .onAppear {
            setupAuthListener()
        }
        .onDisappear {
            removeAuthListener()
        }
    }

    private func setupAuthListener() {
        currentUser = Auth.auth().currentUser
        authListenerHandle = Auth.auth().addStateDidChangeListener { _, user in
            currentUser = user
        }
    }

    private func removeAuthListener() {
        if let handle = authListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error)")
        }
    }
}

#Preview("Signed Out") {
    ProfileView()
}
