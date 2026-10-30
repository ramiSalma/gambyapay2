//
//  NotificationItem.swift
//  DiamaPay
//
//  Created by Bits on 17/9/2025.
//


struct NotificationItem: Codable {
    let id: String?
    let title: String?
    let message: String?
    let type: String?
    let timestamp: Double?
    let isRead: Bool?
    let priority: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case message
        case type
        case timestamp
        case isRead = "is_read"
        case priority
    }
}
