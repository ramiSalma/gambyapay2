import Foundation

struct RequestWalletToMobileMoneyNE: Codable {
    let walletNumber: String
    let phoneNumber: String
    let source: String
    let bank: String
    let provider: String
    let receiverPhone: String
    let requestId: String
    let requestDate: String
    let entityId: String
}
