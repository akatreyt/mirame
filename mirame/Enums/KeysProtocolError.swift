//
//  KeysProtocolError.swift
//  mirame-ios
//
//  Created by Trey Tartt on 1/10/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//


enum KeysProtocolError : Error{
    case unableToCreateURL
    case homieJustGotDeleted
    case keyExistButNoUpdate
    case noData
    case randomError
}
