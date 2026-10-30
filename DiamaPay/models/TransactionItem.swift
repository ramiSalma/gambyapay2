//
//  TransactionItem.swift
//  DiamaPay
//
//  Created by Bits on 1/10/2025.
//


//
//  TransactionItem.swift
//  DiamaPay
//
//  Created by Bits on [Date]
//

import Foundation

struct TransactionItem: Identifiable, Codable {
    var id: String = UUID().uuidString
    
    var transactionReference: String?
    var transactionDate: String?
    var amount: String?
    var status: String?
    var currency: String?
    var sign: String? // "D" for debit, "C" for credit
    var type: String?
    var details: String?
    var openingBalance: String?
    var closingBalance: String?
    
    enum CodingKeys: String, CodingKey {
        case transactionReference = "trxRef"
        case transactionDate = "authDate"
        case amount
        case status
        case currency
        case sign
        case type
        case details = "trxDetails"
        case openingBalance = "openBalance"
        case closingBalance = "closeBalance"
    }
    
    // Computed properties
    var isDebit: Bool {
        return sign == "D"
    }
    
    var isCredit: Bool {
        return sign == "C"
    }
    
    var formattedAmount: String {
        guard let amount = amount, let currency = currency else {
            return "0.00"
        }
        
        let prefix = isDebit ? "-" : (isCredit ? "+" : "")
        return "\(prefix)\(amount) \(currency)"
    }
    
    var cleanDescription: String {
        if let details = details, !details.trimmingCharacters(in: .whitespaces).isEmpty {
            // For received transfers
            if details.contains("Received transfer from:") {
                if let phoneNumber = extractPhoneNumber(from: details, pattern: "Received transfer from:\\s*(\\d+)") {
                    return AppStrings.transfertRecuDeValue(String(describing: maskPhoneNumber(phoneNumber)))
                }
            }
            
            // For sent transfers
            if details.contains("Transfer to:") {
                if let phoneNumber = extractPhoneNumber(from: details, pattern: "Transfer to:\\s*(\\d+)") {
                    return "\(frenchTransactionType) \(maskPhoneNumber(phoneNumber))"
                }
            }
            
            // For acquiring entity
            if details.contains("Acquiring entity :") {
                if let entityId = extractPhoneNumber(from: details, pattern: "Acquiring entity :\\s*(\\d+)") {
                    return AppStrings.valueViaValue(String(describing: frenchTransactionType), String(describing: maskEntityId(entityId)))
                }
            }
            
            // For institution transfers
            if details.contains("institution:") {
                if let institution = extractPhoneNumber(from: details, pattern: "institution:\\s*([^,]+)") {
                    return AppStrings.valueViaValue(String(describing: frenchTransactionType), String(describing: institution.trimmingCharacters(in: .whitespaces)))
                }
            }
            
            // Extract reason
            if details.contains("reason :") {
                let parts = details.components(separatedBy: "reason :")
                if parts.count > 1 {
                    let reason = parts[1].components(separatedBy: ",")[0].trimmingCharacters(in: .whitespaces)
                    if !reason.isEmpty && reason != "edd" && reason != "reff" {
                        return "\(frenchTransactionType) - \(reason)"
                    }
                }
            }
        }
        
        return frenchTransactionType
    }
    
    var frenchTransactionType: String {
        guard let type = type else { return AppStrings.transactionGeneric }
        
        switch type.uppercased() {
        case "CASH OUT": return AppStrings.retraitDEspeces
        case "CASH IN": return AppStrings.depotDEspeces
        case "ACCOUNT TO WALLET": return AppStrings.accountToWallet
        case "TOPUP PURCHASE": return AppStrings.achatDeCredit
        case "EVALUE CREDIT": return AppStrings.creditEvalue
        case "EVALUE DEBIT": return AppStrings.debitEvalue
        case "EVALUE_TRANSFER": return AppStrings.transfertEvalue
        case "TELLER CASH OUT": return AppStrings.retraitGuichet
        case "TELLER CASH IN": return AppStrings.depotGuichet
        case "GIP QR CREDIT": return AppStrings.creditQrGip
        case "GIP QR DEBIT": return AppStrings.debitQrGip
        case "WALLET TO WALLET": return AppStrings.transfertEntrePortefeuilles
        case "MONEY VOUCHER": return "Bon d'argent"
        case "MONEY VOUCHER TRANSFER": return AppStrings.transfertBonDArgent
        case "QR TRANSFER": return AppStrings.qrTransfer
        case "WALLET TO ACCOUNT": return AppStrings.walletToAccount
        case "AGENT CASH IN": return AppStrings.depotAgent
        case "AGENT CASH OUT": return AppStrings.retraitAgent
        case "AGENT MONEY VOUCHER CASH": return AppStrings.especesBonAgent
        case "GIP CREDIT": return AppStrings.creditGip
        case "GIP DEBIT": return AppStrings.debitGip
        case "MOBILE MONEY": return "Argent mobile"
        case "REQUEST TO PAY": return AppStrings.demandeDePaiement
        case "BILLER PAYMENT ACCOUNT": return AppStrings.paiementFactureCompte
        case "BILLER PAYMENT WALLET": return AppStrings.paiementFacturePortefeuille
        case "BILL PAYMENT": return AppStrings.paiementDeFacture
        case "WALLET ENQUIRY": return AppStrings.consultationPortefeuille
        case "SAVING TRANSACTION": return AppStrings.transactionEpargne
        case "SAVING DAILY INTERESTS": return AppStrings.interetsQuotidiensEpargne
        case "SAVING DAILY INTERESTS REV": return AppStrings.annulationInteretsEpargne
        case "SAVING INTERESTS": return AppStrings.interetsEpargne
        case "INTEREST CREDIT": return AppStrings.creditDInterets
        case "INTEREST TRANSACTION": return AppStrings.transactionDInterets
        case "SPONSORED TRANSACTION": return AppStrings.transactionSponsorisee
        case "CREDIT AGENT COMISSION": return AppStrings.commissionAgent
        case "DORMANT WALLET TO UNCLAIMED": return AppStrings.portefeuilleDormant
        case "DORMANT SAVINGS TO UNCLAIMED": return AppStrings.epargneDormante
        case "BRANCH PORTING": return "Portage agence"
        case "WALLET PORTING": return "Portage portefeuille"
        case "TRANSFER TO WALLET": return AppStrings.transfertVersPortefeuille
        case "TRANSFER FROM WALLET": return AppStrings.transfertDepuisPortefeuille
        default: return type
        }
    }
    
    // Helper methods
    private func extractPhoneNumber(from text: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }
        
        let range = NSRange(text.startIndex..., in: text)
        if let match = regex.firstMatch(in: text, options: [], range: range),
           match.numberOfRanges > 1 {
            let matchRange = match.range(at: 1)
            if let swiftRange = Range(matchRange, in: text) {
                return String(text[swiftRange])
            }
        }
        
        return nil
    }
    
    private func maskPhoneNumber(_ phoneNumber: String) -> String {
        guard phoneNumber.count >= 7 else { return phoneNumber }
        let start = phoneNumber.prefix(4)
        let end = phoneNumber.suffix(3)
        return "\(start)****\(end)"
    }
    
    private func maskEntityId(_ entityId: String) -> String {
        guard entityId.count >= 6 else { return AppStrings.agent }
        let end = entityId.suffix(3)
        return "***\(end)"
    }
}