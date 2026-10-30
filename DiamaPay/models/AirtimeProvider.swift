//
//  AirtimeProvider.swift
//  DiamaPay
//
//  Created by Bits on 17/9/2025.
//


struct AirtimeProvider: Codable {
    let id: String?
    let name: String?
    let code: String?
    let shortCode: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case code
        case shortCode = "short_code"
    }
}