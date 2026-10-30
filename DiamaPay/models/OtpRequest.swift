import Foundation

struct OtpRequest: Codable {
    let phoneNumber: String
    let authCode: String
    let otp: String
    let entityId: String?
}
