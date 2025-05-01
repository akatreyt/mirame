//
//  PhotosDBActor.swift
//  mirame
//
//  Created by Trey Tartt on 5/1/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//
import SwiftData
import Foundation

@ModelActor
actor PhotosDBActor {
    public func getAll<T: PersistentModel>() throws -> [T]? {
        do {
            let fetchDescriptor = FetchDescriptor<T>()
            let data = try modelContext.fetch(fetchDescriptor)
            return data
        } catch {
            return []
        }
    }
    /*
    public func getAll<T: PersistentModel>(sortOrder: SortDescriptor<T>, predicate: Predicate<T>) throws -> [T]? {
        let fetchDescriptor = FetchDescriptor<T>(
            predicate: predicate,
            sortBy: [sortOrder]
        )
        do {
            let data = try modelContext.fetch(fetchDescriptor)
            return data
        } catch {
            return []
        }
    }
     */
}
