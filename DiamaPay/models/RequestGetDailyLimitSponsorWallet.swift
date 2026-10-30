//
//  RequestGetDailyLimitSponsorWallet.swift
//  DiamaPay
//
//  Created by Bits on 27/9/2025.
//




struct RequestGetDailyLimitSponsorWallet: Codable {
    var walletNumber: String = ""
    var walletNumberSponsor: String = ""
    var phoneNumber: String = ""
    var source: String = "P"
    var bank: String = "00100"
    var requestId: String = ""
    var requestDate: String = ""
    var entityId: String = UserDataManager.shared.getUserCode()
}
