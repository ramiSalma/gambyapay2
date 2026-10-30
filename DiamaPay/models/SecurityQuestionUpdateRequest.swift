import Foundation

struct SecurityQuestionUpdateRequest: Codable {
    let walletNumber: String
    let phoneNumber: String
    var source = "W"
    let bank: String
    var entityId = "CUSTOMER"
    let secretQ: String
    let answer: String
    let currentAnswer: String?
    let pin: String
}
