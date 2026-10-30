//
//  ValidateJwtRequest.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//


//
//  ValidateJwtRequest.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//

import Foundation

struct ValidateJwtRequest: Codable {
    var jwtToken: String
    
    init(jwtToken: String = "") {
        self.jwtToken = jwtToken
    }
}