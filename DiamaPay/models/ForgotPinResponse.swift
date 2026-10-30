//
//  ForgotPinResponse.swift
//  DiamaPay
//
//  Created by Bits on 17/9/2025.
//


struct ForgotPinResponse: Codable {
    var success: Bool?
    var message: String?
    var respCode: String?
    var sessionToken: String?
    var verificationToken: String?
    var resetToken: String?
    var question: SecurityQuestion?
    var remainingAttempts: Int?
    var retryAfter: Int?
    var authCode: String?
    
    var isSuccessful: Bool {
        return success == true || respCode == "000" || respCode == "OTP_SENT_BY_BACKEND"
    }
}


