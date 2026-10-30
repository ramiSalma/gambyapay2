import Foundation
import Testing
@testable import DIAMACASH

struct WalletAPIContractTests {
    @Test func feeQuoteUsesCustomerAPIFields() throws {
        let quote = WalletFeeQuoteRequest(walletNumber: "00100600000012", phoneNumber: "2207001234",
                                          source: "W", bank: "00100", amount: "500",
                                          destination: "2207005678", transactionType: "41",
                                          destinationBank: "00100")
        let object = try #require(JSONSerialization.jsonObject(with: JSONEncoder().encode(quote)) as? [String: String])
        #expect(object["amount"] == "500")
        #expect(object["transactionType"] == "41")
        #expect(object["destination"] == "2207005678")
        #expect(object["bank"] == "00100")
        #expect(object["processingCode"] == nil)
        #expect(object["transactionAmount"] == nil)
    }

    @Test func feeResponseReadsNestedAmountsAndTax() throws {
        let data = Data(#"{"respCode":"000","message":"Success","result":{"feeAmount":5,"taxAmount":2,"transactionAmount":500,"totalAmount":507,"processingCode":"41"}}"#.utf8)
        let response = try JSONDecoder().decode(FeeCalculationResponse.self, from: data)
        #expect(response.result?.totalFees == 7)
        #expect(response.result?.totalAmount == 507)
    }

    @Test func statementUsesDocumentedDetailAndBalanceFields() throws {
        let data = Data(#"{"trxRef":"TX1","authDate":"2026-10-15 14:02:11","amount":"250.00","currency":"270","sign":"D","trxDetails":"Rent","openBalance":"1500","closeBalance":"1250"}"#.utf8)
        let item = try JSONDecoder().decode(TransactionItem.self, from: data)
        #expect(item.details == "Rent")
        #expect(item.openingBalance == "1500")
        #expect(item.closingBalance == "1250")
        let dictionary = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let history = TransactionResult(from: dictionary)
        #expect(history.details == "Rent")
        #expect(history.closeBal == "1250")
    }

    @Test func pendingTransactionUsesTrxDetails() throws {
        let data = Data(#"{"trxRef":"TX2","trxDetails":"Cash withdrawal","pCode":"01"}"#.utf8)
        let item = try JSONDecoder().decode(PendingTransaction.self, from: data)
        #expect(item.details == "Cash withdrawal")
        #expect(item.pCode == "01")
    }

    @Test func stringResultPreservesTransactionReference() throws {
        let data = Data(#"{"status":"OK","respCode":"000","result":"TX123"}"#.utf8)
        let response = try JSONDecoder().decode(ResponseService.self, from: data)
        #expect(response.isSuccessful)
        #expect(response.transactionReference == "TX123")
    }

    @Test func statusOKDoesNotOverrideFailureCode() throws {
        let data = Data(#"{"status":"OK","respCode":"001","message":"Rejected","result":null}"#.utf8)
        let response = try JSONDecoder().decode(ResponseService.self, from: data)
        #expect(!response.isSuccessful)
        let status = try JSONDecoder().decode(WalletAPIResponseStatus.self, from: data)
        #expect(status.respCode == "001")
        #expect(status.message == "Rejected")
    }
}
