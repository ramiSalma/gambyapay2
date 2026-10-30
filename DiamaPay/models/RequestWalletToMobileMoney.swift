import Foundation

struct RequestWalletToMobileMoney: Codable {
    var walletNumber: String
    var phoneNumber: String
    var source: String
    var amount: String
    var currency: String = "270"
    var provider: String
    var reason: String
    var authCode: String? = nil
    var receiverPhone: String
    var pin: String
    var requestId: String
    var requestDate: String
    var entityId: String
    var sponsorWallet: String? = nil
}
