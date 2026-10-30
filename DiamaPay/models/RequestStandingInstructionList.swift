//
//  RequestStandingInstructionList.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//


struct RequestStandingInstructionList: Codable {
    var phoneNumber: String
    var requestId: String
    var requestDate: String
    var entityId: String
    var bank: String?
}
