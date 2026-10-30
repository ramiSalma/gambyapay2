// MARK: - Change PIN Request
struct RequestChangePin: Codable {
    var walletNumber: String = ""
    var phoneNumber: String? = nil
    var source: String? = nil
    var bank: String = ""
    var oldPinCode: String = ""
    var newPinCode: String = ""
    var confPinCode: String = ""
    var requestId: String = ""
    var requestDate: String = ""
    var entityId: String? = nil
    
    // Custom encoding to skip nil/empty optional fields
    enum CodingKeys: String, CodingKey {
        case walletNumber, phoneNumber, source, bank, oldPinCode, newPinCode, confPinCode, requestId, requestDate, entityId
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(walletNumber, forKey: .walletNumber)
        try container.encode(bank, forKey: .bank)
        try container.encode(oldPinCode, forKey: .oldPinCode)
        try container.encode(newPinCode, forKey: .newPinCode)
        try container.encode(confPinCode, forKey: .confPinCode)
        try container.encode(requestId, forKey: .requestId)
        try container.encode(requestDate, forKey: .requestDate)
        
        // Only encode optional fields if they have values
        if let phoneNumber = phoneNumber, !phoneNumber.isEmpty {
            try container.encode(phoneNumber, forKey: .phoneNumber)
        }
        if let source = source, !source.isEmpty {
            try container.encode(source, forKey: .source)
        }
        if let entityId = entityId, !entityId.isEmpty {
            try container.encode(entityId, forKey: .entityId)
        }
    }
}
