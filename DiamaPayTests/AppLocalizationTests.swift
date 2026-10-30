import Foundation
import Testing
@testable import DIAMACASH

struct AppLocalizationTests {
    @Test func standingInstructionsHaveBuiltInEnglishAndFrench() {
        let (english, defaults, suite) = makeStore()
        defer { defaults.removePersistentDomain(forName: suite) }
        let keys = ["annuel", "annuler", "beneficiaryName", "chargement", "confirmer", "confirmerLaSuppression", "contacts", "createStandingInstruction", "creerUnVirement", "dateDeDebut", "dateDeFin", "dateDeFinOptionnel", "description2", "detailsDePaiement", "detailsDuBeneficiaire", "detailsDuDestinataire", "devise", "echecDeLaCreation", "echecDeLaMiseAJour", "echecDeLaSuppression", "editStandingInstruction", "entrerLeCodePin", "entrerLeMontant", "entrerUneDescription", "entrerVotrePin", "entrezVotreCodePinPourSupprimerCeVirementPermanent", "erreurReseauValue", "erreurValue", "error", "frequence", "hebdomadaire", "information", "instructionMiseAJourAvecSucces", "laDateDeDebutDoitEtreAvantLaDateDe", "laDateDeFinNePeutPasEtreDansLe", "laDescriptionEstRequise", "laDestinationEstRequise", "leCodePinEstRequis", "leMontantEstRequis", "mensuel", "modifier", "modifierLeVirement", "montant3", "nDeCompteDEpargne", "numeroDeTelephoneNonDisponible", "ok", "pin", "planification", "quotidien", "saved", "securite", "standingInstructions", "succes", "supprimer", "termine", "traitementEnCours", "typeDeTransaction", "unableToVerifyThisRecipient", "unknown", "update", "verifyAgain", "veuillezDAbordVerifierLeDestinataire", "veuillezEntrerVotrePin", "virementPermanentCreeAvecSucces", "virementPermanentSupprimeAvecSucces", "vousNAvezAucunVirementPermanent"]
        let missingEnglish = english.missingEntries(for: .english)
        let missingFrench = english.missingEntries(for: .french)
        for key in keys {
            #expect(missingEnglish[key] == nil, "Missing English translation: \(key)")
            #expect(missingFrench[key] == nil, "Missing French translation: \(key)")
        }
        #expect(english.text(for: "montant3") == "Amount")
        #expect(english.text(for: "quotidien") == "Daily")
        defaults.set("fr", forKey: "app.preferredLanguage")
        let french = AppLanguageStore(defaults: defaults, preferredLanguages: ["en"])
        #expect(french.text(for: "montant3") == "Montant")
        #expect(french.text(for: "quotidien") == "Quotidien")
    }


    private func makeStore() -> (AppLanguageStore, UserDefaults, String) {
        let name = "AppLocalizationTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        return (AppLanguageStore(defaults: defaults, preferredLanguages: ["en"]), defaults, name)
    }



    @Test func placeholdersSupportReorderingUnicodeAndLiteralTokensInUserInput() {
        let output = AppStrings.format("__ARG_1__ / __ARG_0__", arguments: ["Awa __ARG_1__", "مرحبا"])
        #expect(output == "مرحبا / Awa __ARG_1__")
        #expect(AppStrings.format("Amount: __ARG_0__", arguments: ["125.50 GMD"]) == "Amount: 125.50 GMD")
    }




    @Test func sourceOptionsAndServiceDataStayStableAcrossLanguages() {
        #expect(AppStrings.original("toSavings") == "To Savings")
        #expect(AppStrings.original("fromSavings") == "From Savings")
        #expect(AppStrings.original("all") == "All")
        #expect(AppStrings.option("2207001234") == "2207001234")
        #expect(AppStrings.option("PRIVATE CUSTOMER NOTE") == "PRIVATE CUSTOMER NOTE")
        let error = APIError(success: false, message: "Invalid response", respCode: "400", details: nil)
        #expect(error.message == "Invalid response")
        #expect(error.respCode == "400")
    }

