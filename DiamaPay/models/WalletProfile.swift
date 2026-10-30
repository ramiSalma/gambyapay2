import Foundation

struct WalletProfileRequest: Codable {
    let walletNumber: String?
    let phoneNumber: String?
    let source: String
    let bank: String
    let entityId = "CUSTOMER"
}

struct WalletProfileResponse: Codable {
    let respCode: String?
    let message: String?
    let result: WalletProfile?
}

struct WalletProfile: Codable {
    let walletNumber: String?
    let customerName: String?
    let firstName: String?
    let familyName: String?
    let phoneNumber: String?
    let walletType: String?
    let walletStatus: String?
    let kycLevel: String?
    let registrationDate: String?
    let email: String?
    let address: String?
    let nationalId: String?
    let documentCode: String?
    let nextOfKinName: String?
    let nextOfKinPhone: String?
    let bankCode: String?
    let bankName: String?
    let bankWording: String?
    let hasSecurityQuestion: Bool?
    let securityQuestion: SecurityQuestion?
}
