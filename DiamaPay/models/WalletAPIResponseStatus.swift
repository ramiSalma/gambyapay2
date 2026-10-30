import Foundation

/// Only the status fields, so error payloads need not match the success result type.
struct WalletAPIResponseStatus: Decodable {
    let respCode: String?
    let message: String?
}
