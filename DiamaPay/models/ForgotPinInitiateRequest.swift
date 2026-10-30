//
//  ForgotPinInitiateRequest 2.swift
//  DiamaPay
//
//  Created by Bits on 2/10/2025.
//

// MARK: - Forgot Pin Initiate Request
struct ForgotPinInitiateRequest: Codable {
    var phoneNumber: String
    var deviceId: String
}
