//
//  AuthenticationView.swift
//  BetterReads
//
//  Sign in and registration views using Supabase Auth.
//

import SwiftUI

struct AuthenticationView: View {
    @Environment(Router.self) private var router
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showingRegistration: Bool = false

    private let authService = AuthService.shared

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Welcome to BetterReads")
                .font(.title)
                .fontWeight(.bold)

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }

            Button("Sign In") {
                signIn()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.cta)
            .disabled(isLoading || email.isEmpty || password.isEmpty)

            Button("Create Account") {
                showingRegistration = true
            }
            .foregroundStyle(Color.cta)

            if isLoading {
                ProgressView()
            }

            Spacer()
        }
        .padding(.horizontal, 40)
        .background(Color.primaryBackground)
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingRegistration) {
            RegistrationView(onRegistrationSuccess: {
                showingRegistration = false
                router.pop()
            })
        }
    }

    private func signIn() {
        guard !email.isEmpty, !password.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await authService.signIn(email: email, password: password)
                router.pop()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

struct RegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    private let authService = AuthService.shared

    var onRegistrationSuccess: (() -> Void)?

    private var passwordsMatch: Bool {
        password == confirmPassword
    }

    private var canSubmit: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        passwordsMatch &&
        password.count >= 6
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.name)
                    .autocorrectionDisabled()

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)

                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)

                if !password.isEmpty && password.count < 6 {
                    Text("Password must be at least 6 characters")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }

                if !confirmPassword.isEmpty && !passwordsMatch {
                    Text("Passwords don't match")
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }

                Button("Create Account") {
                    createAccount()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.cta)
                .disabled(isLoading || !canSubmit)

                if isLoading {
                    ProgressView()
                }

                Spacer()
            }
            .padding(.horizontal, 40)
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func createAccount() {
        guard canSubmit else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await authService.signUp(
                    email: email,
                    password: password,
                    displayName: name
                )
                onRegistrationSuccess?()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview("Sign In") {
    AuthenticationView()
        .environment(Router())
}

#Preview("Registration") {
    RegistrationView()
}
