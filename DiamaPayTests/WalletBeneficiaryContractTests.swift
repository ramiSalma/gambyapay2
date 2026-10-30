import Foundation
import Testing
@testable import DIAMACASH

struct WalletBeneficiaryContractTests {
    @Test func identifiersArePreservedWithoutCountryRestrictions() {
        #expect(WalletTransferRecipient.normalize("7001234") == "7001234")
        #expect(WalletTransferRecipient.normalize("+212612345678") == "+212612345678")
        #expect(WalletTransferRecipient.normalize("002207001234") == "002207001234")
        #expect(WalletTransferRecipient.normalize(" C000123 ") == "C000123")
        #expect(WalletTransferRecipient.isValid("221771234567"))
        #expect(WalletTransferRecipient.isValid("220700123"))
        #expect(WalletTransferRecipient.isValid("C000123"))
        #expect(!WalletTransferRecipient.isValid("  "))
    }

    @Test func walletIdentifiersHaveNoFourteenDigitRestriction() {
        #expect(WalletTransferRecipient.normalize("00100600000012") == "00100600000012")
        #expect(WalletTransferRecipient.isValid("0010060000001234567890"))
        #expect(WalletTransferRecipientKind.wallet.source == "W")
        #expect(WalletTransferRecipientKind.phoneOrCustomerID.source == "P")
    }

    @Test func beneficiaryDestinationIsDistinctFromOwnersPhoneNumber() throws {
        let data = Data(#"{"respCode":"000","result":[{"beneficiaryId":"B1","name":"Awa","transactionType":"41","phoneNumber":"2207001234","destination":"2207005678","destBankCode":"00100","status":"A"}]}"#.utf8)
        let response = try JSONDecoder().decode(WalletBeneficiaryListResponse.self, from: data)
        let saved = try #require(response.result?.first)
        #expect(saved.destination == "2207005678")
        #expect(saved.phoneNumber == "2207001234")
        #expect(saved.destBankCode == "00100")
        #expect(saved.isWalletRecipient)
    }

    @Test func bankAccountBeneficiariesAreExcludedFromWalletPicker() throws {
        let data = Data(#"{"transactionType":"42","destination":"0012345678"}"#.utf8)
        let saved = try JSONDecoder().decode(WalletBeneficiary.self, from: data)
        #expect(!saved.isWalletRecipient)
    }

    @Test func beneficiaryRequestMatchesBackendDTO() throws {
        let request = WalletBeneficiaryListRequest(phoneNumber: "2207001234", requestId: "261019123456", requestDate: "2026-10-19 17:00:00", entityId: "C1")
        let object = try #require(JSONSerialization.jsonObject(with: JSONEncoder().encode(request)) as? [String: String])
        #expect(Set(object.keys) == Set(["phoneNumber", "requestId", "requestDate", "entityId"]))
        #expect(object["phoneNumber"] == "2207001234")
    }

    @Test func emptyAndErrorResponsesDecode() throws {
        let empty = try JSONDecoder().decode(WalletBeneficiaryListResponse.self, from: Data(#"{"respCode":"000","result":[]}"#.utf8))
        #expect(empty.result?.isEmpty == true)
        let error = try JSONDecoder().decode(WalletBeneficiaryListResponse.self, from: Data(#"{"respCode":"999","message":"Unavailable","result":null}"#.utf8))
        #expect(error.result == nil)
        #expect(error.message == "Unavailable")
    }
}
