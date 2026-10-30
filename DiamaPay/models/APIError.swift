//
//  APIError.swift
//  DiamaPay
//
//  Created by Bits on 17/9/2025.
//


import Foundation

struct APIError: Codable, LocalizedError {
    let success: Bool
    let message: String
    let respCode: String?
    let details: String?
    
    var errorDescription: String? { AppStrings.option(message) }

    enum CodingKeys: String, CodingKey {
        case success
        case message
        case respCode = "respCode"
        case details
    }
}
