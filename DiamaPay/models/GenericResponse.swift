//
//  GenericResponse.swift
//  DiamaPay
//
//  Created by Bits on 17/9/2025.
//


// MARK: - Generic API Response
struct GenericResponse<T: Codable>: Codable {
    let success: Bool
    let message: String?
    let data: T?
    let respCode: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case data
        case respCode = "resp_code"
    }
    }
