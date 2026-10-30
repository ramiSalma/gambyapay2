//
//  RegistrationFlowView.swift
//  DiamaPay
//
//  Created by Bits on 25/9/2025.
//

import SwiftUI

private enum RegistrationTheme {
    static let navy = Color(red: 23 / 255.0, green: 73 / 255.0, blue: 157 / 255.0)
    static let teal = Color(red: 0 / 255.0, green: 132 / 255.0, blue: 184 / 255.0)
    static let canvas = Color(red: 247 / 255.0, green: 248 / 255.0, blue: 253 / 255.0)
    static let ink = Color(red: 73 / 255.0, green: 82 / 255.0, blue: 99 / 255.0)
}

struct RegistrationFlowView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @State private var currentStep = 1
    @StateObject private var registrationData = RegistrationData()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var showPersonalInfoErrors = false
    @State private var showPinErrors = false
    @State private var showOtpErrors = false
    @State private var otpServerError: String?
    @Environment(\.dismiss) private var dismiss
    @State private var showImagePicker = false
    @State private var pickerType: String = ""
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .camera
    @State private var showingActionSheet = false
    
    // API data states
    @State private var nationalities: [Nationality] = []
    @State private var branches: [Branch] = []
    @State private var secretQuestions: [SecretQuestion] = []
    @State private var isLoadingNationalities = false
    @State private var isLoadingSecretQuestions = false
    
    // Terms and Conditions tracking
    @State private var expandedTermsSections: Set<String> = []
    
    let totalSteps = 5
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView
                
                if currentStep == 4 {
                    TermsAndConditionsView(
                        registrationAcceptance: Binding(
                            get: { registrationData.acceptTerms && registrationData.acceptPrivacy },
                            set: { accepted in
                                registrationData.acceptTerms = accepted
                                registrationData.acceptPrivacy = accepted
                            }
                        ),
                        onAccept: nextStep,
                        onRefuse: { dismiss() }
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            stepContentView
                            navigationButtonsView
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 30)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .background(RegistrationTheme.canvas)
        }
        .alert(AppStrings.registration, isPresented: $showAlert) {
            Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) { }
        } message: {
            Text(AppStrings.option(alertMessage))
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text(AppStrings.choosePhotoSource),
                message: Text(AppStrings.chooseHowToAddThePhoto),
                buttons: [
                    .default(Text(AppStrings.camera2)) {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            imagePickerSourceType = .camera
                            showImagePicker = true
                        } else {
                            imagePickerSourceType = .photoLibrary
                            showImagePicker = true
                        }
                    },
                    .default(Text(AppStrings.photoLibrary)) {
                        imagePickerSourceType = .photoLibrary
                        showImagePicker = true
                    },
                    .cancel(Text(AppStrings.buttonTitle(AppStrings.cancel)))
                ]
            )
        }
        .onAppear {
            fetchNationalities()
            fetchSecretQuestions()
            fetchRegistrationBranches()
        }
    }
    
    // MARK: - Header View with Step Indicator
    private var headerView: some View {
        VStack(spacing: 18) {
            // "Étape" text centered with back arrow on the left
            ZStack {
                // Back arrow on the left
                HStack {
                    Button(action: {
                        if currentStep > 1 {
                            currentStep -= 1
                        } else {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                }
                
                // Centered text
                Text(AppStrings.stepValueOfValue(String(describing: min(currentStep, totalSteps)), String(describing: totalSteps)))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // Step Indicator
            HStack(spacing: 4) {
                ForEach(1...totalSteps, id: \.self) { step in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(step == currentStep ? RegistrationTheme.teal : (step < currentStep ? RegistrationTheme.navy : .white))
                            .stroke(step <= currentStep ? Color.white : Color.white.opacity(0.8), lineWidth: step == currentStep ? 2 : 1)
                            .frame(width: 34, height: 34)
                            .overlay(
                                Text("\(step)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(step <= currentStep ? .white : RegistrationTheme.ink)
                            )
                        
                        if step < totalSteps {
                            Rectangle()
                                .fill(Color.white.opacity(0.8))
                                .frame(height: 2)
                                .frame(maxWidth: 30)
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 28)
        }
        .background(RegistrationTheme.navy)
    }
    
    // MARK: - Step Content View
    @ViewBuilder
    private var stepContentView: some View {
        switch currentStep {
        case 1: step1PersonalInfoView
        case 2: step2PinSetupView
        case 3: step3DocumentScanView
        case 4: step4TermsAndConditionsView
        case 5: step5OtpVerificationView
        case 6: step6SuccessView
        default: EmptyView()
        }
    }
    
    // MARK: - Step 1: Personal Info
    private var step1PersonalInfoView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(AppStrings.enterYourPersonalInformation)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            sectionHeader(AppStrings.basicInformation)
            CustomTextField(title: AppStrings.firstName2, text: $registrationData.firstName, error: personalInfoError("firstName"))
            CustomTextField(title: AppStrings.lastName, text: $registrationData.lastName, error: personalInfoError("lastName"))
            CustomTextField(title: AppStrings.phoneNumber3, text: $registrationData.phoneNumber.walletPhoneNumber(), icon: "phone.fill", keyboardType: .numberPad, error: personalInfoError("phone"), digitLimit: 10)
            CustomTextField(title: AppStrings.email2, text: $registrationData.email, icon: "envelope", keyboardType: .emailAddress, error: personalInfoError("email"))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(AppStrings.dateOfBirth)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blueH)
                        .frame(width: 20)
                    
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { registrationData.birthDate ?? Date() },
                            set: {
                                registrationData.birthDate = $0
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd"
                                registrationData.dateOfBirth = formatter.string(from: $0)
                            }
                        ),
                        in: ...Calendar.current.date(byAdding: .year, value: -18, to: Date())!,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 18).fill(RegistrationTheme.canvas)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.gray.opacity(0.7), lineWidth: 1.5)))
                inlineFieldError(personalInfoError("birthDate"))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(AppStrings.gender)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(RegistrationTheme.ink)
                Menu {
                    Button(AppStrings.buttonTitle(AppStrings.male)) { registrationData.gender = "M" }
                    Button(AppStrings.buttonTitle(AppStrings.female)) { registrationData.gender = "F" }
                } label: {
                    HStack {
                        Text(registrationData.gender.isEmpty ? AppStrings.selectYourGender : (registrationData.gender == "M" ? AppStrings.male : AppStrings.female))
                            .foregroundColor(registrationData.gender.isEmpty ? .gray : .primary)
                        Spacer()
                        Image(systemName: "chevron.down").foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 19)
                    .background(RoundedRectangle(cornerRadius: 18).fill(.white)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.gray.opacity(0.7), lineWidth: 1.5)))
                }
                inlineFieldError(personalInfoError("gender"))
            }
            
            sectionHeader(AppStrings.identification)
            
            CustomTextField(title: AppStrings.nationalId2, text: $registrationData.documentId, error: personalInfoError("documentId"))

            // Nationality and branch selectors mirror the Android registration form.
            SearchableNationalityPicker(
                nationalities: nationalities,
                isLoading: isLoadingNationalities,
                selectedNationality: $registrationData.nationalityDisplay,
                onSelect: { nationality in
                    registrationData.nationality = nationality.code
                    registrationData.nationalityDisplay = nationality.wording
                }
            )
            inlineFieldError(personalInfoError("nationality"))

            VStack(alignment: .leading, spacing: 8) {
                Menu {
                    ForEach(branches, id: \.id) { branch in
                        Button(AppStrings.buttonTitle(branch.name ?? branch.id ?? AppStrings.branch)) {
                            registrationData.branchCode = branch.id ?? ""
                            registrationData.branchDisplay = branch.name ?? branch.id ?? ""
                        }
                    }
                } label: {
                    HStack {
                        Text(registrationData.branchDisplay.isEmpty ? AppStrings.chooseABranch : registrationData.branchDisplay)
                            .foregroundColor(registrationData.branchDisplay.isEmpty ? .gray : .primary)
                        Spacer()
                        Image(systemName: "chevron.down").foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 19)
                    .background(RoundedRectangle(cornerRadius: 18).fill(RegistrationTheme.canvas)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.gray.opacity(0.7), lineWidth: 1.5)))
                }
                .disabled(branches.isEmpty)
                inlineFieldError(personalInfoError("branchCode"))
            }
            
            CustomTextField(title: AppStrings.residentialAddress, text: $registrationData.address, icon: "location.circle", error: personalInfoError("address"))


            sectionHeader(AppStrings.security)
            
            // Secret Question Picker with API
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(AppStrings.secretQuestion)
                        .font(.system(size: 16, weight: .medium))
                    
                    if isLoadingSecretQuestions {
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                }
                
                Menu {
                    if secretQuestions.isEmpty {
                        Button(AppStrings.buttonTitle(AppStrings.loading)) { }
                            .disabled(true)
                    } else {
                        ForEach(secretQuestions, id: \.id) { question in
                            Button(AppStrings.buttonTitle(question.question)) {
                                registrationData.secretQ = question.id
                                registrationData.secretQDisplay = question.question
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.blueH)
                            .frame(width: 20)
                        
                        Text(registrationData.secretQDisplay.isEmpty ? AppStrings.selectAQuestion : registrationData.secretQDisplay)
                            .foregroundColor(registrationData.secretQDisplay.isEmpty ? .gray : .primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 19)
                    .background(RoundedRectangle(cornerRadius: 18).fill(RegistrationTheme.canvas)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.gray.opacity(0.7), lineWidth: 1.5)))
                }
                .disabled(isLoadingSecretQuestions || secretQuestions.isEmpty)
                inlineFieldError(personalInfoError("secretQ"))
            }
            
            CustomTextField(title: AppStrings.yourAnswer, text: $registrationData.answer, error: personalInfoError("answer"))
            
            sectionHeader(AppStrings.nextOfKin2)
            CustomTextField(title: AppStrings.nextOfKinName, text: $registrationData.nkinName, error: personalInfoError("nkinName"))
            CustomTextField(title: AppStrings.nextOfKinPhone, text: $registrationData.nkinPhone.walletPhoneNumber(), icon: "phone.fill", keyboardType: .numberPad, error: personalInfoError("nkinPhone"), digitLimit: 10)

        }
        .padding(.vertical, 20)
        .padding(.horizontal, 10)
    }

    // MARK: - Step 2: PIN Setup
    private var step2PinSetupView: some View {
        VStack(alignment: .leading, spacing: 20) {
                Text(AppStrings.createYourPinCode)
                .font(.system(size: 24, weight: .semibold))
            
            Text(AppStrings.thisPinCodeWillSecureYourAccountAndConfirmYour)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                WalletPINField(AppStrings.enterYour4DigitPinCode, text: $registrationData.pin)
                    .keyboardType(.numberPad)
                    .padding(18)
                    .background(RoundedRectangle(cornerRadius: 18).fill(RegistrationTheme.canvas)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.gray.opacity(0.7), lineWidth: 1.5)))
                    .onChange(of: registrationData.pin) {
                        if registrationData.pin.count > 4 {
                            registrationData.pin = String(registrationData.pin.prefix(4))
                        }
                    }
                inlineFieldError(showPinErrors ? pinError : nil)
                
                WalletPINField(AppStrings.confirmYourPinCode, text: $registrationData.confirmPin)
                    .keyboardType(.numberPad)
                    .padding(18)
                    .background(RoundedRectangle(cornerRadius: 18).fill(RegistrationTheme.canvas)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.gray.opacity(0.7), lineWidth: 1.5)))
                    .onChange(of: registrationData.confirmPin) {
                        if registrationData.confirmPin.count > 4 {
                            registrationData.confirmPin = String(registrationData.confirmPin.prefix(4))
                        }
                    }
                inlineFieldError(showPinErrors ? confirmPinError : nil)
                
                if !registrationData.pin.isEmpty || !registrationData.confirmPin.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: registrationData.pin.isValidWalletPIN ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(registrationData.pin.isValidWalletPIN ? .green : .red)
                            Text(AppStrings.pinMustContainExactly4Digits)
                                .font(.caption)
                        }
                        
                        if registrationData.pin.isValidWalletPIN {
                            HStack {
                                Image(systemName: isWeakPin(registrationData.pin) ? "xmark.circle.fill" : "checkmark.circle.fill")
                                    .foregroundColor(isWeakPin(registrationData.pin) ? .red : .green)
                                Text(isWeakPin(registrationData.pin)
                                     ? AppStrings.chooseALessPredictablePin
                                     : AppStrings.pinLooksSecure)
                                    .font(.caption)
                                    .foregroundColor(isWeakPin(registrationData.pin) ? .red : .primary)
                            }
                        }
                        
                        if !registrationData.confirmPin.isEmpty {
                            HStack {
                                Image(systemName: registrationData.pin == registrationData.confirmPin ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(registrationData.pin == registrationData.confirmPin ? .green : .red)
                                Text(AppStrings.pinsMustMatch)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Step 3: Document Scan View
    private var step3DocumentScanView: some View {
        VStack(spacing: 25) {
            Text(AppStrings.scanYourIdentificationDocuments)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(RegistrationTheme.ink)
            Text(AppStrings.toValidateYourAccountScanTheRequestedDocumentsMakeSure)
                .font(.system(size: 16))
                .foregroundColor(RegistrationTheme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(alignment: .top, spacing: 14) {
                GeometryReader { geometry in
                    let documentImages = [registrationData.selfieBase64, registrationData.idFrontBase64, registrationData.idBackBase64]
                    let completedCount = documentImages.filter { !$0.isEmpty }.count
                    ZStack(alignment: .top) {
                        Rectangle()
                            .fill(completedCount == 3 ? RegistrationTheme.navy : Color.gray.opacity(0.25))
                            .frame(width: 3, height: max(0, geometry.size.height - 24))
                            .offset(y: 12)

                        VStack(spacing: 0) {
                            ForEach(0..<3, id: \.self) { index in
                                Circle()
                                    .fill(!documentImages[index].isEmpty ? RegistrationTheme.navy : (index == completedCount ? RegistrationTheme.teal : .white))
                                    .frame(width: 24, height: 24)
                                    .overlay(Circle().stroke(index <= completedCount ? RegistrationTheme.teal : Color.gray.opacity(0.35), lineWidth: 2))
                                if index < 2 { Spacer(minLength: 0) }
                            }
                        }
                    }
                }
                .frame(width: 24)

                VStack(spacing: 20) {
            identificationCard(
                title: AppStrings.personalPhoto,
                description: AppStrings.takeAWellLitPhotoOfYourFaceWithoutGlasses,
                buttonText: registrationData.selfieBase64.isEmpty ? AppStrings.takeAPhoto : AppStrings.retakePhoto,
                systemIcon: "person.circle.fill",
                isCompleted: !registrationData.selfieBase64.isEmpty,
                isEnabled: true
            ) {
                pickerType = "selfie"
                showSourceSelection()
            }
            
            identificationCard(
                    title: AppStrings.frontOfIdCard,
                    description: AppStrings.makeSureAllInformationIsClearlyVisibleAndThePhoto,
                    buttonText: registrationData.idFrontBase64.isEmpty ? AppStrings.takeFrontPhoto : AppStrings.retakeFront,
                    systemIcon: "creditcard.fill",
                    isCompleted: !registrationData.idFrontBase64.isEmpty,
                    isEnabled: true
            ) {
                pickerType = "idFront"
                showSourceSelection()
            }
            
            identificationCard(
                    title: AppStrings.backOfIdCard,
                    description: AppStrings.makeSureAllInformationIsClearlyVisibleAndTheDocument,
                    buttonText: registrationData.idBackBase64.isEmpty ? AppStrings.takeBackPhoto : AppStrings.retakeBack,
                    systemIcon: "creditcard.and.123",
                    isCompleted: !registrationData.idBackBase64.isEmpty,
                    isEnabled: true
            ) {
                pickerType = "idBack"
                showSourceSelection()
            }
                }
            }
            
            let completedDocs = [registrationData.selfieBase64, registrationData.idFrontBase64, registrationData.idBackBase64].filter { !$0.isEmpty }.count
            
            HStack {
                Text(AppStrings.documentsCapturedValue3(String(describing: completedDocs)))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                ProgressView(value: Double(completedDocs), total: 3.0)
                    .frame(width: 100)
            }
            .padding(.horizontal)
            
            if completedDocs == 3 {
                Text(AppStrings.allDocumentsAreCapturedYouCanContinue)
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.top, 10)
            }
        }
        .padding(.horizontal, 20)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: imagePickerSourceType) { image in
                handleImageSelection(image)
            }
        }
    }
    
    // MARK: - Step 4: Terms and Conditions (COMPLETE VERSION)
    private var step4TermsAndConditionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(AppStrings.terms)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text("GambiaPay - Moneya")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.blueH)
            
            Text(AppStrings.pleaseReviewAndAcceptTheTermsToContinue)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            // Complete terms content in scrollview
            ScrollView {
                LazyVStack(spacing: 12) {
                    // Definitions Section
                    termsSection(
                        icon: "book.fill",
                        title: AppStrings.definitions2,
                        id: "definitions"
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            termsParagraph(AppStrings.pourLesBesoinsDuPresentContratIlConvientD)
                            
                            termsDefinitionItem(AppStrings.banque, AppStrings.laDiamaBankSa)
                            termsDefinitionItem(AppStrings.contrat, AppStrings.designeLePresentContratDAdhesionAuServiceDiamacash)
                            termsDefinitionItem(AppStrings.applicationMobile, AppStrings.uneApplicationMobileEstUnLogicielApplicatifDeveloppePour)
                            termsDefinitionItem(AppStrings.wallet, AppStrings.constitueUnMoyenDePaiementPermettantASonDetenteur)
                            termsDefinitionItem(AppStrings.etablissement, AppStrings.designeToutEtablissementBancaireOuLesEtablissementsDePaiement)
                            termsDefinitionItem("Cash-In", AppStrings.ilSAgitDUneOperationDeDepotD)
                            termsDefinitionItem("Cash-Out", AppStrings.ilSAgitDUneOperationDeRetraitD)
                            termsDefinitionItem(AppStrings.compteDeRattachement, AppStrings.designeLeCompteOuvertDansLesLivresDeLa)
                            termsDefinitionItem(AppStrings.detenteurDuWallet, AppStrings.peutEtreLeTitulaireDuCompteOuTouteAutre)
                            termsDefinitionItem("GambiaPay", AppStrings.designeLApplicationDePaiementMobilePourLesClients)
                            termsDefinitionItem("DAB/GAB", AppStrings.appareilsDeDistributionAutomatiqueDeBilletsDeBanque)
                            termsDefinitionItem(AppStrings.tpe, AppStrings.terminalDePaiementElectronique)
                        }
                    }
                    
                    // Object Section
                    termsSection(
                        icon: "target",
                        title: AppStrings.object,
                        id: "object"
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            termsParagraph(AppStrings.leWalletDiamacashEstUnMoyenDePaiementElectronique)
                            termsParagraph(AppStrings.cetteApplicationEstTelechargeableAPartirDeGooglePlay)
                        }
                    }
                    
                    // Features Section
                    termsSection(
                        icon: "star.fill",
                        title: AppStrings.serviceFeatures,
                        id: "features"
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            termsParagraph(AppStrings.lesFonctionnalitesDisponiblesAuNiveauDeLApplicationDiamacash)
                            
                            termsDefinitionItem(AppStrings.laSouscription, AppStrings.leClientPeutInitierDirectementSonInscriptionSurL)
                            termsDefinitionItem(AppStrings.laConnexion, AppStrings.leClientSeConnecteASonCompteDiamacashA)
                            termsDefinitionItem(AppStrings.laLiaisonDeSonCompteBancaire, AppStrings.leClientQuiAUnCompteBancaireOuvertDans)
                            termsDefinitionItem(AppStrings.leDeplafonnementDuWallet, AppStrings.parDefautLeCompteDiamacashDuClientEstLimite)
                            termsDefinitionItem(AppStrings.leChargementDuWalletCashIn, AppStrings.leDetenteurDuWalletPeutBeneficierDeDeuxCanaux)
                            termsDefinitionItem(AppStrings.retraitDArgentCashOut, AppStrings.leClientPeutSeRendreChezNImporteQuels)
                            termsDefinitionItem(AppStrings.transfertVersUnAutreCompteDiamacash, AppStrings.leClientPeutAToutMomentEffectuerDesTransferts)
                            termsDefinitionItem(AppStrings.transfertVersMaBanque, AppStrings.leClientPeutAToutMomentEffectuerDesTransferts2)
                            termsDefinitionItem(AppStrings.transfertDeMaBanque, AppStrings.leClientPeutAToutMomentEffectuerDesTransferts3)
                            termsDefinitionItem(AppStrings.moneyVoucher, AppStrings.leClientPeutAToutMomentEffectuerDesTransferts4)
                            termsDefinitionItem(AppStrings.sponsorship, AppStrings.leClientPeutAToutMomentEffectuerLeParrainage)
                            termsDefinitionItem(AppStrings.virementPermanent, AppStrings.leClientPeutAToutMomentInitierDesVirements)
                            termsDefinitionItem(AppStrings.paiementChezLeCommercant, AppStrings.leClientPeutPayerSesAchatsAPartirDe)
                        }
                    }
                    
                    // Article 1
                    termsArticle(number: 1, title: AppStrings.conditionsDInscriptionAuService, id: "article1") {
                        VStack(alignment: .leading, spacing: 12) {
                            termsParagraph(AppStrings.leServiceEstReserveALaClienteleDesParticuliers)
                            termsBulletPoint(AppStrings.dUnSmartphoneCompatibleAvecPlayStoreOuApple)
                            termsBulletPoint(AppStrings.dUnNumeroMobileGuineenEnLeurNom)
                            termsParagraph(AppStrings.lUtilisationDeDiamacashSeFaitEnGuineeComme)
                        }
                    }
                    
                    // Article 2
                    termsArticle(number: 2, title: AppStrings.accesAuService, id: "article2") {
                        VStack(alignment: .leading, spacing: 12) {
                            termsParagraph(AppStrings.lAccesAuServiceEstSubordonneAuRespectPar)
                            
                            Text(AppStrings.moyensTechniques)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.primary)
                                .padding(.top, 8)
                            
                            termsParagraph(AppStrings.lAccesAuServiceSeFaitViaLUtilisation)
                            termsBulletPoint(AppStrings.dUnSmartphoneDeSaMiseEnServiceEt)
                            termsBulletPoint(AppStrings.dUnAccesAInternetSurSonTerminalMobile)
                            termsBulletPoint(AppStrings.deLaCompatibiliteDuMaterielEtDesLogicielsDestines)
                        }
                    }
                    
                    // Article 3
                    termsArticle(number: 3, title: AppStrings.codesEtSecurite, id: "article3") {
                        VStack(alignment: .leading, spacing: 12) {
                            termsParagraph(AppStrings.leCodePersonnelDefiniLorsDeLInscriptionA)
                            termsParagraph(AppStrings.leClientEstEntierementResponsableDeLaConservationEt)
                            termsParagraph(AppStrings.ilAppartientNotammentAuClientDeSAssurerQue)
                            termsParagraph(AppStrings.pourDesRaisonsDeSecuriteLAccesAuService)
                            termsParagraph(AppStrings.laBanqueRecommandeDeModifierLeMotDePasse)
                        }
                    }
                    
                    // Article 4
                    termsArticle(number: 4, title: AppStrings.evolutionsDuService, id: "article4") {
                        VStack(alignment: .leading, spacing: 12) {
                            termsParagraph(AppStrings.enFonctionNotammentDesEvolutionsTechnologiquesLaBanqueApportera)
                        }
                    }
                    
                    // Article 5
                    termsArticle(number: 5, title: AppStrings.assistance, id: "article5") {
                        VStack(alignment: .leading, spacing: 12) {
                            termsParagraph(AppStrings.laBanqueMetADispositionDeLUtilisateurUn)
                        }
                    }
                    
                    // Article 6
                    termsArticle(number: 6, title: AppStrings.secretProfessionnel, id: "article6") {
                        VStack(alignment: .leading, spacing: 12) {
                            termsParagraph(AppStrings.laDiamaBankSaEstTenueAuSecretProfessionnel)
                        }
                    }
                    
                    // Article 7
                    termsArticle(number: 7, title: AppStrings.responsabilite, id: "article7") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(AppStrings.laBanque)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.blueH)
                            
                            termsParagraph(AppStrings.laDiamaBankSaSEngageAFournirLe)
                            termsParagraph(AppStrings.laBanqueDeclineTouteResponsabiliteEnCasDeDysfonctionnement)
                            termsParagraph(AppStrings.laBanqueNEstPasResponsableDesDysfonctionnementsImputables)
                            
                            Text(AppStrings.leClient)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.blueH)
                                .padding(.top, 8)
                            
                            termsParagraph(AppStrings.leClientDoitPrendreTouteMesurePourConserverA)
                            termsParagraph(AppStrings.leClientDoitUtiliserLeServiceConformementAuxFinalites)
                            termsParagraph(AppStrings.leClientSEngageAMettreAJourLes)
                            termsParagraph(AppStrings.leClientEstResponsableDesOperationsEffectueesViaSon)
                        }
                    }
                    
                    // Article 8
                    termsArticle(number: 8, title: AppStrings.interruptionDuService, id: "article8") {
                        VStack(alignment: .leading, spacing: 12) {
                            termsParagraph(AppStrings.laBanquePeutBloquerLAccesTotalAuxServices)
                            termsParagraph(AppStrings.leServicePourraEtrePonctuellementInterrompuPourDeCourtes)
                        }
                    }
                    
                    // Article 9
                    termsArticle(number: 9, title: AppStrings.oppositionOuBlocageParLeClient, id: "article9") {
                        VStack(alignment: .leading, spacing: 12) {
                            termsParagraph(AppStrings.enCasDeVolDeDetournementOuDeToute)
                            termsParagraph(AppStrings.dansTousLesCasLeClientDoitImmediatement)
                            termsBulletPoint(AppStrings.alerterLaBanque)
                            termsBulletPoint(AppStrings.ouAppelerLeCentreDeRelationsClientsCrcDe)
                        }
                    }
                    
                    // Article 10
                    termsArticle(number: 10, title: AppStrings.tarificationDuService, id: "article10") {
                        VStack(alignment: .leading, spacing: 12) {
                            termsParagraph(AppStrings.lesServicesCiApresSontOffertsGratuitementPourLe)
                            termsBulletPoint(AppStrings.laSouscriptionAuWalletDiamacash)
                            termsBulletPoint(AppStrings.leChargementDuWalletDiamacash)
                            termsBulletPoint(AppStrings.lePaiementChezLeCommercantOuAutresPrestataires)
                            termsBulletPoint(AppStrings.laDesinscription)
                            termsParagraph(AppStrings.leClientConserveASaChargeLesCoutsDe)
                        }
                    }
                    
                    // Article 11
                    termsArticle(number: 11, title: AppStrings.dureeDuContratResiliation, id: "article11") {
                        VStack(alignment: .leading, spacing: 12) {
                            termsParagraph(AppStrings.lePresentContratEstConcluPourUneDureeIndeterminee)
                            termsParagraph(AppStrings.ilPeutEtreResilieAToutMomentParLe)
                            termsParagraph(AppStrings.laResiliationParLeClientPrendEffetTrente30)
                            termsParagraph(AppStrings.laResiliationParLaBanquePrendEffetQuinzeJours)
                        }
                    }
                    
                    // Article 12
                    termsArticle(number: 12, title: AppStrings.modificationDuContrat, id: "article12") {
                        VStack(alignment: .leading, spacing: 12) {
                            termsParagraph(AppStrings.laBanqueSeReserveLeDroitDApporterDes)
                            termsParagraph(AppStrings.lAbsenceDeContestationNotifieeALaBanqueAvant)
                        }
                    }
                    
                    // Article 13
                    termsArticle(number: 13, title: AppStrings.arretDuService, id: "article13") {
                        VStack(alignment: .leading, spacing: 12) {
                            termsParagraph(AppStrings.enCasDArretDeLaFournitureDuService)
                        }
                    }
                    
                    // Article 14
                    termsArticle(number: 14, title: AppStrings.loiApplicableJuridictionLitiges, id: "article14") {
                        VStack(alignment: .leading, spacing: 12) {
                            termsParagraph(AppStrings.leContratEstRegiEtInterpreteSelonLeDroit)
                            termsParagraph(AppStrings.toutDifferendYRelatifQuantASonInterpretationOu)
                        }
                    }
                    
                    // Footer
                    VStack(spacing: 8) {
                        Text("2025")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("DIAMA BANK SA")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                .padding(.bottom, 20)
            }
            .frame(maxHeight: 350)
            
            // Acceptance checkboxes
            VStack(alignment: .leading, spacing: 16) {
                Button(action: {
                    registrationData.acceptTerms.toggle()
                }) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: registrationData.acceptTerms ? "checkmark.square.fill" : "square")
                            .font(.system(size: 22))
                            .foregroundColor(registrationData.acceptTerms ? .blueH : .gray)
                        
                        Text(AppStrings.buttonTitle(AppStrings.iHaveReadAndAcceptTheTermsAndConditions))
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                }
                
                Button(action: {
                    registrationData.acceptPrivacy.toggle()
                }) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: registrationData.acceptPrivacy ? "checkmark.square.fill" : "square")
                            .font(.system(size: 22))
                            .foregroundColor(registrationData.acceptPrivacy ? .blueH : .gray)
                        
                        Text(AppStrings.buttonTitle(AppStrings.iAgreeToTheProcessingOfMyPersonalDataUnder))
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                }
            }
            .padding(.top, 10)
            
            // Read all sections requirement
        }
        .padding(.horizontal, 16)
    }
    
    // Helper view for terms sections
    private func termsSection<Content: View>(
        icon: String,
        title: String,
        id: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        let isExpanded = expandedTermsSections.contains(id)
        
        return VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if isExpanded {
                        expandedTermsSections.remove(id)
                    } else {
                        expandedTermsSections.insert(id)
                    }
                }
            }) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.blueH)
                        .font(.system(size: 16))
                        .frame(width: 24)
                    
                    Text(AppStrings.buttonTitle(title))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "checkmark.circle.fill" : "chevron.right")
                        .foregroundColor(isExpanded ? .green : .blueH)
                        .font(.system(size: 14, weight: .semibold))
                        .rotationEffect(.degrees(isExpanded ? 0 : 0))
                }
                .padding(12)
                .background(Color.white)
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    content()
                }
                .padding(12)
                .background(Color.white)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // Helper view for terms articles
    private func termsArticle<Content: View>(
        number: Int,
        title: String,
        id: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        let isExpanded = expandedTermsSections.contains(id)
        
        return VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if isExpanded {
                        expandedTermsSections.remove(id)
                    } else {
                        expandedTermsSections.insert(id)
                    }
                }
            }) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.blueH.opacity(0.1))
                            .frame(width: 36, height: 36)
                        
                        Text(AppStrings.buttonTitle("\(number)"))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.blueH)
                    }
                    
                    Text(AppStrings.buttonTitle(title))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "checkmark.circle.fill" : "chevron.right")
                        .foregroundColor(isExpanded ? .green : .blueH)
                        .font(.system(size: 14, weight: .semibold))
                        .rotationEffect(.degrees(isExpanded ? 0 : 0))
                }
                .padding(12)
                .background(Color.white)
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    content()
                }
                .padding(12)
                .background(Color.white)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func termsParagraph(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundColor(.primary)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private func termsBulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 10))
                .foregroundColor(.green)
                .padding(.top, 3)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.primary)
        }
    }
    
    private func termsDefinitionItem(_ term: String, _ definition: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.blueH)
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(term)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                Text(definition)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Step 5: OTP Verification
    private var step5OtpVerificationView: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text(AppStrings.verifyYourPhoneNumber)
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(.gray)
            
            Text(AppStrings.enterTheVerificationCodeSentToValue(String(describing: maskedPhoneNumber)))
                .font(.system(size: 17))
                .foregroundColor(RegistrationTheme.ink)

            Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                .font(.system(size: 92, weight: .light))
                .foregroundColor(RegistrationTheme.navy)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(AppStrings.verificationCode)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.gray)
                WalletCodeField(AppStrings.enterTheVerificationCode, text: $registrationData.otpCode, isSecure: false, maxLength: 6, centered: true)
                    .keyboardType(.numberPad)
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.7), lineWidth: 1.5)))
            }
            .padding(20)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 22))
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                .onChange(of: registrationData.otpCode) {
                    registrationData.otpCode = String(registrationData.otpCode.filter(\.isNumber).prefix(6))
                    otpServerError = nil
                }
            inlineFieldError(otpServerError ?? (showOtpErrors && !registrationData.otpCode.isValidOTP ? AppStrings.enterThe6DigitVerificationCode : nil))
            
            Text(AppStrings.didnTReceiveTheCodePleaseContactSupport)
                .font(.system(size: 14))
                .foregroundColor(RegistrationTheme.teal)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }
    
    private var maskedPhoneNumber: String {
        let phone = registrationData.phoneNumber
        if phone.count > 4 {
            return phone.prefix(3) + "****" + phone.suffix(3)
        }
        return AppStrings.yourPhone
    }

    private func personalInfoError(_ key: String) -> String? {
        guard showPersonalInfoErrors else { return nil }
        return personalInfoErrors[key]
    }

    private var personalInfoErrors: [String: String] {
        var errors: [String: String] = [:]
        if registrationData.firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors["firstName"] = AppStrings.enterYourFirstName }
        if registrationData.lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors["lastName"] = AppStrings.enterYourLastName }
        if normalizedGambianPhone(registrationData.phoneNumber) == nil { errors["phone"] = AppStrings.enterExactly10DigitsIncludingTheCountryCode }
        if registrationData.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors["email"] = AppStrings.enterYourEmailAddress }
        else if !isValidEmail(registrationData.email) { errors["email"] = "Enter a valid email address, for example name@example.com." }
        if registrationData.dateOfBirth.isEmpty { errors["birthDate"] = AppStrings.selectYourDateOfBirth }
        if registrationData.gender.isEmpty { errors["gender"] = AppStrings.selectMaleOrFemale }
        if registrationData.nationality.isEmpty { errors["nationality"] = AppStrings.chooseYourNationality }
        if registrationData.documentId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors["documentId"] = AppStrings.enterTheNumberShownOnYourId }
        if registrationData.branchCode.isEmpty { errors["branchCode"] = AppStrings.chooseABranch2 }
        if registrationData.address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors["address"] = AppStrings.enterYourResidentialAddress }
        if registrationData.secretQ.isEmpty { errors["secretQ"] = AppStrings.selectASecurityQuestion }
        if registrationData.answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors["answer"] = AppStrings.enterAnAnswerToYourSecurityQuestion }
        if registrationData.nkinName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors["nkinName"] = AppStrings.enterYourNextOfKinSName }
        if normalizedGambianPhone(registrationData.nkinPhone) == nil { errors["nkinPhone"] = AppStrings.enterExactly10DigitsIncludingTheCountryCode }
        if APIClient.getDeviceId().trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors["deviceId"] = AppStrings.couldNotIdentifyThisDevicePleaseRestartTheAppAnd }
        return errors
    }

    private var pinError: String? {
        if !registrationData.pin.isValidWalletPIN { return AppStrings.yourPinMustContainExactly4Digits }
        if isWeakPin(registrationData.pin) { return AppStrings.chooseALessPredictablePinSuchAsOneWithoutRepeated }
        return nil
    }

    private var confirmPinError: String? {
        guard !registrationData.confirmPin.isEmpty else { return AppStrings.confirmYour4DigitPin }
        return registrationData.pin == registrationData.confirmPin ? nil : AppStrings.thePinsDoNotMatch
    }

    @ViewBuilder
    private func inlineFieldError(_ message: String?) -> some View {
        if let message {
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 13))
                Text(message)
                    .font(.system(size: 13))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .foregroundColor(.red)
            .padding(.horizontal, 4)
            .accessibilityLabel(message)
        }
    }
    
    // MARK: - Step 6: Success
    private var step6SuccessView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.green)
            
            Text(AppStrings.felicitations)
                .font(.system(size: 22, weight: .bold))
            
            Text("\(registrationData.firstName) \(registrationData.lastName)")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.green)
            
            Text(AppStrings.votreCompteAEteCreeAvecSucces)
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 80)
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtonsView: some View {
        VStack(spacing: 15) {
            if currentStep <= totalSteps {
                let canAttemptCurrentStep = [1, 2, 5].contains(currentStep) || canProceedToNextStep()
                Button(action: nextStep) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                Text(AppStrings.buttonTitle(isLoading ? AppStrings.loading2 : (currentStep == 4 ? AppStrings.accept2 : (currentStep == 5 ? AppStrings.verify2 : AppStrings.next))))
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(canAttemptCurrentStep && !isLoading ? RegistrationTheme.teal : Color.gray)
                    .cornerRadius(16)
                }
                .disabled(isLoading || !canAttemptCurrentStep)
            } else {
                Button(AppStrings.buttonTitle(AppStrings.goToLogin)) {
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(RegistrationTheme.navy)
                .foregroundColor(.white)
                .fontWeight(.semibold)
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
    
    // MARK: - API Calls
    private func fetchNationalities() {
        isLoadingNationalities = true
        
        APIClient.shared.getNationalities { result in
            DispatchQueue.main.async {
                self.isLoadingNationalities = false
                
                switch result {
                case .success(let nationalitiesList):
                    self.nationalities = nationalitiesList
                    //print("✅ Loaded \(nationalitiesList.count) nationalities")
                    
                case .failure(let error):
                    //print("❌ Failed to load nationalities: \(error)")
                    // Load fallback nationalities
                    self.loadFallbackNationalities()
                }
            }
        }
    }

    private func fetchRegistrationBranches() {
        APIClient.shared.getAllBranches(bankCode: "00100") { result in
            switch result {
            case .success(let values):
                self.branches = values.filter { !($0.id ?? "").isEmpty }
            case .failure:
                self.branches = []
            }
        }
    }
    
    private func fetchSecretQuestions() {
        isLoadingSecretQuestions = true
        
        APIClient.shared.listSecretQuestions { result in
            DispatchQueue.main.async {
                self.isLoadingSecretQuestions = false
                
                switch result {
                case .success(let response):
                    if response.respCode == "000", let resultList = response.result {
                        self.extractSecretQuestions(from: resultList)
                        //print("✅ Loaded \(self.secretQuestions.count) secret questions")
                    } else {
                        //print("❌ API returned error: \(response.message ?? "Unknown")")
                        self.loadFallbackSecretQuestions()
                    }
                    
                case .failure(let error):
                    //print("❌ Failed to load secret questions: \(error)")
                    self.loadFallbackSecretQuestions()
                }
            }
        }
    }
    
    private func extractSecretQuestions(from resultList: [Any]) {
        var questions: [SecretQuestion] = []
        
        for item in resultList {
            guard let dict = item as? [String: Any] else { continue }
            
            if let questionId = dict["id"] as? String ?? dict["questionId"] as? String,
               let questionText = dict["wording"] as? String ?? dict["question"] as? String,
               !questionText.isEmpty {
                questions.append(SecretQuestion(id: questionId, question: questionText))
            }
        }
        
        self.secretQuestions = questions
    }
    
    private func loadFallbackNationalities() {
        nationalities = [
            Nationality(code: "GH", wording: AppStrings.original("ghanaian")),
            Nationality(code: "NG", wording: AppStrings.original("nigerian")),
            Nationality(code: "CI", wording: AppStrings.original("ivorian")),
            Nationality(code: "SN", wording: AppStrings.original("senegalese")),
            Nationality(code: "ML", wording: AppStrings.original("malian")),
            Nationality(code: "BF", wording: AppStrings.original("burkinabe")),
            Nationality(code: "TG", wording: AppStrings.original("togolese")),
            Nationality(code: "BJ", wording: AppStrings.original("beninese")),
            Nationality(code: "GN", wording: AppStrings.original("guinean")),
            Nationality(code: "LR", wording: AppStrings.original("liberian")),
            Nationality(code: "SL", wording: AppStrings.sierraLeonean),
            Nationality(code: "GM", wording: AppStrings.original("gambian")),
            Nationality(code: "OT", wording: AppStrings.other)
        ]
    }
    
    private func loadFallbackSecretQuestions() {
        secretQuestions = [
            SecretQuestion(id: "01", question: AppStrings.quelEstLeNomDeVotreAnimalDeCompagnie),
            SecretQuestion(id: "02", question: AppStrings.dansQuelleVilleEtesVousNeE),
            SecretQuestion(id: "03", question: AppStrings.quelEstLeNomDeJeuneFilleDeVotreMere),
            SecretQuestion(id: "04", question: AppStrings.quelEtaitLeNomDeVotrePremiereEcole),
            SecretQuestion(id: "05", question: AppStrings.quelEstVotreLivrePrefere)
        ]
    }
    
    // MARK: - nextStep
    private func nextStep() {
        switch currentStep {
        case 1:
            if validatePersonalInfo() {
                withAnimation { currentStep += 1 }
            }
            
        case 2:
            showPinErrors = true
            if !registrationData.pin.isValidWalletPIN {
                return
            } else if isWeakPin(registrationData.pin) {
                return
            } else if registrationData.pin != registrationData.confirmPin {
                return
            } else {
                withAnimation { currentStep += 1 }
            }
            
        case 3:
            if registrationData.selfieBase64.isEmpty || registrationData.idFrontBase64.isEmpty || registrationData.idBackBase64.isEmpty {
                alertMessage = AppStrings.veuillezCapturerTousLesDocumentsRequis
                showAlert = true
                return
            }
            
            // Move to Terms and Conditions step
            withAnimation { currentStep += 1 }

        case 4:
         
            if !registrationData.acceptTerms || !registrationData.acceptPrivacy {
                alertMessage = AppStrings.veuillezAccepterLesConditionsPourContinuer
                showAlert = true
                return
            }
            
            // Now submit registration
            isLoading = true
            submitRegistration()

        case 5:
            if registrationData.otpCode.isValidOTP {
                isLoading = true
                verifyOtpCode()
            } else {
                showOtpErrors = true
            }
            
        default:
            break
        }
    }
    
    // MARK: - PIN Security
    /// Rejects trivial PINs: repeated digits (0000, 1111), sequences (1234, 4321), and common weak codes.
    private func isWeakPin(_ pin: String) -> Bool {
        guard pin.isValidWalletPIN else { return false }
        
        let weakPins: Set<String> = [
            "0000", "1111", "2222", "3333", "4444",
            "5555", "6666", "7777", "8888", "9999",
            "0123", "1234", "2345", "3456", "4567", "5678", "6789",
            "9876", "8765", "7654", "6543", "5432", "4321", "3210",
            "1122", "1212", "1000", "2000", "2580"
        ]
        
        if weakPins.contains(pin) { return true }
        
        // All identical digits
        if Set(pin).count == 1 { return true }
        
        // Strictly ascending or descending by 1
        let digits = pin.compactMap { Int(String($0)) }
        let isAscending = zip(digits, digits.dropFirst()).allSatisfy { $1 == $0 + 1 }
        let isDescending = zip(digits, digits.dropFirst()).allSatisfy { $1 == $0 - 1 }
        return isAscending || isDescending
    }
    
    // MARK: - Validation
    private func validatePersonalInfo() -> Bool {
        showPersonalInfoErrors = true
        return personalInfoErrors.isEmpty
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Image Selection
    private func showSourceSelection() {
        #if targetEnvironment(simulator)
        imagePickerSourceType = .photoLibrary
        showImagePicker = true
        #else
        showingActionSheet = true
        #endif
    }

    private func handleImageSelection(_ image: UIImage) {
        guard let base64String = image.toBase64() else {
            alertMessage = AppStrings.erreurLorsDeLaConversionDeLImage
            showAlert = true
            return
        }
        
        switch pickerType {
        case "selfie":
            registrationData.selfieBase64 = base64String
        case "idFront":
            registrationData.idFrontBase64 = base64String
        case "idBack":
            registrationData.idBackBase64 = base64String
        default:
            break
        }
    }
    
    // MARK: - API Submission
    private func submitRegistration() {
        guard personalInfoErrors.isEmpty else {
            isLoading = false
            showPersonalInfoErrors = true
            currentStep = 1
            return
        }
        let request = CustomerRegistrationRequest(
            firstName: registrationData.firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: registrationData.lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            phone: normalizedGambianPhone(registrationData.phoneNumber) ?? "",
            email: registrationData.email.trimmingCharacters(in: .whitespacesAndNewlines),
            birthDate: registrationData.dateOfBirth,
            nationality: registrationData.nationality,
            documentCode: registrationData.documentCode,
            documentId: registrationData.documentId.trimmingCharacters(in: .whitespacesAndNewlines),
            gender: registrationData.gender,
            currencyCode: "270",
            bank: "00100",
            branchCode: registrationData.branchCode,
            secretQ: registrationData.secretQ,
            answer: registrationData.answer.trimmingCharacters(in: .whitespacesAndNewlines),
            address: registrationData.address.trimmingCharacters(in: .whitespacesAndNewlines),
            type: "P",
            productCode: "001",
            pin: registrationData.pin,
            nkinName: registrationData.nkinName.trimmingCharacters(in: .whitespacesAndNewlines),
            nkinPhone: normalizedGambianPhone(registrationData.nkinPhone) ?? "",
            srcFunds: nil,
            occupation: nil,
            estimatedIncome: nil,
            referralCode: registrationData.referralCode,
            deviceId: APIClient.getDeviceId(),
            faceId: registrationData.selfieBase64,
            documentImg: registrationData.idFrontBase64,
            documentImgBack: registrationData.idBackBase64
        )
        
        APIClient.shared.registerCustomer(request: request) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        guard let authCode = response.authCode, !authCode.isEmpty else {
                            self.alertMessage = AppStrings.registrationSucceededButNoVerificationCodeWasReturnedPleaseContact
                            self.showAlert = true
                            return
                        }
                        self.registrationData.authCode = authCode
                        withAnimation { self.currentStep += 1 }
                    } else {
                        if response.respCode == "018" {
                            self.alertMessage = AppStrings.registrationFailedInvalidData
                        } else if response.respCode == "017" {
                            self.alertMessage = AppStrings.sessionExpiredPleaseRestartRegistration
                        } else {
                            self.alertMessage = response.message ?? AppStrings.registrationFailed
                        }
                        self.showAlert = true
                    }
                case .failure(let error):
                    self.alertMessage = (error as? APIError)?.message ?? AppStrings.networkErrorValue(String(describing: error.localizedDescription))
                    self.showAlert = true
                }
            }
        }
    }

    private func verifyOtpCode() {
        let request = OtpRequest(
            phoneNumber: normalizedGambianPhone(registrationData.phoneNumber) ?? registrationData.phoneNumber,
            authCode: registrationData.authCode,
            otp: registrationData.otpCode,
            entityId: nil
        )
        
        APIClient.shared.verifyOtp(request: request) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    if response.respCode == "000" {
                        withAnimation { self.currentStep += 1 }
                    } else {
                        if response.respCode == "018" {
                            self.alertMessage = AppStrings.incorrectOtpPleaseTryAgain
                        } else if response.respCode == "017" {
                            self.alertMessage = AppStrings.sessionExpiredPleaseRestartRegistration
                        } else {
                            self.alertMessage = response.message ?? AppStrings.otpVerificationFailed
                        }
                        self.otpServerError = self.alertMessage
                        self.showOtpErrors = true
                    }
                case .failure(let error):
                    self.alertMessage = (error as? APIError)?.message ?? AppStrings.networkErrorValue(String(describing: error.localizedDescription))
                    self.showAlert = true
                }
            }
        }
    }

    private func normalizedGambianPhone(_ rawPhone: String) -> String? {
        let digits = rawPhone.filter(\.isNumber)
        return digits.count == 10 ? digits : nil
    }
    
    private func canProceedToNextStep() -> Bool {
        switch currentStep {
        case 1:
            return !registrationData.firstName.isEmpty &&
                   !registrationData.lastName.isEmpty &&
                   !registrationData.phoneNumber.isEmpty &&
                   !registrationData.dateOfBirth.isEmpty &&
                   !registrationData.gender.isEmpty &&
                   !registrationData.nationality.isEmpty &&
                   !registrationData.documentId.isEmpty &&
                   !registrationData.branchCode.isEmpty &&
                   !registrationData.address.isEmpty &&
                   !registrationData.secretQ.isEmpty &&
                   !registrationData.answer.isEmpty
        case 2:
            return registrationData.pin.isValidWalletPIN &&
                   registrationData.confirmPin.isValidWalletPIN &&
                   registrationData.pin == registrationData.confirmPin &&
                   !isWeakPin(registrationData.pin)
        case 3:
            return !registrationData.selfieBase64.isEmpty &&
                   !registrationData.idFrontBase64.isEmpty &&
                   !registrationData.idBackBase64.isEmpty
        case 4:
            // Terms acceptance: must read all sections and check both boxes
            return 
                   registrationData.acceptTerms &&
                   registrationData.acceptPrivacy
        case 5:
            return registrationData.otpCode.isValidOTP
        default:
            return true
        }
    }
}


