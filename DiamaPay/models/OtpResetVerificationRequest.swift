//
//  OtpResetVerificationRequest.swift
//  DiamaPay
//
//  Created by Bits on 2/10/2025.
//


struct OtpResetVerificationRequest: Codable {
    var phoneNumber: String
    var otp: String
    var authCode: String
    
    enum CodingKeys: String, CodingKey {
        case phoneNumber
        case otp
        case authCode
    }
}
