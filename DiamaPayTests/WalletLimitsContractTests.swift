import Foundation
import Testing
@testable import DIAMACASH

struct WalletLimitsContractTests {
    @Test func requestUsesOnlyBackendIdentityFields() throws {
        var request = RequestGetWalletLimits()
        request.phoneNumber = "2207001234"
        let data = try JSONEncoder().encode(request)
        let fields = try #require(JSONSerialization.jsonObject(with: data) as? [String: String])
        #expect(fields == ["phoneNumber": "2207001234", "bank": "00100"])
    }

    @Test func responseReadsTopLevelSummaryAndLimits() throws {
        let data = Data(#"{"status":"OK","respCode":"000","message":"Success","summary":{"numeroPortefeuille":"00100600000012","nomComplet":"Awa Jallow","soldeDisponible":1500,"devise":"270","totalConsommeJour":250,"totalTransactionsJour":0},"limits":[{"processingCode":"72","operationName":"Bill Payment","currencyCode":"270","montantMinimum":1,"montantMaximum":1000,"limiteJournaliere":2000,"consommeAujourdhui":250,"restantAujourdhui":1750,"nombreTransactionsJour":0,"pourcentageUtilisationJour":12.5,"limitePeriode":10000,"consommePeriode":3000,"restantPeriode":7000,"typePeriode":"MONTH","debutPeriode":"2026-10-01","finPeriode":"2026-10-31","niveauAlerte":"BANK_ALERT","peutTransacter":"BANK_ELIGIBILITY"},{"processingCode":"41","operationName":"Transfer"}]}"#.utf8)
        let response = try JSONDecoder().decode(ResponseGetWalletLimits.self, from: data)
        #expect(response.isSuccessful)
        #expect(response.summary?.soldeDisponible == 1500)
        #expect(response.summary?.totalTransactionsJour == 0)
        #expect(response.limits?.map(\.processingCode) == ["72", "41"])
        let limit = try #require(response.limits?.first)
        #expect(limit.pourcentageUtilisationJour == 12.5)
        #expect(limit.restantPeriode == 7000)
        #expect(limit.peutTransacter == "BANK_ELIGIBILITY")
        #expect(limit.niveauAlerte == "BANK_ALERT")
    }

    @Test func missingConfigurationResponseHasNoLimitData() throws {
        let data = Data(#"{"status":"NOK","respCode":"404","message":"Limit configuration not found","summary":null,"limits":null}"#.utf8)
        let response = try JSONDecoder().decode(ResponseGetWalletLimits.self, from: data)
        #expect(!response.isSuccessful)
        #expect(response.message == "Limit configuration not found")
        #expect(response.summary == nil)
        #expect(response.limits == nil)
    }

    @Test func missingValuesRemainDistinctFromZeroAndErrorsDecode() throws {
        let data = Data(#"{"respCode":"000","summary":{"totalConsommeJour":0,"soldeDisponible":null},"limits":[{"consommeAujourdhui":null,"restantAujourdhui":0}]}"#.utf8)
        let response = try JSONDecoder().decode(ResponseGetWalletLimits.self, from: data)
        #expect(response.summary?.totalConsommeJour == 0)
        #expect(response.summary?.soldeDisponible == nil)
        #expect(response.limits?.first?.consommeAujourdhui == nil)
        #expect(response.limits?.first?.restantAujourdhui == 0)
        let error = try JSONDecoder().decode(ResponseGetWalletLimits.self, from: Data(#"{"status":"NOK","respCode":"404","message":"No active wallet found for the provided phone number"}"#.utf8))
        #expect(!error.isSuccessful)
        #expect(error.message == "No active wallet found for the provided phone number")
        #expect(error.summary == nil)
        #expect(error.limits == nil)
    }
}
