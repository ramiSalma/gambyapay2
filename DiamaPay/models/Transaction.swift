//
//  Transaction.swift
//  DiamaPay
//
//  Created by Bits on 24/9/2025.
//

import Foundation

struct Transaction: Identifiable, Codable {
    let id: String
    let date: String
    let title: String
    let reference: String
    let amount: String
    let balance: String
    let isPositive: Bool
    let transactionReference: String?
    let transactionDate: String?
    let currency: String?
    let sign: String?
    let status: String?
    let details: String?
    let openingBalance: String?
    let closingBalance: String?
    let isDebit: Bool
    
    // Updated to work with [String: Any] from API response
    init(from result: Any) {
        if let dict = result as? [String: Any] {
            let transactionResult = TransactionResult(from: dict)
            self = Transaction(from: transactionResult)
        } else if let transactionResult = result as? TransactionResult {
            self = Transaction(from: transactionResult)
        } else {
            // Fallback with empty values
            self.id = UUID().uuidString
            self.date = "Date unavailable"
            self.title = "Transaction"
            self.reference = "Ref: N/A"
            self.amount = "0 GMD"
            self.balance = "Balance: 0 GMD"
            self.isPositive = false
            self.transactionReference = nil
            self.transactionDate = nil
            self.currency = "GMD"
            self.sign = nil
            self.status = nil
            self.details = nil
            self.openingBalance = nil
            self.closingBalance = nil
            self.isDebit = false
        }
    }
    
    init(from result: TransactionResult) {
        self.id = result.trxRef ?? UUID().uuidString
        self.transactionReference = result.trxRef
        self.transactionDate = result.authDate
        self.currency = result.currency
        self.sign = result.sign
        self.status = result.status
        self.details = result.details
        self.openingBalance = result.openBal
        self.closingBalance = result.closeBal
        
        // Format date
        if let dateStr = result.authDate, !dateStr.isEmpty {
            self.date = Transaction.formatDate(dateStr)
        } else {
            self.date = "Date unavailable"
        }
        
        self.title = Transaction.getDisplayTitle(type: result.type, details: result.details)
        self.reference = "Ref: \(result.trxRef ?? "N/A")"
        
        // Determine if debit or credit based on sign
        let signValue = result.sign ?? ""
        self.isDebit = signValue.uppercased() == "D"
        
        // Format amount safely
        let rawAmount = result.amount?.isEmpty == false ? result.amount! : "0"
        let formattedAmount = Transaction.formatAmount(rawAmount)
        let currencyCode = result.currency ?? "GMD"
        
        if self.isDebit {
            self.amount = "-\(formattedAmount) \(currencyCode)"
            self.isPositive = false
        } else {
            self.amount = "+\(formattedAmount) \(currencyCode)"
            self.isPositive = true
        }
        
        // Format balance
        let balanceValue = result.closeBal?.isEmpty == false ? result.closeBal! : "0"
        self.balance = "Balance: \(Transaction.formatAmount(balanceValue)) \(currencyCode)"
    }
    
    // Resolve presentation copy at render time so loaded history updates with the language.
    var displayDate: String {
        guard let transactionDate, !transactionDate.isEmpty else { return AppStrings.dateUnavailable }
        return Self.formatDate(transactionDate)
    }

    var displayTitle: String { title == "Transaction" ? AppStrings.transactionGeneric : title }
    var displayReference: String { AppStrings.refValue(transactionReference ?? AppStrings.nA) }
    var displayBalance: String {
        AppStrings.balanceValue(Self.formatAmount(closingBalance ?? "0") + " " + (currency ?? "GMD"))
    }

    var fees: String {
        return Transaction.extractFeesFromDetails(details ?? "")
    }

    // MARK: - Helpers
    
    static func formatDate(_ dateString: String) -> String {
        let inputFormats = [
            "dd/MM/yyyy",
            "yyyy-MM-dd",
            "dd-MM-yyyy",
            "yyyy-MM-dd HH:mm:ss",
            "dd/MM/yyyy HH:mm:ss"
        ]
        
        for format in inputFormats {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "dd MMM yyyy"
                outputFormatter.locale = Locale(identifier: AppLanguageStore.shared.language.rawValue)
                return outputFormatter.string(from: date)
            }
        }
        return dateString
    }
    
    private static func extractFeesFromDetails(_ details: String) -> String {
        let loweredDetails = details.lowercased()
        let feesLabel = loweredDetails.range(of: "fees:") ?? loweredDetails.range(of: "frais:")
        if let feesRange = feesLabel {
            let substring = loweredDetails[feesRange.upperBound...]
            let components = substring.components(separatedBy: ",")
            if let feesComponent = components.first {
                let feesValue = feesComponent.trimmingCharacters(in: .whitespaces)
                return "\(feesValue) GMD"
            }
        }
        return "0 GMD"
    }

    private static func getDisplayTitle(type: String?, details: String?) -> String {
        if let type = type, !type.isEmpty {
            return type
        } else if let details = details, !details.isEmpty {
            return details
        }
        return "Transaction"
    }
    
    private static func formatAmount(_ value: String) -> String {
        if let number = Double(value) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = " "
            return formatter.string(from: NSNumber(value: number)) ?? value
        }
        return value
    }
}

