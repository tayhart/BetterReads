//
//  AuthenticationView.swift
//  BetterReads
//
//  SwiftUI replacement for AuthViewController + SignInView
//

import SwiftUI
import FirebaseAuth

struct AuthenticationView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showingRegistration: Bool = false

    var onAuthenticationSuccess: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

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
            }

            Button("Sign In") {
                signIn()
            }
            .buttonStyle(.bordered)
            .foregroundStyle(Color.cta)
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
        .padding(.horizontal, 50)
        .background(Color.primaryBackground)
        .sheet(isPresented: $showingRegistration) {
            RegistrationView(onRegistrationSuccess: {
                showingRegistration = false
                onAuthenticationSuccess?()
            })
        }
    }

    private func signIn() {
        guard !email.isEmpty, !password.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error {
                errorMessage = error.localizedDescription
            } else {
                onAuthenticationSuccess?()
            }
        }
    }
}

struct RegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var onRegistrationSuccess: (() -> Void)?

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

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                Button("Create Account") {
                    createAccount()
                }
                .buttonStyle(.bordered)
                .foregroundStyle(Color.cta)
                .disabled(isLoading || name.isEmpty || email.isEmpty || password.isEmpty)

                if isLoading {
                    ProgressView()
                }

                Spacer()
            }
            .padding(.horizontal, 50)
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
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        let userObject = FirebaseAuthManager.UserObject(
            email: email,
            password: password,
            displayName: name
        )

        FirebaseAuthManager().createUser(with: userObject) { success in
            isLoading = false
            if success {
                onRegistrationSuccess?()
            } else {
                errorMessage = "Failed to create account. Please try again."
            }
        }
    }
}

#Preview("Sign In") {
    AuthenticationView()
}

#Preview("Registration") {
    RegistrationView()
}
