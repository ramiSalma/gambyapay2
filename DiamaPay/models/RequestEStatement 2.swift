//
//  RequestEStatement.swift
//  DiamaPay
//
//  Created by Bits on 27/9/2025.
//

import Foundation

struct RequestEStatement: Codable {
    var walletNumber: String = ""
    var phoneNumber: String = ""
    var source: String = "W"
    var bank: String = ""
    var campaignId: String = ""
    var groupId: String = ""
    var dateFrom: String = ""
    var dateTo: String = ""
    var type: String = "P"
    var pin: String = ""
    var requestId: String = ""
    var requestDate: String = ""
    var entityId: String = ""
}
