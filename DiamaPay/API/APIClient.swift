import Foundation
import UIKit

class APIClient {
    static let shared = APIClient()

    // private let baseURL = "https://129.151.250.184:8080/DiamaBankWalletF/"
    // private let baseURL = "http://129.151.250.184:8080/DiamaBankWalletF/"
    private let baseURL = "http://192.168.1.228:9192/CustomerWalletBE/"
    //private let baseURL = "https://129.151.250.184:8443/DiamaBankWalletF/"
    //private let baseURL = "https://api2.diamabank.com:8444/DiamaBankWalletF/"


    private var session = URLSession.shared
    private var userDataManager: UserDataManager?
    
    private let defaultTimeout: TimeInterval = 60.0
    private let uploadTimeout: TimeInterval = 120.0
    
    
    private static func buildUserAgent() -> String {
        let appName = "DiamaCash"
          let osType = "iOS"
  
          let versionName = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
      let versionCode = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
      return "\(appName) OS=[\(osType)] VERSION_NAME=[\(versionName)] VERSION_CODE=[\(versionCode)]"
  }

    private init() {
        let configuration = URLSessionConfiguration.default
           configuration.httpAdditionalHeaders = [
            "User-Agent": Self.buildUserAgent()
           ]
        configuration.timeoutIntervalForRequest = defaultTimeout
              configuration.timeoutIntervalForResource = defaultTimeout * 2
              
        
           self.session = URLSession(configuration: configuration)
    }
    

    func calculateWithdrawalFee(
        request: WalletFeeQuoteRequest,
        completion: @escaping (Result<FeeCalculationSimpleResponse, Error>) -> Void
    ) {
        calculateWalletFee(request: request) { result in
            completion(result.map { response in
                FeeCalculationSimpleResponse(
                    respCode: response.respCode, message: response.message,
                    feeAmount: response.result?.totalFees,
                    ruleIndex: response.result?.ruleIndex,
                    requestId: response.result?.requestId
                )
            })
        }
    }

    func calculateTransactionFee(
        request: WalletFeeQuoteRequest,
        completion: @escaping (Result<FeeCalculationResponse, Error>) -> Void
    ) {
        calculateWalletFee(request: request, completion: completion)
    }

    func calculateWalletFee(request: WalletFeeQuoteRequest,
                            completion: @escaping (Result<FeeCalculationResponse, Error>) -> Void) {
        performRequest(endpoint: "api/wallet/calculate-fee", method: .POST,
                       body: request, requiresAuth: true, completion: completion)
    }

