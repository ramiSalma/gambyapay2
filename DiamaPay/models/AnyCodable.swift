//
//  AnyCodable.swift
//  DiamaPay
//
//  Created by Bits on 18/9/2025.
//

import Foundation;
import SwiftUI;

struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            // Handle arrays
            value = arrayValue.map { $0.value }
        } else if let dictValue = try? container.decode([String: AnyCodable].self) {
            // Handle dictionaries
            value = dictValue.mapValues { $0.value }
        } else if container.decodeNil() {
            value = NSNull()
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported type")
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let arrayValue as [Any]:
            // Handle arrays
            let encodableArray = arrayValue.map { AnyCodable($0) }
            try container.encode(encodableArray)
        case let dictValue as [String: Any]:
            // Handle dictionaries
            let encodableDict = dictValue.mapValues { AnyCodable($0) }
            try container.encode(encodableDict)
        case is NSNull:
            try container.encodeNil()
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
}
