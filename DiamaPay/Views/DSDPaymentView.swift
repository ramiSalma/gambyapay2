//
//  DSDPaymentView.swift
//  DiamaPay
//
//  Complete DSD Payment Management - FIXED for ResponseService
//

import SwiftUI

struct DSDPaymentView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var pendingOperations: [DSDPendingOperation] = []
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertTitle = AppStrings.error
    @State private var alertMessage = ""
    @State private var showPinDialog = false
    @State private var showValidationConfirmDialog = false
    @State private var showRejectionConfirmDialog = false
    @State private var selectedOperation: DSDPendingOperation?
    
    private let userDataManager = UserDataManager.shared
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header
                DiamaPayHeader(title: AppStrings.primoArrivant, headerColor: Color(hex: "174EA6"))
                
                if isLoading {
                    loadingView
                } else if pendingOperations.isEmpty {
                    emptyStateView
                } else {
                    operationsListView
                }
                
                // Refresh Button
                refreshButton
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {})
        }
        .navigationBarHidden(true)
        .onAppear {
            loadPendingPayments()
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) { }
        } message: {
            Text(AppStrings.option(alertMessage))
        }
        .overlay(pinDialogOverlay)
        .overlay(validationConfirmOverlay)
        .overlay(rejectionConfirmOverlay)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.blueH.opacity(0.3))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text(AppStrings.primoArrivant)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Placeholder for symmetry
                Color.clear
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.blueH)
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blueH))
                .scaleEffect(1.5)
            
            Text(AppStrings.chargement)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 96))
                .foregroundColor(.gray.opacity(0.3))
            
            Text(AppStrings.aucuneOperationEnAttente)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            
            Text(AppStrings.lesPaiementsDsdEnAttenteApparaitrontIci)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    // MARK: - Operations List View
    private var operationsListView: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(pendingOperations) { operation in
                    DSDOperationCard(
                        operation: operation,
                        onValidate: {
                            selectedOperation = operation
                            showValidationConfirmDialog = true
                        },
                        onReject: {
                            selectedOperation = operation
                            showRejectionConfirmDialog = true
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Refresh Button
    private var refreshButton: some View {
        HStack {
            Spacer()
            Button(action: loadPendingPayments) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.blueH)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .padding(.trailing, 16)
            .padding(.bottom, 24)
        }
    }
    
    // MARK: - PIN Dialog Overlay
    private var pinDialogOverlay: some View {
        Group {
            if showPinDialog, let operation = selectedOperation {
                DSDPinValidationDialog(
                    operation: operation,
                    isPresented: $showPinDialog,
                    onConfirm: { pin in
                        showPinDialog = false
                        validatePayment(operation, pin: pin)
                    },
                    onCancel: {
                        showPinDialog = false
                        selectedOperation = nil
                    }
                )
            }
        }
    }
    
    // MARK: - Validation Confirm Overlay
    private var validationConfirmOverlay: some View {
        Group {
            if showValidationConfirmDialog, let operation = selectedOperation {
                DSDValidationConfirmationDialog(
                    operation: operation,
                    isPresented: $showValidationConfirmDialog,
                    onConfirm: {
                        showValidationConfirmDialog = false
                        showPinDialog = true
                    },
                    onCancel: {
                        showValidationConfirmDialog = false
                        selectedOperation = nil
                    }
                )
            }
        }
    }
    
    // MARK: - Rejection Confirm Overlay
    private var rejectionConfirmOverlay: some View {
        Group {
            if showRejectionConfirmDialog, let operation = selectedOperation {
                DSDRejectionConfirmationDialog(
                    operation: operation,
                    isPresented: $showRejectionConfirmDialog,
                    onConfirm: {
                        showRejectionConfirmDialog = false
                        rejectPayment(operation)
                    },
                    onCancel: {
                        showRejectionConfirmDialog = false
                        selectedOperation = nil
                    }
                )
            }
        }
    }
    
    // MARK: - Load Pending Payments
    private func loadPendingPayments() {
        isLoading = true
        let phoneNumber = userDataManager.getPhoneNumber()
        
        APIClient.shared.getDSDPendingPayments(phoneNumber: phoneNumber) { result in
            isLoading = false
            
            switch result {
            case .success(let response):
                //print("📥 DSD Response - respCode: \(response.respCode)")
                //print("📥 DSD Response - message: \(response.message ?? "nil")")
                
                if response.isSuccessful {
                    // Parse operations from result field
                    if let result = response.result {
                        parseOperationsFromResult(result)
                    } else {
                        //print("⚠️ No result field in response")
                        pendingOperations = []
                    }
                } else {
                    showErrorAlert(response.message ?? AppStrings.erreurLorsDuChargementDesPaiements)
                }
                
            case .failure(let error):
                if let apiError = error as? APIError {
                    showErrorAlert(AppStrings.option(apiError.message))
                } else {
                    showErrorAlert(AppStrings.erreurReseauValue(String(describing: error.localizedDescription)))
                }
            }
        }
    }
    
    // MARK: - Parse Operations from Result
    private func parseOperationsFromResult(_ result: ResponseService.ResultType) {
        if case .string(let jsonString) = result {
            // Result is a JSON string
            //print("📦 Raw JSON String:")
            //print(jsonString)
            
            if let jsonData = jsonString.data(using: .utf8) {
                do {
                    let operations = try JSONDecoder().decode([DSDPendingOperation].self, from: jsonData)
                    pendingOperations = operations.filter {
                        $0.status.uppercased() == "PENDING" || $0.status.uppercased() == "EN_ATTENTE"
                    }
                    //print("✅ Parsed \(pendingOperations.count) pending operations from string")
                    //print("📋 Operations: \(operations)")
                } catch {
                    //print("❌ Error parsing operations from string: \(error)")
                    
                    // Try to see what the JSON actually looks like
                    if let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) {
                        //print("📄 Actual JSON structure:")
                        //print(jsonObject)
                    }
                    
                    pendingOperations = []
                }
            }
        } else if case .array(let stringArray) = result {
            // Result is an array of JSON strings
            var allOperations: [DSDPendingOperation] = []
            for jsonString in stringArray {
                if let jsonData = jsonString.data(using: .utf8),
                   let operation = try? JSONDecoder().decode(DSDPendingOperation.self, from: jsonData) {
                    allOperations.append(operation)
                }
            }
            pendingOperations = allOperations.filter {
                $0.status.uppercased() == "PENDING" || $0.status.uppercased() == "EN_ATTENTE"
            }
            //print("✅ Parsed \(pendingOperations.count) pending operations from array")
        } else if case .dictionary(let dict) = result {
            // Result is a dictionary
            if let dataValue = dict["data"]?.value {
                if let jsonData = try? JSONSerialization.data(withJSONObject: dataValue),
                   let operations = try? JSONDecoder().decode([DSDPendingOperation].self, from: jsonData) {
                    pendingOperations = operations.filter {
                        $0.status.uppercased() == "PENDING" || $0.status.uppercased() == "EN_ATTENTE"
                    }
                    //print("✅ Parsed \(pendingOperations.count) pending operations from dictionary")
                } else {
                    //print("⚠️ Could not decode operations from dictionary data")
                    pendingOperations = []
                }
            } else {
                //print("⚠️ No 'data' key in dictionary")
                pendingOperations = []
            }
        } else {
            //print("⚠️ Unknown result type")
            pendingOperations = []
        }
    }
    
    // MARK: - Validate Payment
    private func validatePayment(_ operation: DSDPendingOperation, pin: String) {
        isLoading = true
        
        APIClient.shared.validateDSDPayment(
            operationId: operation.operationId,
            phoneNumber: userDataManager.getPhoneNumber(),
            pin: pin
        ) { result in
            isLoading = false
            
            switch result {
            case .success(let response):
                if response.isSuccessful ||
                   response.status?.uppercased() == "VALIDE" ||
                   response.status?.uppercased() == "VALIDATED" {
                    alertTitle = AppStrings.succes
                    alertMessage = AppStrings.paiementValideAvecSucces
                    showAlert = true
                    loadPendingPayments()
                } else {
                    showErrorAlert(response.message ?? AppStrings.erreurLorsDeLaValidation)
                }
                
            case .failure(let error):
                if let apiError = error as? APIError {
                    showErrorAlert(AppStrings.option(apiError.message))
                } else {
                    showErrorAlert(AppStrings.erreurReseauValue(String(describing: error.localizedDescription)))
                }
            }
        }
    }
    
    // MARK: - Reject Payment
    private func rejectPayment(_ operation: DSDPendingOperation) {
        isLoading = true
        
        APIClient.shared.rejectDSDPayment(
            operationId: operation.operationId,
            phoneNumber: userDataManager.getPhoneNumber()
        ) { result in
            isLoading = false
            
            switch result {
            case .success(let response):
                if response.isSuccessful ||
                   response.status?.uppercased() == "REJETE" ||
                   response.status?.uppercased() == "REJECTED" {
                    alertTitle = AppStrings.succes
                    alertMessage = AppStrings.paiementRejeteAvecSucces
                    showAlert = true
                    loadPendingPayments()
                } else {
                    showErrorAlert(response.message ?? AppStrings.erreurLorsDuRejet)
                }
                
            case .failure(let error):
                if let apiError = error as? APIError {
                    showErrorAlert(AppStrings.option(apiError.message))
                } else {
                    showErrorAlert(AppStrings.erreurReseauValue(String(describing: error.localizedDescription)))
                }
            }
        }
    }
    
    // MARK: - Show Error Alert
    private func showErrorAlert(_ message: String) {
        alertTitle = AppStrings.error
        alertMessage = message
        showAlert = true
    }
}

