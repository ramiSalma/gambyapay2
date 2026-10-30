//
//  RequestListSponsoringWallets.swift
//  DiamaPay
//
//  Created by Bits on 27/9/2025.
//


struct RequestListSponsoringWallets: Codable {
    var walletNumber: String = ""
    var phoneNumber: String = ""
    var source: String = "P"
    var bank: String = "00100"
    var pin: String = ""
    var requestId: String = ""
    var requestDate: String = ""
    var entityId: String = UserDataManager.shared.getUserCode()
}
