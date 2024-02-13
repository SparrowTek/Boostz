//
//  ReceivePresenter.swift
//  Boostz
//
//  Created by Thomas Rademaker on 2/11/24.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct ReceivePresenter: View {
    var body: some View {
        NavigationStack {
            ReceiveView()
        }
    }
}

fileprivate struct ReceiveView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ReceiveState.self) private var state
    @State private var lightningAddressCopied = false
    
    private var lightningAddress: String {
        #if DEBUG
        "lightning:sparrowtek@getalby.com"
        #else
        state.lightningAddress ?? ""
        #endif
    }
    
    var body: some View {
        VStack {
            Image(uiImage: generateQRCode(from: lightningAddress))
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding()
            
            ZStack {
                Button(action: copyLightningAddress) {
                    Text(lightningAddress)
                    Image(systemName: "doc.on.doc")
                }
                .opacity(lightningAddressCopied ? 0 : 1)
                
                Text("Copied!")
                    .foregroundStyle(Color.green)
                    .opacity(lightningAddressCopied ? 1 : 0)
            }
            .padding()
            
            Button(action: createLightningInvoice) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.yellow)
                            .frame(width: 50)
                            .padding(.vertical, 4)
                        Image(systemName: "bolt")
                    }
                    
                    VStack(alignment: .leading) {
                        Text("lightning invoice")
                            .font(.headline)
                        Text("request instant and specific amount payment")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    }
                    
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            .buttonStyle(.boostz)
            
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", action: { dismiss() })
            }
        }
    }
    
    private func createLightningInvoice() {
        
    }
    
    private func copyLightningAddress() {
        UIPasteboard.general.string = lightningAddress
        lightningAddressCopied = true
        
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            lightningAddressCopied = false
        }
    }
    
    private func generateQRCode(from string: String) -> UIImage {
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
    ReceivePresenter()
        .environment(ReceiveState(parentState: .init(parentState: .init())))
}
