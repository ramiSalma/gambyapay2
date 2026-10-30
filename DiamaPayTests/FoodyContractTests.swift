import Foundation
import Testing
@testable import DIAMACASH

struct FoodyContractTests {
    @Test func restaurantListReadsAvailabilityAndSchedules() throws {
        let json = #"{"status":"OK","authCode":"token","respCode":"000","message":"Success","requestId":"261029482913","result":[{"restaurantId":"R1","name":"Chicken Palace","status":"A","openFlag":"Y","minOrderAmount":"100","specialClosure":"N","defaultPrepTimeMin":"20","workingHours":[{"dayOfWeek":"MON","isOpen":"Y","openingTime":"08:00","closingTime":"22:00"}],"specialDays":[{"date":"2026-12-25","isOpen":"N","reason":"Christmas"}]}]}"#
        let response = try JSONDecoder().decode(FoodyResponse<[FoodRestaurant]>.self, from: Data(json.utf8))
        let restaurant = try #require(response.result?.first)
        #expect(response.respCode == "000")
        #expect(response.requestId == "261029482913")
        #expect(restaurant.isOpen)
        #expect(restaurant.workingHours?.first?.openingTime == "08:00")
        #expect(restaurant.specialDays?.first?.reason == "Christmas")
        let closed = try JSONDecoder().decode(FoodRestaurant.self, from: Data(#"{"restaurantId":"R1","openFlag":"Y","specialClosure":"Y"}"#.utf8))
        #expect(!closed.isOpen)
    }

    @Test func fullMenuPreservesEveryCategoryAndUsesBasePriceForEmptyDiscount() throws {
        let json = #"{"respCode":"000","result":[{"categoryId":"C1","restaurantId":"R1","name":"Burgers","displayOrder":"1","items":[{"itemId":"I1","categoryId":"C1","price":"150","discountedPrice":"","availableFlag":"Y"}]},{"categoryId":"C2","items":[{"itemId":"I4","categoryId":"C2","price":"100","discountedPrice":"80","availableFlag":"N"}]}]}"#
        let response = try JSONDecoder().decode(FoodyResponse<[FoodCategory]>.self, from: Data(json.utf8))
        let items = try #require(response.result).flatMap { $0.items ?? [] }
        #expect(items.count == 2)
        #expect(items[0].amount == 150)
        #expect(items[0].hasValidPrice)
        #expect(items[1].amount == 80)
        #expect(!items[1].isAvailable)
        #expect(items[0].amount * 2 + items[1].amount == 380)
    }

    @Test func profileAndAddressesDecodeDocumentedFieldTypes() throws {
        let json = #"{"restaurantId":"R1","name":"Chicken Palace","openCloseFlag":"Y","specialClosure":"N","minOrderAmount":100,"preparationTime":"20","address":{"addressId":"A1","addressLine1":"12 Kairaba Ave","city":"Serrekunda","defualtFlag":"Y","latitude":"13.45","longitude":"-16.68"},"weeklySchedule":[{"dayOfWeek":"MON","isOpen":"Y"}]}"#
        let profile = try JSONDecoder().decode(FoodRestaurantProfile.self, from: Data(json.utf8))
        #expect(profile.minOrderAmount == 100)
        #expect(profile.isOpen)
        #expect(profile.address?.isDefault == true)
        #expect(profile.address?.displayName == "12 Kairaba Ave, Serrekunda")
        #expect(profile.address?.latitude == "13.45")
        let correctedSpelling = try JSONDecoder().decode(FoodAddress.self, from: Data(#"{"addressId":"A2","defaultFlag":"Y"}"#.utf8))
        #expect(correctedSpelling.isDefault)
    }

    @Test func orderHistoryAndComplaintReadNestedOrderItems() throws {
        let json = #"{"respCode":"000","result":[{"complaint":{"complaintId":"CP1","orderId":"O1","restaurantId":"R1","productId":"I1","description":"Burger was cold","merchantResponse":"We will help","supportResponse":""},"order":{"orderId":"O1","orderRef":"FD261029001","restaurantId":"R1","totalAmount":380,"deliveryFee":50,"status":"DELIVERED","items":[{"orderItemId":"OI1","orderId":"O1","itemId":"I1","itemNameSnapshot":"Cheese burger","unitPrice":150,"qty":2,"lineTotal":300}]}}]}"#
        let response = try JSONDecoder().decode(FoodyResponse<[FoodComplaintRecord]>.self, from: Data(json.utf8))
        let record = try #require(response.result?.first)
        #expect(record.complaint?.productId == "I1")
        #expect(record.order?.deliveryFee == 50)
        #expect(record.order?.items?.first?.qty == 2)
        #expect(record.order?.items?.first?.lineTotal == 300)
        #expect(record.order?.items?.first?.itemNameSnapshot == "Cheese burger")
    }

    @Test func writeRequestsUseCallerIdentityAndDocumentedFields() throws {
        let request = FoodOrderRequest(phoneNumber: "2207001234", restaurantId: "R1", deliveryAddressId: "A1", itemsList: [FoodOrderLineRequest(itemId: "I1", quantity: 2, totalPrice: 300)], bank: "00100", requestId: "261029482913", requestDate: "2026-10-29 12:00:00", entityId: "2207001234")
        let data = try JSONEncoder().encode(request)
        let fields = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(fields["entityId"] as? String == "2207001234")
        #expect(fields["deliveryAddressId"] as? String == "A1")
        let lines = try #require(fields["itemsList"] as? [[String: Any]])
        let line = try #require(lines.first)
        #expect(line["itemId"] as? String == "I1")
        #expect(line["quantity"] as? String == "2")
        #expect(line["totalPrice"] as? String == "300")
        let cancel = FoodOrderActionRequest(phoneNumber: "2207001234", orderId: "O1", restaurantId: "R1", requestId: "261029482913", requestDate: "2026-10-29 12:00:00", entityId: "2207001234")
        let cancelFields = try #require(JSONSerialization.jsonObject(with: JSONEncoder().encode(cancel)) as? [String: String])
        #expect(cancelFields["status"] == nil)
        #expect(cancelFields["orderId"] == "O1")
        let update = FoodUpdateAddressRequest(addressId: "A1", phoneNumber: "2207001234", entityId: "2207001234", label: "Office", addressLine1: "12 Kairaba Ave", addressLine2: "", city: "Serrekunda", countryCode: "GM", postalCode: "", latitude: "13.45", longitude: "-16.68", defaultFlag: "N", requestId: "261029482913", requestDate: "2026-10-29 12:00:00")
        let updateFields = try #require(JSONSerialization.jsonObject(with: JSONEncoder().encode(update)) as? [String: String])
        #expect(updateFields["addressId"] == "A1")
        #expect(updateFields["defaultFlag"] == "N")
        #expect(updateFields["defualtFlag"] == nil)
        #expect(updateFields["latitude"] == "13.45")
    }

    @Test func errorEnvelopeAndStringMutationResultsDecode() throws {
        let error = try JSONDecoder().decode(FoodyResponse<[FoodItem]>.self, from: Data(#"{"status":"NOK","respCode":"404","message":"Restaurant not found","result":null}"#.utf8))
        #expect(error.respCode != "000")
        #expect(error.message == "Restaurant not found")
        let success = try JSONDecoder().decode(FoodyResponse<String>.self, from: Data(#"{"respCode":"000","result":"Order created"}"#.utf8))
        #expect(success.result == "Order created")
    }

    @Test func serverFailurePreservesMessageAndReferenceWithoutDecodingResult() throws {
        let json = #"{"respCode":"500","message":"Unable to create food order","requestId":"261029482913","result":{"details":"server-only result"}}"#
        let failure = try JSONDecoder().decode(FoodyFailureEnvelope.self, from: Data(json.utf8))
        #expect(failure.failureMessage == "Unable to create food order")
        #expect(failure.requestId == "261029482913")
        #expect(failure.respCode == "500")
    }

    @Test func serverFailureReadsErrorFieldWhenMessageIsMissingOrBlank() throws {
        let json = #"{"message":"  ","error":"Internal Server Error"}"#
        let failure = try JSONDecoder().decode(FoodyFailureEnvelope.self, from: Data(json.utf8))
        #expect(failure.failureMessage == "Internal Server Error")
        let empty = try JSONDecoder().decode(FoodyFailureEnvelope.self, from: Data(#"{"error":""}"#.utf8))
        #expect(empty.failureMessage == nil)
    }


    @Test func blankServerReferenceFallsBackToSubmittedRequest() throws {
        let failure = try JSONDecoder().decode(FoodyFailureEnvelope.self, from: Data(#"{"respCode":"400","message":"Internal server error","requestId":" "}"#.utf8))
        #expect(failure.reference(fallback: "261029533850") == "261029533850")
        #expect(failure.reference(fallback: "") == nil)
        let withReference = try JSONDecoder().decode(FoodyFailureEnvelope.self, from: Data(#"{"requestId":"server-reference"}"#.utf8))
        #expect(withReference.reference(fallback: "261029533850") == "server-reference")
    }


    @Test func orderLineEncodesDocumentedStringsWithExactDecimalTotals() throws {
        let price = try #require(Decimal(string: "22.15"))
        let line = FoodOrderLineRequest(itemId: "I1", quantity: 3, totalPrice: price * 3)
        let data = try JSONEncoder().encode(line)
        let fields = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(fields["quantity"] as? String == "3")
        #expect(fields["totalPrice"] as? String == "66.45")
        let decoded = try JSONDecoder().decode(FoodOrderLineRequest.self, from: data)
        #expect(decoded.totalPrice == "66.45")
    }

}
