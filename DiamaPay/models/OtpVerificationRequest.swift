import Foundation

struct OtpVerificationRequest: Codable {
    let phoneNumber: String
    let otp: String
    let deviceId: String
}
