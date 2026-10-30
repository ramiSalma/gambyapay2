//
//  StandingInstructionListView.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//


//
//  StandingInstructionListView.swift
//  DiamaPay
//
//  Created by Assistant on 01/10/2025.
//

import SwiftUI

struct StandingInstructionListView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var instructions: [StandingInstruction] = []
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = AppStrings.information
    @State private var showCreateSheet = false
    @State private var selectedInstruction: StandingInstruction? = nil
    @State private var showDeleteDialog = false
    @State private var instructionToDelete: StandingInstruction? = nil
    
    private let userDataManager = UserDataManager.shared
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                StandingInstructionHeader(title: AppStrings.standingInstructions) {
                    presentationMode.wrappedValue.dismiss()
                }
                
                // Content
                if isLoading {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: StandingInstructionStyle.blue))
                            .scaleEffect(1.5)
                        
                        Text(AppStrings.chargement)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else if instructions.isEmpty {
                    emptyStateView
                } else {
                    instructionsList
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {}, onHome: {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .tint(StandingInstructionStyle.blue)
        .preferredColorScheme(.light)
        .navigationBarHidden(true)
        .onAppear {
            loadStandingInstructions()
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) { }
        } message: {
            Text(AppStrings.option(alertMessage))
        }
        .background(
            NavigationLink(isActive: $showCreateSheet) {
                StandingInstructionCreateView(onSuccess: {
                    showCreateSheet = false
                    loadStandingInstructions()
                })
            } label: { EmptyView() }
        )
        .overlay(alignment: .bottomTrailing) {
            Button { showCreateSheet = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color(hex: "0086B5"))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 6, y: 5)
            }
            .accessibilityLabel(AppStrings.createStandingInstruction)
            .padding(.trailing, 16)
            .padding(.bottom, 88)
        }
        .sheet(item: $selectedInstruction) { instruction in
            NavigationView {
                StandingInstructionUpdateView(
                    instruction: instruction,
                    onSuccess: {
                        selectedInstruction = nil
                        loadStandingInstructions()
                    }
                )
            }
        }
        .overlay(deleteConfirmationDialog)
    }
    

    
    // MARK: - Instructions List
    private var instructionsList: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(instructions) { instruction in
                        StandingInstructionRow(
                            instruction: instruction,
                            onUpdate: {
                                selectedInstruction = instruction
                            },
                            onDelete: {
                                instructionToDelete = instruction
                                showDeleteDialog = true
                            }
                        )
                        .padding(.horizontal, 6)
                        .padding(.vertical, 8)
                        Divider().overlay(StandingInstructionStyle.separator)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 8)
                .padding(.bottom, 80)
            }
            
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(AppStrings.vousNAvezAucunVirementPermanent)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                showCreateSheet = true
            }) {
                Text(AppStrings.buttonTitle(AppStrings.creerUnVirement))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(StandingInstructionStyle.blue)
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Delete Confirmation Dialog
    private var deleteConfirmationDialog: some View {
        Group {
            if showDeleteDialog, let instruction = instructionToDelete {
                DeleteConfirmationDialog(
                    instruction: instruction,
                    isPresented: $showDeleteDialog,
                    onConfirm: { pin in
                        showDeleteDialog = false
                        deleteInstruction(instruction, pin: pin)
                    },
                    onCancel: {
                        showDeleteDialog = false
                        instructionToDelete = nil
                    }
                )
            }
        }
    }
    
    // MARK: - Load Instructions
    private func loadStandingInstructions() {
        isLoading = true
        
        let phoneNumber = userDataManager.getPhoneNumber()
        guard !phoneNumber.isEmpty else {
            isLoading = false
            showErrorAlert(AppStrings.numeroDeTelephoneNonDisponible)
            return
        }
        
        let request = RequestStandingInstructionList(
            phoneNumber: phoneNumber,
            requestId: generateRequestId(),
            requestDate: generateRequestDate(),
            entityId: UserDataManager.shared.getUserCode()
        )
        
        APIClient.shared.listStandingInstructions(request: request) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.respCode == "000", let resultList = response.result {
                        self.parseInstructions(from: resultList)
                    } else {
                        self.instructions = []
                    }
                case .failure(let error):
                    if let apiError = error as? APIError {
                        self.showErrorAlert(AppStrings.erreurValue(AppStrings.option(apiError.message)))
                    } else {
                        self.showErrorAlert(AppStrings.erreurReseauValue(String(describing: error.localizedDescription)))
                    }
                }
            }
        }
    }
    
    // MARK: - Parse Instructions
    private func parseInstructions(from resultList: [Any]) {
        var parsedInstructions: [StandingInstruction] = []
        
        for item in resultList {
            guard let dict = item as? [String: Any] else { continue }
            
            let instruction = StandingInstruction(
                reference: dict["reference"] as? String ?? "",
                destination: dict["destination"] as? String,
                beneficiary: dict["beneficiary"] as? String ?? AppStrings.unknown,
                description: dict["description"] as? String ?? "",
                amount: String(describing: dict["amount"] ?? "0"),
                currency: dict["currency"] as? String ?? "270",
                destBank: dict["destBank"] as? String,
                trxType: dict["trxType"] as? String,
                destBankCode: dict["destBankCode"] as? String,
                frequency: dict["frequency"] as? String ?? "D",
                frequencyNum: dict["frequencyNum"] as? String,
                startDate: convertDateFormat(dict["startDate"] as? String ?? ""),
                endDate: convertDateFormat(dict["endDate"] as? String ?? ""),
                nextDate: dict["nextDate"] as? String
            )
            
            if !instruction.reference.isEmpty {
                parsedInstructions.append(instruction)
            }
        }
        
        self.instructions = parsedInstructions
    }
    
    // MARK: - Delete Instruction
    private func deleteInstruction(_ instruction: StandingInstruction, pin: String) {
        isLoading = true
        
        let request = RequestStandingInstructionDelete(
            bank: "00100",
            destBank: "",
            entityId: UserDataManager.shared.getUserCode(),
            id: instruction.reference,
            phoneNumber: userDataManager.getPhoneNumber(),
            pin: pin,
            requestDate: generateRequestDate(),
            requestId: generateRequestId()
        )
        
        APIClient.shared.deleteStandingInstruction(request: request) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        self.showSuccessAlert(AppStrings.virementPermanentSupprimeAvecSucces)
                        self.loadStandingInstructions()
                    } else {
                        self.showErrorAlert(AppStrings.erreurValue(String(describing: response.message ?? AppStrings.echecDeLaSuppression)))
                    }
                case .failure(let error):
                    if let apiError = error as? APIError {
                        self.showErrorAlert(AppStrings.erreurValue(AppStrings.option(apiError.message)))
                    } else {
                        self.showErrorAlert(AppStrings.erreurReseauValue(String(describing: error.localizedDescription)))
                    }
                }
                
                self.instructionToDelete = nil
            }
        }
    }
    
    // MARK: - Helper Methods
    private func convertDateFormat(_ dateString: String) -> String {
        guard !dateString.isEmpty else { return "" }
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MM-dd-yyyy"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        
        return dateString
    }
    
    private func generateRequestId() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let datePrefix = dateFormatter.string(from: Date())
        let randomDigits = String(format: "%06d", Int.random(in: 0...999999))
        return datePrefix + randomDigits
    }
    
    private func generateRequestDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: Date())
    }
    
    private func showErrorAlert(_ message: String) {
        alertTitle = AppStrings.error
        alertMessage = message
        showAlert = true
    }
    
    private func showSuccessAlert(_ message: String) {
        alertTitle = AppStrings.succes
        alertMessage = message
        showAlert = true
    }
}

