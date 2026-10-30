import SwiftUI
import AVFoundation


enum RecipientType: String {
    case client = "CUSTOMER"
    case merchant = "MERCHANT"
    case agent = "AGENT"
    case unknown
}

func detectRecipientType(from qr: String) -> RecipientType {
    // First try to find in tag 26 or 32 content
    if let tag26 = EMVQRParser.extractTag(qr, "26"),
       let entity = EMVQRParser.extractTag(tag26, "04")?.uppercased() {
        return classifyEntityType(entity)
    }
    
    if let tag32 = EMVQRParser.extractTag(qr, "32"),
       let entity = EMVQRParser.extractTag(tag32, "04")?.uppercased() {
        return classifyEntityType(entity)
    }
    
    // Fallback: search entire QR code
    if let entity = EMVQRParser.extractTag(qr, "04")?.uppercased() {
        return classifyEntityType(entity)
    }
    
    return .unknown
}

private func classifyEntityType(_ raw: String) -> RecipientType {
    if raw.contains("MERCHANT") { return .merchant }
    if raw.contains("CUSTOMER") { return .client }
    if raw.contains("AGENT") { return .agent }
    return .unknown
}

struct MerchantQRData {
    let merchantWallet: String
    let merchantName: String
    let merchantNumber: String
    let bankCode: String
    let originalQrCode: String
    let entityType: String
    var isValid: Bool { !merchantWallet.isEmpty && !merchantName.isEmpty }
}

enum EMVQRParser {
    static func isEMVQRCode(_ qr: String) -> Bool {
        qr.count >= 30 && qr.hasPrefix("00") && qr.contains("63")
    }
    
    static func isDynamicQR(_ qr: String) -> Bool {
        extractTag(qr, "01") == "12" || qr.contains("54")
    }
    
    static func extractTag(_ qr: String, _ tag: String) -> String? {
        var i = qr.startIndex
        while i < qr.index(qr.endIndex, offsetBy: -4, limitedBy: qr.endIndex) ?? qr.endIndex {
            let t = String(qr[i..<qr.index(i, offsetBy: 2)])
            let lenEnd = qr.index(i, offsetBy: 4)
            guard let len = Int(String(qr[qr.index(i, offsetBy: 2)..<lenEnd])) else { break }
            let valEnd = qr.index(lenEnd, offsetBy: len, limitedBy: qr.endIndex) ?? qr.endIndex
            if t == tag { return String(qr[lenEnd..<valEnd]) }
            i = valEnd
        }
        return nil
    }
    
    static func parseStatic(_ qr: String) -> MerchantQRData? {
        var wallet = "", name = "", number = "", bank = "00100", entity = ""
        
        var i = qr.startIndex
        while i < qr.index(qr.endIndex, offsetBy: -4, limitedBy: qr.endIndex) ?? qr.endIndex {
            let t = String(qr[i..<qr.index(i, offsetBy: 2)])
            let lenEnd = qr.index(i, offsetBy: 4)
            guard let len = Int(String(qr[qr.index(i, offsetBy: 2)..<lenEnd])) else { break }
            let valEnd = qr.index(lenEnd, offsetBy: len, limitedBy: qr.endIndex) ?? qr.endIndex
            let val = String(qr[lenEnd..<valEnd])
            
            if t == "59" { name = val }
            else if t == "26" || t == "32" {
                if let w = extractTag(val, "01") { wallet = w; number = w }
                if let b = extractTag(val, "02") { bank = b }
                if let e = extractTag(val, "04") { entity = e }
            }
            i = valEnd
        }
        
        guard !wallet.isEmpty && !name.isEmpty else { return nil }
        return MerchantQRData(merchantWallet: wallet, merchantName: name,
                             merchantNumber: number, bankCode: bank,
                             originalQrCode: qr, entityType: entity)
    }
}

