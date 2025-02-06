//
//  Subscriptions.swift
//  mirame
//
//  Created by Trey Tartt on 2/5/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//
import Foundation
import StoreKit

@Observable final class Subscriptions {
//    static let subscriptionIDs = ["unlocked"]
//    
//    // MARK: Starting the Subscription Observing
//    
//    @ObservationIgnored private var observerTask: Task<Void, Never>?
//    
//    func prepare() async {
//        guard observerTask == nil else { return }
//        observerTask = Task(priority: .background) {
//            for await verificationResult in Transaction.updates {
//                consumeVerificationResult(verificationResult)
//            }
//        }
//        
//        for await verificationResult in Transaction.currentEntitlements {
//            consumeVerificationResult(verificationResult)
//        }
//    }
//    
//    // MARK: Validating Purchased Subscription Status
//    
//    private var verifiedActiveSubscriptionIDs = Set<String>()
//    
//    private func consumeVerificationResult(_ result: VerificationResult<Transaction>) {
//        guard case .verified(let transaction) = result else {
//            return
//        }
//        
//        if transaction.revocationDate != nil {
//            verifiedActiveSubscriptionIDs.remove(transaction.productID)
//        }
//        else if let expirationDate = transaction.expirationDate, expirationDate < Date.now {
//            verifiedActiveSubscriptionIDs.remove(transaction.productID)
//        }
//        else if transaction.isUpgraded {
//            verifiedActiveSubscriptionIDs.remove(transaction.productID)
//        }
//        else {
//            verifiedActiveSubscriptionIDs.insert(transaction.productID)
//        }
//    }
//    
//    var isUnlocked: Bool {
//        !verifiedActiveSubscriptionIDs.isEmpty
//    }
}
