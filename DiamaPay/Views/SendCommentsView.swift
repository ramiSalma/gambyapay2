//
//  SendCommentsView.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//


//
//  SendCommentsView.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//

import SwiftUI

struct SendCommentsView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - State Variables
    @State private var selectedCategory = 0
    @State private var subject: String = ""
    @State private var comment: String = ""
    @State private var email: String = ""
    
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = AppStrings.error
    
    @State private var showConfirmationDialog = false
    @State private var showSuccessDialog = false
    
    private let userDataManager = UserDataManager.shared
    private let maxCommentLength = 500
    
    private let categories = [
        AppStrings.original("interfaceUtilisateur"),
        AppStrings.original("fonctionnalites"),
        AppStrings.original("performance"),
        AppStrings.original("securite"),
        AppStrings.original("serviceClient"),
        AppStrings.original("suggestionDAmelioration"),
        AppStrings.original("felicitations2"),
        AppStrings.original("autre")
    ]
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                DiamaPayHeader(title: AppStrings.commentairesSuggestions, headerColor: Color(hex: "174EA6"))

                if isLoading {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blueH))
                            .scaleEffect(1.5)
                        
                        Text(AppStrings.envoiEnCours)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 14) {
                            // Instruction
                            instructionCard
                            
                            // Category Card
                            categoryCard
                            
                            // Subject Card
                            subjectCard
                            
                            // Comment Card
                            commentCard
                            
                            // Email Card (Optional)
                            emailCard
                            
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
        .alert(alertTitle, isPresented: $showAlert) {
            Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) { }
        } message: {
            Text(AppStrings.option(alertMessage))
        }
        .overlay(confirmationDialogOverlay)
        .sheet(isPresented: $showSuccessDialog) {
            SuccessDialogView(
                title: AppStrings.commentaireEnvoye,
                message: AppStrings.votreCommentaireAEteEnvoyeAvecSuccesMerciPourVotre,
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
                CommentConfirmationDialog(
                    category: categories[selectedCategory],
                    subject: subject,
                    isPresented: $showConfirmationDialog,
                    onConfirm: {
                        showConfirmationDialog = false
                        submitComment()
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
                Text(AppStrings.commentairesSuggestions)
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
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blueH)
                    .font(.system(size: 16))
                
                Text(AppStrings.nousValorisonsVosRetours)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Text(AppStrings.partagezVosCommentairesSuggestionsOuFelicitationsPourNousAiderA)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(14)
        .background(Color(hex: "F3F6FA"))
        .cornerRadius(16)
    }
    
    // MARK: - Category Card
    private var categoryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.categorie)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Rectangle()
                    .fill(Color(hex: "0788B9"))
                    .frame(width: 64, height: 2)
            }
            
            Menu {
                ForEach(0..<categories.count, id: \.self) { index in
                    Button(action: {
                        selectedCategory = index
                    }) {
                        HStack {
                            Text(AppStrings.buttonTitle(AppStrings.option(categories[index])))
                            if selectedCategory == index {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(AppStrings.option(categories[selectedCategory]))
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
    
    // MARK: - Subject Card
    private var subjectCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.sujet)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Rectangle()
                    .fill(Color(hex: "0788B9"))
                    .frame(width: 64, height: 2)
            }
            
            TextField(AppStrings.entrerLeSujet, text: $subject)
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
    
    // MARK: - Comment Card
    private var commentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.commentaire)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Rectangle()
                    .fill(Color(hex: "0788B9"))
                    .frame(width: 64, height: 2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                TextEditor(text: $comment)
                    .font(.system(size: 14, weight: .medium))
                    .frame(height: 140)
                    .padding(8)
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "596273"), lineWidth: 1.2))
                    .cornerRadius(12)
                    .onChange(of: comment) {
                        if comment.count > maxCommentLength {
                            comment = String(comment.prefix(maxCommentLength))
                        }
                    }
                
                HStack {
                    Spacer()
                    Text(AppStrings.valueValueCaracteres(String(describing: comment.count), String(describing: maxCommentLength)))
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
    
    // MARK: - Email Card
    private var emailCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.emailOptionnel)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "174EA6"))
                
                Rectangle()
                    .fill(Color(hex: "0788B9"))
                    .frame(width: 64, height: 2)
            }
            
            TextField(AppStrings.entrerVotreEmail, text: $email)
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
            Text(AppStrings.buttonTitle(AppStrings.envoyer))
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
        let percentage = Double(comment.count) / Double(maxCommentLength)
        if percentage > 0.9 {
            return .red
        } else if percentage > 0.7 {
            return .orange
        } else {
            return .secondary
        }
    }
    
    // MARK: - Helper Methods
    private func validateInputs() -> Bool {
        if subject.trimmingCharacters(in: .whitespaces).isEmpty {
            showErrorAlert(AppStrings.veuillezEntrerUnSujet)
            return false
        }
        
        if comment.trimmingCharacters(in: .whitespaces).isEmpty {
            showErrorAlert(AppStrings.veuillezEntrerVotreCommentaire)
            return false
        }
        
        if comment.trimmingCharacters(in: .whitespaces).count < 10 {
            showErrorAlert(AppStrings.leCommentaireDoitContenirAuMoins10Caracteres)
            return false
        }
        
        if !email.isEmpty && !isValidEmail(email) {
            showErrorAlert(AppStrings.formatDEmailInvalide)
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func submitComment() {
        isLoading = true
        
        let request = CommentRequest(
            userName: userDataManager.getUserName(),
            userPhone: userDataManager.getPhoneNumber(),
            category: categories[selectedCategory],
            subject: subject.trimmingCharacters(in: .whitespaces),
            comment: comment.trimmingCharacters(in: .whitespaces),
            email: email.isEmpty ? nil : email.trimmingCharacters(in: .whitespaces)
        )
        
        APIClient.shared.sendComment(request: request) { result in
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
    
    private func handleApiError(_ error: APIError) {
        let message: String
        switch error.respCode {
        case "400":
            message = AppStrings.donneesInvalidesVeuillezVerifierVosInformations
        case "401":
            message = AppStrings.loginAgain
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

// MARK: - Confirmation Dialog
struct CommentConfirmationDialog: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let category: String
    let subject: String
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
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blueH)
                    
                    Text(AppStrings.confirmerLEnvoi)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                // Details
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(AppStrings.categorie2)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(AppStrings.option(category))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text(AppStrings.sujet2)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(subject)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                    }
                }
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                Text(AppStrings.etesVousSurDeVouloirEnvoyerCeCommentaire)
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
                        Text(AppStrings.buttonTitle(AppStrings.envoyer))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.blueH)
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

// MARK: - Preview
struct SendCommentsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SendCommentsView()
        }
    }
}
