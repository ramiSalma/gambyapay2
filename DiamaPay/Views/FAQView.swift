import SwiftUI

struct FAQView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var expandedIndex: Int? = nil
    
    // Frequently asked questions
    var faqs: [(question: String, answer: String)] { [
        // General
        (AppStrings.whatIsGambiapay, AppStrings.gambiapayIsYourSecureDigitalWalletForManagingPaymentsTransfers),
        (AppStrings.howDoIRegisterForGambiapay, AppStrings.downloadTheGambiapayAppFromTheAppleAppStoreOr),
        (AppStrings.howDoILogInToGambiapay, AppStrings.openTheGambiapayAppEnterYourPhoneNumberAndPin),
        (AppStrings.iForgotMyPinCodeWhatShouldIDo, AppStrings.contactCustomerSupportWithAValidFormOfIdentificationTo),
        
        // Balance and account
        (AppStrings.howDoICheckMyGambiapayWalletBalance, AppStrings.yourBalanceAppearsWhenYouLogInIfItIs),
        (AppStrings.whyDoesMyBalanceShowAsAsterisks, AppStrings.yourBalanceIsHiddenForSecurityTapTheEyeIcon),
        (AppStrings.howDoICheckMyTransactionHistory, AppStrings.afterLoggingInTapSeeMoreBelowYourBalanceTo),
        
        // Transfers
        (AppStrings.howDoISendMoney, AppStrings.tapInternalTransferThenFollowTheseSteps1ChooseThe),
        (AppStrings.howDoILinkMyGambiapayWalletToMyBank, AppStrings.visitABranchOfYourBankWithValidIdentificationTo),
        (AppStrings.howDoIAddMoneyToMyGambiapayWalletFrom, AppStrings.tapTopUpMyWalletThenSelectYourAccountEnter),
        (AppStrings.howDoITransferMoneyFromMyGambiapayWalletTo, AppStrings.tapToMyBankSelectYourAccountEnterTheAmount),
        (AppStrings.howOftenIsMyBalanceUpdated, AppStrings.yourBalanceUpdatesInRealTimeWheneverYouOpenOr),
        
        // Transfer types
        (AppStrings.whatTypesOfTransfersCanIMake, AppStrings.walletToWalletWalletToBankAccountBankAccountTo),
        (AppStrings.areThereLimitsOnHowMuchICanTransfer, AppStrings.yesLimitsDependOnYourAccountTypeAndVerificationLevel),
        (AppStrings.howLongDoTransfersTake, AppStrings.mostWalletToWalletTransfersAreInstant),
        
        // Payments and services
        (AppStrings.canIBuyPhoneCreditInTheApp, AppStrings.yesYouCanBuyPhoneCreditForYourselfOrSomeone),
        (AppStrings.canIBuyDataBundles, AppStrings.theAppLetsYouBuyInternetBundlesForSeveralMobile),
        (AppStrings.canIPayBillsWithGambiapay, AppStrings.yesYouCanUseTheAppToPayUtilityAnd),
        (AppStrings.whatIsACashVoucher, AppStrings.cashVouchersLetYouCreateACodeThatSomeoneElse),
        
        // More features
        (AppStrings.whatAreStandingInstructions, AppStrings.theyLetYouScheduleRecurringAutomaticTransfersSuchAsMonthly),
        (AppStrings.whatAreSponsoredWallets, AppStrings.theyLetUsersSponsorAnotherUserOrBeSponsoredTo),
        (AppStrings.whatIsASavingsWallet, AppStrings.itHelpsYouSetMoneyAsideSeparatelyFromYourMain),
        (AppStrings.howDoIViewRecentTransactions, AppStrings.openMiniStatementFromTheMenuToSeeYourRecent),
        
        // Security
        (AppStrings.isMyMoneySafeInTheApp, AppStrings.yesGambiapayUsesEncryptionAndSecurityProtocolsToHelpProtect),
        (AppStrings.canIChangeMyPin, AppStrings.yesOpenTheMenuAndSelectChangePin),
        (AppStrings.whatShouldIDoIfSomeoneAccessesMyAccountWithout, AppStrings.changeYourPinImmediatelyReviewYourTransactionsAndContactSupport),
        (AppStrings.howDoIDeactivateMyWallet, AppStrings.selectDeactivateWalletFromTheMenuThisActionMayBe),
        
        // Customer support
        (AppStrings.howDoIContactCustomerSupport, AppStrings.call0612008699UseContactUsInThe),
        (AppStrings.howDoIReportAProblem, AppStrings.selectReportAProblemFromTheNavigationMenu),
        (AppStrings.canISendFeedbackAboutTheApp, AppStrings.yesSelectSendFeedbackFromTheMenu),
        
        // Troubleshooting
        (AppStrings.theAppWonTLoadMyBalanceWhatShouldI, AppStrings.copy1CheckYourInternetConnection2RestartTheApp3),
        (AppStrings.iMHavingProblemsWithTransfersWhatCouldBeWrong, AppStrings.checkYourBalanceInternetConnectionRecipientSNumberAndTransfer),
        (AppStrings.howDoIUpdateTheApp, AppStrings.checkTheAppStoreOrGooglePlayForTheLatest),
        (AppStrings.theAppCrashesFrequentlyWhatShouldIDo, AppStrings.copy1RestartYourDevice2ClearTheAppCache3),
        
        // Account
        (AppStrings.howDoILogOutOfTheApp, AppStrings.openTheMenuAndSelectLogOut),
        (AppStrings.canIUseTheAppOnMultipleDevices, AppStrings.yesButYouWillNeedToVerifyWithAOne),
        (AppStrings.whatHappensIfIUninstallTheApp, AppStrings.yourFundsRemainSafeReinstallTheAppToAccessYour),
        
        // Fees
        (AppStrings.areThereFeesForUsingTheApp, AppStrings.someTransactionsMayHaveFeesContactCustomerSupportForDetails)
    ] }
    
    // --- Filtrage FAQ ---
    var filteredFaqs: [(question: String, answer: String)] {
        if searchText.isEmpty {
            return faqs
        } else {
            return faqs.filter {
                $0.question.localizedCaseInsensitiveContains(searchText) ||
                $0.answer.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ZStack {
                    Color(hex: "174EA6")
                    HStack(spacing: 12) {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 44, alignment: .leading)
                        }
                        Spacer(minLength: 0)
                        Text(AppStrings.frequentlyAskedQuestions)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        Spacer(minLength: 0)
                        Color.clear.frame(width: 40, height: 44)
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: 54)
                .background(Color(hex: "174EA6").ignoresSafeArea(edges: .top))

                
                ScrollView {
                    VStack(spacing: 14) {
                        
                        // Search
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .font(.system(size: 17))
                            
                            TextField(AppStrings.search, text: $searchText)
                                .font(.system(size: 15))
                            
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 16))
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.07), lineWidth: 1))
                        .padding(.horizontal, 14)
                        .padding(.top, 12)
                        
                        // Quick help cards
                        VStack(alignment: .leading, spacing: 12) {
                            Text(AppStrings.needHelp)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                            
                            HStack(spacing: 12) {
                                // Contact Card
                                VStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "F1F8F2"))
                                            .frame(width: 42, height: 42)
                                        
                                        Image(systemName: "phone.fill")
                                            .font(.system(size: 17))
                                            .foregroundColor(Color(hex: "0788B9"))
                                    }
                                    
                                    VStack(spacing: 3) {
                                        Text(AppStrings.contactUs)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.black)
                                        
                                        Text("+224 612 00 86 99")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(Color(hex: "0788B9"))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 11)
                                .background(Color.white)
                                .cornerRadius(14)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.07), lineWidth: 1))
                                
                                // Commentaires Card
                                VStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "F1F8F2"))
                                            .frame(width: 42, height: 42)
                                        
                                        Image(systemName: "bubble.left.fill")
                                            .font(.system(size: 17))
                                            .foregroundColor(Color(hex: "174EA6"))
                                    }
                                    
                                    VStack(spacing: 3) {
                                        Text(AppStrings.feedback)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.black)
                                        
                                        Text(AppStrings.giveYourOpinion)
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(Color(hex: "174EA6"))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 11)
                                .background(Color.white)
                                .cornerRadius(14)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.07), lineWidth: 1))
                            }
                            .padding(.horizontal, 14)
                        }
                        
                        // Questions and answers
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(AppStrings.questionsAnswers)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                if !filteredFaqs.isEmpty {
                                    Text("\(filteredFaqs.count)")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.blueH)
                                        .cornerRadius(18)
                                }
                            }
                            .padding(.horizontal, 14)
                            
                            if filteredFaqs.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 30))
                                        .foregroundColor(.gray.opacity(0.5))
                                    
                                    Text(AppStrings.noResultsFound)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                    Text(AppStrings.tryAnotherSearch)
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray.opacity(0.7))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 24)
                            } else {
                                VStack(spacing: 10) {
                                    ForEach(filteredFaqs.indices, id: \.self) { index in
                                        DisclosureGroup(
                                            isExpanded: Binding(
                                                get: { expandedIndex == index },
                                                set: { expandedIndex = $0 ? index : nil }
                                            )
                                        ) {
                                            Text(filteredFaqs[index].answer)
                                                .font(.system(size: 14))
                                                .foregroundColor(Color(hex: "475467"))
                                                .padding(.top, 8)
                                                .padding(.bottom, 12)
                                                .fixedSize(horizontal: false, vertical: true)
                                        } label: {
                                            HStack {
                                                Text(filteredFaqs[index].question)
                                                    .font(.system(size: 15, weight: .semibold))
                                                    .foregroundColor(Color(hex: "263445"))
                                                    .multilineTextAlignment(.leading)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                
                                                Spacer()
                                            }
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 12)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.07), lineWidth: 1))
                                    }
                                }
                                .padding(.horizontal, 14)
                            }
                        }
                        
                        // Help footer
                        VStack(spacing: 12) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 26))
                                .foregroundColor(Color(hex: "174EA6"))
                            
                            Text(AppStrings.needAdditionalHelp)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text(AppStrings.ourTeamIsAvailable247ToHelpYou)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .padding(.bottom, 16)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {})
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationView { FAQView() }
}
