//
//  RequestLast5Transactions.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//


//
//  RequestLast5Transactions.swift
//  DiamaPay
//
//  Created by Bits on [Date]
//

import Foundation

struct RequestLast5Transactions: Codable {
    var walletNumber: String = ""
    var phoneNumber: String = ""
    var source: String = "W" // "P" for phone, "W" for wallet
    var dateFrom: String = ""
    var dateTo: String = ""
    var pin: String = ""
    var bank: String = ""
    var requestId: String = ""
    var requestDate: String = ""
    var entityId: String = ""
    var type: String = "P" // Always "P" for mini-statement
}