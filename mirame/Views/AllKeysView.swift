//
//  AllKeysView.swift
//  mirame-ios
//
//  Created by Trey Tartt on 12/25/24.
//  Copyright © 2024 Trey Tartt. All rights reserved.
//

import SwiftUI
import SneakySync
import CoreHaptics

struct AllKeysView: View {
    @Environment(\.dismiss) var dismiss
    @State private var engine: CHHapticEngine?
    @State private var showNewKeySyncView = false
    @State private var showNewKeyNameAlert = false
    @State private var newKeyName = ""
    
    @State private var shareURL: String?
    
    @State private var deactivateKey: KeyDataSet? {
        didSet {
            confirmDeactivateKeyAlert = true
        }
    }
    @State private var confirmDeactivateKeyAlert = false
    
    @ObservedObject var keychainKeysychain = KeychainKeys.shared
    
    var body: some View {
        VStack {
            header()
                .padding()
            
            Divider()
            
            if KeychainKeys.shared.allKeys.isEmpty {
                Text("No keys found")
                    .font(.title)
                    .multilineTextAlignment(.leading)
                    .padding()
                
                Text("Find someone you would like to share photos with and start the sync process by tapping on the \(Image(systemName: "plus.app")) on the top left.")
                    .multilineTextAlignment(.leading)
                    .padding()
                
                Spacer()
            } else {
                allKeysList(keys: KeychainKeys.shared.allKeys)
            }
        }
        .alert("New Key", isPresented: $showNewKeyNameAlert) {
            TextField("Key Name", text: $newKeyName)
                .disableAutocorrection(true)
            Button("OK", action: {
                newKeyName = $newKeyName.wrappedValue
                showNewKeySyncView = true
            })
            Button("Cancel", action: {
            })
        }
        .sheet(isPresented: $showNewKeySyncView, content: {
            ExampleSyncView(completedSync: { newKeySet in
                recievedNew(keySet: newKeySet)
            })
        })
        .sheet(item: $shareURL, content: { url in
            UIActivityViewControllerView(url: URL(string: url)!)
        })
        .alert("Create deactivation key \(deactivateKey?.name ?? "")",
               isPresented: $confirmDeactivateKeyAlert,
               actions: {
            Button("OK", action: {
                deactivateKey?.createDeactivationPayload()
            })
            Button("Cancel", action: { })
        },
               message: {
            Text("This will create a deactivation key, and when the user opens it, all the media for this key will be deleted.")
        })
    }
    
    @ViewBuilder
    func header() -> some View {
        HStack {
            Button(action: {
                showNewKeyNameAlert.toggle()
            }, label: {
                Image(systemName: "plus.app")
                    .font(.title2)
            })
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func allKeysList(keys: [KeyDataSet]) -> some View {
        List {
            Section {
                ForEach(keys.filter({ $0.isActive }), id: \.id) { key in
                    HStack {
                        Text(key.name ?? "")
                            .font(.body)
                        Spacer()
                        Button(action: {
                            deactivateKey = key
                        }, label: {
                            Image(systemName: "shareplay.slash")
                        })
                    }
                }
            } header: {
                Text("Active Keys")
            }
            
            Section {
                ForEach(keys.filter({ !$0.isActive }), id: \.id) { key in
                    HStack {
                        Text(key.name ?? "")
                            .font(.body)
                    }
                }
            } header: {
                Text("Deactivated Keys")
            }
        }
    }
    
    func recievedNew(keySet: KeyDataSet) {
        do {
            var keySet = keySet
            keySet.name = newKeyName
            try KeychainKeys.shared.saveLocally(key: keySet)
            
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
        var events = [CHHapticEvent]()
        
        for i in stride(from: 0, to: 1, by: 0.1) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(i))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(i))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
            events.append(event)
        }
        
        for i in stride(from: 0, to: 1, by: 0.1) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(1 - i))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(1 - i))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 1 + i)
            events.append(event)
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
        dismiss()
    }
}

extension String: Identifiable {
    public var id: String {
        self
    }
}

extension KeyDataSet {
    func createDeactivationPayload() {
        
    }
}

#Preview {
    AllKeysView()
}
