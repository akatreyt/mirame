//
//  MainView.swift
//  mirame-ios
//
//  Created by Trey Tartt on 12/28/24.
//  Copyright © 2024 Trey Tartt. All rights reserved.
//
import SwiftUI
import SwiftData

@main
struct NewIn14App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase
    
    @State var alertConfig: AlertConfig? {
        didSet {
            hasAlert.toggle()
        }
    }
    @State var hasAlert: Bool = false
    @State var newFileURL: URL?
    @State private var isUnlocked = false
    @State var codeToRunAfterAuth: (() -> Void)?
    @State private var subscriptions = Subscriptions()
    @AppStorage("madeUnlockPurchase") private var madeUnlockPurchase = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if !isUnlocked {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image("name")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color(uiColor: .systemGray5))
                                .font(.largeTitle)
                                .padding(.horizontal, 45)
                            Spacer()
                        }
                        Spacer()
                    }
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: .topLeading
                    )
                    .background(Color(uiColor: .systemBackground))
                    .onAppear{
#if targetEnvironment(simulator)
                        isUnlocked = true
                        //                         TestDataCreator.createPhotos()
#else
                        //                        authenticate()
#endif
                        
                    }
                } else {
                    AllPhotosView()
                        .onAppear() {
                            //                                SaveDeleteContent.deleteOldVideoFiles()
                        }
                }
            }
            .onAppear {
                if !Toggles.isIapEnabled {
                    madeUnlockPurchase = true
                }
            }
            .onOpenURL { url in
                codeToRunAfterAuth = {
                    Task {
                        newFileURL = url
                        do {
                            alertConfig = try await FileParser.doWork(url: url)
                        } catch {
                            print(error)
                        }
                        self.codeToRunAfterAuth = nil
                    }
                }
            }
            .alert(alertConfig?.title ?? "",
                   isPresented: $hasAlert) {
                //                    if let buttons =  alertConfig?.buttons {
                //                        buttons.forEach { button in
                //                            Button(button.title, role: .none) {
                //                                button.action()
                //                            }
                //                        }
                //                    }
            } message: {
                Text(alertConfig?.message ?? "")
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    if !isUnlocked {
                        BioAuthView.authenticate(completedAuthSuccess: {
                            isUnlocked = true
                        }, failedAuth: {
                            isUnlocked = false
                        })
                    } else {
                        codeToRunAfterAuth?()
                        self.codeToRunAfterAuth = nil
                    }
                } else if newPhase == .inactive {
                    // this is causing double auth
                    // isUnlocked = false
                } else if newPhase == .background {
                    isUnlocked = false
                }
            }
            .environment(subscriptions)
        }
        .modelContainer(PhotosDBActor.sharedModelContainer)
    }
}