// MARK: - Standing Instruction Row
struct StandingInstructionRow: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let instruction: StandingInstruction
    let onUpdate: () -> Void
    let onDelete: () -> Void
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Text(initials)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(StandingInstructionStyle.avatarText)
                    .frame(width: 38, height: 38)
                    .background(Color(hex: "E6F2FB"))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 5) {
                    Text(instruction.beneficiary ?? AppStrings.unknown)
                        .font(.system(size: 16, weight: .bold))
                    Text(instruction.description ?? "")
                        .font(.system(size: 14))
                        .foregroundColor(StandingInstructionStyle.secondaryText)
                }
                Spacer(minLength: 0)
                Menu {
                    Button(AppStrings.buttonTitle(AppStrings.modifier), action: onUpdate)
                    Button(AppStrings.buttonTitle(AppStrings.supprimer), role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(StandingInstructionStyle.blue)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(standingText("Instruction actions", "Actions de l’instruction"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 17)
            Divider().overlay(StandingInstructionStyle.separator)
            HStack(alignment: .top, spacing: 0) {
                summary(AppStrings.montant3,
                        formatAmount(instruction.amount ?? "0") + " " + getCurrencyDisplay(instruction.currency ?? "270"),
                        getCurrencyDisplay(instruction.currency ?? "270"))
                Divider()
                summary(AppStrings.frequence, getFrequencyDisplay(instruction.frequency ?? "D"), standingText("recurring", "récurrent"))
                Divider()
                summary(standingText("Next instruction", "Prochaine instruction"), displayNextDate, "")
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 14)
        }
        .background(Color.white)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(StandingInstructionStyle.separator, lineWidth: 1))
        .shadow(color: .black.opacity(0.03), radius: 1, y: 1)
        .contentShape(RoundedRectangle(cornerRadius: 14))
        .onTapGesture(perform: onUpdate)
        .contextMenu {
            Button(AppStrings.buttonTitle(AppStrings.modifier), action: onUpdate)
            Button(AppStrings.buttonTitle(AppStrings.supprimer), role: .destructive, action: onDelete)
        }
        .accessibilityAction(named: Text(AppStrings.modifier), onUpdate)
        .accessibilityAction(named: Text(AppStrings.supprimer), onDelete)
    }

    private var initials: String {
        (instruction.beneficiary ?? "").split(separator: " ").prefix(2).compactMap { $0.first }.map(String.init).joined().uppercased()
    }

    private var displayNextDate: String {
        let raw = instruction.nextDate ?? ""
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        for format in ["yyyy-MM-dd", "MM-dd-yyyy", "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd'T'HH:mm:ss"] {
            formatter.dateFormat = format
            if let date = formatter.date(from: raw) {
                formatter.dateFormat = "dd/MM/yyyy"
                return formatter.string(from: date)
            }
        }
        return raw.isEmpty ? "—" : raw
    }

    private func summary(_ label: String, _ value: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(size: 12)).foregroundColor(StandingInstructionStyle.secondaryText)
            Text(value).font(.system(size: 15, weight: .bold)).foregroundColor(.black).lineLimit(1).minimumScaleFactor(0.7)
            if !detail.isEmpty { Text(detail).font(.system(size: 12)).foregroundColor(StandingInstructionStyle.secondaryText) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
    }

    private func formatAmount(_ amount: String) -> String {
        guard let doubleAmount = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            return amount
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: localization.language.rawValue)
        return formatter.string(from: NSNumber(value: doubleAmount)) ?? amount
    }
    
    private func getCurrencyDisplay(_ code: String) -> String {
        switch code {
        case "270", "GMD": return "GMD"
        case "324": return "GNF"
        case "840": return "USD"
        case "978": return "EUR"
        default: return code
        }
    }
    
    private func getFrequencyDisplay(_ code: String) -> String {
        switch code {
        case "D": return AppStrings.quotidien
        case "W": return AppStrings.hebdomadaire
        case "M": return AppStrings.mensuel
        case "Y": return AppStrings.annuel
        default: return code
        }
    }
}