struct EmptyRequest: Codable {}

// MARK: - Searchable Nationality Picker
struct SearchableNationalityPicker: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let nationalities: [Nationality]
    let isLoading: Bool
    @Binding var selectedNationality: String
    let onSelect: (Nationality) -> Void
    
    @State private var searchText = ""
    @State private var showSheet = false
    
    var filteredNationalities: [Nationality] {
        if searchText.isEmpty {
            return nationalities
        } else {
            return nationalities.filter { nationality in
                nationality.wording.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(AppStrings.nationality)
                    .font(.system(size: 16, weight: .medium))
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }
            
            Button(action: {
                showSheet = true
            }) {
                HStack {
                    Image(systemName: "flag.fill")
                    .foregroundColor(RegistrationTheme.teal)
                        .frame(width: 20)
                    
                    Text(AppStrings.buttonTitle(selectedNationality.isEmpty ? AppStrings.chooseANationality : AppStrings.option(selectedNationality)))
                        .foregroundColor(selectedNationality.isEmpty ? .gray : .primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .background(RoundedRectangle(cornerRadius: 18).fill(RegistrationTheme.canvas)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.gray.opacity(0.7), lineWidth: 1.5)))
            }
            .disabled(isLoading || nationalities.isEmpty)
        }
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField(AppStrings.rechercherUneNationalite, text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding()
                    
                    // Results List
                    if filteredNationalities.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            
                            Text(AppStrings.aucuneNationaliteTrouvee)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(filteredNationalities, id: \.code) { nationality in
                                Button(action: {
                                    onSelect(nationality)
                                    searchText = ""
                                    showSheet = false
                                }) {
                                    HStack {
                                        Text(AppStrings.buttonTitle(AppStrings.option(nationality.wording)))
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        if selectedNationality == nationality.wording {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blueH)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .navigationTitle(AppStrings.chooseANationality)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(AppStrings.buttonTitle(AppStrings.done)) {
                            searchText = ""
                            showSheet = false
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Enhanced UI Components
struct CustomTextField: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let title: String
    @Binding var text: String
    var icon: String? = nil
    var keyboardType: UIKeyboardType = .default
    var error: String? = nil
    var digitLimit: Int? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(RegistrationTheme.teal)
                        .frame(width: 20)
                }
                TextField(title.replacingOccurrences(of: "*", with: ""), text: Binding(
                    get: { text },
                    set: { newValue in
                        guard let digitLimit else {
                            text = newValue
                            return
                        }
                        text = String(newValue.filter(\.isNumber).prefix(digitLimit))
                    }
                ))
                    .keyboardType(keyboardType)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 19)
            .background(RoundedRectangle(cornerRadius: 18).fill(RegistrationTheme.canvas)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.gray.opacity(0.7), lineWidth: 1.5)))
            .overlay(alignment: .topLeading) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(RegistrationTheme.ink)
                    .padding(.horizontal, 7)
                    .background(RegistrationTheme.canvas)
                    .offset(x: 14, y: -9)
            }
            inlineFieldError(error)
        }
    }

    @ViewBuilder
    private func inlineFieldError(_ message: String?) -> some View {
        if let message {
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 13))
                Text(message)
                    .font(.system(size: 13))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .foregroundColor(.red)
            .padding(.horizontal, 4)
            .accessibilityLabel(message)
        }
    }
}

