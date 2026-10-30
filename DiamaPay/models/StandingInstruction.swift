//
//  StandingInstruction.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//


struct StandingInstruction: Codable, Identifiable {
    var id: String { reference }
    var reference: String
    var destination: String?
    var beneficiary: String?
    var description: String?
    var amount: String?
    var currency: String?
    var destBank: String?
    var trxType: String?
    var destBankCode: String?
    var frequency: String?
    var frequencyNum: String?
    var startDate: String?
    var endDate: String?
    var nextDate: String?
    
    enum CodingKeys: String, CodingKey {
        case reference, destination, beneficiary, description
        case amount, currency, destBank, trxType, destBankCode
        case frequency, frequencyNum, startDate, endDate, nextDate
    }
}
