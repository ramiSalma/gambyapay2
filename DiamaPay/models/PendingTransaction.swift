//
//  PendingTransaction.swift
//  DiamaPay
//
//  Created by Assistant on 1/12/2025.
//

import Foundation

struct PendingTransaction: Identifiable, Codable {
    var id = UUID()
    var trxRef: String?
    var authDate: String?
    var amount: String?
    var agent: String?
    var currency: String?
    var tax: String?
    var fees: String?
    var type: String?
    var pCode: String?
    var details: String?
    
    enum CodingKeys: String, CodingKey {
        case trxRef, authDate, amount, agent, currency, tax, fees, type, pCode
        case details = "trxDetails"
    }
    
    var formattedAmount: String {
        guard let amountStr = amount,
              let amountValue = Double(amountStr) else {
            return "0 GMD"
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        let formattedNumber = formatter.string(from: NSNumber(value: amountValue)) ?? "0"
        return "\(formattedNumber) \(currency ?? "GMD")"
    }
    
    var transactionTypeDescription: String {
        guard let code = pCode else { return AppStrings.transactionGeneric }
        
        switch code {
        case "41":
            return AppStrings.transfertDArgent
        case "42":
            return AppStrings.retraitBancaire
        case "43":
            return AppStrings.moneyVoucher
        case "44":
            return AppStrings.qrPayment
        case "51":
            return AppStrings.rechargeTelephonique
        case "70":
            return AppStrings.paiementMarchand
        case "01":
            return AppStrings.retraitDEspeces
        case "71":
            return AppStrings.paiementDeFacture
        default:
            return type ?? AppStrings.transactionGeneric
        }
    }
    
    var transactionIcon: String {
        guard let code = pCode else { return "arrow.left.arrow.right" }
        
        switch code {
        case "41": return "arrow.left.arrow.right"
        case "42": return "building.columns"
        case "43": return "gift"
        case "44": return "qrcode"
        case "51": return "phone.fill"
        case "70": return "dollarsign.circle"
        case "01": return "banknote"
        case "71": return "doc.text"
        default: return "arrow.left.arrow.right"
        }
    }
    
    var formattedDate: String {
        guard let dateStr = authDate else { return "" }
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM, yyyy HH:mm"
        outputFormatter.locale = Locale(identifier: "fr_FR")
        
        if let date = inputFormatter.date(from: dateStr) {
            return outputFormatter.string(from: date)
        }
        return dateStr
    }
    
    var shouldShowBeneficiary: Bool {
        return pCode == "43" || pCode == "01" // Money Voucher or Cash-out
    }
    
    var beneficiaryLabel: String {
        guard let code = pCode else { return AppStrings.beneficiary }
        
        switch code {
        case "43": return AppStrings.beneficiary
        case "01": return AppStrings.agent
        default: return AppStrings.beneficiary
        }
    }
    
    var beneficiaryValue: String {
        // For Money Voucher (pCode 43), extract from details
        if pCode == "43", let detailsStr = details {
            let lowercased = detailsStr.lowercased()
            if let range = lowercased.range(of: "receiver:") {
                let afterReceiver = detailsStr[range.upperBound...].trimmingCharacters(in: .whitespaces)
                // Get up to next comma or end of string
                if let commaRange = afterReceiver.range(of: ",") {
                    return String(afterReceiver[..<commaRange.lowerBound]).trimmingCharacters(in: .whitespaces)
                }
                return afterReceiver
            }
        }
        
        // For Cash-out (pCode 01), extract only name from agent
        guard let agentStr = agent else { return AppStrings.nA }
        let components = agentStr.components(separatedBy: CharacterSet.decimalDigits)
        let nameOnly = components[0].trimmingCharacters(in: .whitespaces)
        return nameOnly.isEmpty ? agentStr : nameOnly
    }
}
