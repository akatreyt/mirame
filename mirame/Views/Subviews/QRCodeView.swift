//
//  QRCodeView.swift
//  mirame-ios
//
//  Created by Trey Tartt on 12/28/24.
//  Copyright © 2024 Trey Tartt. All rights reserved.
//

import SwiftUI

struct QRCodeView: View {
    let qrCode: UIImage
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                Image(uiImage: qrCode)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
        }.background(.black)
    }
}

//#Preview {
//    QRCodeView()
//}
