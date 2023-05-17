//
//  FirebaseAuthManager.swift
//  BetterReads
//
//  Created by Taylor Hartman on 5/15/23.
//

import FirebaseAuth

final class FirebaseAuthManager {

    /// Create a user using the firebase authentication service
    func createUser(email: String, password: String, completionBlock: @escaping (_ success: Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) {(authResult, error) in
            if let user = authResult?.user {
                print(user)
                completionBlock(true)
            } else {
                completionBlock(false)
            }
        }
    }
}
