import Foundation

struct AuthRequest: Codable {
    let phoneNumber: String   
    let pin: String
    let deviceId: String
}
