//
//  BioAuthView.swift
//  mirame-ios
//
//  Created by Trey Tartt on 1/20/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//
import LocalAuthentication


class BioAuthView {
    static func authenticate(completedAuthSuccess: @escaping (() -> Void), failedAuth: @escaping (() -> Void)) {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "We need to unlock your data."
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                if success {
                    completedAuthSuccess()
                } else {
                    failedAuth()
                }
            }
        } else {
            // no biometrics
        }
    }
}
