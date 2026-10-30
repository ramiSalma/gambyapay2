struct SecurityQuestionRequest: Codable {
    var phoneNumber: String
    var sessionToken: String
    var answer: String
    
    enum CodingKeys: String, CodingKey {
        case phoneNumber  // Keep camelCase for JSON encoding
        case sessionToken
        case answer
    }
}