struct DetailRowSmall: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// MARK: - Delete Confirmation Dialog
struct DeleteConfirmationDialog: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let instruction: StandingInstruction
    @Binding var isPresented: Bool
    let onConfirm: (String) -> Void
    let onCancel: () -> Void
    
    @State private var pin = ""
    @State private var showError = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 0) {
                // Header
                Text(AppStrings.confirmerLaSuppression)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                
                // Message
                Text(AppStrings.entrezVotreCodePinPourSupprimerCeVirementPermanent)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                
                // PIN Input
                WalletPINField(AppStrings.pin, text: $pin)
                    .keyboardType(.numberPad)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.horizontal, 16)
                    .frame(height: 50)
                    .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                    .cornerRadius(8)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .onChange(of: pin) {
                        if pin.count > 4 {
                            pin = String(pin.prefix(4))
                        }
                    }
                
                if showError {
                    Text(AppStrings.veuillezEntrerVotrePin)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
                
                // Buttons
                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text(AppStrings.buttonTitle(AppStrings.annuler))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(StandingInstructionStyle.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(StandingInstructionStyle.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        if (!pin.isValidWalletPIN) {
                            showError = true
                        } else {
                            showError = false
                            onConfirm(pin)
                        }
                    }) {
                        Text(AppStrings.buttonTitle(AppStrings.confirmer))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 32)
        }
    }
}

struct StandingInstructionListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StandingInstructionListView()
        }
    }
}


func standingText(_ english: String, _ french: String) -> String {
    AppLanguageStore.shared.language == .french ? french : english
}

enum StandingInstructionStyle {
    static let blue = Color(hex: "174EA6")
    static let accent = Color(hex: "0086B5")
    static let secondaryText = Color(hex: "555F6D")
    static let label = Color(hex: "858585")
    static let separator = Color(hex: "F0F0F0")
    static let avatarText = Color(hex: "12547B")
}

struct StandingInstructionHeader: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        ZStack {
            StandingInstructionStyle.blue.ignoresSafeArea(edges: .top)
            Text(title)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.horizontal, 58)
            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 23, weight: .regular))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 48)
                }
                .accessibilityLabel(standingText("Back", "Retour"))
                Spacer()
            }
            .padding(.horizontal, 12)
        }
        .frame(height: 60)
        .shadow(color: .black.opacity(0.12), radius: 2, y: 2)
    }
}

@ViewBuilder
func standingCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 17) {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(StandingInstructionStyle.blue)
            Rectangle().fill(StandingInstructionStyle.accent).frame(width: 64, height: 2)
        }
        content()
    }
    .font(.system(size: 14))
    .foregroundColor(StandingInstructionStyle.secondaryText)
    .padding(.horizontal, 17)
    .padding(.vertical, 20)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.white)
    .cornerRadius(14)
    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "F3F3F3"), lineWidth: 0.8))
    .shadow(color: .black.opacity(0.16), radius: 3, x: 0, y: 4)
}

extension View {
    func standingField() -> some View {
        self.padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 9))
            .overlay(RoundedRectangle(cornerRadius: 9).stroke(StandingInstructionStyle.secondaryText, lineWidth: 1.2))
    }
}
