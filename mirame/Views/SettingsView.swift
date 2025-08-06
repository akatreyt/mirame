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
    @State private var isAdding = false
    @State private var isDeleting = false
    @AppStorage("madeUnlockPurchase") private var madeUnlockPurchase = false
    @AppStorage("alwaysHideMedia")  private var alwaysHideMedia = false
    
    @State private var downloadMore = false
        
    let icons = ["AltIcon1", "AltIcon2", "AltIcon8", "AltIcon10", "AltIcon11", "AltIcon9", "AltIcon3", "AltIcon4", "AltIcon5", "AltIcon6", "AltIcon7"]
    
    var body: some View {
        List {
            Section {
                if isDeleting {
                    ProgressView()
                } else {
                    Button(action: {
                        deleteEverything.toggle()
                    }, label: {
                        Text("Delete Everything")
                    })
                }
            }
            
            if let bundleID = Bundle.main.bundleIdentifier,
               bundleID.contains("ios-dev") || bundleID.contains("hg"){
                Section {
                    if isAdding {
                        ProgressView()
                    } else {
                        Button("Format to test db", action: {
                            Task {
                                isAdding = true
                                await TestDataCreator().populateTestData(completion: {
                                    isAdding = false
                                })
                            }
                        })
                    }
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
            
            Section(content: {
                Button(action: {
                    
                }, label: {
                    HStack {
                        Text("Share mírame")
                        Spacer()
                        Image(systemName: "square.and.arrow.up")
                    }
                })
            })
           
            
            Section(content: {
                if madeUnlockPurchase {
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
            })
            
            Section(content: {
                Toggle("Always hide media", isOn: $alwaysHideMedia)
            })
            
            if Toggles.isDownloadMoreEnabled {
                Button("Download more stuff") {
                    downloadMore = true
                }
            }
        }
        .manageSubscriptionsSheet(isPresented: $isPresentedManageSubscription)
        .sheet(isPresented: $downloadMore, content: {
            DownloadView()
        })
        .alert("Delete Everything", isPresented: $deleteEverything) {
            Button("Delete", role: .destructive, action: {
                BioAuthView.authenticate(completedAuthSuccess: {
                    Task {
                        isDeleting = true
                        await PhotosDBActor.shared.deleteAll()
                        KeychainKeys.shared.deleteAll()
                        isDeleting = false
                    }
                }, failedAuth: {
                    
                })
            })
        }
    }
}

#Preview {
    SettingsView()
}
