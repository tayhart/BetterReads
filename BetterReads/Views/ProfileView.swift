//
//  ProfileView.swift
//  BetterReads
//
//  User profile view with authentication state.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @Environment(Router.self) private var router
    @State private var currentUser: User?
    @State private var authListenerHandle: AuthStateDidChangeListenerHandle?

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
                    router.navigate(to: .authentication)
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
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
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

#Preview {
    NavigationStack {
        ProfileView()
    }
    .environment(Router())
}
