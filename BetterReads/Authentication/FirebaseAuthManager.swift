//
//  FirebaseAuthManager.swift
//  BetterReads
//
//  Created by Taylor Hartman on 5/15/23.
//

import FirebaseAuth

final class FirebaseAuthManager {

    struct UserObject {
        var email: String
        var password: String
        var displayName: String
    }

    /// Create a user using the firebase authentication service
    func createUser( with userObject: UserObject, completionBlock: @escaping (_ success: Bool) -> Void) {
        Auth.auth().createUser(withEmail: userObject.email, password: userObject.password) {(authResult, error) in
            if let user = authResult?.user {
                // Set user-provided data on sign up
                let userInfoRequest = user.createProfileChangeRequest()
                userInfoRequest.displayName = userObject.displayName
                userInfoRequest.commitChanges() {_ in 
                    completionBlock(true)
                }

            } else {
                completionBlock(false)
            }
        }
    }
}
