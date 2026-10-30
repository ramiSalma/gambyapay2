import Foundation

struct WalletBeneficiaryListRequest: Codable {
    let phoneNumber: String
    let requestId: String
    let requestDate: String
    let entityId: String
}

struct WalletBeneficiaryAddRequest: Codable {
    let phoneNumber: String
    let destination: String
    let institutionCode: String
    let transactionType: String
    let name: String
    let requestId: String
    let requestDate: String
    let entityId: String
}

struct WalletBeneficiaryDeleteRequest: Codable {
    let phoneNumber: String
    let beneficiaryId: String
    let requestId: String
    let requestDate: String
    let entityId: String
}

struct WalletBeneficiaryListResponse: Codable {
    let respCode: String?
    let message: String?
    let result: [WalletBeneficiary]?
}

struct WalletBeneficiary: Codable {
    let beneficiaryId: String?
    let bankCode: String?
    let name: String?
    let transactionType: String?
    let status: String?
    let phoneNumber: String?
    let destination: String?
    let destBankCode: String?
    let actionDate: String?

    var isWalletRecipient: Bool {
        let type = transactionType?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return (type.isEmpty || type == "41" || type == "10") && !(destination ?? "").isEmpty
    }

    var isMobileMoneyRecipient: Bool {
        transactionType?.trimmingCharacters(in: .whitespacesAndNewlines) == "70"
            && !(destination ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isMoneyVoucherRecipient: Bool {
        transactionType?.trimmingCharacters(in: .whitespacesAndNewlines) == "43"
            && !(destination ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isBankAccountRecipient: Bool {
        let type = transactionType?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let bankCode = destBankCode ?? self.bankCode ?? ""
        return !["41", "10", "43", "44", "45", "70"].contains(type)
            && !(destination ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !bankCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var transactionTypeTitle: String {
        switch transactionType?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" {
        case "41": return AppStrings.walletTransfer
        case "10": return AppStrings.sponsoredWallet2
        case "42": return AppStrings.bankTransfer
        case "43": return AppStrings.moneyVoucher
        case "44": return AppStrings.qrTransfer
        case "45": return AppStrings.accountToWallet
        case "": return isBankAccountRecipient ? AppStrings.bankTransfer : AppStrings.walletTransfer
        case let type: return AppStrings.otherTypeValue(String(describing: type))
        }
    }

    var transactionTypeSortOrder: Int {
        switch transactionType?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" {
        case "41": return 0
        case "10": return 1
        case "42": return 2
        case "43": return 3
        case "44": return 4
        case "45": return 5
        default: return 6
        }
    }
}

enum WalletTransferRecipientKind: String, CaseIterable {
    case phoneOrCustomerID
    case wallet

    var title: String {
        switch self {
        case .phoneOrCustomerID: return AppStrings.phoneOrCustomerId
        case .wallet: return AppStrings.walletNumber
        }
    }

    var source: String { self == .wallet ? "W" : "P" }
}

enum WalletTransferRecipient {
    // Identifiers are matched by the backend. Do not add a country code,
    // strip letters from customer IDs, or truncate wallet/phone numbers.
    static func normalize(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func isValid(_ value: String) -> Bool {
        !normalize(value).isEmpty
    }
}
