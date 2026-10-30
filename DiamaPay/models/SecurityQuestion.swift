// MARK: - Security Question (from backend response)
struct SecurityQuestion: Codable {
    var question: String?
    var questionId: String?
    var id: String? // Some backends use 'id' instead of 'questionId'
    
    enum CodingKeys: String, CodingKey {
        case question, questionId, id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        question = try container.decodeIfPresent(String.self, forKey: .question)
        questionId = try container.decodeIfPresent(String.self, forKey: .questionId)
        id = try container.decodeIfPresent(String.self, forKey: .id)
    }
    
    // Helper to get the actual ID regardless of which field is used
    var actualId: String? {
        return questionId ?? id
    }
}
