//
//  MarkTokenUsedRequest.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//


//
//  MarkTokenUsedRequest.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//

import Foundation

struct MarkTokenUsedRequest: Codable {
    var customerWallet: String
    var tokenId: String
    var transactionRef: String
    
    init(customerWallet: String = "", tokenId: String = "", transactionRef: String = "") {
        self.customerWallet = customerWallet
        self.tokenId = tokenId
        self.transactionRef = transactionRef
    }
}