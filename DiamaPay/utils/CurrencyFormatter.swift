//
//  CurrencyFormatter.swift
//  DiamaPay
//
//  Created by Bits on 3/10/2025.
//



import Contacts
import ContactsUI
import SwiftUI

// MARK: - Number Formatter Helper
class CurrencyFormatter {
    static let shared = CurrencyFormatter()
    
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    /// Format a string with thousand separators for display
    func format(_ input: String) -> String {
        let clean = input.replacingOccurrences(of: " ", with: "")
        guard let number = Double(clean) else { return input }
        return formatter.string(from: NSNumber(value: number)) ?? input
    }
    
    /// Remove thousand separators to get clean value for API
    func cleanValue(_ input: String) -> String {
        return input.replacingOccurrences(of: " ", with: "")
    }
}

// MARK: - Custom TextField with Formatting
struct FormattedTextField: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    let placeholder: String
    @Binding var text: String
    var maxLength: Int = 15
    var walletTransferStyle = false
    var sponsorFormStyle = false
    
    @State private var displayText: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextField(placeholder, text: $displayText)
            .keyboardType(.decimalPad)
            .font(.system(size: walletTransferStyle || sponsorFormStyle ? 14 : 12, weight: .medium))
            .padding(.horizontal, 12)
            .frame(height: sponsorFormStyle ? 44 : (walletTransferStyle ? 42 : 48))
            .background(walletTransferStyle || sponsorFormStyle ? Color.white : Color(red: 0.96, green: 0.96, blue: 0.96))
            .overlay {
                if walletTransferStyle {
                    RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "505A69"), lineWidth: 1.5)
                } else if sponsorFormStyle {
                    RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "4B5563"), lineWidth: 1.5)
                }
            }
            .cornerRadius(walletTransferStyle ? 14 : (sponsorFormStyle ? 12 : 8))
            .focused($isFocused)
            .onChange(of: displayText) {
                handleTextChange(displayText)
            }
            .onChange(of: isFocused) {
                if !isFocused {
                    // Format when losing focus
                    displayText = CurrencyFormatter.shared.format(text)
                }
            }
            .onAppear {
                displayText = text.isEmpty ? "" : CurrencyFormatter.shared.format(text)
            }
    }
    
    private func handleTextChange(_ newValue: String) {
        // Remove all non-numeric characters except decimal point
        let filtered = newValue.filter { $0.isNumber || $0 == "." || $0 == "," }
        let clean = filtered.replacingOccurrences(of: " ", with: "")
        
        // Limit length
        let limited = String(clean.prefix(maxLength))
        
        // Update the actual value (without formatting)
        text = limited
        
        // Apply formatting for display
        if isFocused {
            // While typing, show formatted version
            displayText = CurrencyFormatter.shared.format(limited)
        }
    }
}

// MARK: - Extension for easy amount formatting
extension String {
    func formatAsCurrency() -> String {
        return CurrencyFormatter.shared.format(self)
    }
    
  
}

extension Double {
    func formatAsCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
