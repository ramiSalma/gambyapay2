//
//  CommentRequest.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//


//
//  CommentRequest.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//

import Foundation

struct CommentRequest: Codable {
    var userName: String
    var userPhone: String
    var category: String
    var subject: String
    var comment: String
    var email: String?
    
    enum CodingKeys: String, CodingKey {
        case userName, userPhone, category, subject, comment, email
    }
}