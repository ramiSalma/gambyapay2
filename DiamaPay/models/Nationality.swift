//
//  Nationality 2.swift
//  DiamaPay
//
//  Created by Bits on 3/10/2025.
//


//
//  Nationality.swift
//  DiamaPay
//
//  Created by Bits on 3/10/2025.
//

import Foundation

struct Nationality: Codable {
    var code: String
    var wording: String
    
    init() {
        self.code = ""
        self.wording = ""
    }
    
    init(code: String, wording: String) {
        self.code = code
        self.wording = wording
    }
    
    enum CodingKeys: String, CodingKey {
        case code
        case wording
    }
}
