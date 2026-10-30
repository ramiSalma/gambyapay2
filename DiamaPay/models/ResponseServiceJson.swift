//
//  ResponseServiceJson.swift
//  DiamaPay
//
//  Created by Bits on 18/9/2025.
//

import Foundation


struct ResponseServiceJson: Codable {
    let status: String?
    let authCode: String?
    let respCode: String?
    let message: String?
    let requestId: String?
    let result: [String: Any]?
    let resultString: String?
    let accountName: String?

    var isSuccessful: Bool {
        return respCode == "000"
    }
    
    // Convenience properties for different result types
    var balanceResult: BalanceResult? {
        guard let result = result else { return nil }
        do {
            let data = try JSONSerialization.data(withJSONObject: result)
            return try JSONDecoder().decode(BalanceResult.self, from: data)
        } catch {
            return nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case status, authCode, respCode, message, requestId, result, accountName, receiverName, name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        authCode = try container.decodeIfPresent(String.self, forKey: .authCode)
        respCode = try container.decodeIfPresent(String.self, forKey: .respCode)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        requestId = try container.decodeIfPresent(String.self, forKey: .requestId)
        accountName = try container.decodeIfPresent(String.self, forKey: .accountName)
            ?? container.decodeIfPresent(String.self, forKey: .receiverName)
            ?? container.decodeIfPresent(String.self, forKey: .name)
        
        resultString = try? container.decode(String.self, forKey: .result)

        // Handle result as flexible dictionary
        if let resultData = try? container.decode([String: AnyCodable].self, forKey: .result) {
            result = resultData.mapValues { $0.value }
        } else {
            result = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(authCode, forKey: .authCode)
        try container.encodeIfPresent(respCode, forKey: .respCode)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(requestId, forKey: .requestId)
        try container.encodeIfPresent(accountName, forKey: .accountName)
        
        if let resultString = resultString {
            try container.encode(resultString, forKey: .result)
        } else if let result = result {
            let encodableResult = result.mapValues { AnyCodable($0) }
            try container.encode(encodableResult, forKey: .result)
        }
    }
}
