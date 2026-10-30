//
//  SecretQuestion.swift
//  DiamaPay
//
//  Created by Bits on 3/10/2025.
//


//
//  SecretQuestion.swift
//  DiamaPay
//
//  Created by Bits on 3/10/2025.
//

import Foundation

struct SecretQuestion: Codable {
    var id: String
    var bankCode: String
    var question: String
    var status: String
    
    init() {
        self.id = ""
        self.bankCode = ""
        self.question = ""
        self.status = ""
    }
    
    init(id: String, question: String) {
        self.id = id
        self.bankCode = "00100"
        self.question = question
        self.status = "ACTIVE"
    }
    
    init(id: String, bankCode: String, question: String, status: String) {
        self.id = id
        self.bankCode = bankCode
        self.question = question
        self.status = status
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case bankCode = "BANK_CODE"
        case question = "QUESTION"
        case status = "STATUS"
    }
    
    // Helper methods
    var isActive: Bool {
        return status == "A" || status == "ACTIVE"
    }
    
    var isInactive: Bool {
        return status == "I" || status == "INACTIVE"
    }
}
