//
//  RequestAccountToWallet.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//


//
//  RequestAccountToWallet.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//

import Foundation

struct RequestAccountToWallet: Codable {
    var walletNumber: String?
    var phoneNumber: String?
    var source: String?
    var desBank: String?
    var srcBank: String?
    var pin: String?
    var srcAccount: String?
    var accountHolder: String?
    var amount: String?
    var currency: String?
    var reason: String?
    var otp: String?
    var requestId: String?
    var requestDate: String?
    var entityId: String?
}