//
//  AuthService.swift
//  BetterReads
//
//  Authentication service using Supabase Auth.
//

import Foundation
import Supabase

/// Service for handling authentication with Supabase
@MainActor
@Observable
final class AuthService {
    static let shared = AuthService()

    private let supabase = SupabaseManager.shared

    /// Current authenticated user
    private(set) var currentUser: User?

    /// Whether the user is authenticated
    var isAuthenticated: Bool {
        currentUser != nil
    }

    /// Display name for the current user
    var displayName: String? {
        currentUser?.userMetadata["display_name"]?.stringValue
    }

    /// Email for the current user
    var email: String? {
        currentUser?.email
    }

    private init() {
        // Set initial user state
        currentUser = supabase.currentUser

        // Listen for auth state changes
        Task {
            for await (event, session) in supabase.auth.authStateChanges {
                switch event {
                case .signedIn, .tokenRefreshed:
                    currentUser = session?.user
                case .signedOut:
                    currentUser = nil
                default:
                    break
                }
            }
        }
    }

    // MARK: - Authentication Methods

    /// Sign in with email and password
    func signIn(email: String, password: String) async throws {
        let session = try await supabase.auth.signIn(
            email: email,
            password: password
        )
        currentUser = session.user
    }

    /// Sign up with email, password, and display name
    func signUp(email: String, password: String, displayName: String) async throws {
        let session = try await supabase.auth.signUp(
            email: email,
            password: password,
            data: ["display_name": .string(displayName)]
        )
        currentUser = session.user
    }

    /// Sign out the current user
    func signOut() async throws {
        try await supabase.auth.signOut()
        currentUser = nil
    }

    /// Send password reset email
    func resetPassword(email: String) async throws {
        try await supabase.auth.resetPasswordForEmail(email)
    }

    /// Update user's display name
    func updateDisplayName(_ name: String) async throws {
        let user = try await supabase.auth.update(
            user: UserAttributes(data: ["display_name": .string(name)])
        )
        currentUser = user
    }

    /// Refresh the current session
    func refreshSession() async throws {
        let session = try await supabase.auth.refreshSession()
        currentUser = session.user
    }
}

// MARK: - Helper extension for AnyJSON

private extension AnyJSON {
    var stringValue: String? {
        if case .string(let value) = self {
            return value
        }
        return nil
    }
}
