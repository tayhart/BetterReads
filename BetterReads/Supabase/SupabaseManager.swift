//
//  SupabaseManager.swift
//  BetterReads
//
//  Supabase client configuration and shared instance.
//

import Foundation
import Supabase

/// Shared Supabase client instance
@MainActor
final class SupabaseManager {
    nonisolated static let shared = SupabaseManager()

    let client: SupabaseClient

    private nonisolated init() {
        guard let supabaseURL = Bundle.main.object(forInfoDictionaryKey: "Supabase_url") as? String,
              let supabaseKey = Bundle.main.object(forInfoDictionaryKey: "Supabase_key") as? String,
              let url = URL(string: supabaseURL) else {
            fatalError("Missing Supabase configuration. Add SUPABASE_URL and SUPABASE_KEY to Info.plist")
        }

        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: supabaseKey,
            options: SupabaseClientOptions(
                auth: SupabaseClientOptions.AuthOptions(
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
    }
}

// MARK: - Convenience accessors

extension SupabaseManager {
    var auth: AuthClient {
        client.auth
    }

    var database: PostgrestClient {
        client.database
    }

    /// Current authenticated user, if any
    var currentUser: User? {
        client.auth.currentUser
    }

    /// Current session, if any
    var currentSession: Session? {
        client.auth.currentSession
    }
}
