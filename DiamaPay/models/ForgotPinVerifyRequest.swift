//
//  ForgotPinVerifyRequest 2.swift
//  DiamaPay
//
//  Created by Bits on 2/10/2025.
//


struct ForgotPinVerifyRequest: Codable {
    var phoneNumber: String
    var otp: String
    var sessionToken: String
}
