//
//  PersonalKey.swift
//  mirame-ios
//
//  Created by Trey Tartt on 9/16/22.
//  Copyright © 2022 Trey Tartt. All rights reserved.
//

import Foundation

struct MigrateKey: Codable {
    let dbKey: Data
    let personalKey: Data
}