@MainActor
final class QRViewModel: ObservableObject {
    @Published var isProcessing = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var showPinDialog = false
    @Published var showAmountSheet = false
    @Published var showSuccess = false
    @Published var recipientType: RecipientType = .unknown
    @Published var merchantData: MerchantQRData?
    @Published var dynamicData: EMVQRPaymentData?
    @Published var successData: (txId: String, date: String, amount: String, merchant: String, total: Double, sendingFee: Double, withdrawalFee: Double)?
    
    var sendingFee = 0.0
    var withdrawalFee = 0.0
    var paymentAmount = 0.0
    var isDynamic = false
    
    private let user = UserDataManager.shared
    
    func process(qr: String) {
        guard !qr.isEmpty, EMVQRParser.isEMVQRCode(qr) else {
            showError(AppStrings.codeQrInvalide)
            return
        }

        self.recipientType = detectRecipientType(from: qr)
        //print("📌 Recipient type detected: \(recipientType)")

        if EMVQRParser.isDynamicQR(qr) {
            validateDynamic(qr)
        } else {
            processStatic(qr)
        }
    }

    private func validateDynamic(_ qr: String) {
        isProcessing = true
        APIClient.shared.validateJWT(request: ValidateJwtRequest(jwtToken: qr)) { [weak self] result in
            Task { @MainActor [weak self] in
                self?.isProcessing = false
                guard let self else { return }
                
                switch result {
                case .success(let resp):
                    guard resp["respCode"] as? String == "000",
                          let data = resp["result"] as? [String: Any] else {
                        self.showError(AppStrings.qrInvalideOuExpire)
                        return
                    }
                    self.handleDynamicData(data, qr: qr)
                case .failure:
                    self.showError(AppStrings.erreurDeValidation)
                }
            }
        }
    }
    
    private func handleDynamicData(_ data: [String: Any], qr: String) {
        var payment = EMVQRPaymentData()
        payment.originalQrCode = qr
        payment.tokenId = data["tokenId"] as? String ?? ""
        payment.merchantWallet = data["merchantWallet"] as? String ?? ""
        payment.merchantName = data["merchantName"] as? String ?? ""
        payment.merchantNumber = data["merchantNumber"] as? String ?? ""
        payment.bankCode = data["bankCode"] as? String ?? ""

        if let amt = data["amount"] as? String {
            payment.amount = Double(amt)!
        } else if let amt = data["amount"] as? Double {
            payment.amount = amt
        }

        guard payment.isValid, !payment.isExpired else {
            showError(AppStrings.qrExpireOuInvalide)
            return
        }

        self.recipientType = detectRecipientType(from: qr)
        //print("📌 Dynamic QR → Recipient type = \(recipientType)")

        dynamicData = payment
        paymentAmount = payment.amount
        isDynamic = true
        calculateFees()
    }

    private func processStatic(_ qr: String) {
        guard let merchant = EMVQRParser.parseStatic(qr) else {
            showError(AppStrings.codeQrInvalide)
            return
        }

        merchantData = merchant
        self.recipientType = detectRecipientType(from: qr)
        //print("📌 Static QR → Recipient type = \(recipientType)")

        isDynamic = false
        showAmountSheet = true
    }
    
