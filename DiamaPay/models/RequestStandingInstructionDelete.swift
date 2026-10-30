//
//  RequestStandingInstructionDelete.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//


struct RequestStandingInstructionDelete: Codable {
    var bank: String
    var destBank: String
    var entityId: String
    var id: String
    var phoneNumber: String
    var pin: String
    var requestDate: String
    var requestId: String
}