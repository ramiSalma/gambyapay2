//
//  RequestListLinkedAcc.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//


//
//  RequestListLinkedAcc.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//

import Foundation

struct RequestListLinkedAcc: Codable {
    var walletNumber: String?
    var phoneNumber: String?
    var source: String?
    var bank: String?
    var requestId: String?
    var requestDate: String?
    var entityId: String?
}