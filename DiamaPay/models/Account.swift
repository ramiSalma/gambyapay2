//
//  Account.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//


//
//  Account.swift
//  DiamaPay
//
//  Created by Bits on 30/9/2025.
//

import Foundation

struct Account: Codable, Identifiable {
    var id = UUID()
    var accountNumber: String = ""
    var accountName: String = ""
    var bankCode: String = ""
    var bankName: String = ""
    var accountType: String = ""
    var currency: String = ""
    var balance: String = ""
    var accountHolder: String = ""
    
    enum CodingKeys: String, CodingKey {
        case accountNumber
        case accountName
        case bankCode
        case bankName
        case accountType
        case currency
        case balance
        case accountHolder
    }
    
    var displayName: String {
        return "\(accountNumber) - \(accountHolder.isEmpty ? accountName : accountHolder)"
    }
}
 
