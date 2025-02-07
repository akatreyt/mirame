//
//  SubscriptionView.swift
//  mirame
//
//  Created by Trey Tartt on 2/5/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @State private var showingSignIn = false
    @Environment(Subscriptions.self) var subscriptions
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        SubscriptionStoreView(productIDs:  ["unlocked"]) {
            VStack {
                Image("name")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 16)
                    .foregroundColor(Color(uiColor: .label))
                
                Text("Unlock mírame to enjoy unlimited keys and unlimited photos.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(uiColor: .label))
            }
            .foregroundStyle(.white)
            .containerBackground(for: .subscriptionStore, content: {
                Image("smallM")
                    .resizable(resizingMode: .tile)
                    .opacity(0.05)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            })
        }
        .storeButton(.visible, for: .restorePurchases, .redeemCode)
        .subscriptionStoreControlStyle(.prominentPicker)
        .onInAppPurchaseStart { product in
            print(product.displayName)
        }
        .onInAppPurchaseCompletion(perform: { product, results  in
            print("completed for product: \(product.displayName) results: \(results)")
        })
        .onInAppPurchaseCompletion { product, result in
            dismiss()
        }
    }
}

#Preview {
    SubscriptionView()
}
