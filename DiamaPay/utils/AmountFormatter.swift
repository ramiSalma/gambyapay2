//
//  AmountFormatter.swift
//  DiamaPay
//
//  Created by Bits on 3/10/2025.
//


//
//  AmountFormatter.swift
//  DiamaPay
//
//  Utility for formatting currency amounts with thousand separators
//

import Foundation

struct AmountFormatter {
    
    /// Formats a string amount with thousand separators (space-separated)
    /// - Parameter value: The input amount string (may contain spaces or commas)
    /// - Returns: Formatted string with spaces as thousand separators
    static func formatWithThousandSeparator(_ value: String) -> String {
        let cleanValue = value.replacingOccurrences(of: " ", with: "")
        
        guard let number = Double(cleanValue) else { return value }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: number)) ?? value
    }
    
    /// Removes formatting from an amount string (removes spaces and replaces commas with dots)
    /// - Parameter value: The formatted amount string
    /// - Returns: Clean numeric string
    static func cleanAmount(_ value: String) -> String {
        return value.replacingOccurrences(of: " ", with: "")
                   .replacingOccurrences(of: ",", with: ".")
    }
    
    /// Formats an amount for display with currency
    /// - Parameters:
    ///   - amount: The numeric amount
    ///   - currency: The currency code (default: "GNF")
    /// - Returns: Formatted string with currency (e.g., "1 000 000 GNF")
    static func formatWithCurrency(_ amount: Double, currency: String = "GNF") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = 2
        
        let formattedAmount = formatter.string(from: NSNumber(value: amount)) ?? "0"
        return "\(formattedAmount) \(currency)"
    }
    
    /// Validates if a string represents a valid numeric amount
    /// - Parameter value: The input string
    /// - Returns: True if valid numeric format
    static func isValidAmount(_ value: String) -> Bool {
        let cleanValue = cleanAmount(value)
        return Double(cleanValue) != nil
    }
    
    /// Converts a formatted string to Double
    /// - Parameter value: The formatted amount string
    /// - Returns: Double value or nil if invalid
    static func toDouble(_ value: String) -> Double? {
        let cleanValue = cleanAmount(value)
        return Double(cleanValue)
    }
}

// MARK: - SwiftUI TextField Extension for Amount Formatting
import SwiftUI

extension Binding where Value == String {
    /// Creates a binding that automatically formats amounts with thousand separators
    func formattedAmount() -> Binding<String> {
        Binding<String>(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = AmountFormatter.formatWithThousandSeparator(newValue)
            }
        )
    }
}