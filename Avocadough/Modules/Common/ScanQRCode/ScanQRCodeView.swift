//
//  ScanQRCodeView.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 4/7/24.
//

import SwiftUI
@preconcurrency import AVFoundation

struct ScanQRCodeView: View {
    @Environment(ScanQRCodeState.self) private var state
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScannerView()
                .fullScreenColorView()
                .navigationBarTitleDisplayMode(.inline)
                .onDisappear(perform: onDisappear)
                .onChange(of: state.errorMessage, exitView)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done", action: { dismiss() })
                    }
                }
        }
    }
    
    private func exitView() {
        state.exitView()
    }
    
    private func onDisappear() {
        state.postQRCodeScanComplete()
    }
}

fileprivate struct ScannerView: View {
    @Environment(ScanQRCodeState.self) private var state
    private let scanInterval: Double = 1.0
    @State private var lastQrCode: String = ""
    
    var body: some View {
        ZStack {
            QrCodeScannerView()
                .found(r: onFoundQrCode)
                .interval(delay: scanInterval)
                .onChange(of: lastQrCode) { foundCode() }
            
            Image(systemName: "square.dashed")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .foregroundStyle(Color.white)
                .padding(32)
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    private func onFoundQrCode(_ code: String) {
        lastQrCode = code
    }
    
    private func foundCode() {
        state.foundQRCode(lastQrCode)
    }
}

fileprivate struct QrCodeScannerView: UIViewRepresentable {
    
    var supportedBarcodeTypes: [AVMetadataObject.ObjectType] = [.qr]
    typealias UIViewType = CameraPreview
    
    private let session = AVCaptureSession()
    private let delegate = QrCodeCameraDelegate()
    private let metadataOutput = AVCaptureMetadataOutput()
    
    func interval(delay: Double) -> QrCodeScannerView {
        delegate.scanInterval = delay
        return self
    }
    
    func found(r: @escaping (String) -> Void) -> QrCodeScannerView {
        delegate.onResult = r
        return self
    }
    
    func simulator(mockBarCode: String)-> QrCodeScannerView{
        delegate.mockData = mockBarCode
        return self
    }
    
    func setupCamera(_ uiView: CameraPreview) {
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video),
              let input = try? AVCaptureDeviceInput(device: backCamera) else { return }
        session.sessionPreset = .photo
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            
            metadataOutput.metadataObjectTypes = supportedBarcodeTypes
            metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
        }
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        uiView.backgroundColor = UIColor.gray
        previewLayer.videoGravity = .resizeAspectFill
        uiView.layer.addSublayer(previewLayer)
        uiView.previewLayer = previewLayer
        
        Task.detached {
            await session.startRunning()
        }
    }
    
    func makeUIView(context: UIViewRepresentableContext<QrCodeScannerView>) -> QrCodeScannerView.UIViewType {
        let cameraView = CameraPreview(session: session)
        setupCamera(cameraView)

        #if targetEnvironment(simulator)
                cameraView.createSimulatorView(delegate: self.delegate)
        #endif
        
        return cameraView
    }
    
    static func dismantleUIView(_ uiView: CameraPreview, coordinator: ()) {
        uiView.session.stopRunning()
    }
    
    func updateUIView(_ uiView: CameraPreview, context: UIViewRepresentableContext<QrCodeScannerView>) {
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
}

class CameraPreview: UIView {
    
    private var label:UILabel?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    var session = AVCaptureSession()
    weak var delegate: QrCodeCameraDelegate?
    
    init(session: AVCaptureSession) {
        super.init(frame: .zero)
        self.session = session
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSimulatorView(delegate: QrCodeCameraDelegate){
        self.delegate = delegate
        self.backgroundColor = UIColor.black
        label = UILabel(frame: self.bounds)
        label?.numberOfLines = 4
        label?.text = "Click here to simulate scan"
        label?.textColor = UIColor.white
        label?.textAlignment = .center
        if let label = label {
            addSubview(label)
        }
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onClick))
        self.addGestureRecognizer(gesture)
    }
    
    @objc func onClick(){
        delegate?.onSimulateScanning()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
#if targetEnvironment(simulator)
        label?.frame = self.bounds
#else
        previewLayer?.frame = self.bounds
#endif
    }
}

class QrCodeCameraDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    var scanInterval: Double = 1.0
    var lastTime = Date(timeIntervalSince1970: 0)
    
    var onResult: (String) -> Void = { _  in }
    var mockData: String?
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            foundBarcode(stringValue)
        }
    }
    
    @objc func onSimulateScanning(){
        foundBarcode(mockData ?? "Simulated QR-code result.")
    }
    
    func foundBarcode(_ stringValue: String) {
        let now = Date()
        if now.timeIntervalSince(lastTime) >= scanInterval {
            lastTime = now
            self.onResult(stringValue)
        }
    }
}

#Preview {
    ScanQRCodeView()
        .environment(ScanQRCodeState(parentState: SendState(parentState: .init(parentState: .init()))))
}