struct GenderButton: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(AppStrings.buttonTitle(title))
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? RegistrationTheme.teal : Color.clear)
                        .stroke(RegistrationTheme.teal, lineWidth: 1)
                )
                .foregroundColor(isSelected ? .white : RegistrationTheme.teal)
        }
    }
}

// MARK: - Enhanced RegistrationData
class RegistrationData: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var dateOfBirth = ""
    @Published var birthDate: Date?
    @Published var gender = ""
    @Published var phoneNumber = ""
    @Published var email = ""
    @Published var address = ""
    @Published var nationality = ""
    @Published var nationalityDisplay = ""
    @Published var branchCode = ""
    @Published var branchDisplay = ""
    @Published var documentId = ""
    @Published var documentCode = "NI"
    @Published var referralCode = ""
    @Published var pin = ""
    @Published var confirmPin = ""
    
    @Published var secretQ = ""
    @Published var secretQDisplay = ""
    @Published var answer = ""
    @Published var nkinName = ""
    @Published var nkinPhone = ""
    
    @Published var selfieBase64 = ""
    @Published var idFrontBase64 = ""
    @Published var idBackBase64 = ""
    
    @Published var authCode = ""
    @Published var otpCode = ""
    
    @Published var acceptTerms = false
    @Published var acceptPrivacy = false
}

