import SwiftUI

struct TermsAndConditionsView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var expandedSections: Set<String> = []
    @State private var showOriginal = false
    var registrationAcceptance: Binding<Bool>? = nil
    var onAccept: (() -> Void)? = nil
    var onRefuse: (() -> Void)? = nil

    private func termsText(_ key: String) -> String {
        guard showOriginal, let entry = AppStrings.catalog[key] else { return AppStrings.value(key) }
        return entry.french ?? entry.source
    }

    private var isRegistrationMode: Bool {
        if case .some = registrationAcceptance { return true }
        return false
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                if !isRegistrationMode {
                    ZStack {
                        Color(hex: "174EA6")
                        HStack(spacing: 14) {
                            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 21, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 42, height: 48, alignment: .leading)
                            }
                            Spacer(minLength: 0)
                            Text(termsText("conditionsGenerales"))
                                .font(.system(size: 19, weight: .medium))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Spacer(minLength: 0)
                            Color.clear.frame(width: 42, height: 48)
                        }
                        .padding(.horizontal, 22)
                    }
                    .frame(height: 58)
                    .background(Color(hex: "174EA6").ignoresSafeArea(edges: .top))
                }

                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(isRegistrationMode ? termsText("terms") : termsText("conditionsGeneralesDUtilisation"))
                        .font(.system(size: isRegistrationMode ? 22 : 20, weight: .bold))
                        .foregroundColor(Color(hex: "263445"))
                    
                    Text(isRegistrationMode ? "GambiaPay - Moneya" : "GambiaPay - DIAMA BANK SA")
                        .font(.system(size: isRegistrationMode ? 14 : 13, weight: .semibold))
                        .foregroundColor(Color(hex: "0788B9"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, isRegistrationMode ? 20 : 14)
                .padding(.bottom, isRegistrationMode ? 12 : 14)
                .background(Color.white)
                .overlay(alignment: .bottom) {
                    Rectangle().fill(Color.orange.opacity(0.25)).frame(height: 2)
                }
                
                if localization.language.baseCode != "fr" {
                    VStack(alignment: .leading, spacing: 8) {
                        if !showOriginal {
                            Text(AppStrings.automaticTermsNotice).font(.caption).foregroundStyle(.secondary)
                        }
                        Button(AppStrings.buttonTitle(showOriginal ? AppStrings.showTranslatedTerms : AppStrings.showOriginalTerms)) {
                            showOriginal.toggle()
                        }
                        .font(.footnote)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                }

                // Modern Terms Content ScrollView
                ScrollView {
                    LazyVStack(spacing: 10) {
                        // Definitions Section
                        modernSection(
                            icon: "book.fill",
                            title: termsText("definitions"),
                            id: "definitions"
                        ) {
                            definitionsContent
                        }
                        
                        // Object Section
                        modernSection(
                            icon: "target",
                            title: termsText("objet"),
                            id: "object"
                        ) {
                            objectContent
                        }
                        
                        // Features Section
                        modernSection(
                            icon: "star.fill",
                            title: termsText("fonctionnalitesDuService"),
                            id: "features"
                        ) {
                            featuresContent
                        }
                        
                        // Articles
                        ForEach(articles, id: \.number) { article in
                            modernArticle(article: article)
                        }
                        
                        // Footer
                        footerView
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                }
                if let registrationAcceptance {
                    VStack(spacing: 14) {
                        Button {
                            registrationAcceptance.wrappedValue.toggle()
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: registrationAcceptance.wrappedValue ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 22))
                                    .foregroundColor(registrationAcceptance.wrappedValue ? Color(hex: "0788B9") : .gray)
                                Text(termsText("iHaveReadAndAcceptTheTermsAndConditions"))
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                Spacer(minLength: 0)
                            }
                        }
                        .buttonStyle(.plain)

                        HStack(spacing: 14) {
                            Button(AppStrings.buttonTitle(termsText("refuse")), action: { onRefuse?() })
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .foregroundColor(Color(hex: "0788B9"))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "0788B9"), lineWidth: 2))
                            Button(AppStrings.buttonTitle(termsText("accept")), action: { onAccept?() })
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .foregroundColor(.white)
                                .background(Color(hex: "174EA6"), in: RoundedRectangle(cornerRadius: 12))
                                .disabled(!registrationAcceptance.wrappedValue)
                                .opacity(registrationAcceptance.wrappedValue ? 1 : 0.55)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !isRegistrationMode {
                AppBottomBar(onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {})
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Modern Section
    private func modernSection<Content: View>(
        icon: String,
        title: String,
        id: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let isExpanded = expandedSections.contains(id)
        
        return VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if isExpanded {
                        expandedSections.remove(id)
                    } else {
                        expandedSections.insert(id)
                    }
                }
            }) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(Color(hex: "174EA6"))
                        .font(.system(size: isRegistrationMode ? 19 : 17, weight: .semibold))
                        .frame(width: isRegistrationMode ? 36 : 34, height: isRegistrationMode ? 36 : 34)
                    
                    Text(AppStrings.buttonTitle(title))
                        .font(.system(size: isRegistrationMode ? 15 : 15, weight: .semibold))
                        .foregroundColor(Color(hex: "263445"))

                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(hex: "174EA6"))
                        .font(.system(size: isRegistrationMode ? 15 : 14, weight: .semibold))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.horizontal, isRegistrationMode ? 14 : 14)
                .padding(.vertical, isRegistrationMode ? 12 : 12)
                .background(Color.white)
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: isRegistrationMode ? 8 : 12) {
                    content()
                }
                .padding(isRegistrationMode ? 14 : 20)
                .background(Color.white)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.white)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.06), lineWidth: 1))
        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
    }
    
    // MARK: - Definitions Content
    private var definitionsContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            modernParagraph(termsText("pourLesBesoinsDuPresentContratIlConvientD"))
            
            modernDefinitionItem(termsText("banque"), termsText("laDiamaBankSa"))
            modernDefinitionItem(termsText("contrat"), termsText("designeLePresentContratDAdhesionAuServiceDiamacash"))
            modernDefinitionItem(termsText("applicationMobile"), termsText("uneApplicationMobileEstUnLogicielApplicatifDeveloppePour"))
            modernDefinitionItem(termsText("wallet"), termsText("constitueUnMoyenDePaiementPermettantASonDetenteur"))
            modernDefinitionItem(termsText("etablissement"), termsText("designeToutEtablissementBancaireOuLesEtablissementsDePaiement"))
            modernDefinitionItem(termsText("cashIn"), termsText("ilSAgitDUneOperationDeDepotD"))
            modernDefinitionItem(termsText("cashOut"), termsText("ilSAgitDUneOperationDeRetraitD"))
            modernDefinitionItem(termsText("compteDeRattachement"), termsText("designeLeCompteOuvertDansLesLivresDeLa"))
            modernDefinitionItem(termsText("detenteurDuWallet"), termsText("peutEtreLeTitulaireDuCompteOuTouteAutre"))
            modernDefinitionItem(AppStrings.brand, termsText("designeLApplicationDePaiementMobilePourLesClients"))
            modernDefinitionItem(termsText("dabGab"), termsText("appareilsDeDistributionAutomatiqueDeBilletsDeBanque"))
            modernDefinitionItem(termsText("tpe"), termsText("terminalDePaiementElectronique"))
        }
    }
    
    // MARK: - Object Content
    private var objectContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            modernParagraph(termsText("leWalletDiamacashEstUnMoyenDePaiementElectronique"))
            modernParagraph(termsText("cetteApplicationEstTelechargeableAPartirDeGooglePlay"))
        }
    }
    
    // MARK: - Features Content
    private var featuresContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            modernParagraph(termsText("lesFonctionnalitesDisponiblesAuNiveauDeLApplicationDiamacash"))
            
            modernDefinitionItem(termsText("laSouscription"), termsText("leClientPeutInitierDirectementSonInscriptionSurL"))
            
            modernDefinitionItem(termsText("laConnexion"), termsText("leClientSeConnecteASonCompteDiamacashA"))
            
            modernDefinitionItem(termsText("laLiaisonDeSonCompteBancaire"), termsText("leClientQuiAUnCompteBancaireOuvertDans"))
            
            modernDefinitionItem(termsText("leDeplafonnementDuWallet"), termsText("parDefautLeCompteDiamacashDuClientEstLimite"))
            
            modernDefinitionItem(termsText("leChargementDuWalletCashIn"), termsText("leDetenteurDuWalletPeutBeneficierDeDeuxCanaux"))
            
            modernDefinitionItem(termsText("retraitDArgentCashOut"), termsText("leClientPeutSeRendreChezNImporteQuels"))
            
            modernDefinitionItem(termsText("transfertVersUnAutreCompteDiamacash"), termsText("leClientPeutAToutMomentEffectuerDesTransferts"))
            
            modernDefinitionItem(termsText("transfertVersMaBanque"), termsText("leClientPeutAToutMomentEffectuerDesTransferts2"))
            
            modernDefinitionItem(termsText("transfertDeMaBanque"), termsText("leClientPeutAToutMomentEffectuerDesTransferts3"))
            
            modernDefinitionItem(termsText("moneyVoucher"), termsText("leClientPeutAToutMomentEffectuerDesTransferts4"))
            
            modernDefinitionItem(termsText("sponsorship"), termsText("leClientPeutAToutMomentEffectuerLeParrainage"))
            
            modernDefinitionItem(termsText("virementPermanent"), termsText("leClientPeutAToutMomentInitierDesVirements"))
            
            modernDefinitionItem(termsText("paiementChezLeCommercant"), termsText("leClientPeutPayerSesAchatsAPartirDe"))
        }
    }
    
    // MARK: - Modern Article
    private func modernArticle(article: Article) -> some View {
        let isExpanded = expandedSections.contains(article.id)
        
        return VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if isExpanded {
                        expandedSections.remove(article.id)
                    } else {
                        expandedSections.insert(article.id)
                    }
                }
            }) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "F1F8F2"))
                            .frame(width: isRegistrationMode ? 40 : 34, height: isRegistrationMode ? 40 : 34)
                        
                        Text(AppStrings.buttonTitle("\(article.number)"))
                            .font(.system(size: isRegistrationMode ? 15 : 14, weight: .bold))
                            .foregroundColor(Color(hex: "174EA6"))
                    }
                    
                    Text(article.title)
                        .font(.system(size: isRegistrationMode ? 15 : 15, weight: .semibold))
                        .foregroundColor(Color(hex: "263445"))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(hex: "174EA6"))
                        .font(.system(size: isRegistrationMode ? 15 : 14, weight: .semibold))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white)
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: isRegistrationMode ? 8 : 12) {
                    article.content()
                }
                .padding(isRegistrationMode ? 14 : 14)
                .background(Color.white)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.white)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.06), lineWidth: 1))
        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
    }
    
    // MARK: - Helper Views
    private func modernParagraph(_ text: String) -> some View {
        Text(text)
            .font(.system(size: isRegistrationMode ? 12 : 13))
            .foregroundColor(Color(hex: "344054"))
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private func modernDefinitionItem(_ title: String, _ definition: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.blueH)
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: isRegistrationMode ? 12 : 13, weight: .semibold))
                    .foregroundColor(Color(hex: "263445"))
                
                Text(definition)
                    .font(.system(size: isRegistrationMode ? 11 : 12))
                    .foregroundColor(Color(hex: "475467"))
            }
        }
    }
    
    private func modernBulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: isRegistrationMode ? 11 : 12))
                .foregroundColor(.green)
                .padding(.top, 3)
            
            Text(text)
                .font(.system(size: isRegistrationMode ? 12 : 13))
                .foregroundColor(Color(hex: "344054"))
        }
    }
    
    private var footerView: some View {
        VStack(spacing: 6) {
            
            Text(String(Calendar(identifier: .gregorian).component(.year, from: Date())))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
            
            Text("DIAMA BANK SA")
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.orange.opacity(0.25)).frame(height: 2)
        }
    }
    
    // MARK: - Articles Data
    private var articles: [Article] {
        [
            Article(number: 1, title: termsText("conditionsDInscriptionAuService"), id: "article1") {
                VStack(alignment: .leading, spacing: 12) {
                    modernParagraph(termsText("leServiceEstReserveALaClienteleDesParticuliers"))
                    modernBulletPoint(termsText("dUnSmartphoneCompatibleAvecPlayStoreOuApple"))
                    modernBulletPoint(termsText("dUnNumeroMobileGuineenEnLeurNom"))
                    modernParagraph(termsText("lUtilisationDeDiamacashSeFaitEnGuineeComme"))
                }
            },
            Article(number: 2, title: termsText("accesAuService"), id: "article2") {
                VStack(alignment: .leading, spacing: 12) {
                    modernParagraph(termsText("lAccesAuServiceEstSubordonneAuRespectPar"))
                    
                    Text(termsText("moyensTechniques"))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(UIColor.darkGray))
                        .padding(.top, 8)
                    
                    modernParagraph(termsText("lAccesAuServiceSeFaitViaLUtilisation"))
                    modernBulletPoint(termsText("dUnSmartphoneDeSaMiseEnServiceEt"))
                    modernBulletPoint(termsText("dUnAccesAInternetSurSonTerminalMobile"))
                    modernBulletPoint(termsText("deLaCompatibiliteDuMaterielEtDesLogicielsDestines"))
                }
            },
            Article(number: 3, title: termsText("codesEtSecurite"), id: "article3") {
                VStack(alignment: .leading, spacing: 12) {
                    modernParagraph(termsText("leCodePersonnelDefiniLorsDeLInscriptionA"))
                    modernParagraph(termsText("leClientEstEntierementResponsableDeLaConservationEt"))
                    modernParagraph(termsText("ilAppartientNotammentAuClientDeSAssurerQue"))
                    modernParagraph(termsText("pourDesRaisonsDeSecuriteLAccesAuService"))
                    modernParagraph(termsText("laBanqueRecommandeDeModifierLeMotDePasse"))
                }
            },
            Article(number: 4, title: termsText("evolutionsDuService"), id: "article4") {
                VStack(alignment: .leading, spacing: 12) {
                    modernParagraph(termsText("enFonctionNotammentDesEvolutionsTechnologiquesLaBanqueApportera"))
                }
            },
            Article(number: 5, title: termsText("assistance"), id: "article5") {
                VStack(alignment: .leading, spacing: 12) {
                    modernParagraph(termsText("laBanqueMetADispositionDeLUtilisateurUn"))
                }
            },
            Article(number: 6, title: termsText("secretProfessionnel"), id: "article6") {
                VStack(alignment: .leading, spacing: 12) {
                    modernParagraph(termsText("laDiamaBankSaEstTenueAuSecretProfessionnel"))
                }
            },
            Article(number: 7, title: termsText("responsabilite"), id: "article7") {
                VStack(alignment: .leading, spacing: 12) {
                    Text(termsText("laBanque"))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.blueH)
                    
                    modernParagraph(termsText("laDiamaBankSaSEngageAFournirLe"))
                    modernParagraph(termsText("laBanqueDeclineTouteResponsabiliteEnCasDeDysfonctionnement"))
                    modernParagraph(termsText("laBanqueNEstPasResponsableDesDysfonctionnementsImputables"))
                    
                    Text(termsText("leClient"))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.blueH)
                        .padding(.top, 8)
                    
                    modernParagraph(termsText("leClientDoitPrendreTouteMesurePourConserverA"))
                    modernParagraph(termsText("leClientDoitUtiliserLeServiceConformementAuxFinalites"))
                    modernParagraph(termsText("leClientSEngageAMettreAJourLes"))
                    modernParagraph(termsText("leClientEstResponsableDesOperationsEffectueesViaSon"))
                }
            },
            Article(number: 8, title: termsText("interruptionDuService"), id: "article8") {
                VStack(alignment: .leading, spacing: 12) {
                    modernParagraph(termsText("laBanquePeutBloquerLAccesTotalAuxServices"))
                    modernParagraph(termsText("leServicePourraEtrePonctuellementInterrompuPourDeCourtes"))
                }
            },
            Article(number: 9, title: termsText("oppositionOuBlocageParLeClient"), id: "article9") {
                VStack(alignment: .leading, spacing: 12) {
                    modernParagraph(termsText("enCasDeVolDeDetournementOuDeToute"))
                    modernParagraph(termsText("dansTousLesCasLeClientDoitImmediatement"))
                    modernBulletPoint(termsText("alerterLaBanque"))
                    modernBulletPoint(termsText("ouAppelerLeCentreDeRelationsClientsCrcDe"))
                }
            },
            Article(number: 10, title: termsText("tarificationDuService"), id: "article10") {
                VStack(alignment: .leading, spacing: 12) {
                    modernParagraph(termsText("lesServicesCiApresSontOffertsGratuitementPourLe"))
                    modernBulletPoint(termsText("laSouscriptionAuWalletDiamacash"))
                    modernBulletPoint(termsText("leChargementDuWalletDiamacash"))
                    modernBulletPoint(termsText("lePaiementChezLeCommercantOuAutresPrestataires"))
                    modernBulletPoint(termsText("laDesinscription"))
                    modernParagraph(termsText("leClientConserveASaChargeLesCoutsDe"))
                }
            },
            Article(number: 11, title: termsText("dureeDuContratResiliation"), id: "article11") {
                VStack(alignment: .leading, spacing: 12) {
                    modernParagraph(termsText("lePresentContratEstConcluPourUneDureeIndeterminee"))
                    modernParagraph(termsText("ilPeutEtreResilieAToutMomentParLe"))
                    modernParagraph(termsText("laResiliationParLeClientPrendEffetTrente30"))
                    modernParagraph(termsText("laResiliationParLaBanquePrendEffetQuinzeJours"))
                }
            },
            Article(number: 12, title: termsText("modificationDuContrat"), id: "article12") {
                VStack(alignment: .leading, spacing: 12) {
                    modernParagraph(termsText("laBanqueSeReserveLeDroitDApporterDes"))
                    modernParagraph(termsText("lAbsenceDeContestationNotifieeALaBanqueAvant"))
                }
            },
            Article(number: 13, title: termsText("arretDuService"), id: "article13") {
                VStack(alignment: .leading, spacing: 12) {
                    modernParagraph(termsText("enCasDArretDeLaFournitureDuService"))
                }
            },
            Article(number: 14, title: termsText("loiApplicableJuridictionLitiges"), id: "article14") {
                VStack(alignment: .leading, spacing: 12) {
                    modernParagraph(termsText("leContratEstRegiEtInterpreteSelonLeDroit"))
                    modernParagraph(termsText("toutDifferendYRelatifQuantASonInterpretationOu"))
                }
            }
        ]
    }
}

// MARK: - Article Model
struct Article {
    let number: Int
    let title: String
    let id: String
    let content: () -> AnyView
    
    init(number: Int, title: String, id: String, @ViewBuilder content: @escaping () -> some View) {
        self.number = number
        self.title = title
        self.id = id
        self.content = { AnyView(content()) }
    }
}

// MARK: - Preview
struct TermsAndConditionsView_Previews: PreviewProvider {
    static var previews: some View {
        TermsAndConditionsView()
    }
}