    func handleAmount(_ amount: Double, isFeeEnabled: Bool, withdrawalFee: Double, ruleIndex: String) {
        paymentAmount = amount
        
        // ✅ For agents, ALWAYS use the withdrawal fee regardless of toggle
        // For clients (P2P), respect the toggle state
        if recipientType == .agent {
            self.withdrawalFee = withdrawalFee
        } else {
            self.withdrawalFee = isFeeEnabled ? withdrawalFee : 0.0
        }
        
        //print("📋 handleAmount called:")
        //print("  Amount: \(amount)")
        //print("  isFeeEnabled: \(isFeeEnabled)")
        //print("  withdrawalFee param: \(withdrawalFee)")
        //print("  recipientType: \(recipientType)")
        //print("  Final withdrawal fee: \(self.withdrawalFee)")
        
        showAmountSheet = false
        calculateFees()
    }

    
    private func calculateFees() {
        //print("🔄 Starting fee calculation...")
        isProcessing = true
        
        let req = WalletFeeQuoteRequest.current(
            amount: paymentAmount, destination: dynamicData?.merchantWallet ?? merchantData?.merchantWallet ?? "",
            transactionType: "44", destinationBank: dynamicData?.bankCode ?? merchantData?.bankCode ?? "00100"
        )
        
        APIClient.shared.calculateTransactionFee(request: req) { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self else { return }
                
                switch result {
                case .success(let resp):
                    if resp.respCode == "000",
                       let feeResult = resp.result,
                       let _ = feeResult.feeAmount {
                        let fee = feeResult.totalFees
                        self.sendingFee = fee
                        //print("💰 Sending fee calculated: \(fee) GMD")
                        
                        // ✅ For dynamic QR with agent or client, calculate withdrawal fee
                        if self.isDynamic && (self.recipientType == .agent || self.recipientType == .client) {
                            self.calculateWithdrawalFeeForDynamic()
                        } else {
                            // Merchant or static QR - show dialog immediately
                            self.isProcessing = false
                            //print("💰 Withdrawal fee: \(self.withdrawalFee) GMD")
                            //print("💰 Payment amount: \(self.paymentAmount) GMD")
                            self.showPinDialog = true
                        }
                    } else {
                        self.isProcessing = false
                        self.sendingFee = 0
                        self.showError(AppStrings.impossibleDeCalculerLesFrais)
                    }
                    
                case .failure(let error):
                    self.isProcessing = false
                    self.sendingFee = 0
                    self.showError(AppStrings.erreurLorsDuCalculDesFraisValue(String(describing: error.localizedDescription)))
                }
            }
        }
    }
    
    private func calculateWithdrawalFeeForDynamic() {
        //print("🔄 Calculating withdrawal fee for dynamic QR...")
        
        let processingCode = recipientType == .agent ? "01" : "22" // AGENT CASHOUT vs P2P CASHOUT
        let origin = recipientType == .agent ? "V" : "W"
        
        let req = WalletFeeQuoteRequest.current(
            amount: paymentAmount, destination: dynamicData?.merchantWallet ?? merchantData?.merchantWallet ?? "",
            transactionType: processingCode, destinationBank: dynamicData?.bankCode ?? merchantData?.bankCode ?? "00100"
        )
        
        //print("  Processing Code: \(processingCode) (\(recipientType == .agent ? "AGENT CASHOUT" : "P2P CASHOUT"))")
        
        APIClient.shared.calculateWithdrawalFee(request: req) { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isProcessing = false
                
                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        if let feeAmount = response.feeAmount {
                            self.withdrawalFee = feeAmount
                            //print("💰 Withdrawal fee calculated: \(feeAmount) GMD")
                        } else {
                            self.withdrawalFee = 0.0
                            //print("💰 No withdrawal fee")
                        }
                    } else {
                        self.withdrawalFee = 0.0
                        //print("❌ Withdrawal fee calculation error: \(response.message ?? "Unknown")")
                    }
                    
                    //print("💰 Final fees - Sending: \(self.sendingFee), Withdrawal: \(self.withdrawalFee)")
                    //print("💰 Payment amount: \(self.paymentAmount) GMD")
                    self.showPinDialog = true
                    
                case .failure(let error):
                    self.withdrawalFee = 0.0
                    //print("❌ Withdrawal fee calculation failed: \(error.localizedDescription)")
                    // Still show dialog even if withdrawal fee calc fails
                    //print("💰 Final fees - Sending: \(self.sendingFee), Withdrawal: \(self.withdrawalFee)")
                    //print("💰 Payment amount: \(self.paymentAmount) GMD")
                    self.showPinDialog = true
                }
            }
        }
    }
    
    func executePayment(pin: String) {
        isProcessing = true
        
        // ✅ Calculate final amount to send in payment request
        let finalAmount: Double
        if isDynamic {
            // Dynamic QR: Always send base amount only (for all recipient types)
            finalAmount = paymentAmount
        } else {
            // Static QR: Only add withdrawal fee for CLIENT
            if recipientType == .client && withdrawalFee > 0 {
                finalAmount = paymentAmount + withdrawalFee
            } else {
                // Agent or Merchant: send base amount only
                finalAmount = paymentAmount
            }
        }
        
        //print("💳 EXECUTING PAYMENT:")
        //print("  Recipient Type: \(recipientType)")
        //print("  Is Dynamic: \(isDynamic)")
        //print("  Base Amount: \(paymentAmount)")
        //print("  Withdrawal Fee: \(withdrawalFee)")
        //print("  Final Amount to Send: \(finalAmount)")
        
        let qrData = isDynamic ? (dynamicData?.originalQrCode ?? "") : (merchantData?.originalQrCode ?? "")
        let merchantName = isDynamic ? (dynamicData?.merchantName ?? "") : (merchantData?.merchantName ?? "")
        
        var req = RequestQrPayment()
        req.source = "W"
        req.walletNumber = user.getWalletNumber()
        req.phoneNumber = user.getPhoneNumber()
        req.amount = String(format: "%.2f", finalAmount)
        req.currency = "270"
        req.qrData = qrData
        req.reason = String(AppStrings.paymentToValue(String(describing: merchantName)).prefix(25))
        req.pin = pin
        req.entityId = user.getUserCode()
        
        let df = DateFormatter()
        df.dateFormat = "yyMMdd"
        req.requestId = String((df.string(from: Date()) + String(format: "%06d", Int.random(in: 0...999999))).prefix(12))
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        req.requestDate = df.string(from: Date())
        
        APIClient.shared.qrTransfer(request: req) { [weak self] result in
            Task { @MainActor [weak self] in
                self?.isProcessing = false
                guard let self else { return }
                
                self.showPinDialog = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    switch result {
                    case .success(let resp):
                        if resp.respCode == "000" {
                            self.handleSuccess(resp, merchantName: merchantName)
                        } else {
                            self.showError(AppStrings.paiementEchoueValue(String(describing: resp.message ?? "")))
                        }
                    case .failure:
                        self.showError(AppStrings.erreurReseau2)
                    }
                }
            }
        }
    }
    
    private func handleSuccess(_ resp: ResponseService, merchantName: String) {
        let txId = resp.result?.stringValue ?? resp.authCode ?? "N/A"
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy HH:mm"
        let date = df.string(from: Date())
        
        // ✅ Calculate EFFECTIVE fees based on recipient type (what will actually be shown/charged)
        let effectiveSendingFee: Double
        let effectiveWithdrawalFee: Double
        
        switch recipientType {
        case .client:
            effectiveSendingFee = sendingFee
            effectiveWithdrawalFee = withdrawalFee
        case .agent:
            effectiveSendingFee = 0.0
            effectiveWithdrawalFee = withdrawalFee  // Always show for agent
        case .merchant, .unknown:
            effectiveSendingFee = 0.0
            effectiveWithdrawalFee = 0.0  // Never show for merchant
        }
        
        // Calculate base amount and total
        let baseAmount: Double
        let total: Double
        
        switch recipientType {
        case .client:
            if isDynamic {
                baseAmount = paymentAmount - withdrawalFee
                total = paymentAmount + effectiveSendingFee
            } else {
                baseAmount = paymentAmount
                total = paymentAmount + effectiveSendingFee + effectiveWithdrawalFee
            }
        case .agent:
            // ✅ For agent, always show full amount (no deduction)
            baseAmount = paymentAmount
            total = paymentAmount + effectiveWithdrawalFee
        case .merchant, .unknown:
            // No fees for merchant
            baseAmount = paymentAmount
            total = paymentAmount
        }
        
        //print("💰 SUCCESS CALCULATION:")
        //print("  Recipient Type: \(recipientType)")
        //print("  Is Dynamic: \(isDynamic)")
        //print("  Base Amount: \(baseAmount)")
        //print("  Sending Fee (effective): \(effectiveSendingFee)")
        //print("  Withdrawal Fee (effective): \(effectiveWithdrawalFee)")
        //print("  Total: \(total)")
        
        // ✅ Pass EFFECTIVE fees to success sheet
        successData = (txId, date, String(format: "%.0f", baseAmount), merchantName, total, effectiveSendingFee, effectiveWithdrawalFee)
        
        if isDynamic, let tokenId = dynamicData?.tokenId, !tokenId.isEmpty {
            let req = MarkTokenUsedRequest(
                customerWallet: user.getWalletNumber(),
                tokenId: tokenId,
                transactionRef: "TXN_\(Int(Date().timeIntervalSince1970))"
            )
            APIClient.shared.markTokenUsed(request: req) { _ in }
        }
        
        showSuccess = true
    }
    
    func showError(_ msg: String) {
        alertMessage = msg
        showAlert = true
    }
}

