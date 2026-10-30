import Foundation

/// Payload accepted by POST /api/customer/register.
struct CustomerRegistrationRequest: Codable {
    let firstName: String
    let lastName: String
    let phone: String
    let email: String
    let birthDate: String
    let nationality: String
    let documentCode: String
    let documentId: String
    let gender: String
    let currencyCode: String
    let bank: String
    let branchCode: String
    let secretQ: String
    let answer: String
    let address: String
    let type: String
    let productCode: String
    let pin: String
    let nkinName: String
    let nkinPhone: String
    let srcFunds: String?
    let occupation: String?
    let estimatedIncome: String?
    let referralCode: String
    let deviceId: String
    let faceId: String
    let documentImg: String
    let documentImgBack: String

    private enum CodingKeys: String, CodingKey {
        case firstName, lastName, phone, email, birthDate, nationality, documentCode
        case documentId, gender, currencyCode, bank, branchCode, secretQ, answer
        case address, type, productCode, pin, nkinName, nkinPhone, srcFunds
        case occupation, estimatedIncome, referralCode, deviceId, faceId
        case documentImg, documentImgBack
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(phone, forKey: .phone)
        try container.encode(email, forKey: .email)
        try container.encode(birthDate, forKey: .birthDate)
        try container.encode(nationality, forKey: .nationality)
        try container.encode(documentCode, forKey: .documentCode)
        try container.encode(documentId, forKey: .documentId)
        try container.encode(gender, forKey: .gender)
        try container.encode(currencyCode, forKey: .currencyCode)
        try container.encode(bank, forKey: .bank)
        try container.encode(branchCode, forKey: .branchCode)
        try container.encode(secretQ, forKey: .secretQ)
        try container.encode(answer, forKey: .answer)
        try container.encode(address, forKey: .address)
        try container.encode(type, forKey: .type)
        try container.encode(productCode, forKey: .productCode)
        try container.encode(pin, forKey: .pin)
        try container.encode(nkinName, forKey: .nkinName)
        try container.encode(nkinPhone, forKey: .nkinPhone)
        try container.encode(srcFunds, forKey: .srcFunds)
        try container.encode(occupation, forKey: .occupation)
        try container.encode(estimatedIncome, forKey: .estimatedIncome)
        try container.encode(referralCode, forKey: .referralCode)
        try container.encode(deviceId, forKey: .deviceId)
        try container.encode(faceId, forKey: .faceId)
        try container.encode(documentImg, forKey: .documentImg)
        try container.encode(documentImgBack, forKey: .documentImgBack)
    }
}