    private func decodeResponse<T: Codable>(_ data: Data) -> Result<T, Error> {
        do {
            let result = try JSONDecoder().decode(T.self, from: data)
            return .success(result)
        } catch {
            if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                return .failure(apiError)
            }
            return .failure(error)
        }
    }
    
    
    func getWalletProfile(
        request: WalletProfileRequest,
        completion: @escaping (Result<WalletProfileResponse, Error>) -> Void
    ) {
        performRequest(endpoint: "api/wallet/profile", method: .POST,
                       body: request, requiresAuth: true, completion: completion)
    }

    func getWalletLimits(
           request: RequestGetWalletLimits,
           completion: @escaping (Result<ResponseGetWalletLimits, Error>) -> Void
       ) {
           let endpoint = "api/wallet/limits"
           performRequest(
               endpoint: endpoint,
               method: .POST,
               body: request,
               requiresAuth: true,
               completion: completion
           )
       }

    // MARK: - Food ordering
    func listFoodRestaurants(request: FoodyListingRequest, completion: @escaping (Result<FoodyResponse<[FoodRestaurant]>, Error>) -> Void) {
        performRequest(endpoint: "api/foody/listRestaurants", method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func listFoodItems(request: FoodyItemsRequest, completion: @escaping (Result<FoodyResponse<[FoodItem]>, Error>) -> Void) {
        performRequest(endpoint: "api/foody/listItems", method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func listFoodCategories(request: FoodyRestaurantRequest, completion: @escaping (Result<FoodyResponse<[FoodCategory]>, Error>) -> Void) {
        performRequest(endpoint: "api/foody/listCategories", method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func getFoodRestaurantProfile(request: FoodyRestaurantRequest, completion: @escaping (Result<FoodyResponse<FoodRestaurantProfile>, Error>) -> Void) {
        performRequest(endpoint: "api/foody/restaurantProfile", method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func listFoodMenu(request: FoodyRestaurantRequest, completion: @escaping (Result<FoodyResponse<[FoodCategory]>, Error>) -> Void) {
        performRequest(endpoint: "api/foody/listItemsWithCategories", method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func updateFoodAddress(request: FoodUpdateAddressRequest, completion: @escaping (Result<FoodyResponse<String>, Error>) -> Void) {
        performRequest(endpoint: "api/foody/deliveryAddressUpdate", method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func listActiveFoodOrders(request: FoodyListingRequest, completion: @escaping (Result<FoodyResponse<[FoodOrder]>, Error>) -> Void) {
        performRequest(endpoint: "api/foody/listActiveOrders", method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func listClosedFoodOrders(request: FoodyListingRequest, completion: @escaping (Result<FoodyResponse<[FoodOrder]>, Error>) -> Void) {
        performRequest(endpoint: "api/foody/listClosedOrders", method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func cancelFoodOrder(request: FoodOrderActionRequest, completion: @escaping (Result<FoodyResponse<String>, Error>) -> Void) {
        performRequest(endpoint: "api/foody/cancelOrder", method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func addFoodComplaint(request: FoodComplaintRequest, completion: @escaping (Result<FoodyResponse<String>, Error>) -> Void) {
        performRequest(endpoint: "api/foody/addComplaint", method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func listFoodComplaints(request: FoodyListingRequest, completion: @escaping (Result<FoodyResponse<[FoodComplaintRecord]>, Error>) -> Void) {
        performRequest(endpoint: "api/foody/listComplaints", method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func listFoodAddresses(request: FoodyListingRequest, completion: @escaping (Result<FoodyResponse<[FoodAddress]>, Error>) -> Void) {
        performRequest(endpoint: "api/foody/listAddresses", method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func addFoodAddress(request: FoodAddAddressRequest, completion: @escaping (Result<FoodyResponse<String>, Error>) -> Void) {
        performRequest(endpoint: "api/foody/addAddress", method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func placeFoodOrder(request: FoodOrderRequest, completion: @escaping (Result<FoodyResponse<String>, Error>) -> Void) {
        performRequest(endpoint: "api/foody/addOrder", method: .POST, body: request, requiresAuth: true, completion: completion)
    }
    
    func qrTransfer(request: RequestQrPayment, completion: @escaping (Result<ResponseService, Error>) -> Void) {
        let endpoint = "api/wallet/qrtransfer"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func getOrGenerateCustomerQR(request: GenerateCustomerQRRequest, completion: @escaping (Result<ResponseServiceJson, Error>) -> Void) {
        let endpoint = "api/wallet/qr/customer"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func listSecretQuestions(completion: @escaping (Result<JResponseService, Error>) -> Void) {
        let endpoint = "api/wallet/list-secretQ"
        performRequest(endpoint: endpoint, method: .POST, body: nil as EmptyRequest?, requiresAuth: false, completion: completion)
    }
    
    func getNationalities(completion: @escaping (Result<[Nationality], Error>) -> Void) {
        let endpoint = "api/nationalities"
        performRequest(endpoint: endpoint, method: .GET, body: nil as String?, requiresAuth: false, completion: completion)
    }

 
    // MARK: - Security Questions Endpoint
    func updateSecurityQuestion(request: SecurityQuestionUpdateRequest,
                                completion: @escaping (Result<ResponseService, Error>) -> Void) {
        performRequest(endpoint: "api/wallet/update-info", method: .POST,
                       body: request, requiresAuth: true, completion: completion)
    }

    func listSecurityQuestions(completion: @escaping (Result<JResponseService, Error>) -> Void) {
        let endpoint = "api/wallet/list-secretQ"
        performRequest(endpoint: endpoint, method: .POST, body: nil as String?, requiresAuth: false, completion: completion)
    }

    func verifyOtpReset(request: OtpResetVerificationRequest, completion: @escaping (Result<ForgotPinResponse, Error>) -> Void) {
        let endpoint = "api/auth/forgot-pin/verify-otp"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: false, completion: completion)
    }
       func unlinkSponsoredWallet(
           request: SponsoredWalletDto,
           completion: @escaping (Result<JResponseService, Error>) -> Void
       ) {
           let endpoint = "api/sponsor/unlink"
           performRequest(endpoint: endpoint,
                         method: .POST,
                         body: request,
                         requiresAuth: true,
                         completion: completion)
       }
       
       func updateSponsoredWallet(
           request: SponsoredWalletDto,
           completion: @escaping (Result<ResponseServiceJson, Error>) -> Void
       ) {
           let endpoint = "api/sponsor/update"
           performRequest(endpoint: endpoint,
                         method: .POST,
                         body: request,
                         requiresAuth: true,
                         completion: completion)
       }
       
       func sponsorWallet(
           request: SponsoredWalletDto,
           completion: @escaping (Result<ResponseServiceJson, Error>) -> Void
       ) {
           let endpoint = "api/sponsor/sponsor-wallet"
           performRequest(endpoint: endpoint,
                         method: .POST,
                         body: request,
                         requiresAuth: true,
                         completion: completion)
       }
    
   
    func getLast5Transactions(request: RequestLast5Transactions, completion: @escaping (Result<JResponseService, Error>) -> Void) {
        let endpoint = "api/wallet/transactions/last5"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func downloadEStatement(request: RequestEStatement, completion: @escaping (Result<ResponseService, Error>) -> Void) {
        let endpoint = "api/wallet/estatement"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    // MARK: - Savings wallet
    func getSavingsBalance(request: RequestSavingBalance, completion: @escaping (Result<ResponseServiceJson, Error>) -> Void) {
        performRequest(endpoint: "api/savings-wallet/balance", method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func creditSavingsWallet(request: RequestCreditSaving, completion: @escaping (Result<ResponseService, Error>) -> Void) {
        performRequest(endpoint: "api/savings-wallet/credit", method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func debitSavingsWallet(request: RequestDebitSaving, completion: @escaping (Result<ResponseService, Error>) -> Void) {
        performRequest(endpoint: "api/savings-wallet/debit", method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func getSavingsLast5(request: RequestEStatement, completion: @escaping (Result<JResponseService, Error>) -> Void) {
        performRequest(endpoint: "api/savings-wallet/last5", method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func requestSavingsEStatement(request: RequestEStatement, completion: @escaping (Result<ResponseService, Error>) -> Void) {
        performRequest(endpoint: "api/savings-wallet/e-statement", method: .POST, body: request, requiresAuth: true, completion: completion)
    }
    func getPendingTransactions(request: RequestListPendingTransactions, completion: @escaping (Result<JResponseService, Error>) -> Void) {
        let endpoint = "api/wallet/transactions/pending"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func validateTransaction(request: RequestApproval, completion: @escaping (Result<ResponseService, Error>) -> Void) {
        let endpoint = "api/wallet/validate-transaction"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
    }
       
    // Check PIN
       func checkPin(request: RequestCheckPin, completion: @escaping (Result<ResponseServiceJson, Error>) -> Void) {
           let endpoint = "api/wallet/check-pin"
           performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
       }
       
       // Change PIN
       func changePin(request: RequestChangePin, completion: @escaping (Result<ResponseService, Error>) -> Void) {
           let endpoint = "api/pin/change"
           performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
       }
    func getSponsoredWallets(request: RequestListSponsoredWallets, completion: @escaping (Result<JResponseService, Error>) -> Void) {
        let endpoint = "api/sponsor/sponsored-wallets"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
    }
    
    func moneyVoucher(request: RequestMoneyVoucher, completion: @escaping (Result<ResponseService, Error>) -> Void) {
        let endpoint = "api/wallet/money-voucher"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func transferWalletToMobileMoney(
        request: RequestWalletToMobileMoney,
        completion: @escaping (Result<ResponseService, Error>) -> Void
    ) {
        performRequest(endpoint: "api/wallet/wallet-to-mobile-money", method: .POST,
                       body: request, requiresAuth: true, completion: completion)
    }

    func enquireMobileMoneyReceiver(
        request: RequestWalletToMobileMoneyNE,
        completion: @escaping (Result<ResponseServiceJson, Error>) -> Void
    ) {
        performRequest(endpoint: "api/wallet/mobile-money-enquiry", method: .POST,
                       body: request, requiresAuth: true, completion: completion)
    }

    func getLoanProviders(completion: @escaping (Result<[Provider], Error>) -> Void) {
        performRequest(endpoint: "api/loan/providers", method: .GET, body: Optional<String>.none,
                       requiresAuth: true, completion: completion)
    }

    func getLoanPurposes(completion: @escaping (Result<[LoanOption], Error>) -> Void) {
        performRequest(endpoint: "api/loan/purposes", method: .GET, body: Optional<String>.none,
                       requiresAuth: true, completion: completion)
    }

    func createLoan(request: LoanRequestPayload, completion: @escaping (Result<LoanEnvelope<LoanRecord>, Error>) -> Void) {
        performRequest(endpoint: "api/loan/add", method: .POST, body: request,
                       requiresAuth: true, completion: completion)
    }

    func getLoans(phoneNumber: String, completion: @escaping (Result<LoanEnvelope<[LoanRecord]>, Error>) -> Void) {
        let escapedPhone = phoneNumber.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? phoneNumber
        performRequest(endpoint: "api/loan/phone/\(escapedPhone)", method: .GET, body: Optional<String>.none,
                       requiresAuth: true, completion: completion)
    }

    func getLoan(id: Int64, completion: @escaping (Result<LoanEnvelope<LoanRecord>, Error>) -> Void) {
        performRequest(endpoint: "api/loan/\(id)", method: .GET, body: Optional<String>.none,
                       requiresAuth: true, completion: completion)
    }

    func cancelLoan(id: Int64, completion: @escaping (Result<LoanRecord, Error>) -> Void) {
        performRequest(endpoint: "api/loan/\(id)/cancel", method: .PUT, body: Optional<String>.none,
                       requiresAuth: true, completion: completion)
    }
    func accountToWallet(request: RequestAccountToWallet, completion: @escaping (Result<ResponseServiceJson, Error>) -> Void) {
        let endpoint = "api/wallet/account-to-wallet"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func getAccountNameEnquiry(request: RequestWalletToBankAccountNE, completion: @escaping (Result<ResponseServiceJson, Error>) -> Void) {
        let endpoint = "api/wallet/account-name-enquiry"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
    }
  
    func transferWalletToAccountNE(request: RequestWalletToBankAccountNE, completion: @escaping (Result<ResponseServiceJson, Error>) -> Void) {
        let endpoint = "api/wallet/account-name-enquiry"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func transferWalletToAccount(request: RequestWalletToAccount, completion: @escaping (Result<ResponseServiceJson, Error>) -> Void) {
        let endpoint = "api/wallet/transfer-to-account"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
    }
    
    
    func listWalletBeneficiaries(
        request: WalletBeneficiaryListRequest,
        completion: @escaping (Result<WalletBeneficiaryListResponse, Error>) -> Void
    ) {
        performRequest(endpoint: "api/wallet/ListBeneficiary", method: .POST,
                       body: request, requiresAuth: true, completion: completion)
    }

    func addWalletBeneficiary(
        request: WalletBeneficiaryAddRequest,
        completion: @escaping (Result<ResponseServiceJson, Error>) -> Void
    ) {
        performRequest(endpoint: "api/wallet/AddBeneficiary", method: .POST,
                       body: request, requiresAuth: true, completion: completion)
    }

    func deleteWalletBeneficiary(
        request: WalletBeneficiaryDeleteRequest,
        completion: @escaping (Result<ResponseServiceJson, Error>) -> Void
    ) {
        performRequest(endpoint: "api/wallet/DeleteBeneficiary", method: .POST,
                       body: request, requiresAuth: true, completion: completion)
    }

    func getWalletInfo(request: RequestNameEnquiry, completion: @escaping (Result<ResponseServiceJson, Error>) -> Void) {
        let endpoint = "api/wallet/enquiry"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
    }
    
 
    func transferWalletToWallet(request: RequestWalletToWallet, completion: @escaping (Result<ResponseServiceJson, Error>) -> Void) {
        let endpoint = "api/wallet/transfer"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
    }
    func registerCustomer(
            request: CustomerRegistrationRequest,
            completion: @escaping (Result<ResponseServiceJson, Error>) -> Void
        ) {
            let endpoint = "api/customer/register"
            guard !request.documentId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                completion(.failure(APIError(success: false, message: AppStrings.original("enterTheNumberShownOnYourNationalId"), respCode: "400", details: nil)))
                return
            }
            logRegistrationRequestDiagnostics(request)
            performRequest(endpoint: endpoint,
                           method: .POST,
                           body: request,
                           requiresAuth: false,
                           customTimeout: uploadTimeout,
                           completion: completion)
        }

    /// Logs registration field values in debug builds, with credentials and images masked.
    private func logRegistrationRequestDiagnostics(_ request: CustomerRegistrationRequest) {
        let requiredFields = [
            "firstName", "lastName", "phone", "email", "birthDate", "nationality",
            "documentCode", "documentId", "gender", "currencyCode", "bank", "branchCode",
            "secretQ", "answer", "address", "type", "productCode", "pin", "nkinName",
            "nkinPhone", "deviceId", "faceId",
            "documentImg", "documentImgBack"
        ]
        let safeValueFields: Set<String> = [
            "nationality", "documentCode", "gender", "currencyCode", "bank",
            "branchCode", "secretQ", "type", "productCode"
        ]

        do {
            let encoded = try JSONEncoder().encode(request)
            guard let payload = try JSONSerialization.jsonObject(with: encoded) as? [String: Any] else {
                print("[Registration] Could not inspect encoded request fields.")
                return
            }

            let fieldAudit = payload.keys.sorted().map { field -> String in
                guard let value = payload[field] as? String else {
                    return "\(field)=<non-string-or-null>"
                }
                let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedValue.isEmpty { return "\(field)=<blank>" }
                if safeValueFields.contains(field) { return "\(field)=\(trimmedValue)" }
                return "\(field)=<present,length:\(value.count)>"
            }
            let missingFields = requiredFields.filter { field in
                guard let value = payload[field] as? String else { return true }
                return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            let unexpectedFields = Set(payload.keys).subtracting(requiredFields + ["srcFunds", "occupation", "estimatedIncome", "referralCode"])

            print("[Registration] Encoded JSON size: \(encoded.count) bytes")
            print("[Registration] POST api/customer/register payload field audit (sensitive values redacted; safe codes shown): \(fieldAudit.joined(separator: ", "))")
            print("[Registration] Required fields missing/blank: \(missingFields.isEmpty ? "none" : missingFields.joined(separator: ", "))")
            print("[Registration] Unexpected payload fields: \(unexpectedFields.isEmpty ? "none" : unexpectedFields.sorted().joined(separator: ", "))")
#if DEBUG
            let maskedFields: Set<String> = ["pin", "answer", "faceId", "documentImg", "documentImgBack"]
            for field in payload.keys.sorted() {
                if maskedFields.contains(field) {
                    print("[Registration] \(field)=<redacted>")
                } else if let value = payload[field], !(value is NSNull) {
                    print("[Registration] \(field)=\(value)")
                } else {
                    print("[Registration] \(field)=null")
                }
            }
#endif
        } catch {
            print("[Registration] Could not encode request for field diagnostics: \(error.localizedDescription)")
        }
    }

        // Verify OTP (Step 4)
        func verifyOtp(
            request: OtpRequest,
            completion: @escaping (Result<ResponseServiceJson, Error>) -> Void
        ) {
            let endpoint = "api/otp/verify"
            performRequest(endpoint: endpoint,
                           method: .POST,
                           body: request,
                           requiresAuth: false,
                           completion: completion)
        }

    func uploadCustomerDocuments(
        request: CustomerDocumentUploadRequest,
        completion: @escaping (Result<ResponseServiceJson, Error>) -> Void
    ) {
        let endpoint = "api/customer/upload-documents"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func getWalletBalance( request: RequestBalanceEnquiry, completion: @escaping (Result<ResponseServiceJson, Error>) -> Void ) { let endpoint = "api/wallet/balance"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion) }
    
    func getLast30DaysTransactions( request: RequestEStatement, completion: @escaping (Result<JResponseService, Error>) -> Void ) { let endpoint = "api/wallet/lastThirty"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion) } // MA
    // MARK: - Initialize
    func initialize(with userDataManager: UserDataManager) {
        self.userDataManager = userDataManager
    }
    func getBalance(completion: @escaping (Result<BalanceResponse, Error>) -> Void) {
        let user = UserDataManager.shared
        let wallet = user.getWalletNumber()
        let phone = user.getPhoneNumber()
        guard !wallet.isEmpty || !phone.isEmpty else {
            completion(.failure(APIError(success: false, message: AppStrings.original("walletDetailsAreMissingPleaseSignInAgain"), respCode: nil, details: nil)))
            return
        }
        let request = RequestBalanceEnquiry(
            walletNumber: wallet, phoneNumber: phone,
            source: wallet.isEmpty ? "P" : "W", pin: user.getPinForAPI(),
            bank: user.getBankCode().isEmpty ? "00100" : user.getBankCode(),
            requestId: DateFormatter.with(format: "yyMMdd").string(from: Date()) + String(format: "%06d", Int.random(in: 0...999999)),
            requestDate: DateFormatter.with(format: "yyyy-MM-dd HH:mm:ss").string(from: Date()),
            entityId: phone
        )
        getWalletBalance(request: request) { result in
            completion(result.flatMap { response in
                guard response.respCode == "000", let values = response.result,
                      let available = Double(String(describing: values["availableBalance"] ?? "")),
                      let total = Double(String(describing: values["globalBalance"] ?? "")) else {
                    return .failure(APIError(success: false, message: response.message ?? "Unable to read wallet balance", respCode: response.respCode, details: nil))
                }
                return .success(BalanceResponse(availableAmount: available, totalAmount: total,
                                                currency: values["currencyWording"] as? String ?? "GMD"))
            })
        }
    }

    func getSponsoringWallets(request: RequestListSponsoringWallets, completion: @escaping (Result<JResponseService, Error>) -> Void) {
        let endpoint = "api/sponsor/list-sponsoring-wallets"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
    }
    
    func getDailyLimit(request: RequestGetDailyLimitSponsorWallet, completion: @escaping (Result<ResponseService, Error>) -> Void) {
        let endpoint = "api/sponsor/daily-limits"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
    }
    
   
    func getLinkedAccounts(request: RequestListLinkedAcc, completion: @escaping (Result<JResponseService, Error>) -> Void) {
        let endpoint = "api/wallet/linked-accounts"
#if DEBUG
        print("[LinkedAccounts] source=\(request.source ?? "nil"), walletPresent=\(!(request.walletNumber ?? "").isEmpty), phonePresent=\(!(request.phoneNumber ?? "").isEmpty), bank=\(request.bank ?? "nil"), requestId=\(request.requestId ?? "nil")")
#endif
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
    }

    func getAccountBalance(accountNumber: String, clientId: String, completion: @escaping (Result<BalanceResponsea, Error>) -> Void) {
        let endpoint = "api/account/balance/\(accountNumber)?clientId=\(clientId)"
        performRequest(endpoint: endpoint, method: .GET, body: nil as String?, requiresAuth: true, completion: completion)
    }
     
    // MARK: - Auth Endpoints
    func login(request: AuthRequest, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        let endpoint = "api/auth/login"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: false, completion: completion)
    }
    
    func verifyOtp(request: OtpVerificationRequest, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        let endpoint = "api/auth/verify-otp"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: false, completion: completion)
    }
    
    func initPassword(request: AuthRequest, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        let endpoint = "api/auth/init-password"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: false, completion: completion)
    }
    
    func initiateForgotPin(request: ForgotPinInitiateRequest, completion: @escaping (Result<ForgotPinResponse, Error>) -> Void) {
        let endpoint = "api/auth/forgot-pin/initiate"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: false, completion: completion)
    }
    
    func verifyOtpReset(request: ForgotPinVerifyRequest, completion: @escaping (Result<ForgotPinResponse, Error>) -> Void) {
        let endpoint = "api/auth/forgot-pin/verify-otp"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: false, completion: completion)
    }
    
    func verifySecurityQuestion(request: SecurityQuestionRequest, completion: @escaping (Result<ForgotPinResponse, Error>) -> Void) {
        let endpoint = "api/auth/forgot-pin/verify-question"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: false, completion: completion)
    }
    
    func resetPin(request: PinResetRequest, completion: @escaping (Result<ForgotPinResponse, Error>) -> Void) {
        let endpoint = "api/auth/forgot-pin/reset"
        performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: false, completion: completion)
    }
    

    // MARK: - List Standing Instructions
       func listStandingInstructions(
           request: RequestStandingInstructionList,
           completion: @escaping (Result<JResponseService, Error>) -> Void
       ) {
           let endpoint = "api/standing-instruction/list"
           performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
       }
       
       // MARK: - Create Standing Instruction
       func createStandingInstruction(
           request: StandingInstructionDto,
           completion: @escaping (Result<ResponseServiceJson, Error>) -> Void
       ) {
           let endpoint = "api/standing-instruction/create"
           performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
       }
       
       // MARK: - Update Standing Instruction
       func updateStandingInstruction(
           request: StandingInstructionUpdateRequest,
           completion: @escaping (Result<ResponseService, Error>) -> Void
       ) {
           let endpoint = "api/standing-instruction/update"
           performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
       }
       
       // MARK: - Delete Standing Instruction
       func deleteStandingInstruction(
           request: RequestStandingInstructionDelete,
           completion: @escaping (Result<ResponseService, Error>) -> Void
       ) {
           let endpoint = "api/standing-instruction/delete"
           performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true, completion: completion)
       }
    
       func sendComment(request: CommentRequest, completion: @escaping (Result<Void, Error>) -> Void) {
           let endpoint = "api/comments"
           
           guard let url = URL(string: baseURL + endpoint) else {
               completion(.failure(APIError(success: false, message: AppStrings.original("invalidUrl"), respCode: nil, details: nil)))
               return
           }
           
           var urlRequest = URLRequest(url: url)
           urlRequest.httpMethod = "POST"
           urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
           urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
           
           addAuthHeaders(to: &urlRequest)
           
           do {
               let encoder = JSONEncoder()
               encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
               let jsonData = try encoder.encode(request)
               urlRequest.httpBody = jsonData
               
               if let jsonString = String(data: jsonData, encoding: .utf8) {
                   print("=== COMMENT REQUEST JSON ===")
                   print(jsonString)
               }
           } catch {
               print("Error encoding comment request: \(error)")
               completion(.failure(error))
               return
           }
           
           session.dataTask(with: urlRequest) { data, response, error in
               DispatchQueue.main.async {
                   if let error = error {
                       print("❌ Comment network error: \(error)")
                       completion(.failure(error))
                       return
                   }
                   
                   guard let httpResponse = response as? HTTPURLResponse else {
                       completion(.failure(APIError(success: false, message: AppStrings.original("invalidResponse"), respCode: nil, details: nil)))
                       return
                   }
                   
                   
                   switch httpResponse.statusCode {
                   case 200...299:
                       print("Comment sent successfully")
                       completion(.success(()))
                   case 400:
                       completion(.failure(APIError(success: false, message: AppStrings.original("donneesInvalides"), respCode: "400", details: nil)))
                   case 401:
                       completion(.failure(APIError(success: false, message: AppStrings.original("nonAutorise"), respCode: "401", details: nil)))
                   case 500...599:
                       completion(.failure(APIError(success: false, message: AppStrings.original("erreurDuServeur"), respCode: "\(httpResponse.statusCode)", details: nil)))
                   default:
                       completion(.failure(APIError(success: false, message: AppStrings.original("unknownError"), respCode: "\(httpResponse.statusCode)", details: nil)))
                   }
               }
           }.resume()
       }
       
       func sendComplaint(request: ComplaintRequest, completion: @escaping (Result<Void, Error>) -> Void) {
           let endpoint = "api/complaints"
           
           guard let url = URL(string: baseURL + endpoint) else {
               completion(.failure(APIError(success: false, message: AppStrings.original("invalidUrl"), respCode: nil, details: nil)))
               return
           }
           
           var urlRequest = URLRequest(url: url)
           urlRequest.httpMethod = "POST"
           urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
           urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
           
           addAuthHeaders(to: &urlRequest)
           
           do {
               let encoder = JSONEncoder()
               encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
               let jsonData = try encoder.encode(request)
               urlRequest.httpBody = jsonData
               
               if let jsonString = String(data: jsonData, encoding: .utf8) {
                   print(" === COMPLAINT REQUEST JSON ===")
                   print(jsonString)
               }
           } catch {
                   print("Error encoding complaint request: \(error)")
                   completion(.failure(error))
                   return
               }
           
           session.dataTask(with: urlRequest) { data, response, error in
               DispatchQueue.main.async {
                   if let error = error {
                       print(" Complaint network error: \(error)")
                       completion(.failure(error))
                       return
                   }
                   
                   guard let httpResponse = response as? HTTPURLResponse else {
                       completion(.failure(APIError(success: false, message: AppStrings.original("invalidResponse"), respCode: nil, details: nil)))
                       return
                   }
                   
                   
                   switch httpResponse.statusCode {
                   case 200...299:
                       completion(.success(()))
                   case 400:
                       completion(.failure(APIError(success: false, message: AppStrings.original("donneesInvalides"), respCode: "400", details: nil)))
                   case 401:
                       completion(.failure(APIError(success: false, message: AppStrings.original("nonAutorise"), respCode: "401", details: nil)))
                   case 429:
                       completion(.failure(APIError(success: false, message: AppStrings.original("tropDePlaintesRecentes"), respCode: "429", details: nil)))
                   case 500...599:
                       completion(.failure(APIError(success: false, message: AppStrings.original("erreurDuServeur"), respCode: "\(httpResponse.statusCode)", details: nil)))
                   default:
                       completion(.failure(APIError(success: false, message: AppStrings.original("unknownError"), respCode: "\(httpResponse.statusCode)", details: nil)))
                   }
               }
           }.resume()
       }
    
    func validateJWT(request: ValidateJwtRequest, completion: @escaping (Result<[String: Any], Error>) -> Void) {
            let endpoint = "api/wallet/validate-jwt"
            performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true) { (result: Result<ResponseWithDynamicResult, Error>) in
                switch result {
                case .success(let response):
                    completion(.success(response.toDictionary()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        func markTokenUsed(request: MarkTokenUsedRequest, completion: @escaping (Result<[String: Any], Error>) -> Void) {
            let endpoint = "api/wallet/mark-token-used"
            performRequest(endpoint: endpoint, method: .POST, body: request, requiresAuth: true) { (result: Result<ResponseWithDynamicResult, Error>) in
                switch result {
                case .success(let response):
                    completion(.success(response.toDictionary()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    
    
        func deactivateWallet(
            request: RequestDeactivateWallet,
            completion: @escaping (Result<ResponseService, Error>) -> Void
        ) {
            let endpoint = "api/wallet/deactivate"
            performRequest(
                endpoint: endpoint,
                method: .POST,
                body: request,
                requiresAuth: true,
                completion: completion
            )
        }
 
        func getAllBranches(
            bankCode: String,
            completion: @escaping (Result<[Branch], Error>) -> Void
        ) {
            let endpoint = "branches/\(bankCode)"
            
            guard let url = URL(string: baseURL + endpoint) else {
                completion(.failure(APIError(success: false, message: AppStrings.original("invalidUrl"), respCode: nil, details: nil)))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.GET.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
                        
            if let userDataManager = userDataManager {
                let token = userDataManager.getToken()
                if !token.isEmpty {
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    request.setValue(token, forHTTPHeaderField: "X-Auth-Token")
                }
            }
            
            session.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print(" Network error: \(error)")
                        completion(.failure(error))
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        print(" Invalid response type")
                        completion(.failure(APIError(success: false, message: AppStrings.original("invalidResponse"), respCode: nil, details: nil)))
                        return
                    }
                    
                    
                    guard let data = data else {
                        print(" No data received")
                        completion(.failure(APIError(success: false, message: AppStrings.original("noDataReceived"), respCode: nil, details: nil)))
                        return
                    }
                    
                    if let responseString = String(data: data, encoding: .utf8) {
                        let preview = String(responseString.prefix(500))
                        print("Response preview: \(preview)")
                    }
                    
                    switch httpResponse.statusCode {
                    case 200...299:
                        do {
                            // Parse as array of dictionaries first, then convert to Branch objects
                            if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                                var branches: [Branch] = []
                                
                                for dict in jsonArray {
                                    var branch = Branch()
                                    branch.id = dict["id"] as? String
                                    branch.name = dict["name"] as? String
                                    branch.address = dict["address"] as? String
                                    branch.location = dict["location"] as? String
                                    branch.phoneNumber = dict["phoneNumber"] as? String
                                    branch.bankCode = dict["bankCode"] as? String
                                    branches.append(branch)
                                }
                                
                                completion(.success(branches))
                            } else {
                                completion(.failure(APIError(success: false, message: AppStrings.original("invalidResponseFormat"), respCode: nil, details: nil)))
                            }
                        } catch {
                            completion(.failure(error))
                        }
                        
                    case 401:
                        self.handleTokenExpiration()
                        let error = APIError(success: false, message: AppStrings.original("sessionExpired2"), respCode: "401", details: "Please login again")
                        completion(.failure(error))
                        
                    default:
                        let error = APIError(success: false, message: AppStrings.original("serverError"), respCode: "\(httpResponse.statusCode)", details: nil)
                        completion(.failure(error))
                    }
                }
            }.resume()
        }
    func listCrowdfundingGroups(phoneNumber: String, completion: @escaping (Result<[CrowdfundingGroup], Error>) -> Void) {
        var allowed = CharacterSet.urlPathAllowed
        allowed.remove(charactersIn: "/?#%")
        guard let phone = phoneNumber.addingPercentEncoding(withAllowedCharacters: allowed) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        performRequest(endpoint: "crowdfunding/getUserGroups/" + phone, method: .POST,
                       body: Optional<WalletBeneficiaryListRequest>.none,
                       requiresAuth: true, completion: completion)
    }

    // MARK: - Generic Request Method
    private func performRequest<T: Codable, U: Codable>(
        endpoint: String,
        method: HTTPMethod,
        body: T?,
        requiresAuth: Bool,
        customTimeout: TimeInterval? = nil,
        completion: @escaping (Result<U, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(APIError(success: false, message: AppStrings.original("invalidUrl"), respCode: nil, details: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Set custom timeout if provided
        if let timeout = customTimeout {
            request.timeoutInterval = timeout
            print("⏱️ Using custom timeout: \(timeout)s for \(endpoint)")
        }
        
        if requiresAuth {
            addAuthHeaders(to: &request)
        }
        
        if let body = body {
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                let jsonData = try encoder.encode(body)
                request.httpBody = jsonData

                if endpoint == "api/wallet/transfer-to-account" {
                    logWalletToAccountRequest(jsonData)
                }
                #if DEBUG
                if endpoint.hasPrefix("api/foody/"),
                   let payload = (try? JSONSerialization.jsonObject(with: jsonData)) as? [String: Any] {
                    var safePayload = payload
                    for field in ["phoneNumber", "entityId", "addressLine1", "addressLine2", "city", "postalCode", "latitude", "longitude", "description", "reason", "label"] where safePayload[field] != nil {
                        safePayload[field] = "<redacted>"
                    }
                    if let safeData = try? JSONSerialization.data(withJSONObject: redactSensitiveLogValues(safePayload), options: [.sortedKeys]),
                       let safeText = String(data: safeData, encoding: .utf8) {
                        print("[Foody] POST \(endpoint) request=\(safeText)")
                    }
                }
                #endif
                
                // Log payload size for debugging
                let sizeInKB = Double(jsonData.count) / 1024.0
                
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                }
            } catch {
                completion(.failure(error))
                return
            }
        } else {
            print("Request has body: NO")
        }

        let requestID = request.httpBody.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }?["requestId"] as? String
        // Perform the request
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if endpoint.hasPrefix("api/foody/") {
                    self.handleFoodyResponse(data: data, response: response, error: error, endpoint: endpoint, requestID: requestID, completion: completion)
                    return
                }
                if requiresAuth,
                   (endpoint.hasPrefix("api/wallet/") || endpoint.hasPrefix("api/pin/")),
                   error == nil, let data,
                   let httpResponse = response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode),
                   let envelope = try? JSONDecoder().decode(WalletAPIResponseStatus.self, from: data),
                   let code = envelope.respCode, code != "000" {
                    completion(.failure(APIError(success: false, message: envelope.message ?? "Request failed", respCode: code, details: nil)))
                    return
                }
                self.handleResponse(data: data, response: response, error: error, completion: completion)
            }
        }.resume()
    }

    private func handleFoodyResponse<U: Codable>(
        data: Data?, response: URLResponse?, error: Error?, endpoint: String,
        requestID: String?, completion: @escaping (Result<U, Error>) -> Void
    ) {
        let httpStatus = (response as? HTTPURLResponse)?.statusCode
        let envelope = data.flatMap { try? JSONDecoder().decode(FoodyFailureEnvelope.self, from: $0) }
        let reference = envelope?.reference(fallback: requestID) ?? requestID
        let operationKeys = [
            "listRestaurants": "foodLoadingRestaurants", "restaurantProfile": "foodLoadingRestaurant",
            "listItemsWithCategories": "foodLoadingMenu", "listItems": "foodLoadingMenu", "listCategories": "foodLoadingMenu",
            "listAddresses": "foodLoadingAddresses", "addAddress": "foodSavingAddress", "deliveryAddressUpdate": "foodSavingAddress",
            "addOrder": "foodPlacingOrder", "cancelOrder": "foodCancellingOrder",
            "listActiveOrders": "foodLoadingOrders", "listClosedOrders": "foodLoadingOrders",
            "addComplaint": "foodSendingComplaint", "listComplaints": "foodLoadingComplaints"
        ]
        let operation = AppStrings.value(operationKeys[String(endpoint.split(separator: "/").last ?? "")] ?? "orderFood")
        let fail: (Error) -> Void = { originalError in
            // A transport failure has no server response; keep its network diagnosis intact.
            let reason = error == nil ? (envelope?.failureMessage ?? originalError.localizedDescription) : originalError.localizedDescription
            var message = AppStrings.value("foodOperationFailed", arguments: [operation, reason])
            if let reference, !reference.isEmpty {
                message += "\n" + AppStrings.value("foodErrorReference", arguments: [reference])
            }
            #if DEBUG
            print("[Foody] FAILED endpoint=\(endpoint) HTTP=\(httpStatus.map(String.init) ?? "none") respCode=\(envelope?.respCode ?? "none") requestId=\(reference ?? "none")")
            // Business errors return before the generic response logger runs.
            if let data, let object = try? JSONSerialization.jsonObject(with: data),
               let safeData = try? JSONSerialization.data(withJSONObject: self.redactSensitiveLogValues(object), options: [.sortedKeys]),
               let safeText = String(data: safeData, encoding: .utf8) {
                print("[Foody] Failure response=\(safeText)")
            }
            #endif
            completion(.failure(APIError(success: false, message: message, respCode: envelope?.respCode ?? httpStatus.map(String.init), details: "endpoint=\(endpoint); requestId=\(reference ?? "none")")))
        }
        // Order-history endpoints use 009/NOK with a null result for an empty list.
        // Preserve that response for the history view; mutations must still fail on 009.
        let emptyOrderHistory = envelope?.respCode == "009" &&
            ["api/foody/listActiveOrders", "api/foody/listClosedOrders"].contains(endpoint)
        if error == nil, let httpStatus, (200...299).contains(httpStatus),
           let code = envelope?.respCode, code != "000", !emptyOrderHistory {
            fail(APIError(success: false, message: envelope?.failureMessage ?? AppStrings.original("unknownError"), respCode: code, details: nil))
            return
        }
        handleResponse(data: data, response: response, error: error) { (result: Result<U, Error>) in
            switch result {
            case .success(let value): completion(.success(value))
            case .failure(let failure): fail(failure)
            }
        }
    }

    /// Prints the encoded transfer payload while masking credentials and personal identifiers.
    private func logWalletToAccountRequest(_ data: Data) {
        guard var payload = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
            print("[WalletToAccount] Could not inspect encoded request body (\(data.count) bytes).")
            return
        }

        let maskedFields: Set<String> = ["walletNumber", "phoneNumber", "desAccount", "sponsorWallet", "entityId"]
        for field in maskedFields {
            guard let value = payload[field] as? String else { continue }
            let suffix = String(value.suffix(4))
            payload[field] = value.isEmpty ? "<blank>" : "<masked>…\(suffix)"
        }
        for field in ["pin", "authCode"] {
            guard let value = payload[field] as? String else { continue }
            payload[field] = value.isEmpty ? "<blank>" : "<redacted; length:\(value.count)>"
        }

        guard let safeData = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys]),
              let safeJSON = String(data: safeData, encoding: .utf8) else {
            print("[WalletToAccount] Encoded request body: <unable to render sanitized JSON>; bytes=\(data.count)")
            return
        }
        print("[WalletToAccount] POST api/wallet/transfer-to-account encoded request body (sensitive values masked):\n\(safeJSON)")
    }

    private func redactSensitiveLogValues(_ value: Any) -> Any {
        let sensitiveKeys: Set<String> = [
            "token", "accesstoken", "refreshtoken", "authorization", "pin", "authcode",
            "walletnumber", "phonenumber", "phone", "desaccount", "accountnumber",
            "entityid", "email", "password", "secret", "answer"
        ]
        if let object = value as? [String: Any] {
            return object.reduce(into: [String: Any]()) { result, entry in
                if sensitiveKeys.contains(entry.key.lowercased()) {
                    result[entry.key] = "<redacted>"
                } else {
                    result[entry.key] = redactSensitiveLogValues(entry.value)
                }
            }
        }
        if let array = value as? [Any] {
            return array.map(redactSensitiveLogValues)
        }
        return value
    }


    private func addAuthHeaders(to request: inout URLRequest) {
        // Login initializes this reference, but a restored session can reach
        // authenticated screens before LoginView has run in the current launch.
        let dataManager = userDataManager ?? UserDataManager.shared
        let token = dataManager.getToken()

        if !token.isEmpty {
            // Required headers
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue(token, forHTTPHeaderField: "X-Auth-Token")

            // User/device headers
            if !dataManager.getUserCode().isEmpty {
                request.setValue(dataManager.getUserCode(), forHTTPHeaderField: "X-User-Code")
            }

            var deviceId = dataManager.getDeviceIdentifier()
            if deviceId.isEmpty {
                deviceId = APIClient.getDeviceId()
                UserDefaults.standard.set(deviceId, forKey: "device_identifier")
            }
            request.setValue(deviceId, forHTTPHeaderField: "X-Device-ID")

            if !dataManager.getPhoneNumber().isEmpty {
                request.setValue(dataManager.getPhoneNumber(), forHTTPHeaderField: "X-Phone-Number")
            }

            if !dataManager.getWalletNumber().isEmpty {
                request.setValue(dataManager.getWalletNumber(), forHTTPHeaderField: "X-Wallet-Number")
            }

            if !dataManager.getBankCode().isEmpty {
                request.setValue(dataManager.getBankCode(), forHTTPHeaderField: "X-Bank-Code")
            }

        } else {
            print("NO TOKEN AVAILABLE")
        }
    }


    private func handleResponse<T: Codable>(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            completion(.failure(APIError(success: false, message: AppStrings.original("invalidResponse"), respCode: nil, details: nil)))
            return
        }
        
        
        guard let data = data else {
            completion(.failure(APIError(success: false, message: AppStrings.original("noDataReceived"), respCode: nil, details: nil)))
            return
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            let preview = String(responseString.prefix(500))
        }
//        if let responseString = String(data: data, encoding: .utf8) {
//
//            print("""
//            
//            ==================== 🔥 BACKEND RESPONSE 🔥 ====================
//            HTTP STATUS: \(httpResponse.statusCode)
//            
//            \(responseString)
//            
//            ==================================================================
//            
//            """)
//        }
        
        // Log JSON responses with credentials and personal identifiers redacted.
        if let json = try? JSONSerialization.jsonObject(with: data) {
            let safeJSON = redactSensitiveLogValues(json)
            if let safeData = try? JSONSerialization.data(withJSONObject: safeJSON, options: [.prettyPrinted, .sortedKeys]),
               let safeBody = String(data: safeData, encoding: .utf8) {
                print("""

                ==================== HTTP RESPONSE [\(httpResponse.url?.path ?? "unknown endpoint")] (status \(httpResponse.statusCode)) ====================
                \(safeBody)
                ===========================================================================================

                """)
            } else {
                print("[HTTP] Response from \(httpResponse.url?.path ?? "unknown endpoint"); status=\(httpResponse.statusCode), bytes=\(data.count)")
            }
        } else {
            print("[HTTP] Non-JSON response from \(httpResponse.url?.path ?? "unknown endpoint"); status=\(httpResponse.statusCode), bytes=\(data.count)")
        }
        
        switch httpResponse.statusCode {
            
        case 200...299:
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                completion(.success(result))
            } catch {
                if let errorResponse = try? JSONDecoder().decode(APIError.self, from: data) {
                    completion(.failure(errorResponse))
                } else {
                    completion(.failure(error))
                }
            }
            
        case 401:
            if let authError = try? JSONDecoder().decode(APIError.self, from: data) {
                completion(.failure(authError))
            } else if let authResponse = try? JSONDecoder().decode(AuthResponse.self, from: data) {
                let error = APIError(success: false,
                                     message: authResponse.message ?? "Unauthorized",
                                     respCode: authResponse.respCode,
                                     details: "401 Unauthorized")
                completion(.failure(error))
            } else {
                handleTokenExpiration()
                let error = APIError(success: false, message: AppStrings.original("sessionExpired2"), respCode: "401", details: "Please login again")
                completion(.failure(error))
            }
        case 403:
                // Handle version update requirement
                if let authResponse = try? JSONDecoder().decode(AuthResponse.self, from: data) {
                    let error = APIError(success: false,
                                         message: authResponse.message ?? "Access denied",
                                         respCode: authResponse.respCode,
                                         details: "VERSION_UPDATE_REQUIRED")
                    completion(.failure(error))
                } else {
                    let error = APIError(success: false, message: AppStrings.original("accessDenied"), respCode: "403", details: "VERSION_UPDATE_REQUIRED")
                    completion(.failure(error))
                }
        case 400...499:
            // Client error
            if let wrapper = try? JSONDecoder().decode(ResponseServiceJson.self, from: data) {
                let errorResponse = APIError(
                    success: false,
                    message: wrapper.message ?? "Request failed",
                    respCode: wrapper.respCode ?? "\(httpResponse.statusCode)",
                    details: nil
                )
                completion(.failure(errorResponse))
            } else if let errorResponse = try? JSONDecoder().decode(APIError.self, from: data) {
                completion(.failure(errorResponse))
            } else {
                let genericError = APIError(success: false, message: AppStrings.original("clientError"), respCode: "\(httpResponse.statusCode)", details: nil)
                completion(.failure(genericError))
            }
            
        case 500...599:
            let error = APIError(success: false, message: AppStrings.original("serverError"), respCode: "\(httpResponse.statusCode)", details: nil)
            completion(.failure(error))
            
        default:
            let error = APIError(success: false, message: AppStrings.original("unknownError2"), respCode: "\(httpResponse.statusCode)", details: nil)
            completion(.failure(error))
        }
    }

    
    private func handleTokenExpiration() {
        userDataManager?.clearAllUserData()
        
        // Post notification for token expiration
        NotificationCenter.default.post(name: .tokenExpired, object: nil)
    }
    
    // MARK: - Token Management
    func updateToken(_ newToken: String) {
        userDataManager?.updateToken(newToken)
    }
    
    func hasAuthToken() -> Bool {
        guard let userDataManager = userDataManager else { return false }
        let token = userDataManager.getToken()
        return !token.isEmpty && !userDataManager.isTokenExpired()
    }
    
    func getCurrentToken() -> String {
        return userDataManager?.getToken() ?? ""
    }
    
    func isAuthenticated() -> Bool {
        guard let userDataManager = userDataManager else { return false }
        return userDataManager.isLoggedIn() &&
               !userDataManager.isTokenExpired() &&
               !userDataManager.getToken().isEmpty
    }
    
 
    // Get DSD Pending Payments
    func getDSDPendingPayments(
        phoneNumber: String,
        completion: @escaping (Result<ResponseService, Error>) -> Void
    ) {
        let endpoint = "api/dsd/payments/pending/\(phoneNumber)"
        performRequest(
            endpoint: endpoint,
            method: .GET,
            body: nil as String?,
            requiresAuth: true,
            completion: completion
        )
    }

    // Validate DSD Payment
    func validateDSDPayment(
        operationId: String,
        phoneNumber: String,
        pin: String,
        completion: @escaping (Result<ResponseService, Error>) -> Void
    ) {
        let endpoint = "api/dsd/payments/validate"
        
        performDSDFormRequest(
            endpoint: endpoint,
            formData: [
                "operationId": operationId,
                "phoneNumber": phoneNumber,
                "pin": pin
            ],
            requiresAuth: true,
            completion: completion
        )
    }

    // Reject DSD Payment
    func rejectDSDPayment(
        operationId: String,
        phoneNumber: String,
        completion: @escaping (Result<ResponseService, Error>) -> Void
    ) {
        let endpoint = "api/dsd/payments/reject"
        
        performDSDFormRequest(
            endpoint: endpoint,
            formData: [
                "operationId": operationId,
                "phoneNumber": phoneNumber
            ],
            requiresAuth: true,
            completion: completion
        )
    }

    // Initiate DSD Payment
    func initiateDSDPayment(
        phoneNumber: String,
        chassisNumber: String,
        category: String,
        amount: String,
        completion: @escaping (Result<ResponseService, Error>) -> Void
    ) {
        let endpoint = "api/dsd/payments/initiate"
        
        performDSDFormRequest(
            endpoint: endpoint,
            formData: [
                "phoneNumber": phoneNumber,
                "chassisNumber": chassisNumber,
                "category": category,
                "amount": amount
            ],
            requiresAuth: true,
            completion: completion
        )
    }

    // Query DSD Payment Status
    func queryDSDPaymentStatus(
        operationId: String,
        completion: @escaping (Result<ResponseService, Error>) -> Void
    ) {
        let endpoint = "api/dsd/payments/status/\(operationId)"
        performRequest(
            endpoint: endpoint,
            method: .GET,
            body: nil as String?,
            requiresAuth: true,
            completion: completion
        )
    }

    // MARK: - DSD Helper Method (Form-Encoded Request)

    private func performDSDFormRequest(
        endpoint: String,
        formData: [String: String],
        requiresAuth: Bool,
        completion: @escaping (Result<ResponseService, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(APIError(success: false, message: AppStrings.original("invalidUrl"), respCode: nil, details: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if requiresAuth {
            addAuthHeaders(to: &request)
        }
        
        // Build form-encoded body
        let formString = formData.map { key, value in
            let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
            return "\(encodedKey)=\(encodedValue)"
        }.joined(separator: "&")
        
        request.httpBody = formString.data(using: .utf8)
        
        // Perform the request
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.handleResponse(data: data, response: response, error: error, completion: completion)
            }
        }.resume()
    }
    
    // MARK: - Device Utilities
    static func getDeviceId() -> String {
        if let deviceId = UIDevice.current.identifierForVendor?.uuidString {
            return deviceId
        }

        // Keep a stable fallback identifier if the vendor identifier is unavailable.
        let defaults = UserDefaults.standard
        if let storedDeviceId = defaults.string(forKey: "device_id"), !storedDeviceId.isEmpty {
            return storedDeviceId
        }

        let generatedDeviceId = UUID().uuidString
        defaults.set(generatedDeviceId, forKey: "device_id")
        return generatedDeviceId
    }
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - Notification Names
extension Notification.Name {
    static let tokenExpired = Notification.Name("tokenExpired")
    static let logoutRequired = Notification.Name("logoutRequired")

}
