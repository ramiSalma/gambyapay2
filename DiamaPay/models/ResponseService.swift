//
//  ResponseService.swift
//  DiamaPay
//
//  Created by Bits on 27/9/2025.
//
import Foundation
struct ResponseService: Codable {
    let status: String?
    let authCode: String?
    let respCode: String
    let message: String?
    let requestId: String?
    let result: ResultType?
    
    enum ResultType: Codable {
        case string(String)
        case array([String])
        case dictionary([String: AnyCodable])
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            if let stringValue = try? container.decode(String.self) {
                self = .string(stringValue)
            } else if let arrayValue = try? container.decode([String].self) {
                self = .array(arrayValue)
            } else if let dictValue = try? container.decode([String: AnyCodable].self) {
                self = .dictionary(dictValue)
            } else {
                throw DecodingError.typeMismatch(
                    ResultType.self,
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Result type not supported"
                    )
                )
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let value):
                try container.encode(value)
            case .array(let value):
                try container.encode(value)
            case .dictionary(let value):
                try container.encode(value)
            }
        }
        
        var stringValue: String? {
            if case .string(let value) = self {
                return value
            }
            return nil
        }
        
        var arrayValue: [String]? {
            if case .array(let value) = self {
                return value
            }
            return nil
        }
        
        var dictionaryValue: [String: Any]? {
            if case .dictionary(let value) = self {
                return value.mapValues { $0.value }
            }
            return nil
        }
        
        // NEW: Helper to get transaction reference from dictionary
        var transactionReference: String? {
            guard case .dictionary(let dict) = self else { return nil }
            return dict["transactionReference"]?.value as? String ??
                   dict["transactionRef"]?.value as? String ??
                   dict["reference"]?.value as? String
        }
        // NEW: Merchant name
        var merchantName: String? {
            return getString("merchantName")
                ?? getString("merchant")
                ?? getString("merchant_name")
        }

        // NEW: Merchant phone or number
        var merchantPhone: String? {
            return getString("merchantPhone")
                ?? getString("merchantNumber")
                ?? getString("merchant_phone")
        }

        // NEW: Transaction date
        var transactionDate: String? {
            return getString("transactionDate")
                ?? getString("date")
        }

        // NEW: Currency
        var currency: String? {
            return getString("currency")
                ?? getString("currencyCode")
                ?? getString("currency_code")
        }

        // NEW: Helper to get amount from dictionary
        var amount: String? {
            guard case .dictionary(let dict) = self else { return nil }
            if let amountValue = dict["amount"]?.value {
                if let stringAmount = amountValue as? String {
                    return stringAmount
                } else if let doubleAmount = amountValue as? Double {
                    return String(format: "%.2f", doubleAmount)
                } else if let intAmount = amountValue as? Int {
                    return String(intAmount)
                }
            }
            return nil
        }
        
        // NEW: Helper to get any string value from dictionary by key
        func getString(_ key: String) -> String? {
            guard case .dictionary(let dict) = self else { return nil }
            return dict[key]?.value as? String
        }
    }
    
    var isSuccessful: Bool {
        return respCode == "000"
    }
    var transactionReference: String {
        return result?.stringValue ?? result?.transactionReference ?? (result?.getString("authCode") ?? authCode ?? "")
    }

    var transactionAmount: String {
        return result?.amount ?? getSafeAmount()
    }

    var merchantName: String {
        return result?.merchantName ?? ""
    }

    var merchantPhone: String {
        return result?.merchantPhone ?? ""
    }

    var transactionDateFormatted: String {
        return result?.transactionDate ?? currentDate()
    }

    private func getSafeAmount() -> String {
        if let msg = message, let num = Double(msg) {
            return String(format: "%.0f", num)
        }
        return ""
    }

    private func currentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }

}
