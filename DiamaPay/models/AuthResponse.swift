struct AuthResponse: Codable {
    let success: Bool?
    let token: String?
    let message: String?
    let respCode: String?
    let userCode: String?
    let phoneNumber: String?
    let name: String?
    let email: String?
    let type: String?
    let userType: String?
    let walletnumber: String?
    let bankCode: String?
    let bankWording: String?
    let branchCode: String?
    let tokenTimeout: Int?
    let deviceIdentifier: String?
    
    // Lists
    let notificationList: [AnyCodable]?
    let questionsList: [AnyCodable]?
    let nationalitiesList: [AnyCodable]?
    let providerList: [AnyCodable]?
    let airtimeProviderList: [AnyCodable]?
    let reasonList: [AnyCodable]?
    let branchList: [AnyCodable]?
    let processingCodes: [AnyCodable]?

    // ✅ Ads
    let ads: [Advertisement]?
    let adsDelay: Int?
    let requiresPinChange: Bool?
}
