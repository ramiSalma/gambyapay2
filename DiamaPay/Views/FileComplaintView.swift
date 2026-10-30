//
//  FileComplaintView.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//


//
//  FileComplaintView.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//

import SwiftUI

struct FileComplaintView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - State Variables
    @State private var selectedComplaintType = 0
    @State private var selectedPriority = 0
    @State private var selectedContactMethod = 0
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var incidentDate: String = ""
    @State private var transactionRef: String = ""
    @State private var alternateContact: String = ""
    
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = AppStrings.error
    
    @State private var showConfirmationDialog = false
    @State private var showSuccessDialog = false
    
    private let userDataManager = UserDataManager.shared
    private let maxDescriptionLength = 1000
    
    private let complaintTypes = [
        AppStrings.original("transactionEchouee"),
        AppStrings.original("debitNonAutorise"),
        AppStrings.original("problemeDeSecurite"),
        AppStrings.original("serviceClient"),
        AppStrings.original("applicationDefaillante"),
        AppStrings.original("fraisIncorrects"),
        AppStrings.original("problemeDeCompte"),
        AppStrings.original("autre")
    ]
    
    private let priorities = [
        AppStrings.original("urgentPerteFinanciere"),
        AppStrings.original("eleveServiceIndisponible"),
        AppStrings.original("moyenProblemeFonctionnel"),
        AppStrings.original("faibleAmelioration")
    ]
    
    private let contactMethods = [
        AppStrings.original("smsNumeroEnregistre"),
        AppStrings.original("emailAlternatif"),
        AppStrings.original("nePasMeContacter")
    ]
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                DiamaPayHeader(title: AppStrings.deposerUnePlainte, headerColor: Color(hex: "174EA6"))

                if isLoading {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blueH))
                            .scaleEffect(1.5)
                        
                        Text(AppStrings.traitementEnCours)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 14) {
                            // Instruction
                            instructionCard
                            
                            // Complaint Type Card
                            complaintTypeCard
                            
                            // Priority Card
                            priorityCard
                            
                            // Title Card
                            titleInputCard
                            
                            // Description Card
                            descriptionCard
                            
                            // Incident Date Card
                            incidentDateCard
                            
                            // Transaction Reference Card
                            transactionRefCard
                            
                            // Contact Method Card
                            contactMethodCard
                            
                            // Alternate Contact Card (conditional)
                            if selectedContactMethod == 1 {
                                alternateContactCard
                            }
                            
                            // Submit Button
                            submitButton
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 16)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {})
        }
        .navigationBarHidden(true)
        .onAppear {
            setDefaultDate()
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) { }
        } message: {
            Text(AppStrings.option(alertMessage))
        }
        .overlay(confirmationDialogOverlay)
        .sheet(isPresented: $showSuccessDialog) {
            ComplaintSuccessDialogView(
                complaintType: complaintTypes[selectedComplaintType],
                priority: extractPriorityLevel(priorities[selectedPriority]),
                title: title,
                expectedResolution: getExpectedResolutionTime(extractPriorityLevel(priorities[selectedPriority])),
                onClose: {
                    showSuccessDialog = false
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private var confirmationDialogOverlay: some View {
        Group {
            if showConfirmationDialog {
                ComplaintConfirmationDialog(
                    complaintType: complaintTypes[selectedComplaintType],
                    priority: priorities[selectedPriority],
                    title: title,
                    expectedResolution: getExpectedResolutionTime(extractPriorityLevel(priorities[selectedPriority])),
                    isPresented: $showConfirmationDialog,
                    onConfirm: {
                        showConfirmationDialog = false
                        submitComplaint()
                    },
                    onCancel: {
                        showConfirmationDialog = false
                    }
                )
            }
        }
    }
    
    
    // MARK: - Title Card
    private var titleCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "174EA6"))
                .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
            
            VStack(spacing: 8) {
                Text(AppStrings.deposerUnePlainte)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Rectangle()
                    .fill(.white)
                    .frame(width: 64, height: 2)
            }
            .padding(.vertical, 14)
        }
    }
    
    // MARK: - Instruction Card
    private var instructionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 16))
                
                Text(AppStrings.signalerUnProbleme)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Text(AppStrings.veuillezFournirAutantDeDetailsQuePossiblePourNousAider)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(14)
        .background(Color(hex: "FFF8ED"))
        .cornerRadius(16)
    }
    
    // MARK: - Complaint Type Card
    private var complaintTypeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.typeDePlainte)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Rectangle()
                    .fill(Color(hex: "0788B9"))
                    .frame(width: 64, height: 2)
            }
            
            Menu {
                ForEach(0..<complaintTypes.count, id: \.self) { index in
                    Button(action: {
                        selectedComplaintType = index
                    }) {
                        HStack {
                            Text(AppStrings.buttonTitle(AppStrings.option(complaintTypes[index])))
                            if selectedComplaintType == index {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(AppStrings.option(complaintTypes[selectedComplaintType]))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "596273"), lineWidth: 1.2))
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Priority Card
    private var priorityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.priorite)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Rectangle()
                    .fill(Color(hex: "0788B9"))
                    .frame(width: 64, height: 2)
            }
            
            Menu {
                ForEach(0..<priorities.count, id: \.self) { index in
                    Button(action: {
                        selectedPriority = index
                    }) {
                        HStack {
                            Text(AppStrings.buttonTitle(AppStrings.option(priorities[index])))
                            if selectedPriority == index {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(AppStrings.option(priorities[selectedPriority]))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "596273"), lineWidth: 1.2))
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Title Input Card
    private var titleInputCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.titre)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Rectangle()
                    .fill(Color(hex: "0788B9"))
                    .frame(width: 64, height: 2)
            }
            
            TextField(AppStrings.entrerLeTitre, text: $title)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "596273"), lineWidth: 1.2))
                .cornerRadius(12)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Description Card
    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.description2)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Rectangle()
                    .fill(Color(hex: "0788B9"))
                    .frame(width: 64, height: 2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                TextEditor(text: $description)
                    .font(.system(size: 14, weight: .medium))
                    .frame(height: 160)
                    .padding(8)
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "596273"), lineWidth: 1.2))
                    .cornerRadius(12)
                    .onChange(of: description) {
                        if description.count > maxDescriptionLength {
                            description = String(description.prefix(maxDescriptionLength))
                        }
                    }
                
                HStack {
                    Spacer()
                    Text(AppStrings.valueValueCaracteres(String(describing: description.count), String(describing: maxDescriptionLength)))
                        .font(.system(size: 12))
                        .foregroundColor(characterCountColor)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Incident Date Card
    private var incidentDateCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.dateDeLIncident)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Rectangle()
                    .fill(Color(hex: "0788B9"))
                    .frame(width: 64, height: 2)
            }
            
            TextField(AppStrings.jjMmAaaa, text: $incidentDate)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "596273"), lineWidth: 1.2))
                .cornerRadius(12)
                .disabled(true)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Transaction Reference Card
    private var transactionRefCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.referenceTransactionOptionnel)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Rectangle()
                    .fill(Color(hex: "0788B9"))
                    .frame(width: 64, height: 2)
            }
            
            TextField(AppStrings.entrerLaReference, text: $transactionRef)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "596273"), lineWidth: 1.2))
                .cornerRadius(12)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Contact Method Card
    private var contactMethodCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.methodeDeContact)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Rectangle()
                    .fill(Color(hex: "0788B9"))
                    .frame(width: 64, height: 2)
            }
            
            Menu {
                ForEach(0..<contactMethods.count, id: \.self) { index in
                    Button(action: {
                        selectedContactMethod = index
                    }) {
                        HStack {
                            Text(AppStrings.buttonTitle(AppStrings.option(contactMethods[index])))
                            if selectedContactMethod == index {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(AppStrings.option(contactMethods[selectedContactMethod]))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "596273"), lineWidth: 1.2))
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Alternate Contact Card
    private var alternateContactCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.emailAlternatif2)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Rectangle()
                    .fill(Color(hex: "0788B9"))
                    .frame(width: 64, height: 2)
            }
            
            TextField(AppStrings.entrerVotreEmail, text: $alternateContact)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "596273"), lineWidth: 1.2))
                .cornerRadius(12)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Submit Button
    private var submitButton: some View {
        Button(action: {
            if validateInputs() {
                showConfirmationDialog = true
            }
        }) {
            Text(AppStrings.buttonTitle(AppStrings.soumettre))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 180, height: 50)
                .background(Color(hex: "174EA6"))
                .cornerRadius(12)
        }
        .disabled(isLoading)
        .padding(.bottom, 20)
    }
    
    // MARK: - Computed Properties
    private var characterCountColor: Color {
        let percentage = Double(description.count) / Double(maxDescriptionLength)
        if percentage > 0.9 {
            return .red
        } else if percentage > 0.7 {
            return .orange
        } else {
            return .secondary
        }
    }
    
    // MARK: - Helper Methods
    private func setDefaultDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        incidentDate = dateFormatter.string(from: Date())
    }
    
    private func validateInputs() -> Bool {
        if title.trimmingCharacters(in: .whitespaces).isEmpty {
            showErrorAlert(AppStrings.veuillezEntrerUnTitre)
            return false
        }
        
        if title.trimmingCharacters(in: .whitespaces).count < 5 {
            showErrorAlert(AppStrings.leTitreDoitContenirAuMoins5Caracteres)
            return false
        }
        
        if description.trimmingCharacters(in: .whitespaces).isEmpty {
            showErrorAlert(AppStrings.veuillezDecrireVotrePlainte)
            return false
        }
        
        if description.trimmingCharacters(in: .whitespaces).count < 20 {
            showErrorAlert(AppStrings.laDescriptionDoitContenirAuMoins20Caracteres)
            return false
        }
        
        if incidentDate.trimmingCharacters(in: .whitespaces).isEmpty {
            showErrorAlert(AppStrings.veuillezEntrerLaDateDeLIncident)
            return false
        }
        
        if selectedContactMethod == 1 && !alternateContact.isEmpty {
            if !isValidEmail(alternateContact) {
                showErrorAlert(AppStrings.formatDEmailInvalide)
                return false
            }
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func submitComplaint() {
        isLoading = true
        
        let request = ComplaintRequest(
            userPhone: userDataManager.getPhoneNumber(),
            userName: userDataManager.getUserName(),
            complaintType: complaintTypes[selectedComplaintType],
            priority: extractPriorityLevel(priorities[selectedPriority]),
            title: title.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            incidentDate: incidentDate,
            transactionRef: transactionRef.isEmpty ? nil : transactionRef.trimmingCharacters(in: .whitespaces),
            contactMethod: contactMethods[selectedContactMethod],
            alternateContact: alternateContact.isEmpty ? nil : alternateContact.trimmingCharacters(in: .whitespaces)
        )
        
        APIClient.shared.sendComplaint(request: request) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success:
                    self.showSuccessDialog = true
                case .failure(let error):
                    if let apiError = error as? APIError {
                        self.handleApiError(apiError)
                    } else {
                        self.showErrorAlert(AppStrings.erreurReseauValue(String(describing: error.localizedDescription)))
                    }
                }
            }
        }
    }
    
    private func extractPriorityLevel(_ priority: String) -> String {
        if priority.contains("Urgent") { return "URGENT" }
        if priority.contains("Élevé") { return "ÉLEVÉ" }
        if priority.contains("Moyen") { return "MOYEN" }
        if priority.contains("Faible") { return "FAIBLE" }
        return "MOYEN"
    }
    
    private func getExpectedResolutionTime(_ priority: String) -> String {
        switch priority {
        case "URGENT": return AppStrings.original("copy2448Heures")
        case "ÉLEVÉ": return AppStrings.original("copy23JoursOuvrables")
        case "MOYEN": return AppStrings.original("copy57JoursOuvrables")
        case "FAIBLE": return AppStrings.original("copy714JoursOuvrables")
        default: return AppStrings.original("copy57JoursOuvrables")
        }
    }
    
    private func handleApiError(_ error: APIError) {
        let message: String
        switch error.respCode {
        case "400":
            message = AppStrings.donneesInvalidesVeuillezVerifierVosInformations
        case "401":
            message = AppStrings.loginAgain
        case "429":
            message = AppStrings.vousAvezDeposeTropDePlaintesRecemmentVeuillezAttendre
        case "500", "502", "503":
            message = AppStrings.erreurDuServeurVeuillezReessayerPlusTard
        default:
            message = error.message
        }
        showErrorAlert(message)
    }
    
    private func showErrorAlert(_ message: String) {
        alertTitle = AppStrings.error
        alertMessage = message
        showAlert = true
    }
}

