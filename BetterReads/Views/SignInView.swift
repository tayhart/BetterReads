//
//  SignInView.swift
//  BetterReads
//
//  Created by Taylor Hartman on 5/15/23.
//

import UIKit

protocol AuthenticationDelegate: AnyObject {
    func didSelectSignUpButton(with userObject: FirebaseAuthManager.UserObject)
    func didSelectSignInButton(email: String, password: String)
}

final class SignInView: UIView {
    // MARK: - Views

    private lazy var nameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Name"
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocorrectionType = .no
        return field
    }()

    // TODO: Validate info in email field
    private lazy var emailTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email"
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    // TODO: Validate info in password field
    private lazy var passwordTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.borderStyle = .roundedRect
        field.isSecureTextEntry = true
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        return field
    }()

    private lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .ctaColor
        button.addAction(UIAction {_ in
            self.didSelectSignInButton()
        }, for: .touchUpInside)
        return button
    }()

    private lazy var createAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Account", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .ctaColor
        button.addAction(UIAction {_ in
            self.didSelectSignUpButton()
        }, for: .touchUpInside)
        return button
    }()

    // MARK: - Interaction Delegates
    var signInDelegate: AuthenticationDelegate?

    // MARK: - init
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(nameTextField)
        addSubview(emailTextField)
        addSubview(passwordTextField)
        addSubview(signInButton)
        addSubview(createAccountButton)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 350),
            widthAnchor.constraint(equalToConstant: 200),

            nameTextField.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 50),
            nameTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50),
            nameTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50),

            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),

            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),

            signInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            signInButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            signInButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),

            createAccountButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 20),
            createAccountButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            createAccountButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Delegate Callers
    private func didSelectSignUpButton() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let name = nameTextField.text else {
            return
        }
        let user = FirebaseAuthManager.UserObject(
            email: email,
            password: password,
            displayName: name)
        signInDelegate?.didSelectSignUpButton(with: user)
    }

    private func didSelectSignInButton() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {
            return
        }

        signInDelegate?.didSelectSignInButton(email: email, password: password)
    }
}