    @Test func catalogTemplatesHaveContiguousArgumentSlots() throws {
        let regex = try NSRegularExpression(pattern: "__ARG_([0-9]+)__")
        for entry in AppStrings.catalog.values {
            #expect(["en", "fr"].contains(entry.language))
            let slots = regex.matches(in: entry.source, range: NSRange(entry.source.startIndex..., in: entry.source)).compactMap {
                Range($0.range(at: 1), in: entry.source).flatMap { Int(entry.source[$0]) }
            }
            if let maximum = slots.max() { #expect(Set(slots) == Set(0...maximum)) }
        }
    }

    @Test func nonLinguisticTemplatesNeedNoTranslationDownload() {
        let template = AppStrings.Entry(source: "__ARG_0__ · __ARG_1__", language: "en")
        #expect(!template.hasLinguisticContent)
        #expect(AppStrings.Entry(source: "Amount: __ARG_0__", language: "en").hasLinguisticContent)
    }

    @Test func profileBeneficiariesAndLoansHaveCompleteOfflineFrenchCopy() throws {
        let (_, defaults, suite) = makeStore()
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set("fr", forKey: "app.preferredLanguage")
        let store = AppLanguageStore(defaults: defaults)
        let keys = ["acceptContinue", "accepted", "accountToWallet", "addANote", "addedValue", "address", "approvalDate", "bankCode", "bankTransfer", "beneficiaries", "beneficiaryDetailsAreIncomplete", "canICancelMyLoanRequest", "canIRepayMyLoanEarly", "cancel", "cancelRequest", "cancelThisLoanRequest", "chooseALoanProviderAndPurpose", "chooseAProviderEnterTheAmountAndPurposeSelectA", "contactYourLoanProviderPromptlyFeesOrOtherConsequencesDepend", "couldntLoadBeneficiaries", "couldntRemoveBeneficiary", "currentStatus", "customerName", "dateUnavailable", "documentCode", "done", "earlyRepaymentRulesDependOnYourProviderContactThemTo", "eligibility", "email", "enterAValidLoanAmount", "enterAmountGmd", "familyName", "filter", "filterByStatusOrProvider", "filterLoanRequests", "firstName", "gambiapayLoanServices", "howDoIApplyForALoan", "howDoIRepayMyLoan", "howLongDoesApprovalTake", "iAcceptTheLoanTermsConditions", "identification", "informationEnteredForALoanRequestIsSharedWithThe", "kycLevel", "loadingBeneficiaries", "loadingProfile", "loanAmount", "loanAmountsFeesInterestAndFinalApprovalAreDeterminedBy", "loanConditions", "loanDetails", "loanFaqs", "loanHelp2", "loanProvider", "loanProvider2", "loanRequest", "loanRequestDetails", "loanRequests", "loanTermsConditions", "moneyVoucher", "myLoans", "myProfile", "name", "nationalId", "nextOfKin", "noBeneficiariesYet", "noLoanRequests", "notProvided", "ok", "otherTypeValue", "personalInformation", "phoneNumber2", "phoneOrCustomerId", "pleaseAcceptTheLoanTermsToContinue", "pleaseSignInAgainToLoadYourBeneficiaries", "pleaseSignInAgainToManageBeneficiaries", "pleaseTryAgain", "privacyPolicy", "profileUnavailable", "provider", "purpose", "purposeOfLoan", "qrTransfer", "reference", "refreshProfile", "registrationDate", "remarks", "remarksOptional", "remove", "removeBeneficiary", "removeBeneficiary2", "repayment", "repaymentDatesAndMethodsAreSetByTheLoanProvider", "repaymentIsHandledByTheLoanProviderFollowTheRepayment", "repaymentPeriod", "requestDate", "requestLoan", "requestSubmitted", "requestedAmount", "reset", "search", "searchTermsAndFaqs", "selectLoanProvider", "selectPurpose", "selectRepaymentPeriod", "sponsoredWallet2", "status", "submitRequest", "theSelectedProviderReviewsEachApplicationProcessingTimesVaryCheck", "thisBeneficiaryWillBeRemovedFromYourSavedList", "tryAgain", "unableToLoadBeneficiaries", "unableToLoadBeneficiariesPleaseTryAgain", "unableToLoadYourProfilePleaseCheckYourConnectionAnd", "unableToLoadYourProfilePleaseTryAgain", "unableToRemoveBeneficiary", "unableToRemoveBeneficiaryPleaseTryAgain", "valueMonths", "valueMonths2", "valueValue", "walletInformation2", "walletNumber", "walletNumber2", "walletStatus", "walletTransfer", "walletType", "whatHappensIfIMissAPayment", "youCanCancelARequestWhileItsStatusIsPending", "youMustHaveAnActiveGambiapayWalletAndProvideAccurate", "yourLoanRequestHasBeenReceived", "yourRequestHasBeenCancelled", "yourRequestStatusWillUpdateAsItProgresses", "yourSavedWalletAndBankBeneficiariesWillAppearHere", "yourSubmittedLoanRequestsWillAppearHere", "yourWalletDetailsAreMissingPleaseSignInAgain"]
        let missing = store.missingEntries(for: .french)
        for key in keys { #expect(missing[key] == nil, "Missing French translation: \(key)") }
        #expect(store.text(for: "personalInformation") == "Informations personnelles")
        #expect(store.text(for: "noBeneficiariesYet") == "Aucun bénéficiaire pour le moment")
        #expect(store.text(for: "loanProvider") == "Organisme de prêt")
        #expect(store.text(for: "bankTransfer") == "Virement bancaire")
        #expect(store.request == nil)
    }









    @Test func onlyFrenchAndEnglishAreSupported() {
        #expect(AppLanguage.supported.map(\.rawValue) == ["fr", "en"])
        #expect(AppLanguage(rawValue: "ar") == nil)
        #expect(AppLanguage(rawValue: "es-MX") == nil)
        #expect(AppLanguage(rawValue: "") == nil)
        #expect(AppLanguage(rawValue: "fr-MA") == .french)
        #expect(AppLanguage(rawValue: "en-GB") == .english)
    }

    @Test func unsupportedSavedLanguageMigratesToSupportedDevicePreference() {
        let (_, defaults, suite) = makeStore()
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set("es", forKey: "app.preferredLanguage")
        let store = AppLanguageStore(defaults: defaults, preferredLanguages: ["ar-MA", "fr-FR"])
        #expect(store.language == .french)
        #expect(defaults.string(forKey: "app.preferredLanguage") == "fr")
    }

    @Test func savedSupportedChoiceWinsAndUnsupportedDeviceDefaultsToEnglish() {
        let (_, defaults, suite) = makeStore()
        defer { defaults.removePersistentDomain(forName: suite) }
        #expect(AppLanguageStore(defaults: defaults, preferredLanguages: ["ar"]).language == .english)
        defaults.set("fr", forKey: "app.preferredLanguage")
        #expect(AppLanguageStore(defaults: defaults, preferredLanguages: ["en"]).language == .french)
    }

    @Test func incompleteFrenchCatalogKeepsCurrentChoiceAndCancelledResultsAreIgnored() throws {
        let (store, defaults, suite) = makeStore()
        defer { defaults.removePersistentDomain(forName: suite) }
        store.select(.french, refresh: true)
        let request = try #require(store.request)
        store.finish(request, translations: [:])
        #expect(store.language == .english)
        #expect(store.translationError != nil)
        store.select(.french, refresh: true)
        let cancelled = try #require(store.request)
        store.cancel()
        store.finish(cancelled, translations: [:])
        #expect(store.language == .english)
        #expect(defaults.string(forKey: "app.preferredLanguage") == nil)
    }

}
