//
//  RequestWalletToBankAccountNE.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//


//
//  RequestWalletToBankAccountNE.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//

import Foundation

struct RequestWalletToBankAccountNE: Codable {
    var walletNumber: String?
    var phoneNumber: String?
    var source: String?
    var srcBank: String?
    var desAccount: String?
    var desBank: String?
    var requestId: String?
    var requestDate: String?
    var entityId: String?
}