// MARK: - DSD Operation Card
struct DSDOperationCard: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let operation: DSDPendingOperation
    let onValidate: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Chassis Section
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(AppStrings.chassis)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .tracking(0.5)
                    
                    Text(operation.chassisNumber)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Circle()
                    .fill(Color(hex: "0788B9"))
                    .frame(width: 8, height: 8)
            }
            
            Divider()
                .background(Color.gray.opacity(0.2))
            
            // Amount and Category Section
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(AppStrings.montantAPayer)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .tracking(0.5)
                    
                    Text(operation.formattedAmount)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "174EA6"))
                }
                
                Spacer()
                
                Text(operation.categoryDisplay)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.blueH)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blueH.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Reference and Date Section
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(AppStrings.reference2)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .tracking(0.5)
                    
                    Text(operation.operationId)
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    Text(operation.createdAt != nil ? AppStrings.dateDeCreation : "Statut")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .tracking(0.5)
                    
                    Text(operation.createdAt != nil ? operation.formattedCreatedAt : operation.status.uppercased())
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: onReject) {
                    Text(AppStrings.buttonTitle(AppStrings.rejeter))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red, lineWidth: 2)
                        )
                }
                
                Button(action: onValidate) {
                    Text(AppStrings.buttonTitle(AppStrings.approuver))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "174EA6"))
                        .cornerRadius(16)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - DSD Pending Operation Model
