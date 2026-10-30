struct PinResetRequest: Codable {
    var phoneNumber: String
    var newPin: String
    var confirmPin: String
    var resetToken: String
}
