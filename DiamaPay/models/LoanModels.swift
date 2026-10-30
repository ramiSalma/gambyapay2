import Foundation

struct LoanOption: Codable, Identifiable, Hashable {
    let id: Int64
    let code: String?
    let name: String
}

struct LoanRequestPayload: Codable {
    let phoneNumber: String
    let entityId: String
    let providerId: Int64
    let purposeId: Int64
    let amount: Double
    let duration: Int
    let remarks: String
}

struct LoanRecord: Codable, Identifiable, Hashable {
    let id: Int64
    let phoneNumber: String?
    let provider: LoanOption?
    let purpose: LoanOption?
    let amount: Double?
    let duration: Int?
    let status: String?
    let requestDate: String?
    let approvedDate: String?
    let entityId: String?
    let remarks: String?
}

struct LoanEnvelope<Value: Codable>: Codable {
    let respCode: String?
    let message: String?
    let result: Value?
}
