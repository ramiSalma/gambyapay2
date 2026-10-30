//
//  StandingInstructionUpdateRequest.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//


struct StandingInstructionUpdateRequest: Codable {
    var phoneNumber: String
    var id: String
    var destination: String
    var amount: String
    var currency: String
    var details: String
    var pin: String
    var frequency: String
    var startDate: String
    var endDate: String
    var requestId: String
    var requestDate: String
    var entityId: String
}