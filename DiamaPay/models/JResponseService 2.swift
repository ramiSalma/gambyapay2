struct JResponseService: Codable {
    var status: String?
    var authCode: String?
    var respCode: String?
    var message: String?
    var requestId: String?
    var result: [Any]?
    
    var isSuccessful: Bool {
        return respCode == "000"
    }
    
    enum CodingKeys: String, CodingKey {
        case status, authCode, respCode, message, requestId, result
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        authCode = try container.decodeIfPresent(String.self, forKey: .authCode)
        respCode = try container.decodeIfPresent(String.self, forKey: .respCode)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        requestId = try container.decodeIfPresent(String.self, forKey: .requestId)
        
        // Handle result as array of dictionaries
        if let resultArray = try? container.decode([[String: AnyCodable]].self, forKey: .result) {
            result = resultArray.map { dict in
                return dict.mapValues { $0.value }
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(authCode, forKey: .authCode)
        try container.encodeIfPresent(respCode, forKey: .respCode)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(requestId, forKey: .requestId)
        
        if let result = result {
            let codableResult = result.compactMap { item -> [String: AnyCodable]? in
                guard let dict = item as? [String: Any] else { return nil }
                return dict.mapValues { AnyCodable($0) }
            }
            try container.encode(codableResult, forKey: .result)
        }
    }
}
