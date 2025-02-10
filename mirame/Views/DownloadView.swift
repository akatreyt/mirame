//
//  DownloadWebView.swift
//  mirame
//
//  Created by Trey Tartt on 2/9/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//

import SwiftUI
import WebKit

struct DownloadableMask: Codable, Identifiable {
    let id = UUID()
    let name: String
    let image: String
    let saveName: String
    var imageData: Data?
}

struct DownloadedMask {
    let location: String
    let name: String
    let imageData: Data
}

struct DownloadView: View {
    @State var downloadableMask = [DownloadableMask]()
    @State var images: [UUID: Image] = [:]
    
    var body: some View {
        List {
            ForEach(downloadableMask, id:\.id) { mask in
                HStack {
                    Text(mask.name)
                    AsyncImage(url: URL(string: mask.image)!) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .onAppear {
                                self.images[mask.id] = image
                            }
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 44, height: 44)
                    .background(Color.gray)
                    .clipShape(Circle())
                }
                .onTapGesture {
                    save(image: images[mask.id]!, toLocation: "Face", withName: mask.saveName)
                }
            }
        }
        .onAppear{
            guard let url = Bundle.main.url(forResource: "testDownloadFile", withExtension: "json") else { return }
            let data = try! Data(contentsOf: url)
            downloadableMask = try! JSONDecoder().decode([DownloadableMask].self, from: data)
        }
    }
    
    func save(image: Image, toLocation location: String, withName name: String) {
        do {
            let locationDirectory = try FileManager.default.url(for: .documentDirectory,
                                                                in: .userDomainMask,
                                                                appropriateFor: nil,
                                                                create: true)
                .appending(path: location)
            
            if !FileManager.default.fileExists(atPath: locationDirectory.path()) {
                do {
                    try FileManager.default.createDirectory(atPath: locationDirectory.path(),
                                                            withIntermediateDirectories: true,
                                                            attributes: nil)
                } catch {
                    print(error.localizedDescription);
                }
            }
            
            let fileURL = locationDirectory.appendingPathComponent(name)
            
            if let data = image.getUIImage(newSize: CGSize(width: 100, height: 100))!.pngData() {
                try data.write(to: fileURL)
                print("file saved")
            }
        } catch {
            print("error:", error)
        }
    }
}

#Preview {
    DownloadView()
}
