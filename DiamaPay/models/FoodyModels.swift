import Foundation

struct FoodyResponse<T: Codable>: Codable {
    let status: String?
    let authCode: String?
    let requestId: String?
    let respCode: String?
    let message: String?
    let result: T?
}

struct FoodyListingRequest: Codable {
    let phoneNumber: String
    let requestId: String
    let requestDate: String
    let entityId: String
}

struct FoodyItemsRequest: Codable {
    let phoneNumber: String
    let restaurantId: String
    let categoryId: String?
    let requestId: String
    let requestDate: String
    let entityId: String
}

struct FoodyRestaurantRequest: Codable {
    let phoneNumber: String
    let restaurantId: String
    let requestId: String
    let requestDate: String
    let entityId: String
}

struct FoodRestaurant: Codable, Identifiable {
    let restaurantId: String
    let name: String?
    let logoUrl: String?
    let status: String?
    let openFlag: String?
    let address1: String?
    let address2: String?
    let city: String?
    let minOrderAmount: String?
    let defaultPrepTimeMin: String?
    let specialClosure: String?
    let specialClosureReason: String?
    let contact: String?
    let latitude: String?
    let longitude: String?
    let postalCode: String?
    let countryCode: String?
    let enrollementDate: String?
    let specialDays: [FoodSpecialDay]?
    let workingHours: [FoodWorkingHours]?
    var id: String { restaurantId }

    var isOpen: Bool {
        specialClosure?.uppercased() != "Y" && status?.uppercased() != "I" &&
        (openFlag?.uppercased() == "Y" || openFlag?.lowercased() == "true")
    }
}

struct FoodItem: Codable, Identifiable {
    let itemId: String
    let categoryId: String?
    let restaurantId: String?
    let name: String?
    let description: String?
    let price: String?
    let imageUrl: String?
    let discountedPrice: String?
    let availableFlag: String?
    let prepTimeMin: String?
    let displayOrder: String?
    var id: String { itemId }

    var amount: Double {
        if let discountedPrice, let discount = Double(discountedPrice), discount.isFinite, discount >= 0 { return discount }
        return Double(price ?? "") ?? 0
    }
    var hasValidPrice: Bool { amount.isFinite && amount >= 0 && Double(price ?? "") != nil }
    var isAvailable: Bool { availableFlag == nil || availableFlag?.lowercased() == "y" || availableFlag?.lowercased() == "true" }
}

struct FoodAddress: Codable, Identifiable {
    let addressId: String
    let addressLine1: String?
    let addressLine2: String?
    let city: String?
    let countryCode: String?
    let defualtFlag: String?
    let defaultFlag: String?
    let label: String?
    let postalCode: String?
    let latitude: String?
    let longitude: String?
    var isDefault: Bool { (defaultFlag ?? defualtFlag)?.uppercased() == "Y" }
    var id: String { addressId }

    var displayName: String { [addressLine1, addressLine2, city].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", ") }
}

struct FoodCategory: Codable, Identifiable {
    let categoryId: String
    let restaurantId: String?
    let name: String?
    let displayOrder: String?
    let items: [FoodItem]?
    var id: String { categoryId }
}

struct FoodOrder: Codable, Identifiable {
    let orderId: String
    let orderRef: String?
    let restaurantId: String?
    let totalAmount: Double?
    let deliveryFee: Double?
    let status: String?
    let paymentStatus: String?
    let createdAt: String?
    let items: [FoodOrderItem]?
    var id: String { orderId }
}

struct FoodOrderActionRequest: Codable {
    let phoneNumber: String
    let orderId: String
    let restaurantId: String
    let requestId: String
    let requestDate: String
    let entityId: String
}

struct FoodComplaintRequest: Codable {
    let phoneNumber: String
    let orderId: String
    let restaurantId: String
    let description: String
    let reason: String
    let complaintType: String
    let productId: String
    let bank: String
    let requestId: String
    let requestDate: String
    let entityId: String
}

struct FoodComplaintDetails: Codable {
    let complaintId: String?
    let orderId: String?
    let restaurantId: String?
    let productId: String?
    let complaintType: String?
    let description: String?
    let status: String?
    let merchantResponse: String?
    let supportResponse: String?
    let createdAt: String?
    let updatedAt: String?
}

struct FoodComplaintRecord: Codable, Identifiable {
    let complaint: FoodComplaintDetails?
    let order: FoodOrder?
    var id: String { complaint?.complaintId ?? complaint?.orderId ?? complaint?.createdAt ?? "food-complaint" }
}

/// addOrder uses string values; order-history responses use numeric qty/lineTotal.
struct FoodOrderLineRequest: Codable {
    let itemId: String
    let quantity: String
    let totalPrice: String

    init(itemId: String, quantity: Int, totalPrice: Decimal) {
        self.itemId = itemId
        self.quantity = String(quantity)
        self.totalPrice = NSDecimalNumber(decimal: totalPrice).stringValue
    }
}

struct FoodOrderRequest: Codable {
    let phoneNumber: String
    let restaurantId: String
    let deliveryAddressId: String
    let itemsList: [FoodOrderLineRequest]
    let bank: String
    let requestId: String
    let requestDate: String
    let entityId: String
}

struct FoodAddAddressRequest: Codable {
    let phoneNumber: String
    let label: String
    let addressLine1: String
    let addressLine2: String
    let city: String
    let countryCode: String
    let postalCode: String
    let latitude: String
    let longitude: String
    let defaultFlag: String
    let requestId: String
    let requestDate: String
    let entityId: String
}


struct FoodWorkingHours: Codable {
    let dayOfWeek: String?
    let isOpen: String?
    let openingTime: String?
    let closingTime: String?
}

struct FoodSpecialDay: Codable {
    let date: String?
    let isOpen: String?
    let openingTime: String?
    let closingTime: String?
    let reason: String?
}

struct FoodRestaurantProfile: Codable {
    let restaurantId: String
    let name: String?
    let logoUrl: String?
    let openCloseFlag: String?
    let address: FoodAddress?
    let contact: String?
    let defaultPreparationTimeMin: String?
    let temporaryClosureReason: String?
    let specialClosure: String?
    let weeklySchedule: [FoodWorkingHours]?
    let minOrderAmount: Double?
    let preparationTime: String?
    let specialDays: [FoodSpecialDay]?

    var isOpen: Bool { openCloseFlag?.uppercased() == "Y" && specialClosure?.uppercased() != "Y" }
}

struct FoodOrderItem: Codable, Identifiable {
    let orderItemId: String
    let orderId: String?
    let itemId: String
    let itemNameSnapshot: String?
    let unitPrice: Double?
    let qty: Int?
    let lineTotal: Double?
    var id: String { orderItemId }
}

struct FoodUpdateAddressRequest: Codable {
    let addressId: String
    let phoneNumber: String
    let entityId: String
    let label: String
    let addressLine1: String
    let addressLine2: String
    let city: String
    let countryCode: String
    let postalCode: String
    let latitude: String
    let longitude: String
    let defaultFlag: String
    let requestId: String
    let requestDate: String
}


/// Error envelopes can have a different result shape from successful responses.
struct FoodyFailureEnvelope: Decodable {
    let respCode: String?
    let message: String?
    let error: String?
    let requestId: String?

    var failureMessage: String? {
        [message, error].compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }.first { !$0.isEmpty }
    }

    func reference(fallback: String?) -> String? {
        [requestId, fallback].compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }.first { !$0.isEmpty }
    }
}
