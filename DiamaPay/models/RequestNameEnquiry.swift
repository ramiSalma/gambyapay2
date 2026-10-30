//
//  RequestNameEnquiry.swift
//  DiamaPay
//
//  Created by Bits on 28/9/2025.
//


struct RequestNameEnquiry: Codable {
    var requestId: String = ""
    var requestDate: String = ""
    var source: String = ""
    var walletNumber: String = ""
    var phoneNumber: String = ""
    var bank: String = ""
    var entityId: String = ""
    var pin: String = ""
}