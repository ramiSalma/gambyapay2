struct SecurityQuestionItem: Codable, Identifiable {
    var id: String
    var question: String
    var questionCode: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "questionId"  // Map "questionId" from JSON to "id" property
        case question
        case questionCode
    }
}