// MARK: - Main View
struct QRPaymentView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var vm = QRViewModel()
    @State private var showScanner = false
    @State private var showPicker = false
    @State private var showMyQR = false
    @State private var scannedCode: String?
    @State private var selectedImage: UIImage?
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                DiamaPayHeader(title: AppStrings.merchantPayment, headerColor: Color(hex: "174EA6"))
                
                if vm.isProcessing {
                    Spacer()
                    ProgressView().scaleEffect(1.5)
                    Text(AppStrings.processing).padding(.top)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 22) {
                            Text(AppStrings.chooseScanMethod)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(hex: "245C2A"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 16)
                            HStack(spacing: 14) {
                                scanMethodCard(
                                    icon: "qrcode.viewfinder",
                                    title: AppStrings.camera,
                                    subtitle: AppStrings.scanNow,
                                    color: Color(hex: "2368B8"),
                                    tint: Color(hex: "E7F3FC"),
                                    action: checkCamera
                                )
                                scanMethodCard(
                                    icon: "photo.badge.magnifyingglass",
                                    title: AppStrings.gallery,
                                    subtitle: AppStrings.fromPhotos,
                                    color: Color(hex: "378C4A"),
                                    tint: Color(hex: "E9F5E9"),
                                    action: { showPicker = true }
                                )
                            }
                            tipsCard
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(
                onSponsors: {},
                onQR: { showMyQR = true },
                onLimits: {},
                onSettings: {}
            )
        }
        .navigationBarHidden(true)
        .alert(AppStrings.error, isPresented: $vm.showAlert) {
            Button(AppStrings.buttonTitle(AppStrings.ok)) { }
        } message: {
            Text(vm.alertMessage)
        }
        .fullScreenCover(isPresented: $showScanner) {
            CustomQRScannerView(scannedCode: $scannedCode)
        }
        .sheet(isPresented: $showPicker) {
            ImagePickerA(image: $selectedImage)
        }
        .sheet(isPresented: $vm.showAmountSheet) {
            if let merchant = vm.merchantData {
                AmountInputView(merchantData: merchant) { amt, isFeeEnabled, fee, ruleIndex in
                    vm.handleAmount(amt, isFeeEnabled: isFeeEnabled, withdrawalFee: fee, ruleIndex: ruleIndex)
                }
            }
        }
        .sheet(isPresented: $vm.showPinDialog) {
            pinSheet
        }
        .sheet(isPresented: $vm.showSuccess) {
            if let data = vm.successData {
                successSheet(data)
            }
        }
        .fullScreenCover(isPresented: $showMyQR) {
            MyQRCodeView()
        }
        .onChange(of: scannedCode) { _, code in
            if let c = code {
                vm.process(qr: c)
                scannedCode = nil
            }
        }
        .onChange(of: selectedImage) { _, img in
            if let i = img {
                processImage(i)
                selectedImage = nil
            }
        }
    }
    
    private func scanMethodCard(
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 58, height: 58)
                    .background(tint)
                    .clipShape(Circle())

                Text(AppStrings.buttonTitle(title))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(color)
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "7A8D99"))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 158)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.22), lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
    
    private var tipsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 22))
                VStack(alignment: .leading, spacing: 6) {
                    Text(AppStrings.quickTip)
                        .font(.system(size: 16, weight: .bold))
                    Text(AppStrings.scanTheQrCodeDisplayedAtTheMerchantLocationTo)
                        .font(.system(size: 13, weight: .medium))
                }
            }
            .foregroundColor(Color(hex: "E87800"))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "FFF8DF"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 3)
    }

    @ViewBuilder
    private var pinSheet: some View {
        if vm.isDynamic, let data = vm.dynamicData {
            QRPaymentConfirmationDialog(
                paymentData: data,
                sendingFee: vm.sendingFee,
                withdrawalFee: vm.withdrawalFee,
                isDynamic: true,
                recipientType: vm.recipientType,
                isPresented: $vm.showPinDialog,
                onConfirm: { vm.executePayment(pin: $0) },
                onCancel: { vm.showPinDialog = false }
            )
        } else if let merchant = vm.merchantData {
            QRPaymentConfirmationDialog(
                paymentData: EMVQRPaymentData(
                    tokenId: "", originalQrCode: merchant.originalQrCode,
                    merchantWallet: merchant.merchantWallet, merchantNumber: merchant.merchantNumber,
                    merchantName: merchant.merchantName, bankCode: merchant.bankCode,
                    amount: vm.paymentAmount, currency: "GMD", expiresAt: nil
                ),
                sendingFee: vm.sendingFee,
                withdrawalFee: vm.withdrawalFee,
                isDynamic: false,
                recipientType: vm.recipientType,
                isPresented: $vm.showPinDialog,
                onConfirm: { vm.executePayment(pin: $0) },
                onCancel: { vm.showPinDialog = false }
            )
        }
    }
    
    // ✅ FIXED: Pass effective fees directly to success sheet
    private func successSheet(_ data: (txId: String, date: String, amount: String, merchant: String, total: Double, sendingFee: Double, withdrawalFee: Double)) -> some View {
        QRPaymentSuccessView(
            transactionId: data.txId,
            transactionDate: data.date,
            amount: data.amount,
            merchantName: data.merchant,
            merchantWallet: vm.merchantData?.merchantWallet ?? vm.dynamicData?.merchantWallet ?? "",
            merchantNumber: vm.merchantData?.merchantNumber ?? vm.dynamicData?.merchantNumber ?? "",
            bankCode: vm.merchantData?.bankCode ?? vm.dynamicData?.bankCode ?? "",
            senderName: UserDataManager.shared.getUserName(),
            senderPhone: UserDataManager.shared.getPhoneNumber(),
            sendingFee: data.sendingFee,  // ✅ Already filtered
            withdrawalFee: data.withdrawalFee,  // ✅ Already filtered
            total: data.total,
            currency: "GMD",
            paymentDetails: AppStrings.paiementQrCodeEmv,
            recipientType: vm.recipientType,
            onClose: {
                vm.showSuccess = false
                presentationMode.wrappedValue.dismiss()
            }
        )
    }
    
    private func checkCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showScanner = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted { showScanner = true }
                    else { vm.showError(AppStrings.permissionCameraRequise) }
                }
            }
        default:
            vm.showError(AppStrings.activezLaCameraDansLesReglages)
        }
    }
    
    private func processImage(_ img: UIImage) {
        guard let ci = CIImage(image: img),
              let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil,
                                       options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]),
              let feature = (detector.features(in: ci) as? [CIQRCodeFeature])?.first,
              let qr = feature.messageString else {
            vm.showError(AppStrings.aucunQrDetecte)
            return
        }
        vm.process(qr: qr)
    }
}

