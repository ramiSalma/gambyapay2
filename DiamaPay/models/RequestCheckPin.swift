//
//  RequestCheckPin.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//

import Foundation

struct RequestCheckPin: Codable {
    var phoneNumber: String? = nil

    var pin: String = ""
    var walletNumber: String = ""
    var source: String = ""
    var entityId: String = ""
    var requestId: String = ""
    var requestDate: String = ""
    var bank: String = ""
}