struct DSDPendingOperation: Codable, Identifiable {
    var id: String { operationId }
    let operationId: String
    let transactionId: String?
    let chassisNumber: String
    let category: String
    let amount: Double
    let status: String
    let createdAt: DateObject?
    let updatedAt: DateObject?
    
    // Nested date object structure from API
    struct DateObject: Codable {
        let time: Double  // Timestamp in milliseconds
        let year: Int?
        let month: Int?
        let date: Int?
        let hours: Int?
        let minutes: Int?
        let seconds: Int?
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        
        if let formattedValue = formatter.string(from: NSNumber(value: amount)) {
            return "\(formattedValue) GNF"
        }
        return "\(Int(amount)) GNF"
    }
    
    var categoryDisplay: String {
        switch category.uppercased() {
        case "CATEGORIE A", "CATEGORIE_A":
            return AppStrings.categorieA
        case "CATEGORIE B", "CATEGORIE_B":
            return AppStrings.categorieB
        case "CATEGORIE C", "CATEGORIE_C":
            return AppStrings.categorieC
        case "CATEGORIE D", "CATEGORIE_D":
            return AppStrings.categorieD
        default:
            return category.uppercased()
        }
    }
    
    var formattedCreatedAt: String {
        guard let dateObject = createdAt else { return "N/A" }
        
        // Convert milliseconds timestamp to Date
        let date = Date(timeIntervalSince1970: dateObject.time / 1000.0)
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        outputFormatter.locale = Locale(identifier: "fr_FR")
        
        return outputFormatter.string(from: date)
    }
}
