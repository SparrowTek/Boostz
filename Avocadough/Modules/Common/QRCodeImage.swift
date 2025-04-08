//
//  QRCodeImage.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 2/28/24.
//

import SwiftUI

struct QRCodeImage: View {
    var code: String?
    
    var body: some View {
        Image(uiImage: generateQRCode(from: code))
            .resizable()
            .interpolation(.none)
            .scaledToFit()
    }
    
    func generateQRCode(from string: String?) -> UIImage {
        guard let string else { return UIImage() }
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

#Preview {
    QRCodeImage(code: "Avocadough")
}
