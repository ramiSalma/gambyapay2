//
//  LimitModels.swift
//  DiamaPay
//

import Foundation

// MARK: - Request Models
struct RequestGetWalletLimits: Codable {
    var walletNumber: String?
    var phoneNumber: String?
    var bank: String? = "00100"
}

// This endpoint returns summary and limits at the top level, without the standard wrapper.
// MARK: - Response Models
struct ResponseGetWalletLimits: Codable {
    var status: String?
    var respCode: String?
    var message: String?
    var summary: LimitSummary?
    var limits: [LimitDetail]?
    
    var isSuccessful: Bool {
        return respCode == "000"
    }
}

struct LimitSummary: Codable {
    var numeroPortefeuille: String?
    var numeroMobile: String?
    var nomComplet: String?
    var produit: String?
    var typeClient: String?
    var statut: String?
    var niveauKyc: String?
    var profilLimite: String?
    var nomProfil: String?
    var totalConsommeJour: Double?
    var totalTransactionsJour: Int?
    var totalConsommePeriode: Double?
    var typePeriode: String?
    var debutPeriode: String?
    var finPeriode: String?
    var derniereTransaction: String?
    var soldeDisponible: Double?
    var devise: String?
}

struct LimitDetail: Codable {
    var processingCode: String?
    var operationName: String?
    var currencyCode: String?
    var montantMinimum: Double?
    var montantMaximum: Double?
    var limiteJournaliere: Double?
    var consommeAujourdhui: Double?
    var restantAujourdhui: Double?
    var nombreTransactionsJour: Int?
    var pourcentageUtilisationJour: Double?
    var limitePeriode: Double?
    var consommePeriode: Double?
    var restantPeriode: Double?
    var typePeriode: String?
    var debutPeriode: String?
    var finPeriode: String?
    var niveauAlerte: String?
    var peutTransacter: String?
}

//
//  ProcessingCodeMapper.swift
//  DiamaPay
//

import Foundation

class ProcessingCodeMapper {
    
    enum OperationType {
        case debit      // Money going out
        case credit     // Money coming in
        case transfer   // Moving money
        case special    // Sponsored/special transactions
        case other      // Inquiry, etc.
    }
    
    struct OperationInfo {
        let name: String
        let emoji: String
        let type: OperationType
    }
    
    private static let operationMap: [String: OperationInfo] = [
        // EXACTLY matching Android ProcessingCodeMapper.java
        "01": OperationInfo(name: "Retrait d'espèces", emoji: "💵", type: .debit),
        "02": OperationInfo(name: "Dépôt agent", emoji: "🏪", type: .credit),
        "05": OperationInfo(name: "Retrait agence", emoji: "🏪", type: .debit),
        "10": OperationInfo(name: "Transaction sponsorisée", emoji: "🎁", type: .special),
        "11": OperationInfo(name: "Dépôt agence", emoji: "🏪", type: .credit),
        "21": OperationInfo(name: "Dépôt d'espèces", emoji: "💰", type: .credit),
        "22": OperationInfo(name: "Retrait agent", emoji: "🏪", type: .debit),
        "23": OperationInfo(name: "Commission agent", emoji: "💼", type: .credit),
        "26": OperationInfo(name: "Encaissement voucher", emoji: "🎫", type: .credit),
        "30": OperationInfo(name: "Paiement marchand", emoji: "🏪", type: .debit),
        "31": OperationInfo(name: "Consultation solde", emoji: "🔍", type: .other),
        "32": OperationInfo(name: "Consultation wallet", emoji: "🔍", type: .other),
        "33": OperationInfo(name: "Transaction épargne", emoji: "🏦", type: .other),
        "34": OperationInfo(name: "Intérêts épargne", emoji: "📈", type: .credit),
        "35": OperationInfo(name: "Intérêts quotidiens", emoji: "📊", type: .credit),
        "40": OperationInfo(name: "Transfert bancaire", emoji: "🏦", type: .transfer),
        "41": OperationInfo(name: "Transfert d'argent", emoji: "💸", type: .transfer),
        "42": OperationInfo(name: "Vers ma banque", emoji: "🏦", type: .transfer),
        "43": OperationInfo(name: "Mise à disposition", emoji: "🎫", type: .debit),
        "44": OperationInfo(name: "Paiement QR", emoji: "📱", type: .debit),
        "45": OperationInfo(name: "Recharge wallet", emoji: "🔄", type: .credit),
        "46": OperationInfo(name: "Crédit GIP", emoji: "💳", type: .credit),
        "47": OperationInfo(name: "Débit GIP", emoji: "💳", type: .debit),
        "48": OperationInfo(name: "Crédit QR GIP", emoji: "📱", type: .credit),
        "49": OperationInfo(name: "Transfert QR", emoji: "📱", type: .debit),
        "50": OperationInfo(name: "Achat de crédit", emoji: "📲", type: .debit),
        "51": OperationInfo(name: "Achat de crédit", emoji: "📲", type: .debit),
        "60": OperationInfo(name: "Retrait ATM", emoji: "🏧", type: .debit),
        "70": OperationInfo(name: "Mobile Money", emoji: "📱", type: .transfer),
        "71": OperationInfo(name: "Demande de paiement", emoji: "💰", type: .other),
        "72": OperationInfo(name: "Paiement de facture", emoji: "🧾", type: .debit),
        "73": OperationInfo(name: "Facture depuis compte", emoji: "🧾", type: .debit),
        "74": OperationInfo(name: "Facture depuis wallet", emoji: "🧾", type: .debit),
        "91": OperationInfo(name: "Crédit d'intérêts", emoji: "💹", type: .credit),
        "92": OperationInfo(name: "Transaction d'intérêts", emoji: "💹", type: .other),
        "98": OperationInfo(name: "Portage agence", emoji: "🔄", type: .other),
        "99": OperationInfo(name: "Portage wallet", emoji: "🔄", type: .other)
    ]
    
    static func getOperationInfo(_ processingCode: String) -> OperationInfo {
        if let info = operationMap[processingCode] {
            return info
        }
        // Default for unknown codes
        return OperationInfo(name: "Opération \(processingCode)", emoji: "📋", type: .other)
    }
    
    static func getOperationName(_ processingCode: String) -> String {
        return getOperationInfo(processingCode).name
    }
    
    static func getOperationEmoji(_ processingCode: String) -> String {
        return getOperationInfo(processingCode).emoji
    }
    
    static func getOperationType(_ processingCode: String) -> OperationType {
        return getOperationInfo(processingCode).type
    }
}
