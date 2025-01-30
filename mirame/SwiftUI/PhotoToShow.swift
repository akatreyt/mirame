//
//  PhotoToShow.swift
//  mirame-ios
//
//  Created by Trey Tartt on 12/29/24.
//  Copyright © 2024 Trey Tartt. All rights reserved.
//
import Foundation
import SneakySync

struct PhotoToShow: Identifiable {
    var id: UUID
    var photo: Photo
    var keyDataSet: KeyDataSet?
}
