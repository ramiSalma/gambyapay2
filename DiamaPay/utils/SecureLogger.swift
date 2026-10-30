//
//  for.swift
//  DiamaPay
//
//  Created by bits dev team on 12/12/2025.
//


import Foundation

/// Helper class for secure logging that sanitizes sensitive data
class SecureLogger {
    
    // Sensitive field names to redact
    private static let sensitiveFields = [
        "pin", "password", "otp", "token", "jwt", "secret",
        "oldPin", "newPin", "confirmPin", "currentPin",
        "secretAnswer", "authorization", "apiKey", "api_key"
    ]
    
    /// Sanitize JSON string by replacing sensitive field values with ****
    static func sanitize(_ jsonString: String) -> String {
        var sanitized = jsonString
        
        for field in sensitiveFields {
            // Pattern: "field": "value" or "field":"value"
            let patterns = [
                "\"\(field)\"\\s*:\\s*\"([^\"]+)\"",  // "field": "value"
                "\"\(field)\"\\s*:\\s*([0-9]+)",      // "field": 12345
            ]
            
            for pattern in patterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                    sanitized = regex.stringByReplacingMatches(
                        in: sanitized,
                        options: [],
                        range: NSRange(sanitized.startIndex..., in: sanitized),
                        withTemplate: "\"\(field)\": \"****\""
                    )
                }
            }
        }
        
        return sanitized
    }
    
    /// Log request safely - only in DEBUG mode, with sanitization
    static func logRequest(endpoint: String, method: String, body: String?) {
        #if DEBUG
        //print("📤 API Request: \(method) \(endpoint)")
        if let body = body {
            let sanitized = sanitize(body)
            let preview = String(sanitized.prefix(300))
            //print("📦 Body: \(preview)\(sanitized.count > 300 ? "..." : "")")
        } else {
            //print("📦 Body: (empty)")
        }
        #endif
    }
    
    /// Log response safely - only in DEBUG mode, with sanitization
    static func logResponse(statusCode: Int, data: Data?) {
        #if DEBUG
        //print("📥 API Response: Status \(statusCode)")
        
        if let data = data, let responseString = String(data: data, encoding: .utf8) {
            let sanitized = sanitize(responseString)
            let preview = String(sanitized.prefix(300))
            //print("📦 Data: \(preview)\(sanitized.count > 300 ? "..." : "")")
        } else {
            //print("📦 Data: (empty)")
        }
        #endif
    }
    
    /// Log error safely
    static func logError(_ message: String, error: Error? = nil) {
        #if DEBUG
        //print("❌ Error: \(message)")
        if let error = error {
            //print("   Details: \(error.localizedDescription)")
        }
        #endif
    }
    
    /// Log token (safely - only first/last 4 chars)
    static func logToken(_ token: String) {
        #if DEBUG
        if token.isEmpty {
            //print("🔑 Token: (empty)")
        } else if token.count > 8 {
            let start = String(token.prefix(4))
            let end = String(token.suffix(4))
            //print("🔑 Token: \(start)...\(end) (length: \(token.count))")
        } else {
            //print("🔑 Token: ****")
        }
        #endif
    }
}
