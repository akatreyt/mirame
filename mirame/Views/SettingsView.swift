//
//  SettingsView.swift
//  mirame-ios
//
//  Created by Trey Tartt on 1/19/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @State private var deleteEverything = false
    @State private var isPresentedManageSubscription = false
    @AppStorage("isUnlocked") private var isUnlocked = false
    
    let icons = ["AltIcon1", "AltIcon2", "AltIcon8", "AltIcon10", "AltIcon11", "AltIcon9", "AltIcon3", "AltIcon4", "AltIcon5", "AltIcon6", "AltIcon7"]
    
    var body: some View {
        List {
            Section {
                Button(action: {
                    deleteEverything.toggle()
                }, label: {
                    Text("Delete Everything")
                })
            }
            
            if let bundleID = Bundle.main.bundleIdentifier,
               bundleID.contains("ios-dev") {
                Section {
                    Button("Format to test db", action: {
                        Task {
                            await TestDataCreator().populateTestData()
                        }
                    })
                }
            }
            
            Section(content: {
                ScrollView(.horizontal) {
                    HStack {
                        
                        Button(action: {
                            UIApplication.shared.setAlternateIconName(nil) { error in
                                if let error = error {
                                    print("Error setting alternate icon \(error.localizedDescription)")
                                }
                            }
                        }, label: {
                            ZStack {
                                Image(systemName: "arrow.clockwise")
                                    .resizable()
                                    .frame(width: 22, height: 22)
                            }
                            .frame(width: 88, height: 88)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                        })
                        
                        ForEach(icons, id: \.self) { icon in
                            Button(action: {
                                UIApplication.shared.setAlternateIconName(icon) { error in
                                    if let error = error {
                                        print("Error setting alternate icon \(error.localizedDescription)")
                                    }
                                }
                            }, label: {
                                Image(icon+"-preview")
                                    .resizable()
                                    .frame(width: 88, height: 88)
                                    .cornerRadius(10)
                            })
                        }
                    }
                }
            }, header: {
                Text("icon")
            })
            
            if isUnlocked {
                Button("Manage Subscription") {
                    isPresentedManageSubscription = true
                }
            } else {
                ProductView(id: "unlocked") {
                    Image("AltIcon1-preview")
                        .resizable()
                        .frame(width: 88, height: 88)
                        .cornerRadius(10)
                }
            }
        }
        .manageSubscriptionsSheet(isPresented: $isPresentedManageSubscription)
        .alert("Delete Everything", isPresented: $deleteEverything) {
            Button("Delete", role: .destructive, action: {
                BioAuthView.authenticate(completedAuthSuccess: {
                    DataBase.shared.deleteAll()
                    KeychainKeys.shared.deleteAll()
                }, failedAuth: {
                    
                })
            })
        }
    }
}

#Preview {
    SettingsView()
}
