//
//  DownloadWebView.swift
//  mirame
//
//  Created by Trey Tartt on 2/9/25.
//  Copyright © 2025 Trey Tartt. All rights reserved.
//

import SwiftUI
import WebKit
import SwiftData

struct DownloadableMask: Codable, Identifiable {
    let id: Int
    let name: String
    let image: String
    let saveName: String
    var imageData: Data?
}

struct DownloadedMask: Codable {
    let id: Int
    let location: String
    let name: String
    let imageData: Data
}

struct DownloadView: View {
    @State var downloadableMask = [DownloadableMask]()
    @State var images: [Int: Image] = [:]
    @AppStorage("downloadedMask") private var downloadedMaskStorage = Data()
    @State var downloadedMask = [DownloadedMask]()
    
    var body: some View {
        List {
            ForEach(downloadableMask, id:\.id) { mask in
                HStack {
                    if downloadedMask.contains(where: { $0.id == mask.id }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
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
                    if downloadedMask.contains(where: { $0.id == mask.id }) {
                        remove(image: images[mask.id]!, id: mask.id, toLocation: "Face", withName: mask.saveName)
                    } else {
                        save(image: images[mask.id]!, id: mask.id, toLocation: "Face", withName: mask.saveName)
                    }
                }
            }
        }
        .onAppear{
            guard let url = Bundle.main.url(forResource: "testDownloadFile", withExtension: "json") else { return }
            let data = try! Data(contentsOf: url)
            downloadableMask = try! JSONDecoder().decode([DownloadableMask].self, from: data)
            
            if let _downloadedMask = try? JSONDecoder().decode([DownloadedMask].self, from: downloadedMaskStorage) {
                downloadedMask = _downloadedMask
            }
        }
    }
    
    func save(image: Image, id: Int, toLocation location: String, withName name: String) {
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
                downloadedMask.append(
                    DownloadedMask(id: id,
                                   location: location,
                                   name: name,
                                   imageData: data)
                    )
                if let _downloadedMaskData = try? JSONEncoder().encode(downloadedMask) {
                    downloadedMaskStorage = _downloadedMaskData
                }
                print("file saved")
            }
        } catch {
            print("error:", error)
        }
    }
    
    func remove(image: Image, id: Int, toLocation location: String, withName name: String) {
        do {
            let locationDirectory = try FileManager.default.url(for: .documentDirectory,
                                                                in: .userDomainMask,
                                                                appropriateFor: nil,
                                                                create: true)
                .appending(path: location)
            let fileURL = locationDirectory.appendingPathComponent(name)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
                if let idx = downloadedMask.firstIndex(where: {
                    $0.id == id
                }) {
                    downloadedMask.remove(at: idx)
                    if let _downloadedMaskData = try? JSONEncoder().encode(downloadedMask) {
                        downloadedMaskStorage = _downloadedMaskData
                    }
                }
            }
        } catch {
            
        }
    }
}

#Preview {
    DownloadView()
}
