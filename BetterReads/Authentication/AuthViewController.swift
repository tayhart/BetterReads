//
//  AuthViewController.swift
//  BetterReads
//
//  Created by Taylor Hartman on 5/15/23.
//

import UIKit
import Firebase
import FirebaseAuth


class AuthViewController: UIViewController {

    let signInView = SignInView()

    override func viewDidLoad() {
        view.addSubview(signInView)
        signInView.signInDelegate = self
        view.backgroundColor = .primaryBackgroundColor

        NSLayoutConstraint.activate([
            signInView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            signInView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            signInView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            signInView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
}

extension AuthViewController: AuthenticationDelegate {
    func didSelectSignUpButton(with userObject: FirebaseAuthManager.UserObject) {
        assert(Auth.auth().currentUser == nil)
        FirebaseAuthManager().createUser(with: userObject) { success in
            if success {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    func didSelectSignInButton(email: String, password: String) {
        assert(Auth.auth().currentUser == nil)
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error == nil {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