// MARK: - Section Header Helper Function
private func sectionHeader(_ title: String) -> some View {
    HStack {
        Rectangle()
            .fill(RegistrationTheme.teal)
            .frame(width: 6, height: 32)
            .cornerRadius(3)
        
        Text(title)
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(RegistrationTheme.teal)
        
        Spacer()
    }
}

// MARK: - Enhanced Identification Card Component
@ViewBuilder
private func identificationCard(
    title: String,
    description: String,
    buttonText: String,
    systemIcon: String,
    isCompleted: Bool = false,
    isEnabled: Bool = true,
    action: @escaping () -> Void
) -> some View {
    VStack(alignment: .leading, spacing: 12) {
        HStack {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isCompleted ? .green : .gray)
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isEnabled ? .primary : .gray)
        }
        
        Text(description)
            .font(.system(size: 14))
            .foregroundColor(.secondary)
        
        Button(action: action) {
            HStack {
                Image(systemName: systemIcon)
                Text(AppStrings.buttonTitle(buttonText))
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                isEnabled ? RegistrationTheme.teal : Color.gray
            )
            .cornerRadius(14)
        }
        .disabled(!isEnabled)
    }
    .padding()
    .background(RoundedRectangle(cornerRadius: 22).fill(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(isCompleted ? RegistrationTheme.teal.opacity(0.45) : Color.gray.opacity(0.15), lineWidth: 1)))
    .shadow(color: Color.black.opacity(0.12), radius: 5, x: 0, y: 3)
}

extension UIImage {
    func toBase64() -> String? {
        // Resize to max 1024px to reduce size
        let resized = self.resized(toMax: 1024)
        
        // Use 0.5 compression for balance between quality and size
        guard let imageData = resized.jpegData(compressionQuality: 0.5) else {
            return nil
        }
        
        return imageData.base64EncodedString()
    }
    
    func resized(toMax maxDimension: CGFloat) -> UIImage {
        let ratio = min(maxDimension / size.width, maxDimension / size.height)
        if ratio >= 1 { return self }
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

// MARK: - Enhanced ImagePicker
struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            picker.sourceType = sourceType
        } else {
            picker.sourceType = .photoLibrary
        }
        
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
    
}
#Preview {
    RegistrationFlowView()
        .environmentObject(AuthenticationManager())
}
