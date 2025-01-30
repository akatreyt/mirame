//
//  AlertConfig.swift
//  mirame-ios
//
//  Created by Trey Tartt on 12/28/24.
//  Copyright © 2024 Trey Tartt. All rights reserved.
//
import SwiftUI

struct AlertConfig {
    let title: String
    let message: String
    let buttons: [AlertConfigButton]
}

struct AlertConfigButton {
    let title: String
    let action: () -> Void
    
    static var buttonOK: AlertConfigButton {
        AlertConfigButton(title: "OK", action: {})
    }
    
    static var generalError: AlertConfigButton {
        AlertConfigButton(title: "Something went wrong", action: {})
    }
}

class AlertConfigFactory {
    static func make(title: String, message: String, buttons: [AlertConfigButton]) -> AlertConfig {
        AlertConfig(title: title, message: message, buttons: buttons)
    }
}
