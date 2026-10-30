//
//  RequestMoneyVoucher.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//


//
//  RequestMoneyVoucher.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//

import Foundation

struct RequestMoneyVoucher: Codable {
    var walletNumber: String = ""
    var phoneNumber: String = ""
    var source: String = ""
    var bank: String = ""
    var currency: String = ""
    var amount: String = ""
    var receiverPhone: String = ""
    var reason: String = ""
    var pin: String = ""
    var requestId: String = ""
    var requestDate: String = ""
    var entityId: String = ""
    var sponsorWallet: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case walletNumber, phoneNumber, source, bank, currency
        case amount, receiverPhone, reason, pin, requestId
        case requestDate, entityId, sponsorWallet
    }
}