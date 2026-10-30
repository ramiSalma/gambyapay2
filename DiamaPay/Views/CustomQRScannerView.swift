import SwiftUI
import AVFoundation

struct CustomQRScannerView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Binding var scannedCode: String?
    @Environment(\.presentationMode) var presentationMode
    
    @State private var flashOn = false
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        ZStack {
            // Camera Preview Layer - FIXED
            CameraPreviewContainer(cameraManager: cameraManager)
                .edgesIgnoringSafeArea(.all)
            
            // Dark overlay with cut-out
            GeometryReader { geometry in
                ZStack {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                    
                    // Transparent rectangle in center
                    Rectangle()
                        .frame(width: 280, height: 280)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
            }
            
            // Corner Frames
            ScannerCornerFrames()
            
            VStack(spacing: 0) {
                // Top Bar
                topBar
                
                Spacer()
                
                // Bottom Instructions
                bottomInstructions
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            //print("🎥 CustomQRScannerView appeared")
            cameraManager.checkPermissionAndStart()
            cameraManager.onCodeScanned = { code in
                //print("✅ QR Code scanned: \(code)")
                scannedCode = code
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onDisappear {
            //print("🎥 CustomQRScannerView disappeared")
            cameraManager.stopScanning()
        }
    }
    
    private var topBar: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.7),
                    Color.black.opacity(0.4),
                    Color.clear
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 100)
            
            HStack {
                // Back Button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text(AppStrings.scannerQrCode)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Flash Button
                Button(action: {
                    toggleFlash()
                }) {
                    Image(systemName: flashOn ? "bolt.fill" : "bolt.slash.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .frame(height: 100)
    }
    
    private var bottomInstructions: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.black.opacity(0.4),
                    Color.black.opacity(0.7)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 180)
            
            VStack(spacing: 8) {
                Text(AppStrings.placezLeCodeQrDansLeCadre)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.6))
                    )
                
                Text(AppStrings.leScanSeFeraAutomatiquement)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.bottom, 20)
        }
        .frame(height: 180)
    }
    
    private func toggleFlash() {
        flashOn.toggle()
        cameraManager.toggleFlash(on: flashOn)
    }
}

// MARK: - Scanner Corner Frames
struct ScannerCornerFrames: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            let frameSize: CGFloat = 280
            
            ZStack {
                // Top-left corner
                VStack(alignment: .leading, spacing: 0) {
                    Rectangle()
                        .fill(Color.blueH)
                        .frame(width: 40, height: 4)
                    Rectangle()
                        .fill(Color.blueH)
                        .frame(width: 4, height: 36)
                }
                .position(x: centerX - frameSize/2 + 20, y: centerY - frameSize/2 + 20)
                
                // Top-right corner
                VStack(alignment: .trailing, spacing: 0) {
                    Rectangle()
                        .fill(Color.blueH)
                        .frame(width: 40, height: 4)
                    HStack {
                        Spacer()
                        Rectangle()
                            .fill(Color.blueH)
                            .frame(width: 4, height: 36)
                    }
                    .frame(width: 40)
                }
                .position(x: centerX + frameSize/2 - 20, y: centerY - frameSize/2 + 20)
                
                // Bottom-left corner
                VStack(alignment: .leading, spacing: 0) {
                    Rectangle()
                        .fill(Color.blueH)
                        .frame(width: 4, height: 36)
                    Rectangle()
                        .fill(Color.blueH)
                        .frame(width: 40, height: 4)
                }
                .position(x: centerX - frameSize/2 + 20, y: centerY + frameSize/2 - 20)
                
                // Bottom-right corner
                VStack(alignment: .trailing, spacing: 0) {
                    HStack {
                        Spacer()
                        Rectangle()
                            .fill(Color.blueH)
                            .frame(width: 4, height: 36)
                    }
                    .frame(width: 40)
                    Rectangle()
                        .fill(Color.blueH)
                        .frame(width: 40, height: 4)
                }
                .position(x: centerX + frameSize/2 - 20, y: centerY + frameSize/2 - 20)
            }
        }
    }
}

