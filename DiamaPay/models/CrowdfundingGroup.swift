import Foundation

struct CrowdfundingGroup: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let approvalPolicy: Decimal?
    let memberCount: Int?
}
