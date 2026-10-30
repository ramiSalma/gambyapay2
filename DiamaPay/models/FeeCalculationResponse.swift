//
//  FeeCalculationResponse.swift
//  DiamaPay
//
//  Created by Bits on 28/9/2025.
//

import Foundation

struct FeeCalculationResponse: Codable {
    var respCode: String?
    var message: String?
    var feeAmount: Double?
    var ruleIndex: String?
    var result: FeeResult?
}

struct FeeResult: Codable {
    var totalFees: Double { (feeAmount ?? 0) + (taxAmount ?? 0) }
    var taxAmount: Double?
    var feeAmount: Double?
    var totalAmount: Double?
    var ruleIndex: String?
    var processingCode: String?
    var requestId: String?
    var transactionAmount: Double?
    var actionCode: String?
    var currency: String?
}