// MARK: - Camera Manager - FIXED
class CameraManager: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var hasScanned = false
    @Published var isAuthorized = false
    var onCodeScanned: ((String) -> Void)?
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override init() {
        super.init()
        //print("📸 CameraManager init")
    }
    
    func checkPermissionAndStart() {
        //print("📸 Checking camera permission...")
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        //print("📸 Permission status: \(status.rawValue)")
        
        switch status {
        case .authorized:
            //print("✅ Camera authorized - setting up")
            setupCamera()
            startScanning()
            
        case .notDetermined:
            //print("⚠️ Camera not determined - requesting")
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    //print("📸 Permission granted: \(granted)")
                    if granted {
                        self?.setupCamera()
                        self?.startScanning()
                    }
                }
            }
            
        case .denied, .restricted:
            print("❌ Camera denied/restricted")
            
        @unknown default:
            print("❌ Unknown camera status")
        }
    }
    
    private func setupCamera() {
        //print("📸 Setting up camera...")
        
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            //print("❌ No video capture device found")
            return
        }
        
        //print("✅ Video capture device found")
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            //print("✅ Video input created")
        } catch {
            //print("❌ Error creating video input: \(error)")
            return
        }
        
        guard let session = captureSession else { return }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
            //print("✅ Video input added to session")
        } else {
            //print("❌ Cannot add video input")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
            //print("✅ Metadata output added")
        } else {
            //print("❌ Cannot add metadata output")
            return
        }
        
        //print("✅ Camera setup complete")
        isAuthorized = true
    }
    
    func startScanning() {
        //print("📸 Starting scan...")
        guard let session = captureSession else {
            //print("❌ No capture session")
            return
        }
        
        guard !session.isRunning else {
            //print("⚠️ Session already running")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
            //print("✅ Capture session started")
        }
    }
    
    func stopScanning() {
        //print("📸 Stopping scan...")
        guard let session = captureSession, session.isRunning else {
            //print("⚠️ Session not running")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            session.stopRunning()
            //print("✅ Capture session stopped")
        }
    }
    
    func toggleFlash(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
            //print("⚠️ Device doesn't have torch")
            return
        }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
            //print("✅ Flash toggled: \(on)")
        } catch {
            //print("❌ Flash error: \(error)")
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !hasScanned else { return }
        
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            
            //print("📱 QR Code detected: \(stringValue)")
            hasScanned = true
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            onCodeScanned?(stringValue)
        }
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        guard let session = captureSession else {
            //print("❌ No capture session for preview layer")
            return nil
        }
        
        if previewLayer == nil {
            //print("📸 Creating preview layer")
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer?.videoGravity = .resizeAspectFill
        }
        
        return previewLayer
    }
}

// MARK: - Camera Preview Container - FIXED
struct CameraPreviewContainer: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        //print("📸 Making camera preview view")
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        // CRITICAL: Set up the preview layer properly
        DispatchQueue.main.async {
            if let previewLayer = self.cameraManager.getPreviewLayer() {
                // Remove any existing preview layers
                view.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                
                // Set the frame to fill the entire screen
                previewLayer.frame = UIScreen.main.bounds
                view.layer.insertSublayer(previewLayer, at: 0)
                //print("✅ Preview layer added with frame: \(previewLayer.frame)")
            } else {
                //print("❌ Could not get preview layer")
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the preview layer frame when view size changes
        if let previewLayer = cameraManager.getPreviewLayer() {
            DispatchQueue.main.async {
                let newFrame = uiView.bounds.isEmpty ? UIScreen.main.bounds : uiView.bounds
                if previewLayer.frame != newFrame {
                    previewLayer.frame = newFrame
                    //print("📸 Preview layer frame updated: \(newFrame)")
                }
            }
        }
    }
}