// MARK: - Complaint Confirmation Dialog
struct ComplaintConfirmationDialog: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let complaintType: String
    let priority: String
    let title: String
    let expectedResolution: String
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text(AppStrings.confirmerLeDepotDePlainte)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                
                // Details
                VStack(alignment: .leading, spacing: 12) {
                    DetailRow(label: AppStrings.type2, value: complaintType)
                    Divider()
                    DetailRow(label: AppStrings.priorite2, value: priority.replacingOccurrences(of: #"^[🔴🟠🟡🟢]\s*"#, with: "", options: .regularExpression))
                    Divider()
                    DetailRow(label: AppStrings.titre2, value: title)
                    Divider()
                    DetailRow(label: AppStrings.resolutionEstimee, value: AppStrings.option(expectedResolution))
                }
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                Text(AppStrings.etesVousSurDeVouloirDeposerCettePlainte)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // Buttons
                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text(AppStrings.buttonTitle(AppStrings.annuler))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.blueH)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.blueH.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Button(action: onConfirm) {
                        Text(AppStrings.buttonTitle(AppStrings.deposer))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.orange)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 20)
            .padding(.horizontal, 32)
        }
    }
}

// MARK: - Complaint Success Dialog
struct ComplaintSuccessDialogView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let complaintType: String
    let priority: String
    let title: String
    let expectedResolution: String
    let onClose: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                        .padding(.top, 20)
                    
                    Text(AppStrings.plainteDeposee)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(label: AppStrings.type2, value: complaintType)
                        Divider()
                        DetailRow(label: AppStrings.priorite2, value: priority)
                        Divider()
                        DetailRow(label: AppStrings.titre2, value: title)
                        Divider()
                        DetailRow(label: AppStrings.tempsDeResolutionEstime, value: AppStrings.option(expectedResolution))
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    Text(AppStrings.vousRecevrezUneConfirmationEtDesMisesAJourSelon)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: onClose) {
                        Text(AppStrings.buttonTitle(AppStrings.fermer))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blueH)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationBarItems(trailing: Button(AppStrings.buttonTitle(AppStrings.fermer), action: onClose))
            .navigationBarTitle(AppStrings.confirmation, displayMode: .inline)
        }
    }
}

// MARK: - Success Dialog (for Comments)
struct SuccessDialogView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let title: String
    let message: String
    let onClose: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Spacer()
                
                Button(action: onClose) {
                    Text(AppStrings.buttonTitle(AppStrings.fermer))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blueH)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
            .navigationBarItems(trailing: Button(AppStrings.buttonTitle(AppStrings.fermer), action: onClose))
            .navigationBarTitle(AppStrings.succes, displayMode: .inline)
        }
    }
}

// MARK: - Preview
struct FileComplaintView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FileComplaintView()
        }
    }
}
