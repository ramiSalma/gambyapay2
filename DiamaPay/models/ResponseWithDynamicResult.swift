//
//  ResponseWithDynamicResult.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//


struct ResponseWithDynamicResult: Codable {
    let status: String?
    let authCode: String?
    let respCode: String?
    let message: String?
    let requestId: String?
    let result: [String: AnyCodable]?
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["status"] = status
        dict["authCode"] = authCode
        dict["respCode"] = respCode
        dict["message"] = message
        dict["requestId"] = requestId
        if let result = result {
            dict["result"] = result.mapValues { $0.value }
        }
        return dict
    }
}
