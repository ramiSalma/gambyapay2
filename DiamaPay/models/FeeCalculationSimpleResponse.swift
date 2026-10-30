//
//  FeeCalculationSimpleResponse.swift
//  DiamaPay
//
//  Created by Bits on 23/10/2025.
//


struct FeeCalculationSimpleResponse: Codable {
    let respCode: String?
    let message: String?
    let feeAmount: Double?
    let ruleIndex: String?
  let requestId: String?
}

