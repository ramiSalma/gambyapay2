//
//  RequestQrPayment.swift
//  DiamaPay
//
//  Created by Bits on 20/10/2025.
//


struct RequestQrPayment: Codable {
    var source: String?
    var walletNumber: String?
    var phoneNumber: String?
    var bank: String?
    var amount: String?
    var currency: String?
    var qrData: String?           // ← The ORIGINAL EMV QR code goes here
    var reason: String?
    var pin: String?
    var requestId: String?
    var requestDate: String?
    var entityId: String?
    var sponsorWallet: String?
}